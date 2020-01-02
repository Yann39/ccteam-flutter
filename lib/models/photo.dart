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

import 'package:intl/intl.dart';

/// class representing a photo
class Photo {
  int id;
  String title;
  String description;
  String link;
  DateTime createdOn;
  DateTime modifiedOn;

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
      createdOn: ${this.createdOn != null ? this.createdOn.toIso8601String() : ""},
      modifiedOn: ${this.modifiedOn != null ? this.modifiedOn.toIso8601String() : ""},
    }""";
  }

  /// Convert [json] map to the corresponding object
  Photo.fromJson(Map<String, dynamic> json)
      : id = json['id'] != null ? int.parse(json['id']) : -1,
        title = json['title'],
        description = json['description'],
        link = json['link'],
        createdOn = json['created_on'] != null ? new DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['created_on']) : null,
        modifiedOn = json['modified_on'] != null ? new DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['modified_on']) : null;

  /// Convert [member] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "link": link,
        "created_on": createdOn,
        "modified_on": modifiedOn,
      };
}
