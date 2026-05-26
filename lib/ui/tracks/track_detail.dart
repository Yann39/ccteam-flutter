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
import 'package:ccteam/models/record.dart';
import 'package:ccteam/models/track.dart';
import 'package:ccteam/providers/event_detail_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/record_detail_provider.dart';
import 'package:ccteam/providers/record_list_provider.dart';
import 'package:ccteam/providers/track_creation_provider.dart';
import 'package:ccteam/providers/track_detail_provider.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/utils/track_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TrackDetail extends StatefulWidget {
  const TrackDetail({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TrackDetailState();
  }
}

class _TrackDetailState extends State<TrackDetail> {
  /// Pagination of the events list (5 events per page, newest first).
  static const int _eventsPageSize = 5;
  int _eventsPage = 0;

  /// Pagination of the records list (5 records per page).
  static const int _recordsPageSize = 5;
  int _recordsPage = 0;

  @override
  void initState() {
    super.initState();
    // synchronously clear any stale data and mark the lists as "loading"
    // so the very first frame of this page shows loaders instead of the
    // previously visited track's events / records
    Provider.of<EventDetailProvider>(context, listen: false).clearAllEvents();
    Provider.of<RecordListProvider>(context, listen: false).clearTrackRecords();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final TrackDetailProvider trackDetailProvider = Provider.of<TrackDetailProvider>(context, listen: false);
      if (trackDetailProvider.currentTrack != null) {
        final int trackId = trackDetailProvider.currentTrack!.id!;
        Provider.of<EventDetailProvider>(context, listen: false).fetchEventsByTrack(trackDetailProvider.currentTrack!);
        Provider.of<RecordListProvider>(context, listen: false).fetchTrackRecords(trackId);
      }
    });
  }

  /// A small "loading" card that visually replaces the events / records
  /// table while their data is being fetched.
  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28.0),
      decoration: CustomDecorations.cardLight,
      child: Center(
        child: SizedBox(
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          ),
        ),
      ),
    );
  }

  /// Slim placeholder card that replaces the events / chronos table for ROLE_USER callers.
  Widget _buildMembersOnlyPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: CustomDecorations.cardLight,
      child: Row(
        children: <Widget>[
          Icon(Icons.lock_outline, size: 18.0, color: Colors.black.withAlpha(160)),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              AppString.contentReservedForMembers,
              style: TextStyle(color: Colors.black.withAlpha(180), fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recordsTable(RecordListProvider recordListProvider) {
    if (recordListProvider.loadingStatus == LoadingStatus.loading) {
      return _buildLoadingCard();
    }
    if (recordListProvider.trackRecords.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12.0),
        decoration: CustomDecorations.cardLight,
        child: Text(AppString.trackNoChrono),
      );
    }

    // sort by lap time ascending (fastest first); records without a lap
    // time go last
    final List<Record> records = List<Record>.of(recordListProvider.trackRecords)
      ..sort((a, b) {
        final int? aLap = a.lapTime;
        final int? bLap = b.lapTime;
        if (aLap == null && bLap == null) return 0;
        if (aLap == null) return 1;
        if (bLap == null) return -1;
        return aLap.compareTo(bLap);
      });

    // compute pagination, clamping the current page if the list shrank
    final int totalPages = (records.length / _recordsPageSize).ceil().clamp(1, 1 << 30);
    final int currentPage = _recordsPage.clamp(0, totalPages - 1);
    final int start = currentPage * _recordsPageSize;
    final int end = (start + _recordsPageSize).clamp(0, records.length);
    final List<Record> pageRecords = records.sublist(start, end);

    // fastest lap time used as the reference to compute the gap displayed
    // on every other row (records are sorted ascending so it's the first
    // record with a non-null lap time, regardless of pagination)
    final int? fastestLapTime = records.firstWhere((r) => r.lapTime != null, orElse: () => records.first).lapTime;

    return Container(
      decoration: CustomDecorations.cardLight,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // record rows
          for (int i = 0; i < pageRecords.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: Colors.black.withValues(alpha: 0.10)),
            _buildRecordRow(pageRecords[i], fastestLapTime),
          ],
          // pagination footer (rendered as part of the same card)
          if (totalPages > 1)
            _buildPaginationFooter(
              currentPage: currentPage,
              totalPages: totalPages,
              onPageChanged: (p) => setState(() => _recordsPage = p),
            ),
        ],
      ),
    );
  }

  /// Navigate to the detail screen of the specified [event].
  void _navigateToEventDetailScreen(Event event) {
    Provider.of<EventDetailProvider>(
      context,
      listen: false,
    ).fetchEvent(event).then((value) => Navigator.pushNamed(context, '/eventDetail'));
  }

  /// Build a single track-stat card (lap record, length, GPS) used in the
  /// row at the top of the track detail page. Reproduces the original card
  /// look (cardLight decoration, large icon at the top, bold label,
  /// value below) with the whole content vertically centered.
  ///
  /// [iconColor] lets the caller pick a distinct accent color per card.
  ///
  /// If [onTap] is provided, the card becomes tappable and a small
  /// "outward" arrow is shown in the top-right corner to hint at the
  /// external link.
  /// Build a single track-stat card.
  ///
  /// Three interaction modes, mutually exclusive (in priority order):
  ///  1. [infoOnTap] set → the whole card is tappable; tapping it
  ///     fires the callback (typically opens a modal bottom sheet
  ///     with contextual details).
  ///  2. [onTap] set → the whole card is tappable and a "↗" hint is
  ///     drawn in the top-right corner. Used for cards that link out
  ///     (GPS, website, …).
  ///  3. Neither → the card is purely informational (no ripple, no
  ///     corner hint).
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Widget value,
    VoidCallback? onTap,
    VoidCallback? infoOnTap,
  }) {
    // info mode wins over external-link mode (we expect callers to use only one)
    final VoidCallback? effectiveOnTap = infoOnTap ?? onTap;
    final IconData? cornerIcon = infoOnTap != null ? Icons.info_outline : (onTap != null ? Icons.arrow_outward : null);

    final Widget content = Container(
      height: 106,
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: CustomDecorations.cardLight,
      child: Stack(
        children: <Widget>[
          // top-right hint icon — ⓘ for info-sheet mode, ↗ for external-link mode
          if (cornerIcon != null)
            Positioned(top: 0, right: 0, child: Icon(cornerIcon, size: 14.0, color: iconColor.withValues(alpha: 0.7))),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 30, color: iconColor),
                const SizedBox(height: 4.0),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4.0),
                DefaultTextStyle.merge(
                  style: const TextStyle(color: Colors.black87),
                  textAlign: TextAlign.center,
                  child: value,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final Widget result = effectiveOnTap != null ? InkWell(onTap: effectiveOnTap, child: content) : content;

    return Expanded(flex: 1, child: result);
  }

  /// Format an absolute gap (in ms) as a compact lap-time delta, e.g.
  /// `+2"456` for 2.456 s, `+1'03"010` for 1 min 3.010 s. Leading
  /// zeros are stripped on the minute side so short gaps stay
  /// visually light. Always prefixed with `+` because the caller
  /// guarantees this is called only when the member is slower than
  /// the record holder.
  String _formatLapGap(int gapMs) {
    final int m = gapMs ~/ 60000;
    final int s = (gapMs % 60000) ~/ 1000;
    final int ms = gapMs % 1000;
    final String mmm = ms.toString().padLeft(3, '0');
    if (m > 0) {
      final String ss = s.toString().padLeft(2, '0');
      return '+$m\'$ss"$mmm';
    }
    return '+$s"$mmm';
  }

  /// Show a Material-3 styled modal bottom sheet with the lap-record
  /// context (date, rider, bike, conditions, …) plus, when available,
  /// the logged member's own best chrono on this track and the gap
  /// to the record.
  ///
  /// Visual language mirrors the palette picker (gradient blue
  /// background, rounded top, drag handle) so it feels native to the
  /// app rather than a generic system overlay.
  ///
  /// [recordLapTimeStr] is pre-formatted with the AlarmClock font
  /// like on the card itself so the user sees the same number, just
  /// larger. [recordLapTimeMs] is needed to compute the gap.
  /// [info] is the free-text context — typically year, name, motorcycle.
  /// [memberLapTimeMs] is the logged member's best on this track,
  /// `null` if they have no chrono recorded (we then skip the
  /// "your chrono" section entirely rather than show "—").
  void _showLapRecordInfoSheet(
    BuildContext context, {
    required String recordLapTimeStr,
    required int recordLapTimeMs,
    required String info,
    int? memberLapTimeMs,
  }) {
    // Compute the gap up-front so the builder body stays readable.
    // Two distinct UI paths: member faster-or-equal than record vs
    // strictly slower. The "faster" branch shouldn't normally happen
    // (it'd mean the lap-record column is stale), but treating it as
    // "you hold the record" is the least surprising fallback.
    final String? memberLapTimeStr = memberLapTimeMs != null ? AppDateUtils.toLapTimeString(memberLapTimeMs) : null;
    final int? gapMs = memberLapTimeMs != null ? memberLapTimeMs - recordLapTimeMs : null;
    final bool memberHoldsRecord = gapMs != null && gapMs <= 0;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (BuildContext sheetCtx) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[100]!, Colors.blue[200]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  // header row: icon + title
                  Row(
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue[700]!.withValues(alpha: 0.15),
                        ),
                        child: Icon(Icons.timer, color: Colors.blue[700], size: 22.0),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          AppString.lapRecord,
                          style: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // lap-time
                  Center(
                    child: Text(
                      recordLapTimeStr,
                      style: const TextStyle(
                        fontFamily: "AlarmClock",
                        fontSize: 38.0,
                        letterSpacing: -1.5,
                        height: 1.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // thin separator between the figure and the context text
                  Container(height: 1, color: Colors.black.withValues(alpha: 0.12)),
                  const SizedBox(height: 14.0),
                  Text(info, style: TextStyle(fontSize: 13.5, color: Colors.black.withAlpha(204), height: 1.35)),
                  // Member's own chrono on this track, when available.
                  // Rendered as a small card-in-card with a subtle white
                  // background so it has its own visual identity without
                  // competing with the hero record figure above.
                  if (memberLapTimeStr != null) ...[
                    const SizedBox(height: 16.0),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.white, width: 1.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(Icons.person_outline, size: 16.0, color: Colors.blue[700]),
                              const SizedBox(width: 6.0),
                              Text(
                                AppString.yourBestChrono,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black.withAlpha(160),
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: <Widget>[
                              Text(
                                memberLapTimeStr,
                                style: const TextStyle(
                                  fontFamily: "AlarmClock",
                                  fontSize: 22.0,
                                  letterSpacing: -1,
                                  height: 1.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              if (memberHoldsRecord)
                                Text(
                                  AppString.youHoldTheRecord,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              else
                                Expanded(
                                  child: Text(
                                    "${_formatLapGap(gapMs!)} ${AppString.fromRecord}",
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black.withAlpha(160),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build the pagination footer rendered at the bottom of a paginated
  /// card (events list, records list, …). Renders a divider, a soft
  /// grey background and prev / page-indicator / next controls.
  Widget _buildPaginationFooter({
    required int currentPage,
    required int totalPages,
    required ValueChanged<int> onPageChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Divider(height: 1, thickness: 1, color: Colors.black.withValues(alpha: 0.15)),
        Container(
          color: Colors.black.withValues(alpha: 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.chevron_left),
                iconSize: 22,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                color: Colors.black.withValues(alpha: 0.8),
                onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
              ),
              const SizedBox(width: 8.0),
              Text(
                "${currentPage + 1} / $totalPages",
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.8),
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                iconSize: 22,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                color: Colors.black.withValues(alpha: 0.8),
                onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build a compact colored date "block" displayed on the left of each
  /// event row.
  Widget _buildDateBlock(Event event) {
    final DateTime? date = event.startDate;
    return Container(
      width: 46,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(color: Colors.blue[700], borderRadius: BorderRadius.circular(6.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            date != null ? DateFormat('dd', 'fr').format(date) : "?",
            style: const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold, height: 1.0),
          ),
          const SizedBox(height: 1.0),
          Text(
            date != null ? DateFormat('MMM', 'fr').format(date).toUpperCase() : "—",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.0,
              fontWeight: FontWeight.w600,
              height: 1.0,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 1.0),
          Text(
            date != null ? DateFormat('yyyy', 'fr').format(date) : "",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 9.0, height: 1.0),
          ),
        ],
      ),
    );
  }

  /// Build a single event row: date block on the left, organizer + price in
  /// the middle, participants chip on the right. The whole row is tappable
  /// and navigates to the event detail screen.
  Widget _buildEventRow(Event event) {
    final int participantsCount = event.participants?.length ?? 0;

    return InkWell(
      onTap: () => _navigateToEventDetailScreen(event),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildDateBlock(event),
            const SizedBox(width: 12.0),
            // organizer + price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    (event.organizer?.name != null && event.organizer!.name!.isNotEmpty) ? event.organizer!.name! : "—",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2.0),
                  Row(
                    children: <Widget>[
                      Icon(Icons.euro_symbol, size: 12.0, color: Colors.purple[700]),
                      const SizedBox(width: 2.0),
                      Text(
                        StringUtils.formatPrice(event.price ?? 0.0),
                        style: TextStyle(color: Colors.black.withValues(alpha: 0.75), fontSize: 12.0, height: 1.1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            // participants chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(participantsCount > 1 ? Icons.group : Icons.person, size: 12.0, color: Colors.blue[700]),
                  const SizedBox(width: 3.0),
                  Text(
                    "$participantsCount",
                    style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 12.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a single chrono (record) row: member name on top, lap time +
  /// date below, weather icon on the right.
  /// Format a [Bike] for display in a chrono row, e.g.
  /// "KAWASAKI ZX-10R". Returns null if the bike has no manufacturer
  /// nor model.
  String? _bikeText(Bike? bike) {
    if (bike == null) return null;
    final String manufacturer = (bike.manufacturer ?? "").trim();
    final String model = (bike.modelName ?? "").trim();
    final String text = [
      if (manufacturer.isNotEmpty) manufacturer.toUpperCase(),
      if (model.isNotEmpty) model,
    ].join(" ");
    return text.isEmpty ? null : text;
  }

  /// Small rider-number badge (e.g. "#46") shown next to the pilot name.
  Widget _riderNumberBadge(int number) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(3.0)),
      child: Text(
        "#$number",
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.75),
          fontSize: 11.0,
          fontWeight: FontWeight.bold,
          height: 1.1,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  /// Small icon + text pair used for chrono row metadata (bike, date).
  Widget _chronoMetaItem(IconData icon, Color iconColor, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 11.0, color: iconColor),
        const SizedBox(width: 3.0),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: Colors.black.withValues(alpha: 0.7), fontSize: 12.0, height: 1.1),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  /// Format a lap-time gap (in milliseconds) as e.g. "+1.234".
  String _formatGap(int gapMs) {
    final double seconds = gapMs / 1000.0;
    return "+${seconds.toStringAsFixed(3)}";
  }

  Widget _buildRecordRow(Record record, int? fastestLapTime) {
    final String memberName = record.member != null
        ? "${record.member!.firstName ?? ""} ${record.member!.lastName ?? ""}".trim()
        : "—";
    final int? riderNumber = record.member?.riderNumber;
    final String lapTime = AppDateUtils.toLapTimeString(record.lapTime) ?? "";
    // Display the bike used for this record if available, otherwise fall
    // back to the member's currently marked bike.
    Bike? displayBike = record.bike;
    if (displayBike == null && record.member?.bikes != null) {
      final List<Bike> memberBikes = record.member!.bikes!;
      if (memberBikes.isNotEmpty) {
        displayBike = memberBikes.firstWhere((b) => b.current ?? false, orElse: () => memberBikes.first);
      }
    }
    final String? bikeStr = _bikeText(displayBike);

    // gap with the fastest record (only shown when this record is not the fastest itself and both lap times are known)
    final bool isFastest = record.lapTime != null && fastestLapTime != null && record.lapTime == fastestLapTime;
    final int? gapMs = (record.lapTime != null && fastestLapTime != null && !isFastest)
        ? record.lapTime! - fastestLapTime
        : null;

    // tap → open the chrono detail page
    return InkWell(
      onTap: () {
        Provider.of<RecordDetailProvider>(context, listen: false).setCurrentRecord(record);
        Navigator.pushNamed(context, '/chronoDetail');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // lap time pill + gap-with-leader caption underneath
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(color: Colors.blue[700], borderRadius: BorderRadius.circular(5.0)),
                  child: Text(
                    lapTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontFamily: "AlarmClock",
                      letterSpacing: -1.0,
                      height: 1.0,
                    ),
                  ),
                ),
                if (gapMs != null) ...[
                  const SizedBox(height: 2.0),
                  Text(
                    _formatGap(gapMs),
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 10.0),
            // pilot name (+ rider number) on top, bike below
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          memberName,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (riderNumber != null) ...[const SizedBox(width: 6.0), _riderNumberBadge(riderNumber)],
                    ],
                  ),
                  if (bikeStr != null) ...[
                    const SizedBox(height: 2.0),
                    _chronoMetaItem(CustomIcons.motorbike_plain, Colors.deepPurple, bikeStr),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6.0),
            // weather icon on the right
            Icon(
              record.conditions == "dry" ? Icons.wb_sunny : CustomIcons.rain,
              color: record.conditions == "dry" ? Colors.orange[600] : Colors.blueGrey[400],
              size: 16.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventsTable(EventDetailProvider eventDetailProvider) {
    if (eventDetailProvider.eventsByTrackLoadingStatus == LoadingStatus.loading) {
      return _buildLoadingCard();
    }
    if (eventDetailProvider.allEvents.isEmpty) {
      return Container(
        padding: EdgeInsets.all(12.0),
        decoration: CustomDecorations.cardLight,
        child: Text(AppString.trackNoEvent),
      );
    }

    // sort events by start date, most recent first (events without a date go last)
    final List<Event> sortedEvents = List<Event>.of(eventDetailProvider.allEvents)
      ..sort((a, b) {
        final DateTime? aDate = a.startDate;
        final DateTime? bDate = b.startDate;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

    // compute pagination, clamping the current page if the list shrank
    final int totalPages = (sortedEvents.length / _eventsPageSize).ceil().clamp(1, 1 << 30);
    final int currentPage = _eventsPage.clamp(0, totalPages - 1);
    final int start = currentPage * _eventsPageSize;
    final int end = (start + _eventsPageSize).clamp(0, sortedEvents.length);
    final List<Event> pageEvents = sortedEvents.sublist(start, end);

    return Container(
      decoration: CustomDecorations.cardLight,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // event rows
          for (int i = 0; i < pageEvents.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: Colors.black.withValues(alpha: 0.10)),
            _buildEventRow(pageEvents[i]),
          ],
          // pagination footer (rendered as part of the same card)
          if (totalPages > 1)
            _buildPaginationFooter(
              currentPage: currentPage,
              totalPages: totalPages,
              onPageChanged: (p) => setState(() => _eventsPage = p),
            ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    final RecordListProvider _recordListProvider = Provider.of<RecordListProvider>(context, listen: true);
    final TrackDetailProvider _trackDetailProvider = Provider.of<TrackDetailProvider>(context, listen: true);
    final EventDetailProvider _eventDetailProvider = Provider.of<EventDetailProvider>(context, listen: true);
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    // if currentTrack is null (e.g. after session expiration), don't render content
    if (_trackDetailProvider.currentTrack == null) {
      return Scaffold(body: Container(decoration: CustomDecorations.mainContent));
    }

    return Scaffold(
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              actions: <Widget>[
                if (_trackDetailProvider.currentTrack?.website != null &&
                    _trackDetailProvider.currentTrack!.website!.isNotEmpty)
                  IconButton(
                    tooltip: "Site web",
                    icon: const Icon(Icons.public, color: Colors.white),
                    onPressed: () => AppUtils.launchURL(_trackDetailProvider.currentTrack!.website!),
                  ),
                if (_loginProvider.isAdmin)
                  IconButton(
                    tooltip: AppString.trackEdit,
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      // deep-clone so cancelling the form doesn't mutate the track held by TrackDetailProvider / TrackListProvider
                      Provider.of<TrackCreationProvider>(
                        context,
                        listen: false,
                      ).setTrackToEdit(Track.clone(_trackDetailProvider.currentTrack!));
                      Navigator.pushNamed(context, '/addEditTrack');
                    },
                  ),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final FlexibleSpaceBarSettings settings = context
                      .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
                  final double deltaExtent = settings.maxExtent - settings.minExtent;
                  final double t = (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent).clamp(0.0, 1.0);

                  // t is 0.0 when completely deployed, 1.0 when completely collapsed
                  // smoothly fade the country line out as the header collapses,
                  // so it never overlaps the standard AppBar title
                  final double countryOpacity = ((1.0 - t * 2.0).clamp(0.0, 1.0)).toDouble();
                  final track = _trackDetailProvider.currentTrack;
                  final bool showCountry = track?.country != null && countryOpacity > 0.0;
                  return FlexibleSpaceBar(
                    // shift the title to the right of the circular badge
                    // when expanded; slide it back to the standard AppBar
                    // position as the header collapses
                    titlePadding: EdgeInsetsDirectional.only(start: 90.0 - t * 30.0, bottom: 16.0),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          track != null ? (track.name ?? "") : "",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: t < 0.5
                                ? const [Shadow(offset: Offset(1.0, 1.0), blurRadius: 3.0, color: Colors.black)]
                                : null,
                          ),
                        ),
                        if (showCountry)
                          Opacity(
                            opacity: countryOpacity,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                "${track!.country!.flagEmoji}  ${track.country!.localizedName(Localizations.localeOf(context).languageCode)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.normal,
                                  height: 1.1,
                                  shadows: [Shadow(offset: Offset(1.0, 1.0), blurRadius: 3.0, color: Colors.black)],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    background: Stack(
                      alignment: Alignment.bottomLeft,
                      fit: StackFit.expand,
                      children: <Widget>[
                        _trackDetailProvider.currentTrack != null
                            ? Image.asset(
                                TrackUtils.trackCoverImageUrlFromName(_trackDetailProvider.currentTrack!.name),
                                fit: BoxFit.fitWidth,
                              )
                            : Container(),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.0, 0.5),
                              end: Alignment(0.0, -0.5),
                              colors: <Color>[
                                Colors.black.withAlpha(179),
                                Colors.black.withAlpha(76),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // circular badge with the track-shape silhouette,
                        // anchored to the bottom-left, fading out as the
                        // header collapses
                        if (_trackDetailProvider.currentTrack != null)
                          Positioned(
                            bottom: 12.0,
                            left: 12.0,
                            child: Opacity(
                              opacity: (1.0 - t * 1.5).clamp(0.0, 1.0).toDouble(),
                              child: Container(
                                width: 64.0,
                                height: 64.0,
                                padding: const EdgeInsets.all(8.0),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: CircleBorder(
                                    side: BorderSide(color: Colors.white.withValues(alpha: 0.9), width: 2.0),
                                  ),
                                  shadows: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 6.0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: TrackUtils.getTrackIcon(_trackDetailProvider.currentTrack!.name ?? ""),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(12.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                () {
                                  final int? recordLapTimeMs = _trackDetailProvider.currentTrack!.lapRecord;
                                  final String? lapTimeStr = AppDateUtils.toLapTimeString(recordLapTimeMs);
                                  final String? info = _trackDetailProvider.currentTrack!.lapRecordInfo;
                                  final bool hasInfo =
                                      info != null && info.isNotEmpty && lapTimeStr != null && recordLapTimeMs != null;
                                  int? memberLapTimeMs;
                                  final int? loggedMemberId = _loginProvider.loggedMember?.id;
                                  if (loggedMemberId != null) {
                                    for (final Record r in _recordListProvider.trackRecords) {
                                      if (r.member?.id != loggedMemberId) continue;
                                      if (r.lapTime == null) continue;
                                      if (memberLapTimeMs == null || r.lapTime! < memberLapTimeMs) {
                                        memberLapTimeMs = r.lapTime;
                                      }
                                    }
                                  }
                                  return _buildStatCard(
                                    icon: Icons.timer,
                                    iconColor: Colors.blue[700]!,
                                    label: AppString.lapRecord,
                                    value: Text(
                                      lapTimeStr ?? "—",
                                      style: const TextStyle(
                                        fontFamily: "AlarmClock",
                                        fontSize: 14.0,
                                        letterSpacing: -1,
                                        height: 1.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    infoOnTap: hasInfo
                                        ? () => _showLapRecordInfoSheet(
                                            context,
                                            recordLapTimeStr: lapTimeStr,
                                            recordLapTimeMs: recordLapTimeMs,
                                            info: info,
                                            memberLapTimeMs: memberLapTimeMs,
                                          )
                                        : null,
                                  );
                                }(),
                                _buildStatCard(
                                  icon: Icons.straighten,
                                  iconColor: Colors.teal[600]!,
                                  label: AppString.length,
                                  value: Text(
                                    _trackDetailProvider.currentTrack!.distance != null
                                        ? "${_trackDetailProvider.currentTrack!.distance} m"
                                        : "—",
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                _buildStatCard(
                                  icon: Icons.place,
                                  iconColor: Colors.red[700]!,
                                  label: "GPS",
                                  value: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        _trackDetailProvider.currentTrack!.latitude != null
                                            ? _trackDetailProvider.currentTrack!.latitude!.toStringAsFixed(4)
                                            : "—",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          height: 1.1,
                                          fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                                        ),
                                      ),
                                      Text(
                                        _trackDetailProvider.currentTrack!.longitude != null
                                            ? _trackDetailProvider.currentTrack!.longitude!.toStringAsFixed(4)
                                            : "—",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          height: 1.1,
                                          fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap:
                                      _trackDetailProvider.currentTrack!.latitude != null &&
                                          _trackDetailProvider.currentTrack!.longitude != null
                                      ? () => AppUtils.launchURL(
                                          "https://www.google.com/maps/search/?api=1&query=${_trackDetailProvider.currentTrack!.latitude},${_trackDetailProvider.currentTrack!.longitude}",
                                        )
                                      : null,
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Icon(Icons.description, size: 16, color: Colors.black.withAlpha(204)),
                                SizedBox(width: 5.0),
                                Text(
                                  AppString.trackEvents,
                                  textScaler: TextScaler.linear(1.2),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withAlpha(204)),
                                ),
                                SizedBox(width: 4.0),
                                Text(
                                  "(${_eventDetailProvider.allEvents.length})",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black.withAlpha(204),
                                    fontSize: 11.0,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            _loginProvider.isMember
                                ? _eventsTable(_eventDetailProvider)
                                : _buildMembersOnlyPlaceholder(),
                            SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Icon(Icons.group, size: 18, color: Colors.black.withAlpha(163)),
                                SizedBox(width: 5.0),
                                Text(
                                  AppString.chronos,
                                  textScaler: TextScaler.linear(1.2),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withAlpha(163)),
                                ),
                                SizedBox(width: 4.0),
                                Text(
                                  "(${_recordListProvider.trackRecords.length})",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black.withAlpha(163),
                                    fontSize: 11.0,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            _loginProvider.isMember
                                ? _recordsTable(_recordListProvider)
                                : _buildMembersOnlyPlaceholder(),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 16.0),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
