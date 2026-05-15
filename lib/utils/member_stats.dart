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
import 'package:ccteam/models/event_member.dart';
import 'package:ccteam/models/record.dart';

/// Aggregated activity-derived stats for a single member, computed
/// from the [EventMember] list (and optionally the member's [Record]
/// list, for the km estimation that needs lap times).
///
/// Past-only (i.e. events whose `startDate` is in the past) so the
/// numbers stay meaningful: an event scheduled for next month is a
/// commitment, not a fact.
class MemberStatsUtils {
  MemberStatsUtils._();

  /// Number of past track events the member has attended.
  static int pastEventsCount({
    required List<EventMember>? eventMembers,
    required DateTime now,
  }) {
    if (eventMembers == null || eventMembers.isEmpty) return 0;
    int count = 0;
    for (final em in eventMembers) {
      final DateTime? start = em.event?.startDate;
      if (start == null) continue;
      if (start.isAfter(now)) continue;
      count++;
    }
    return count;
  }

  /// Sum of the registration prices for the member's past events,
  /// in EUR. Future commitments are intentionally excluded, the
  /// label that fronts this metric reads "dépensé" (past tense).
  static double totalSpent({
    required List<EventMember>? eventMembers,
    required DateTime now,
  }) {
    if (eventMembers == null || eventMembers.isEmpty) return 0.0;
    double total = 0.0;
    for (final em in eventMembers) {
      final Event? event = em.event;
      if (event == null) continue;
      final DateTime? start = event.startDate;
      if (start == null) continue;
      if (start.isAfter(now)) continue;
      final double? price = event.price;
      if (price == null) continue;
      total += price;
    }
    return total;
  }

  /// The track the member has rolled the most (highest number of
  /// past event registrations on that track). Returns `null` when
  /// the member has no past event with a known track.
  static MostRiddenTrack? mostRiddenTrack({
    required List<EventMember>? eventMembers,
    required DateTime now,
  }) {
    if (eventMembers == null || eventMembers.isEmpty) return null;
    // two parallel maps so we can rank by count *and* recover a human-friendly name for the winning track id.
    final Map<int, int> countsById = <int, int>{};
    final Map<int, String> namesById = <int, String>{};
    for (final em in eventMembers) {
      final Event? event = em.event;
      if (event == null) continue;
      final DateTime? start = event.startDate;
      if (start == null) continue;
      if (start.isAfter(now)) continue;
      final int? trackId = event.track?.id;
      final String? trackName = event.track?.name;
      if (trackId == null) continue;
      countsById.update(trackId, (v) => v + 1, ifAbsent: () => 1);
      if (trackName != null && trackName.isNotEmpty) {
        namesById.putIfAbsent(trackId, () => trackName);
      }
    }
    if (countsById.isEmpty) return null;
    MapEntry<int, int> best = countsById.entries.first;
    for (final entry in countsById.entries) {
      if (entry.value > best.value) best = entry;
    }
    final String? name = namesById[best.key];
    if (name == null) return null;
    return MostRiddenTrack(name: name, count: best.value);
  }

  /// Rough estimate of total kilometres ridden by the member across
  /// past events. Necessarily approximate, the app doesn't track
  /// laps per event, but grounded enough to give a meaningful
  /// "achievement" number on the profile.
  ///
  /// Heuristic, applied per past event:
  ///  1. **Sessions** : a full track day is treated as 6 × 20-minute
  ///     sessions. A short event (under 6 hours) is treated as a
  ///     half-day = 3 sessions. Anything longer is counted as
  ///     `ceil(hours / 24)` full days × 6 sessions.
  ///  2. **Laps per session** : `20 min / lap_time`. The lap time
  ///     used is the member's *own* best chrono on the circuit if any
  ///     (bumped by 2 % to model an average lap rather than the
  ///     personal best), else the track's overall lap record +15 %
  ///     (amateurs are typically slower than the recordman), else a
  ///     2-minute fallback so an event with no data still produces a
  ///     number.
  ///  3. **Distance** : `sessions × laps_per_session × track.distance`
  ///     then divided by 1000 to get km.
  static int estimateKm({
    required List<EventMember>? eventMembers,
    required Iterable<Record> records,
    required DateTime now,
  }) {
    if (eventMembers == null || eventMembers.isEmpty) return 0;

    int totalMeters = 0;

    for (final em in eventMembers) {
      final Event? event = em.event;
      if (event == null) continue;
      final DateTime? start = event.startDate;
      if (start == null) continue;
      if (start.isAfter(now)) continue;
      final track = event.track;
      if (track?.distance == null || track!.distance! <= 0) continue;

      // sessions, based on event duration
      final DateTime end = event.endDate ?? start;
      final int hours = end.difference(start).inHours;
      int sessions;
      if (hours < 6) {
        sessions = 3; // demi-journée
      } else {
        final int days = (hours / 24).ceil().clamp(1, 30);
        sessions = days * 6;
      }

      // lap time on this track: member's best chrono bumped by 2 %
      // for "average lap" feel, else track's record + 15 %, else 2-minute default
      int? lapMs;
      for (final r in records) {
        if (r.track?.id == track.id && r.lapTime != null) {
          if (lapMs == null || r.lapTime! < lapMs) lapMs = r.lapTime;
        }
      }
      if (lapMs != null) {
        lapMs = (lapMs * 1.02).round();
      } else if (track.lapRecord != null && track.lapRecord! > 0) {
        lapMs = (track.lapRecord! * 1.15).round();
      }
      lapMs ??= 120 * 1000;

      // 20 min = 1 200 000 ms — integer divide gives full laps
      final int lapsPerSession = (20 * 60 * 1000) ~/ lapMs;
      final int totalLaps = sessions * lapsPerSession;
      totalMeters += track.distance! * totalLaps;
    }

    return (totalMeters / 1000).round();
  }
}

/// Bundle returned by [MemberStatsUtils.mostRiddenTrack].
class MostRiddenTrack {
  const MostRiddenTrack({required this.name, required this.count});

  /// Display name of the track (e.g. "Bresse").
  final String name;

  /// Number of past event registrations on that track.
  final int count;
}
