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
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/maintenance_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds the maintenance logbook of a bike as a PDF document: bike details, maintenance plan, then every
/// maintenance in chronological order with its operations, the time and distance elapsed since the previous one,
/// and its comment. Prices are deliberately left out, the document is meant to be handed to a buyer or a garage.
///
/// The document only uses the PDF standard fonts (Helvetica), which every PDF reader provides, so no font has to
/// be shipped with the application. Those fonts only cover the Latin-1 character set: every text goes through
/// [_text], which maps the common typographic characters to Latin-1 equivalents and drops the others (emoji...).
class MaintenancePdf {
  MaintenancePdf._();

  static final PdfColor _accent = PdfColor.fromInt(0xFF00796B); // teal 700, the maintenance pages accent
  static final PdfColor _muted = PdfColor.fromInt(0xFF616161);
  static final PdfColor _rule = PdfColor.fromInt(0xFFD0D0D0);
  static final PdfColor _headerFill = PdfColor.fromInt(0xFFE0F2F1);

  /// Replacements for the characters people commonly type or that the app formatting produces, but that are
  /// outside Latin-1 (the only range the standard fonts can draw).
  static const Map<String, String> _replacements = {
    ' ': ' ', // narrow no-break space, used as thousands separator by the fr_CH number format
    ' ': ' ',
    '‘': "'",
    '’': "'",
    '“': '"',
    '”': '"',
    '–': '-',
    '—': '-',
    '•': '-',
    '…': '...',
    'Œ': 'OE',
    'œ': 'oe',
    '€': 'EUR',
    '≈': '~',
    '→': '->',
    '≤': '<=',
    '≥': '>=',
  };

  /// Make [value] drawable with the standard fonts: known characters are replaced, anything else outside Latin-1
  /// (emoji, other scripts...) is dropped rather than failing the whole document.
  static String _text(String value) {
    final StringBuffer buffer = StringBuffer();
    for (final int rune in value.runes) {
      final String char = String.fromCharCode(rune);
      final String? replacement = _replacements[char];
      if (replacement != null) {
        buffer.write(replacement);
      } else if (rune == 0x0A || (rune >= 0x20 && rune <= 0x7E) || (rune >= 0xA0 && rune <= 0xFF)) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  static String _date(DateTime date) => DateFormat(DATE_FORMAT_DAY).format(date);

  /// File name of the document, e.g. "carnet-entretien-yamaha-r6.pdf".
  static String fileName(Bike bike) {
    final String slug = "${bike.manufacturer ?? ''} ${bike.modelName ?? ''}"
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'carnet-entretien.pdf' : 'carnet-entretien-$slug.pdf';
  }

  /// Build the logbook of [bike], owned by [owner], from its [maintenance] data.
  static Future<Uint8List> build({required Bike bike, required Member? owner, required BikeMaintenance maintenance}) {
    final DateTime now = DateTime.now();
    final String bikeLabel = "${(bike.manufacturer ?? '').toUpperCase()} ${bike.modelName ?? ''}".trim();
    // oldest first, the way a logbook reads
    final List<Maintenance> maintenances = maintenance.maintenances.reversed.toList();

    final pw.Document document = pw.Document(title: _text("${AppString.maintenancePdfTitle} $bikeLabel"));
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 30),
        footer: (pw.Context context) => _footer(context, bikeLabel, now),
        build: (pw.Context context) => <pw.Widget>[
          _title(bikeLabel),
          pw.SizedBox(height: 14),
          _details(bike, owner, maintenance),
          pw.SizedBox(height: 18),
          _summary(maintenances),
          pw.SizedBox(height: 8),
          if (maintenances.isEmpty)
            pw.Text(_text(AppString.maintenanceNone), style: pw.TextStyle(color: _muted))
          else
            _table(maintenances),
        ],
      ),
    );
    return document.save();
  }

  static pw.Widget _title(String bikeLabel) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          _text(AppString.maintenancePdfTitle).toUpperCase(),
          style: pw.TextStyle(color: _accent, fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 1.2),
        ),
        pw.SizedBox(height: 2),
        pw.Text(_text(bikeLabel), style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Container(height: 2, width: 60, color: _accent),
      ],
    );
  }

  /// Key / value block: owner, engine size, year, odometer, maintenance plan.
  static pw.Widget _details(Bike bike, Member? owner, BikeMaintenance maintenance) {
    final String ownerName = "${owner?.firstName ?? ''} ${owner?.lastName ?? ''}".trim();
    final List<List<String>> rows = <List<String>>[
      if (ownerName.isNotEmpty) [AppString.maintenancePdfOwner, ownerName],
      if (bike.engineSize != null) [AppString.bikeEngineSize, "${bike.engineSize} cc"],
      if (bike.year != null) [AppString.bikeYear, bike.year.toString()],
      if (maintenance.odometerKm != null)
        [
          AppString.maintenancePdfOdometer,
          maintenance.odometerUpdatedOn != null
              ? AppString.format(AppString.odometerReadOn, [
                  MaintenanceUtils.formatKm(maintenance.odometerKm!),
                  _date(maintenance.odometerUpdatedOn!),
                ])
              : MaintenanceUtils.formatKm(maintenance.odometerKm!),
        ],
      [
        AppString.maintenancePlan,
        maintenance.plan != null ? MaintenanceUtils.formatPlan(maintenance.plan!) : AppString.maintenancePlanNone,
      ],
    ];

    return pw.Table(
      columnWidths: const <int, pw.TableColumnWidth>{0: pw.FixedColumnWidth(140), 1: pw.FlexColumnWidth()},
      children: <pw.TableRow>[
        for (final List<String> row in rows)
          pw.TableRow(
            children: <pw.Widget>[
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Text(_text(row[0]), style: pw.TextStyle(color: _muted, fontSize: 10)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Text(_text(row[1]), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ),
      ],
    );
  }

  /// "5 entretiens dont 3 révisions, du 02/06/2022 au 12/09/2026".
  static pw.Widget _summary(List<Maintenance> maintenances) {
    final List<pw.Widget> children = <pw.Widget>[
      pw.Text(
        _text(AppString.maintenanceHistoryTitle),
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
          ? AppString.format(AppString.maintenancePdfOn, [_date(maintenances.first.maintenanceDate!)])
          : AppString.format(AppString.maintenancePdfPeriod, [
              _date(maintenances.first.maintenanceDate!),
              _date(maintenances.last.maintenanceDate!),
            ]);
      children.add(pw.SizedBox(height: 2));
      children.add(
        pw.Text(_text("$count $serviceCount, $period"), style: pw.TextStyle(color: _muted, fontSize: 10)),
      );
    }
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: children);
  }

  static pw.Widget _cell(pw.Widget child) =>
      pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5), child: child);

  static pw.Widget _headerCell(String label) => _cell(
    pw.Text(_text(label), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _accent)),
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
      final pw.TextStyle small = pw.TextStyle(fontSize: 8, color: _muted);

      rows.add(
        pw.TableRow(
          verticalAlignment: pw.TableCellVerticalAlignment.top,
          decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _rule, width: 0.5))),
          children: <pw.Widget>[
            _cell(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(_date(m.maintenanceDate!), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  if (previous != null)
                    pw.Text(
                      _text("+${MaintenanceUtils.formatElapsed(previous.maintenanceDate!, m.maintenanceDate!)}"),
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
                    m.odometerKm != null ? _text(MaintenanceUtils.formatKm(m.odometerKm!)) : '-',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  if (previous?.odometerKm != null && m.odometerKm != null)
                    pw.Text(_text("+${MaintenanceUtils.formatKm(m.odometerKm! - previous!.odometerKm!)}"), style: small),
                ],
              ),
            ),
            _cell(
              pw.Text(
                _text(m.resetsPlan ? AppString.maintenanceServiceBadge : AppString.maintenancePdfOther),
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: m.resetsPlan ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: m.resetsPlan ? _accent : _muted,
                ),
              ),
            ),
            _cell(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  for (final MaintenanceOperation operation in m.operations) ...[
                    pw.Text(_text("- ${operation.title}"), style: const pw.TextStyle(fontSize: 10)),
                    if (operation.details != null)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 8, bottom: 1),
                        child: pw.Text(_text(operation.details!), style: small),
                      ),
                  ],
                  if (m.comment != null)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 3),
                      child: pw.Text(
                        _text(m.comment!),
                        style: pw.TextStyle(fontSize: 9, color: _muted, fontStyle: pw.FontStyle.italic),
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

  static pw.Widget _footer(pw.Context context, String bikeLabel, DateTime now) {
    final pw.TextStyle style = pw.TextStyle(fontSize: 8, color: _muted);
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 4),
      decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: _rule, width: 0.5))),
      child: pw.Row(
        children: <pw.Widget>[
          pw.Expanded(
            child: pw.Text(
              _text(AppString.format(AppString.maintenancePdfFooter, [bikeLabel, _date(now)])),
              style: style,
            ),
          ),
          pw.Text("${context.pageNumber} / ${context.pagesCount}", style: style),
        ],
      ),
    );
  }
}
