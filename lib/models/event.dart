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

import 'package:ccteam/models/event_member.dart';
import 'package:ccteam/models/member.dart';
import 'package:ccteam/models/track.dart';
import 'package:intl/intl.dart';

/// Class representing an event
class Event {
  int? id;
  String? title;
  String? description;
  DateTime? startDate;
  DateTime? endDate;
  Track? track;
  String? organizer;
  double? price;
  List<EventMember>? participants;
  DateTime? createdOn;
  Member? createdBy;
  DateTime? modifiedOn;
  Member? modifiedBy;

  Event({
    this.id,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.track,
    this.organizer,
    this.price,
    this.participants,
    this.createdOn,
    this.createdBy,
    this.modifiedOn,
    this.modifiedBy,
  });

  @override
  String toString() {
    return """{
      id: ${this.id.toString()},
      title: ${this.title},
      description: ${this.description},
      startDate: ${this.startDate?.toIso8601String()},
      endDate: ${this.endDate?.toIso8601String()},
      track: ${this.track?.toString()},
      organizer: ${this.organizer},
      price: ${this.price},
      participants: ${this.participants?.map((eventMember) => eventMember.toString())},
      createdOn: ${this.createdOn?.toIso8601String()},
      createdBy: ${this.createdBy.toString()},
      modifiedOn: ${this.modifiedOn?.toIso8601String()},
      modifiedBy: ${this.modifiedBy.toString()},
    }""";
  }

  /// Convert [json] map to the corresponding object
  Event.fromJson(Map<String, dynamic> json)
      : id = json['id'] != null ? int.parse(json['id'].toString()) : null,
        title = json['title'],
        description = json['description'],
        startDate = json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
        endDate = json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        track = json['track'] != null ? Track.fromJson(json['track']) : null,
        organizer = json['organizer'],
        price = json['price'],
        participants = json['participants'] != null
            ? (json['participants'] as Iterable).map((i) => EventMember.fromJson(i)).toList()
            : null,
        createdOn = json['createdOn'] != null ? DateTime.parse(json['createdOn']) : null,
        createdBy = json['createdBy'] != null ? Member.fromJson(json['createdBy']) : null,
        modifiedOn = json['modifiedOn'] != null ? DateTime.parse(json['modifiedOn']) : null,
        modifiedBy = json['modifiedBy'] != null ? Member.fromJson(json['modifiedBy']) : null;

  /// Convert [Event] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
        "id": id.toString(),
        "title": title,
        "description": description,
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "track": track?.toJson(),
        "organizer": organizer,
        "price": price,
        "participants": participants?.map((i) => i.toJson()).toList(),
        "createdOn": createdOn?.toIso8601String(),
        "createdBy": createdBy?.toJson(),
        "modifiedOn": modifiedOn?.toIso8601String(),
        "modifiedBy": modifiedBy?.toJson(),
      };

  /// Returns the event full date (begin - end) formatted as String
  String get fullDate {
    final DateFormat formatterDate = new DateFormat("dd MMM yyyy", "fr");
    // both date are null, return empty string
    if (this.startDate == null && this.endDate == null) {
      return "";
    }
    // start date is null, display until end date (i.e. "Until 04 Jan. 2020")
    else if (this.startDate == null && this.endDate != null) {
      return "Until " + formatterDate.format(this.endDate!);
    }
    // end date is null, display from start date (i.e. "From 27 Dec. 2019")
    else if (this.startDate != null && this.endDate == null) {
      return "From " + formatterDate.format(this.endDate!);
    }
    // same day, display only one of the dates (i.e "24 Apr. 2020")
    else if (this.startDate == this.endDate) {
      return formatterDate.format(this.startDate!);
    } else {
      // 2 different years, display the complete 2 dates (i.e. "27 Dec. 2019 - 04 Jan. 2020")
      if (this.startDate!.year != this.endDate!.year) {
        return formatterDate.format(this.startDate!) + " - " + formatterDate.format(this.endDate!);
      }
      // same year but 2 different months, display the 2 months (i.e. "27 Aug. - 11 Sept. 2020")
      else if (this.startDate!.month != this.endDate!.month) {
        final DateFormat formatterMonth = new DateFormat("dd MMM", "fr");
        return formatterMonth.format(this.startDate!) + " - " + formatterDate.format(this.endDate!);
      }
      // same year and month but 2 different days, display the 2 days (i.e. "19 - 22 Oct. 2020")
      else {
        final DateFormat formatterDay = new DateFormat("dd", "fr");
        return formatterDay.format(this.startDate!) + " - " + formatterDate.format(this.endDate!);
      }
    }
  }
}
