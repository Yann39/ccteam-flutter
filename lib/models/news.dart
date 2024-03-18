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

import 'package:chachatte_team/models/liked_news.dart';
import 'package:chachatte_team/models/member.dart';
import 'package:intl/intl.dart';

/// Class representing a news
class News {
  int id;
  String title;
  String catchLine;
  String content;
  DateTime newsDate;
  List<LikedNews> likedNews;
  DateTime createdOn;
  Member createdBy;
  DateTime modifiedOn;
  Member modifiedBy;

  News({
    this.id,
    this.title,
    this.catchLine,
    this.content,
    this.newsDate,
    this.likedNews,
    this.createdOn,
    this.createdBy,
    this.modifiedOn,
    this.modifiedBy,
  });

  News.clone(News news)
      : this.id = news.id,
        this.title = news.title,
        this.catchLine = news.catchLine,
        this.content = news.content,
        this.newsDate = news.newsDate,
        this.likedNews = List.of(news.likedNews),
        this.createdOn = news.createdOn,
        this.createdBy = news.createdBy,
        this.modifiedOn = news.modifiedOn,
        this.modifiedBy = news.modifiedBy;

  @override
  String toString() {
    return """{
      id: ${this.id},
      title: ${this.title},
      catchLine: ${this.catchLine},
      content: ${this.content},
      newsDate: ${this.newsDate?.toIso8601String()},
      likedNews: ${this.likedNews?.map((i) => i.toString())},
      createdOn: ${this.createdOn?.toIso8601String()},
      createdBy: ${this.createdBy?.toString()},
      modifiedOn: ${this.modifiedOn?.toIso8601String()},
      modifiedBy: ${this.modifiedBy?.toString()},
    }""";
  }

  /// Convert [json] map to the corresponding object
  News.fromJson(Map<String, dynamic> json)
      : id = json['id'] != null ? int.parse(json['id']) : -1,
        title = json['title'],
        catchLine = json['catchLine'],
        content = json['content'],
        newsDate = json['newsDate'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['newsDate']) : null,
        likedNews =
            json['likedNews'] != null ? (json['likedNews'] as List).map((i) => LikedNews.fromJson(i)).toList() : null,
        createdOn = json['createdOn'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['createdOn']) : null,
        createdBy = json['createdBy'] != null ? Member.fromJson(json['createdBy']) : null,
        modifiedOn =
            json['modifiedOn'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['modifiedOn']) : null,
        modifiedBy = json['modifiedBy'] != null ? Member.fromJson(json['createdBy']) : null;

  /// Convert [News] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "catchLine": catchLine,
        "content": content,
        "newsDate": newsDate?.toIso8601String(),
        "likedNews": likedNews != null && likedNews.length > 0 ? '[${likedNews.map((ln) => ln.toJson())}]' : null,
        "createdOn": createdOn?.toIso8601String(),
        "createdBy": createdBy?.toJson(),
        "modifiedOn": modifiedOn?.toIso8601String(),
        "modifiedBy": modifiedBy?.toJson(),
      };
}
