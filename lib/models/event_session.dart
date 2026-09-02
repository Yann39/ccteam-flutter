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

/// A single track session of an event, e.g. one 20-minute run.
///
/// The schedule is entered by an admin as groups ("5 sessions of 20 min,
/// then 1 of 25"), but stored and exposed flat, one entry per session, so
/// that a participant can tick the individual sessions they actually rode.
class EventSession {
  int? id;

  /// 1-based rank of the session within the event day.
  int? position;

  /// Duration of the session, in minutes.
  int? durationMinutes;

  EventSession({this.id, this.position, this.durationMinutes});

  @override
  String toString() => "{ id: ${id.toString()}, position: $position, durationMinutes: $durationMinutes }";

  EventSession.fromJson(Map<String, dynamic> json)
    : id = json['id'] != null ? int.parse(json['id'].toString()) : null,
      position = json['position'],
      durationMinutes = json['durationMinutes'];

  Map<String, dynamic> toJson() => {"id": id?.toString(), "position": position, "durationMinutes": durationMinutes};

  /// Sessions are identified by their database id, so a session can be
  /// looked up in a participant's skipped list regardless of which copy
  /// of the object the caller holds.
  @override
  bool operator ==(Object other) => other is EventSession && other.id != null && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// A group of identical sessions, the way a track day is described out
/// loud ("5 sessions of 20 minutes"). Used to enter and display a
/// schedule compactly, never stored as such.
class EventSessionGroup {
  int count;
  int durationMinutes;

  EventSessionGroup({required this.count, required this.durationMinutes});

  @override
  String toString() => "{ count: $count, durationMinutes: $durationMinutes }";

  Map<String, dynamic> toJson() => {"count": count, "durationMinutes": durationMinutes};

  /// Collapse an ordered list of [sessions] back into the groups it was
  /// entered as, merging consecutive sessions of equal duration.
  static List<EventSessionGroup> fromSessions(List<EventSession>? sessions) {
    final List<EventSessionGroup> groups = [];
    if (sessions == null) return groups;
    for (final EventSession session in sessions) {
      final int? duration = session.durationMinutes;
      if (duration == null) continue;
      if (groups.isNotEmpty && groups.last.durationMinutes == duration) {
        groups.last.count++;
      } else {
        groups.add(EventSessionGroup(count: 1, durationMinutes: duration));
      }
    }
    return groups;
  }
}
