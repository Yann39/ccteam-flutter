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

/// Class representing a member track lap record
class Record {
  int id;
  Track track;
  Member member;
  int lapTime;
  DateTime recordDate;
  String conditions;
  String comments;
  DateTime createdOn;
  DateTime modifiedOn;

  Record({
    this.id,
    this.track,
    this.member,
    this.lapTime,
    this.recordDate,
    this.conditions,
    this.comments,
    this.createdOn,
    this.modifiedOn,
  });

  @override
  String toString() {
    return """{
      id: ${this.id},
      track: ${this.track.toString()},
      member: ${this.member.toString()},
      lapTime: ${this.lapTime},
      recordDate: ${this.recordDate?.toIso8601String()},
      conditions: ${this.conditions},
      comments: ${this.comments},
      createdOn: ${this.createdOn?.toIso8601String()},
      modifiedOn: ${this.modifiedOn?.toIso8601String()},
    }""";
  }

  /// Convert [json] map to the corresponding object
  Record.fromJson(Map<String, dynamic> json)
      : id = json['id'] != null ? int.parse(json['id']) : -1,
        track = Track.fromJson(json['track']),
        member = Member.fromJson(json['member']),
        lapTime = json['lapTime'] != null ? int.parse(json['lapTime']) : null,
        recordDate = json['recordDate'] != null ? DateFormat("yyyy-MM-dd").parseStrict(json['recordDate']) : null,
        conditions = json['conditions'],
        comments = json['comments'],
        createdOn = json['createdOn'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['createdOn']) : null,
        modifiedOn =
            json['modifiedOn'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['modifiedOn']) : null;

  /// Convert [Record] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
        "id": id,
        "track": track?.toJson(),
        "member": member?.toJson(),
        "lapTime": lapTime,
        "recordDate": recordDate?.toIso8601String(),
        "conditions": conditions,
        "comments": comments,
        "createdOn": createdOn?.toIso8601String(),
        "modifiedOn": createdOn?.toIso8601String(),
      };
}
