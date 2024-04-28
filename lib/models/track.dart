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

/// Class representing a track
class Track {
  int? id;
  String? name;
  int? distance;
  int? lapRecord;
  String? website;
  double? latitude;
  double? longitude;

  Track({
    this.id,
    this.name,
    this.distance,
    this.lapRecord,
    this.website,
    this.latitude,
    this.longitude,
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
    }""";
  }

  /// Convert [json] map to the corresponding object
  Track.fromJson(Map<String, dynamic> json)
      : id = json['id'] != null ? int.parse(json['id']) : null,
        name = json['name'],
        distance = json['distance'] != null ? json['distance'] : null,
        lapRecord = json['lapRecord'] != null ? json['lapRecord'] : null,
        website = json['website'],
        latitude = json['latitude'] != null ? json['latitude'] : null,
        longitude = json['longitude'] != null ? json['longitude'] : null;

  /// Convert [Record] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
        "id": id.toString(),
        "name": name,
        "distance": distance,
        "lapRecord": lapRecord,
        "website": website,
        "latitude": latitude,
        "longitude": longitude,
      };
}
