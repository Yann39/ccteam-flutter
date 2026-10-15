/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of CCTeam application.
 *
 * CCTeam is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * CCTeam is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with CCTeam. If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:typed_data';

import 'package:ccteam/models/bike.dart';
import 'package:ccteam/models/bike_maintenance.dart';
import 'package:ccteam/models/member.dart';
import 'package:ccteam/utils/maintenance_utils.dart';
import 'package:ccteam/utils/pdf_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds the maintenance logbook of a bike as a PDF document: bike details, maintenance plan, then every
/// maintenance in chronological order with its operations, the time and distance elapsed since the previous one,
/// and its comment. Prices are deliberately left out, the document is meant to be handed to a buyer or a garage.
///
/// Every text goes through [PdfUtils.text], the document only uses the PDF standard fonts.
class MaintenancePdf {
  MaintenancePdf._();

  static final PdfColor _accent = PdfColor.fromInt(0xFF00796B); // teal 700, the maintenance pages accent
  static final PdfColor _headerFill = PdfColor.fromInt(0xFFE0F2F1);

  /// File name of the document, e.g. "carnet-entretien-yamaha-r6.pdf".
  static String fileName(Bike bike) => PdfUtils.fileName('carnet-entretien', bike);

  /// Build the logbook of [bike], owned by [owner], from its [maintenance] data.
  static Future<Uint8List> build({required Bike bike, required Member? owner, required BikeMaintenance maintenance}) {
    final DateTime now = DateTime.now();
    final String bikeLabel = PdfUtils.bikeLabel(bike);
    // oldest first, the way a logbook reads
    final List<Maintenance> maintenances = maintenance.maintenances.reversed.toList();

    final pw.Document document = pw.Document(title: PdfUtils.text("${AppString.maintenancePdfTitle} $bikeLabel"));
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 30),
        footer: (pw.Context context) =>
            PdfUtils.footer(context, AppString.format(AppString.maintenancePdfFooter, [bikeLabel, PdfUtils.date(now)])),
        build: (pw.Context context) => <pw.Widget>[
          PdfUtils.title(AppString.maintenancePdfTitle, bikeLabel, _accent),
          pw.SizedBox(height: 14),
          _details(bike, owner, maintenance),
          pw.SizedBox(height: 18),
          _summary(maintenances),
          pw.SizedBox(height: 8),
          if (maintenances.isEmpty)
            pw.Text(PdfUtils.text(AppString.maintenanceNone), style: pw.TextStyle(color: PdfUtils.muted))
          else
            _table(maintenances),
        ],
      ),
    );
    return document.save();
  }

  /// Key / value block: owner, engine size, year, odometer, maintenance plan.
  static pw.Widget _details(Bike bike, Member? owner, BikeMaintenance maintenance) {
    final String ownerName = "${owner?.firstName ?? ''} ${owner?.lastName ?? ''}".trim();
    return PdfUtils.details(<List<String>>[
      if (ownerName.isNotEmpty) [AppString.maintenancePdfOwner, ownerName],
      if (bike.engineSize != null) [AppString.bikeEngineSize, "${bike.engineSize} cc"],
      if (bike.year != null) [AppString.bikeYear, bike.year.toString()],
      if (maintenance.odometerKm != null)
        [
          AppString.maintenancePdfOdometer,
          maintenance.odometerUpdatedOn != null
              ? AppString.format(AppString.odometerReadOn, [
                  MaintenanceUtils.formatKm(maintenance.odometerKm!),
                  PdfUtils.date(maintenance.odometerUpdatedOn!),
                ])
              : MaintenanceUtils.formatKm(maintenance.odometerKm!),
        ],
      [
        AppString.maintenancePlan,
        maintenance.plan != null ? MaintenanceUtils.formatPlan(maintenance.plan!) : AppString.maintenancePlanNone,
      ],
    ]);
  }

  /// "5 entretiens dont 3 révisions, du 02/06/2022 au 12/09/2026".
  static pw.Widget _summary(List<Maintenance> maintenances) {
    final List<pw.Widget> children = <pw.Widget>[
      pw.Text(
        PdfUtils.text(AppString.maintenanceHistoryTitle),
        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _accent),
      ),
    ];
    if (maintenances.isNotEmpty) {
      final int services = maintenances.where((m) => m.resetsPlan).length;
      final String count = maintenances.length == 1
          ? AppString.maintenancePdfCountOne
          : AppString.format(AppString.maintenancePdfCountMany, [maintenances.length]);
      final String serviceCount = services == 0
          ? AppString.maintenancePdfServicesNone
          : services == 1
          ? AppString.maintenancePdfServicesOne
          : AppString.format(AppString.maintenancePdfServicesMany, [services]);
      final String period = maintenances.length == 1
          ? AppString.format(AppString.maintenancePdfOn, [PdfUtils.date(maintenances.first.maintenanceDate!)])
          : AppString.format(AppString.maintenancePdfPeriod, [
              PdfUtils.date(maintenances.first.maintenanceDate!),
              PdfUtils.date(maintenances.last.maintenanceDate!),
            ]);
      children.add(pw.SizedBox(height: 2));
      children.add(
        pw.Text(
          PdfUtils.text("$count $serviceCount, $period"),
          style: pw.TextStyle(color: PdfUtils.muted, fontSize: 10),
        ),
      );
    }
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: children);
  }

  static pw.Widget _cell(pw.Widget child) =>
      pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5), child: child);

  static pw.Widget _headerCell(String label) => _cell(
    pw.Text(
      PdfUtils.text(label),
      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _accent),
    ),
  );

  /// One row per maintenance: date (with the time elapsed since the previous one), odometer (with the distance
  /// since the previous one), service or not, operations with their precision and the comment.
  static pw.Widget _table(List<Maintenance> maintenances) {
    final List<pw.TableRow> rows = <pw.TableRow>[
      pw.TableRow(
        decoration: pw.BoxDecoration(color: _headerFill),
        repeat: true,
        children: <pw.Widget>[
          _headerCell(AppString.maintenancePdfColumnDate),
          _headerCell(AppString.maintenancePdfColumnKm),
          _headerCell(AppString.maintenancePdfColumnType),
          _headerCell(AppString.maintenanceOperations),
        ],
      ),
    ];

    for (int i = 0; i < maintenances.length; i++) {
      final Maintenance m = maintenances[i];
      final Maintenance? previous = i > 0 ? maintenances[i - 1] : null;
      final pw.TextStyle small = pw.TextStyle(fontSize: 8, color: PdfUtils.muted);

      rows.add(
        pw.TableRow(
          verticalAlignment: pw.TableCellVerticalAlignment.top,
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfUtils.rule, width: 0.5)),
          ),
          children: <pw.Widget>[
            _cell(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(
                    PdfUtils.date(m.maintenanceDate!),
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  if (previous != null)
                    pw.Text(
                      PdfUtils.text(
                        "+${MaintenanceUtils.formatElapsed(previous.maintenanceDate!, m.maintenanceDate!)}",
                      ),
                      style: small,
                    ),
                ],
              ),
            ),
            _cell(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(
                    m.odometerKm != null ? PdfUtils.text(MaintenanceUtils.formatKm(m.odometerKm!)) : '-',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  if (previous?.odometerKm != null && m.odometerKm != null)
                    pw.Text(
                      PdfUtils.text("+${MaintenanceUtils.formatKm(m.odometerKm! - previous!.odometerKm!)}"),
                      style: small,
                    ),
                ],
              ),
            ),
            _cell(
              pw.Text(
                PdfUtils.text(m.resetsPlan ? AppString.maintenanceServiceBadge : AppString.maintenancePdfOther),
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: m.resetsPlan ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: m.resetsPlan ? _accent : PdfUtils.muted,
                ),
              ),
            ),
            _cell(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  for (final MaintenanceOperation operation in m.operations) ...[
                    pw.Text(PdfUtils.text("- ${operation.title}"), style: const pw.TextStyle(fontSize: 10)),
                    if (operation.details != null)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 8, bottom: 1),
                        child: pw.Text(PdfUtils.text(operation.details!), style: small),
                      ),
                  ],
                  if (m.comment != null)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 3),
                      child: pw.Text(
                        PdfUtils.text(m.comment!),
                        style: pw.TextStyle(fontSize: 9, color: PdfUtils.muted, fontStyle: pw.FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return pw.Table(
      columnWidths: const <int, pw.TableColumnWidth>{
        0: pw.FixedColumnWidth(78),
        1: pw.FixedColumnWidth(72),
        2: pw.FixedColumnWidth(62),
        3: pw.FlexColumnWidth(),
      },
      children: rows,
    );
  }
}
