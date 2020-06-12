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
import 'package:chachatte_team/models/track.dart';
import 'package:intl/intl.dart';

/// Class representing a track event
class Event {
  int id;
  String title;
  String description;
  DateTime startDate;
  DateTime endDate;
  Track track;
  String organizer;
  double price;
  List<Member> members;
  DateTime createdOn;
  Member createdBy;
  DateTime modifiedOn;
  Member modifiedBy;

  Event({
    this.id,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.track,
    this.organizer,
    this.price,
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
      description: ${this.description},
      startDate: ${this.startDate != null ? this.startDate.toIso8601String() : ""},
      endDate: ${this.endDate != null ? this.endDate.toIso8601String() : ""},
      track: ${this.track != null ? this.track.toString() : ""},
      organizer: ${this.organizer},
      price: ${this.price},
      members: ${this.members != null ? this.members.map((i) => i.toString()) : ""},
      createdOn: ${this.createdOn != null ? this.createdOn.toIso8601String() : ""},
      createdBy: ${this.createdBy != null ? this.createdBy.toString() : ""},
      modifiedOn: ${this.modifiedOn != null ? this.modifiedOn.toIso8601String() : ""},
      modifiedBy: ${this.modifiedBy != null ? this.modifiedBy.toString() : ""},
    }""";
  }

  /// Convert [json] map to the corresponding object
  Event.fromJson(Map<String, dynamic> json)
      : id = json['id'] != null ? int.parse(json['id']) : -1,
        title = json['title'],
        description = json['description'],
        startDate = json['start_date'] != null ? new DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['start_date']) : null,
        endDate = json['end_date'] != null ? new DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['end_date']) : null,
        track = json['track'] != null ? Track.fromJson(json['track']) : null,
        organizer = json['organizer'],
        price = json['price'] != null ? double.parse(json['price']) : null,
        members = json['members'] != null ? (json['members'] as List).map((i) => Member.fromJson(i)).toList() : null,
        createdOn = json['created_on'] != null ? new DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['created_on']) : null,
        createdBy = json['created_by'] != null ? Member.fromJson(json['created_by']) : null,
        modifiedOn = json['modified_on'] != null ? new DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['modified_on']) : null,
        modifiedBy = json['modified_by'] != null ? Member.fromJson(json['modified_by']) : null;

  /// Convert [member] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "start_date": startDate,
        "end_date": endDate,
        "track": track != null ? track.toJson() : null,
        "organizer": organizer,
        "price": price,
        "members": members != null ? members.map((i) => i.toJson()) : null,
        "created_on": createdOn,
        "created_by": createdBy != null ? createdBy.toJson() : null,
        "modified_on": modifiedOn,
        "modified_by": modifiedBy != null ? modifiedBy.toJson() : null,
      };

  String get fullDate {
    final DateFormat formatterDate = new DateFormat("dd MMM yyyy", "fr");
    // same day, display only one of the dates (i.e "24 Apr. 2020")
    if (this.startDate == this.endDate) {
      return formatterDate.format(this.startDate);
    } else {
      // 2 different years, display the complete 2 dates (i.e. "27 Dec. 2019 - 04 Jan. 2020")
      if (this.startDate.year != this.endDate.year) {
        return formatterDate.format(this.startDate) + " - " + formatterDate.format(this.endDate);
      }
      // same year but 2 different months, display the 2 months (i.e. "27 Aug. - 11 Sept. 2020")
      else if (this.startDate.month != this.endDate.month) {
        final DateFormat formatterMonth = new DateFormat("dd MMM", "fr");
        return formatterMonth.format(this.startDate) + " - " + formatterDate.format(this.endDate);
      }
      // same year and month but 2 different days, display the 2 days (i.e. "19 - 22 Oct. 2020")
      else {
        final DateFormat formatterDay = new DateFormat("dd", "fr");
        return formatterDay.format(this.startDate) + " - " + formatterDate.format(this.endDate);
      }
    }
  }
}
