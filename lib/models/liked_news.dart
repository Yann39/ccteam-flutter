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

import 'package:ccteam/models/member.dart';
import 'package:ccteam/models/news.dart';

/// Class representing a liked news
class LikedNews {
  int? id;
  News? news;
  Member? member;
  DateTime? createdOn;

  LikedNews({
    this.id,
    this.news,
    this.member,
    this.createdOn,
  });

  @override
  String toString() {
    return """{
      id: ${this.id.toString()},
      news: ${this.news.toString()},
      member: ${this.member.toString()},
      createdOn: ${this.createdOn?.toIso8601String()},
    }""";
  }

  /// Convert [json] map to the corresponding object
  LikedNews.fromJson(Map<String, dynamic> json)
      : id = json['id'] != null ? int.parse(json['id']) : null,
        news = json['news'] != null ? News.fromJson(json['news']) : null,
        member = json['member'] != null ? Member.fromJson(json['member']) : null,
        createdOn = json['createdOn'] != null ? DateTime.parse(json['createdOn']) : null;

  /// Convert [LikedNews] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
        "id": id.toString(),
        "news": news?.toJson(),
        "member": member?.toJson(),
        "createdOn": createdOn?.toIso8601String(),
      };
}
