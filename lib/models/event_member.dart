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

import 'package:ccteam/models/event.dart';
import 'package:ccteam/models/member.dart';

/// Class representing an event participant
class EventMember {
  int? id;
  Member? member;
  Event? event;
  DateTime? createdOn;

  EventMember({
    this.id,
    this.member,
    this.event,
    this.createdOn,
  });

  @override
  String toString() {
    return """{
      id: ${this.id.toString()},
      members: ${this.member.toString()},
      members: ${this.event.toString()},
      createdOn: ${this.createdOn?.toIso8601String()},
    }""";
  }

  /// Convert [json] map to the corresponding object
  EventMember.fromJson(Map<String, dynamic> json)
      : id = json['id'] != null ? int.parse(json['id']) : null,
        member = json['member'] != null ? Member.fromJson(json['member']) : null,
        event = json['event'] != null ? Event.fromJson(json['event']) : null,
        createdOn = json['createdOn'] != null ? DateTime.parse(json['createdOn']) : null;

  /// Convert [EventMember] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
        "id": id.toString(),
        "member": member?.toJson(),
        "event": event?.toJson(),
        "createdOn": createdOn?.toIso8601String(),
      };
}
