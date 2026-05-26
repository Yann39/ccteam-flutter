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

/// Bike utility functions
class BikeUtils {
  /// Set of manufacturers we have an SVG logo for in `images/manufacturers/`.
  static const Set<String> _knownManufacturers = <String>{
    'aprilia',
    'bmw',
    'ducati',
    'honda',
    'kawasaki',
    'ktm',
    'suzuki',
    'triumph',
    'yamaha',
    'ohvale',
  };

  /// Return the asset path of the manufacturer logo, or null if we don't have one for that brand.
  static String? manufacturerLogoPath(String? manufacturer) {
    if (manufacturer == null || manufacturer.isEmpty) return null;
    final String normalized = manufacturer.toLowerCase().trim();
    if (!_knownManufacturers.contains(normalized)) return null;
    return 'images/manufacturers/logo-$normalized.svg';
  }
}
