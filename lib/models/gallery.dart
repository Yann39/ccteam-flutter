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

import 'package:chachatte_team/models/photo.dart';
import 'package:intl/intl.dart';

/// Class representing a photo gallery
class Gallery {
  int id;
  String title;
  String description;
  DateTime createdOn;
  DateTime modifiedOn;
  List<Photo> photos;

  Gallery({
    this.id,
    this.title,
    this.description,
    this.createdOn,
    this.modifiedOn,
    this.photos,
  });

  @override
  String toString() {
    return """{
      id: ${this.id},
      title: ${this.title},
      description: ${this.description},
      createdOn: ${this.createdOn?.toIso8601String()},
      modifiedOn: ${this.modifiedOn?.toIso8601String()},
      photos: ${this.photos?.map((i) => i.toString())},
    }""";
  }

  /// Convert [json] map to the corresponding [Gallery] object
  Gallery.fromJson(Map<String, dynamic> json)
      : id = json['id'] != null ? int.parse(json['id']) : -1,
        title = json['title'],
        description = json['description'],
        createdOn = json['createdOn'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['createdOn']) : null,
        modifiedOn = json['modifiedOn'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['modifiedOn']) : null,
        photos = json['photos'] != null ? (json['photos'] as List).map((i) => Photo.fromJson(i)).toList() : null;

  /// Convert [Gallery] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "createdOn": createdOn?.toIso8601String(),
        "modifiedOn": modifiedOn?.toIso8601String(),
        "photos": photos?.map((i) => i.toJson()),
      };
}
