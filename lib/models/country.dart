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

/// Class representing a country (ISO 3166-1 alpha-2 reference + localized
/// names). Shared reference data used e.g. for [Track.country].
class Country {
  /// ISO 3166-1 alpha-2 code (e.g. "FR", "ES").
  final String code;

  /// Localized name in French.
  final String nameFr;

  /// Localized name in English.
  final String nameEn;

  const Country({
    required this.code,
    required this.nameFr,
    required this.nameEn,
  });

  /// Returns the country name for the given [languageCode] (`'fr'` or
  /// `'en'`). Falls back to French for unknown locales.
  String localizedName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return nameEn;
      case 'fr':
      default:
        return nameFr;
    }
  }

  /// Convert the ISO code to its flag emoji (🇫🇷 for "FR", etc.).
  /// Returns an empty string if the code is invalid.
  String get flagEmoji {
    if (code.length != 2) return '';
    final upper = code.toUpperCase();
    final first = 0x1F1E6 + upper.codeUnitAt(0) - 'A'.codeUnitAt(0);
    final second = 0x1F1E6 + upper.codeUnitAt(1) - 'A'.codeUnitAt(0);
    return String.fromCharCodes(<int>[first, second]);
  }

  @override
  String toString() => "{code: $code, nameFr: $nameFr, nameEn: $nameEn}";

  /// Convert [json] map to the corresponding object.
  Country.fromJson(Map<String, dynamic> json)
      : code = json['code'] ?? '',
        nameFr = json['nameFr'] ?? '',
        nameEn = json['nameEn'] ?? '';

  /// Convert [Country] object to the corresponding JSON map.
  Map<String, dynamic> toJson() => {
        "code": code,
        "nameFr": nameFr,
        "nameEn": nameEn,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
