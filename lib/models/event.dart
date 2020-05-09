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

/// Class representing an event on a track
class Event {
  int id;
  String title;
  String description;
  DateTime eventDate;
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
    this.eventDate,
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
      eventDate: ${this.eventDate != null ? this.eventDate.toIso8601String() : ""},
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
        eventDate = json['event_date'] != null ? new DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['event_date']) : null,
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
        "event_date": eventDate,
        "track": track != null ? track.toJson() : null,
        "organizer": organizer,
        "price": price,
        'members': members != null ? members.map((i) => i.toJson()) : null,
        "created_on": createdOn,
        "created_by": createdBy != null ? createdBy.toJson() : null,
        "modified_on": modifiedOn,
        "modified_by": modifiedBy != null ? modifiedBy.toJson() : null,
      };
}
