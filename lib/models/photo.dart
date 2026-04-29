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



/// Class representing a photo
/// todo Add Gallery property ?
class Photo {
  String? id;
  String? title;
  String? description;
  String? link;
  DateTime? createdOn;
  DateTime? modifiedOn;

  Photo({
    this.id,
    this.title,
    this.description,
    this.link,
    this.createdOn,
    this.modifiedOn,
  });

  @override
  String toString() {
    return """{
      id: ${this.id},
      title: ${this.title},
      description: ${this.description},
      link: ${this.link},
      createdOn: ${this.createdOn?.toIso8601String()},
      modifiedOn: ${this.modifiedOn?.toIso8601String()},
    }""";
  }

  /// Convert [json] map to the corresponding [photo] object
  Photo.fromJson(Map<String, dynamic> json)
      : id = json['id']?.toString(),
        title = json['title'],
        description = json['description'],
        link = json['link'],
        createdOn = json['createdOn'] != null ? DateTime.parse(json['createdOn']) : null,
        modifiedOn = json['modifiedOn'] != null ? DateTime.parse(json['modifiedOn']) : null;

  /// Convert [Photo] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "link": link,
        "createdOn": createdOn?.toIso8601String(),
        "modifiedOn": modifiedOn?.toIso8601String(),
      };
}
