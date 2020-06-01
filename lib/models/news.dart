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

import 'package:chachatte_team/models/member.dart';
import 'package:intl/intl.dart';

/// Class representing a news
class News {
  int id;
  String title;
  String catchLine;
  String content;
  DateTime newsDate;
  List<Member> members;
  DateTime createdOn;
  int createdBy;
  DateTime modifiedOn;
  int modifiedBy;

  News({
    this.id,
    this.title,
    this.catchLine,
    this.content,
    this.newsDate,
    this.members,
    this.createdOn,
    this.createdBy,
    this.modifiedOn,
    this.modifiedBy,
  });

  @override
  String toString() {
    return """{
      id: ${this.id},
      title: ${this.title},
      catchLine: ${this.catchLine},
      content: ${this.content},
      newsDate: ${this.newsDate != null ? this.newsDate.toIso8601String() : ""},
      members: ${this.members != null ? this.members.map((i) => i.toString()) : ""},
      createdOn: ${this.createdOn != null ? this.createdOn.toIso8601String() : ""},
      createdBy: ${this.createdBy},
      modifiedOn: ${this.modifiedOn != null ? this.modifiedOn.toIso8601String() : ""},
      modifiedBy: ${this.modifiedBy},
    }""";
  }

  /// Convert [json] map to the corresponding object
  News.fromJson(Map<String, dynamic> json)
      : id = json['id'] != null ? int.parse(json['id']) : -1,
        title = json['title'],
        catchLine = json['catch_line'],
        content = json['content'],
        newsDate = json['news_date'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['news_date']) : null,
        members = json['members'] != null ? (json['members'] as List).map((i) => Member.fromJson(i)).toList() : null,
        createdOn = json['created_on'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['created_on']) : null,
        createdBy = json['created_by'] != null ? int.parse(json['created_by']) : null,
        modifiedOn = json['modified_on'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['modified_on']) : null,
        modifiedBy = json['modified_by'] != null ? int.parse(json['modified_by']) : null;

  /// Convert [member] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "catch_line": catchLine,
        "content": content,
        "news_date": newsDate != null ? newsDate.toIso8601String() : null,
        "members": members != null && members.length > 0 ? '[${members.map((m) => m.toJson())}]' : null,
        "created_on": createdOn != null ? createdOn.toIso8601String() : null,
        "created_by": createdBy,
        "modified_on": modifiedOn != null ? modifiedOn.toIso8601String() : null,
        "modified_by": modifiedBy,
      };
}
