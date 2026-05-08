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

import 'package:ccteam/models/country.dart';

/// Class representing a track
class Track {
  int? id;
  String? name;
  int? distance;
  int? lapRecord;
  String? website;
  double? latitude;
  double? longitude;
  Country? country;

  Track({
    this.id,
    this.name,
    this.distance,
    this.lapRecord,
    this.website,
    this.latitude,
    this.longitude,
    this.country,
  });

  @override
  String toString() {
    return """{
      id: ${this.id.toString()},
      name: ${this.name},
      distance: ${this.distance},
      lapRecord: ${this.lapRecord},
      website: ${this.website},
      latitude: ${this.latitude},
      longitude: ${this.longitude},
      country: ${this.country},
    }""";
  }

  /// Convert [json] map to the corresponding object
  Track.fromJson(Map<String, dynamic> json)
    : id = json['id'] != null ? int.parse(json['id'].toString()) : null,
      name = json['name'],
      distance = json['distance'] != null ? json['distance'] : null,
      lapRecord = json['lapRecord'] != null ? json['lapRecord'] : null,
      website = json['website'],
      latitude = json['latitude'] != null ? json['latitude'] : null,
      longitude = json['longitude'] != null ? json['longitude'] : null,
      country = json['country'] != null
          ? Country.fromJson(json['country'])
          : null;

  /// Convert [Record] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
    "id": id.toString(),
    "name": name,
    "distance": distance,
    "lapRecord": lapRecord,
    "website": website,
    "latitude": latitude,
    "longitude": longitude,
    "country": country?.toJson(),
  };

  /// Override == operator to compare tracks by id
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
