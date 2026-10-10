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

import 'package:ccteam/models/bike.dart';
import 'package:ccteam/models/event.dart';
import 'package:ccteam/models/event_session.dart';
import 'package:ccteam/models/member.dart';

/// Class representing an event participant
class EventMember {
  int? id;
  Member? member;
  Event? event;

  /// Optional bike the member intends to (or did) ride at this event.
  /// May be null when the member registered without pinning a bike, or
  /// after the bike has been deleted from the member's profile (the
  /// server clears the reference, the participation stays).
  Bike? bike;

  /// Sessions of the event the member did *not* ride.
  ///
  /// Absences are stored rather than attendances, so an empty list means
  /// "rode everything", the default state of a participation, and the one
  /// the UI shows with every session ticked.
  List<EventSession>? skippedSessions;

  /// Free comment of the member about their participation (optional).
  String? comment;

  DateTime? createdOn;

  EventMember({this.id, this.member, this.event, this.bike, this.skippedSessions, this.comment, this.createdOn});

  @override
  String toString() {
    return """{
      id: ${this.id.toString()},
      members: ${this.member.toString()},
      members: ${this.event.toString()},
      bike: ${this.bike.toString()},
      skippedSessions: ${this.skippedSessions?.map((session) => session.toString())},
      comment: ${this.comment},
      createdOn: ${this.createdOn?.toIso8601String()},
    }""";
  }

  /// Convert [json] map to the corresponding object
  EventMember.fromJson(Map<String, dynamic> json)
    : id = json['id'] != null ? int.parse(json['id'].toString()) : null,
      member = json['member'] != null ? Member.fromJson(json['member']) : null,
      event = json['event'] != null ? Event.fromJson(json['event']) : null,
      bike = json['bike'] != null ? Bike.fromJson(json['bike']) : null,
      skippedSessions = json['skippedSessions'] != null
          ? (json['skippedSessions'] as Iterable).map((i) => EventSession.fromJson(i)).toList()
          : null,
      comment = json['comment'],
      createdOn = json['createdOn'] != null ? DateTime.parse(json['createdOn']) : null;

  /// Convert [EventMember] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
    "id": id.toString(),
    "member": member?.toJson(),
    "event": event?.toJson(),
    "bike": bike?.toJson(),
    "skippedSessions": skippedSessions?.map((i) => i.toJson()).toList(),
    "comment": comment,
    "createdOn": createdOn?.toIso8601String(),
  };
}
