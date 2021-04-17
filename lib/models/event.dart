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
      startDate: ${this.startDate?.toIso8601String()},
      endDate: ${this.endDate?.toIso8601String()},
      track: ${this.track?.toString()},
      organizer: ${this.organizer},
      price: ${this.price},
      members: ${this.members?.map((member) => member.toString())},
      createdOn: ${this.createdOn?.toIso8601String()},
      createdBy: ${this.createdBy?.toString()},
      modifiedOn: ${this.modifiedOn?.toIso8601String()},
      modifiedBy: ${this.modifiedBy?.toString()},
    }""";
  }

  /// Convert [json] map to the corresponding object
  Event.fromJson(Map<String, dynamic> json)
      : id = json['id'] != null ? int.parse(json['id']) : -1,
        title = json['title'],
        description = json['description'],
        startDate = json['startDate'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['startDate']) : null,
        endDate = json['endDate'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['endDate']) : null,
        track = json['track'] != null ? Track.fromJson(json['track']) : null,
        organizer = json['organizer'],
        price = json['price'],
        members = json['members'] != null ? (json['members'] as List).map((i) => Member.fromJson(i)).toList() : null,
        createdOn = json['createdOn'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['createdOn']) : null,
        createdBy = json['createdBy'] != null ? Member.fromJson(json['createdBy']) : null,
        modifiedOn =
            json['modifiedOn'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['modifiedOn']) : null,
        modifiedBy = json['modifiedBy'] != null ? Member.fromJson(json['modifiedBy']) : null;

  /// Convert [member] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "track": track?.toJson(),
        "organizer": organizer,
        "price": price,
        "members": members?.map((i) => i.toJson()),
        "createdOn": createdOn?.toIso8601String(),
        "createdBy": createdBy?.toJson(),
        "modifiedOn": modifiedOn?.toIso8601String(),
        "modifiedBy": modifiedBy?.toJson(),
      };

  /// Returns the event full date (begin - end) formatted as String
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
