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
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/track_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;

  /// Optional bike the *current viewer* has pinned to this event.
  final Bike? bike;

  EventCard(this.event, {this.bike});

  /// Short human-readable label for the pinned bike.
  String _bikeLabel(Bike b) {
    final String base = "${b.manufacturer?.toUpperCase() ?? ''} ${b.modelName ?? ''}".trim();
    if (b.year == null) return base.isEmpty ? '—' : base;
    if (base.isEmpty) return b.year!.toString();
    return "$base (${b.year})";
  }

  /// Two [DateTime]s share the same calendar day (ignoring time-of-day).
  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// Date overlay rendered on top of the track cover image. Picks one
  /// of four layouts depending on whether the event spans a single
  /// day, multiple days of the same month, multiple months of the
  /// same year, or two different years.
  ///
  /// Visual rules across all layouts:
  ///  - white text with subtle shadow handled by the parent overlay,
  ///  - column width is constrained to the 90 px image column, so
  ///    longer lines (like "27 - 31") use [FittedBox] to scale down
  ///    rather than overflow.
  Widget _buildDateOverlay() {
    final DateTime start = event.startDate ?? DateTime.now();
    final DateTime? end = event.endDate;

    // single day or missing end → the original stacked display
    if (end == null || _sameDay(start, end)) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            DateFormat('dd', 'fr').format(start),
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.0),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('MMM', 'fr').format(start),
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.0),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('yyyy', 'fr').format(start),
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.0),
          ),
        ],
      );
    }

    // multi-day, same month & year → "27 - 31" / "Oct." / "2025"
    if (start.year == end.year && start.month == end.month) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${start.day} - ${end.day}',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.0),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('MMM', 'fr').format(start),
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.0),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('yyyy', 'fr').format(start),
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.0),
          ),
        ],
      );
    }

    // multi-day, same year, different months → "27 oct." / "→ 02 nov." / "2025"
    if (start.year == end.year) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${start.day} ${DateFormat('MMM', 'fr').format(start)}',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.0),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '→ ${end.day} ${DateFormat('MMM', 'fr').format(end)}',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.0),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('yyyy', 'fr').format(start),
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.0),
          ),
        ],
      );
    }

    // different years → full dates on two lines, no shared year footer
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            DateFormat('dd MMM yy', 'fr').format(start),
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, height: 1.0),
          ),
        ),
        const SizedBox(height: 2),
        const Text('→', style: TextStyle(color: Colors.white, fontSize: 12, height: 1.0)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            DateFormat('dd MMM yy', 'fr').format(end),
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, height: 1.0),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: IntrinsicHeight(
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // image with date overlay (full card height)
                  SizedBox(
                    width: 90,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(TrackUtils.trackCoverImageUrlFromName(event.track?.name), fit: BoxFit.cover),
                        // dark overlay for date readability
                        Container(color: Colors.black.withValues(alpha: 0.4)),
                        // stacked date (single day or range, see helper)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: _buildDateOverlay(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // right side info column
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // title (with right padding to leave room for chip)
                          Padding(
                            padding: const EdgeInsets.only(right: 56.0),
                            child: Text(
                              event.title ?? "",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: Colors.red[700]),
                              SizedBox(width: 4.0),
                              Expanded(
                                child: Text(
                                  event.track?.name ?? "",
                                  style: TextStyle(color: Colors.white, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.0),
                          Row(
                            children: [
                              Icon(Icons.perm_contact_calendar, size: 14, color: Colors.teal[700]),
                              SizedBox(width: 4.0),
                              Expanded(
                                child: Text(
                                  event.organizer?.name ?? "",
                                  style: TextStyle(color: Colors.white, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Icon(Icons.euro_symbol, size: 14, color: Colors.purple[700]),
                              SizedBox(width: 4.0),
                              Text(
                                "${StringUtils.formatPrice(event.price ?? 0.0)}€",
                                style: TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                          // row only present when the viewer has pinned a bike to this participation
                          if (bike != null) ...[
                            SizedBox(height: 2.0),
                            Row(
                              children: [
                                Icon(CustomIcons.motorbike_plain, size: 14, color: Colors.blue[800]),
                                SizedBox(width: 4.0),
                                Expanded(
                                  child: Text(
                                    _bikeLabel(bike!),
                                    style: TextStyle(color: Colors.white, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // participant count chip - top right
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (event.participants != null && event.participants!.length > 1) ? Icons.group : Icons.person,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text("${event.participants?.length ?? 0}", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
