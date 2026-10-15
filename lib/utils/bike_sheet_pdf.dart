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
import 'package:ccteam/models/bike_equipment.dart';
import 'package:ccteam/models/member.dart';
import 'package:ccteam/utils/maintenance_utils.dart';
import 'package:ccteam/utils/pdf_utils.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds the sheet of a bike as a PDF document: bike details, then the parts fitted to it with their comment.
/// The maintenance history has its own document (see `MaintenancePdf`), and the prices are left out like in the
/// logbook: the sheet is meant to be handed to a buyer or a garage.
///
/// Every text goes through [PdfUtils.text], the document only uses the PDF standard fonts.
class BikeSheetPdf {
  BikeSheetPdf._();

  static final PdfColor _accent = PdfColor.fromInt(0xFFD32F2F); // red 700, the application bar color

  /// File name of the document, e.g. "fiche-moto-yamaha-r6.pdf".
  static String fileName(Bike bike) => PdfUtils.fileName('fiche-moto', bike);

  /// Build the sheet of [bike], owned by [owner], with its last [odometerKm] reading (taken on [odometerUpdatedOn])
  /// and its [equipments].
  static Future<Uint8List> build({
    required Bike bike,
    required Member? owner,
    required int? odometerKm,
    required DateTime? odometerUpdatedOn,
    required List<BikeEquipment> equipments,
  }) {
    final DateTime now = DateTime.now();
    final String bikeLabel = PdfUtils.bikeLabel(bike);
    final String ownerName = "${owner?.firstName ?? ''} ${owner?.lastName ?? ''}".trim();

    final pw.Document document = pw.Document(title: PdfUtils.text("${AppString.bikeSheetPdfTitle} $bikeLabel"));
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 30),
        footer: (pw.Context context) =>
            PdfUtils.footer(context, AppString.format(AppString.bikeSheetPdfFooter, [bikeLabel, PdfUtils.date(now)])),
        build: (pw.Context context) => <pw.Widget>[
          PdfUtils.title(AppString.bikeSheetPdfTitle, bikeLabel, _accent),
          pw.SizedBox(height: 14),
          PdfUtils.details(<List<String>>[
            if (ownerName.isNotEmpty) [AppString.bikeOwner, ownerName],
            if (bike.manufacturer != null)
              [AppString.bikeManufacturer, StringUtils.capitalize(bike.manufacturer!) ?? bike.manufacturer!],
            if (bike.modelName != null) [AppString.bikeModel, bike.modelName!],
            if (bike.engineSize != null) [AppString.bikeEngineSize, "${bike.engineSize} cc"],
            if (bike.year != null) [AppString.bikeYear, bike.year.toString()],
            if (odometerKm != null)
              [
                AppString.bikeMileage,
                odometerUpdatedOn != null
                    ? AppString.format(AppString.odometerReadOn, [
                        MaintenanceUtils.formatKm(odometerKm),
                        PdfUtils.date(odometerUpdatedOn),
                      ])
                    : MaintenanceUtils.formatKm(odometerKm),
              ],
          ]),
          pw.SizedBox(height: 18),
          pw.Text(
            PdfUtils.text(AppString.equipmentTitle),
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _accent),
          ),
          pw.SizedBox(height: 6),
          if (equipments.isEmpty)
            pw.Text(PdfUtils.text(AppString.equipmentNone), style: pw.TextStyle(color: PdfUtils.muted))
          else
            // one widget per equipment rather than a single column, so a long list can break across pages
            for (int i = 0; i < equipments.length; i++) _equipment(equipments[i], first: i == 0),
        ],
      ),
    );
    return document.save();
  }

  /// One equipment between two rules: designation, with its comment below it.
  static pw.Widget _equipment(BikeEquipment equipment, {required bool first}) {
    final pw.BorderSide side = pw.BorderSide(color: PdfUtils.rule, width: 0.5);
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: first ? side : pw.BorderSide.none, bottom: side),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(PdfUtils.text(equipment.designation), style: const pw.TextStyle(fontSize: 10.5)),
          if (equipment.comment != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 1),
              child: pw.Text(
                PdfUtils.text(equipment.comment!),
                style: pw.TextStyle(fontSize: 9, color: PdfUtils.muted),
              ),
            ),
        ],
      ),
    );
  }
}
