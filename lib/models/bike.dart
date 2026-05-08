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

/// Class representing a bike
class Bike {
  int? id;
  String? manufacturer;
  String? modelName;
  int? engineSize;
  int? year;
  bool? current;

  Bike({
    this.id,
    this.manufacturer,
    this.modelName,
    this.engineSize,
    this.year,
    this.current,
  });

  @override
  String toString() {
    return """{
      id: ${this.id.toString()},
      manufacturer: ${this.manufacturer},
      modelName: ${this.modelName},
      engineSize: ${this.engineSize},
      year: ${this.year},
      current: ${this.current},
    }""";
  }

  /// Convert [json] map to the corresponding object
  Bike.fromJson(Map<String, dynamic> json)
    : id = json['id'] != null ? int.parse(json['id'].toString()) : null,
      manufacturer = json['manufacturer'],
      modelName = json['modelName'],
      engineSize = json['engineSize'],
      year = json['year'],
      current = json['current'] != null
          ? (json['current'] == true || json['current'] == '1')
          : null;

  /// Convert [Bike] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
    "id": id?.toString(),
    "manufacturer": manufacturer,
    "modelName": modelName,
    "engineSize": engineSize,
    "year": year,
    "current": current,
  };

  /// Override == operator to compare bikes by id
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bike && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
