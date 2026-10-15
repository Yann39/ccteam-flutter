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

import 'package:ccteam/models/bike.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Shared building blocks of the PDF documents about a bike (maintenance logbook, bike sheet).
///
/// The documents only use the PDF standard fonts (Helvetica), which every PDF reader provides, so no font has to
/// be shipped with the application. Those fonts only cover the Latin-1 character set: every text goes through
/// [text], which maps the common typographic characters to Latin-1 equivalents and drops the others (emoji...).
class PdfUtils {
  PdfUtils._();

  /// Color of the secondary texts.
  static final PdfColor muted = PdfColor.fromInt(0xFF616161);

  /// Color of the separation lines.
  static final PdfColor rule = PdfColor.fromInt(0xFFD0D0D0);

  /// Replacements for the characters people commonly type or that the app formatting produces, but that are
  /// outside Latin-1 (the only range the standard fonts can draw).
  static const Map<String, String> _replacements = {
    ' ': ' ', // narrow no-break space, used as thousands separator by the fr_CH number format
    ' ': ' ', // thin space
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

  /// Base letter of each Latin Extended-A character (U+0100 to U+017F), so names such as "Akrapovič" or "Škoda" are
  /// drawn without their accent rather than losing a letter. Œ and œ are covered by [_replacements].
  static const String _latinExtendedA =
      'AaAaAaCcCcCcCcDdDdEeEeEeEeEeGgGgGgGgHhHhIiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnnNnOoOoOoOoRrRrRrSsSsSsSsTtTtTtUuUuUuUu'
      'UuUuWwYyYZzZzZzs';

  /// Make [value] drawable with the standard fonts: known characters are replaced, anything else outside Latin-1
  /// (emoji, other scripts...) is dropped rather than failing the whole document.
  static String text(String value) {
    final StringBuffer buffer = StringBuffer();
    for (final int rune in value.runes) {
      final String char = String.fromCharCode(rune);
      final String? replacement = _replacements[char];
      if (replacement != null) {
        buffer.write(replacement);
      } else if (rune == 0x0A || (rune >= 0x20 && rune <= 0x7E) || (rune >= 0xA0 && rune <= 0xFF)) {
        buffer.write(char);
      } else if (rune >= 0x100 && rune <= 0x17F) {
        buffer.write(_latinExtendedA[rune - 0x100]);
      }
    }
    return buffer.toString();
  }

  static String date(DateTime date) => DateFormat(DATE_FORMAT_DAY).format(date);

  /// Name of the bike as displayed in the app, e.g. "YAMAHA R6".
  static String bikeLabel(Bike bike) => "${(bike.manufacturer ?? '').toUpperCase()} ${bike.modelName ?? ''}".trim();

  /// File name of a document about [bike], e.g. "carnet-entretien-yamaha-r6.pdf" for the [prefix] "carnet-entretien".
  static String fileName(String prefix, Bike bike) {
    final String slug = "${bike.manufacturer ?? ''} ${bike.modelName ?? ''}"
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? '$prefix.pdf' : '$prefix-$slug.pdf';
  }

  /// Heading of the document: its [kind] in small [accent] capitals, the [bikeLabel] in large, and an accent rule.
  static pw.Widget title(String kind, String bikeLabel, PdfColor accent) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          text(kind).toUpperCase(),
          style: pw.TextStyle(color: accent, fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 1.2),
        ),
        pw.SizedBox(height: 2),
        pw.Text(text(bikeLabel), style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Container(height: 2, width: 60, color: accent),
      ],
    );
  }

  /// Key / value block, one `[label, value]` pair per row.
  static pw.Widget details(List<List<String>> rows) {
    return pw.Table(
      columnWidths: const <int, pw.TableColumnWidth>{0: pw.FixedColumnWidth(140), 1: pw.FlexColumnWidth()},
      children: <pw.TableRow>[
        for (final List<String> row in rows)
          pw.TableRow(
            children: <pw.Widget>[
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Text(text(row[0]), style: pw.TextStyle(color: muted, fontSize: 10)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Text(text(row[1]), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ),
      ],
    );
  }

  /// Page footer: [label] on the left, page number on the right.
  static pw.Widget footer(pw.Context context, String label) {
    final pw.TextStyle style = pw.TextStyle(fontSize: 8, color: muted);
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: rule, width: 0.5)),
      ),
      child: pw.Row(
        children: <pw.Widget>[
          pw.Expanded(child: pw.Text(text(label), style: style)),
          pw.Text("${context.pageNumber} / ${context.pagesCount}", style: style),
        ],
      ),
    );
  }
}
