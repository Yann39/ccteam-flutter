/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of Chachatte Team application.
 *
 * Chachatte Team is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Chachatte Team is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Chachatte Team. If not, see <http://www.gnu.org/licenses/>.
 */

/// class representing a track
class Track {
  int id;
  String name;
  String description;

  Track({this.id, this.name, this.description,});

  @override
  String toString() {
    return """{
      id: ${this.id},
      name: ${this.name},
      description: ${this.description},
    }""";
  }

  /// Convert [json] map to the corresponding object
  Track.fromJson(Map<String, dynamic> json)
      : id = json['id'] != null ? int.parse(json['id']) : -1,
        name = json['name'],
        description = json['description'];

  /// Convert [member] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
  };
}
