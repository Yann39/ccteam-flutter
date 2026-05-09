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
import 'package:ccteam/providers/event_detail_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/record_list_provider.dart';
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
    Provider.of<EventDetailProvider>(
      context,
      listen: false,
    ).clearAllEvents();
    Provider.of<RecordListProvider>(
      context,
      listen: false,
    ).clearTrackRecords();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final TrackDetailProvider trackDetailProvider =
          Provider.of<TrackDetailProvider>(context, listen: false);
      if (trackDetailProvider.currentTrack != null) {
        final int trackId = trackDetailProvider.currentTrack!.id!;
        Provider.of<EventDetailProvider>(
          context,
          listen: false,
        ).fetchEventsByTrack(trackDetailProvider.currentTrack!);
        Provider.of<RecordListProvider>(
          context,
          listen: false,
        ).fetchTrackRecords(trackId);
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
    final List<Record> records =
        List<Record>.of(recordListProvider.trackRecords)
          ..sort((a, b) {
            final int? aLap = a.lapTime;
            final int? bLap = b.lapTime;
            if (aLap == null && bLap == null) return 0;
            if (aLap == null) return 1;
            if (bLap == null) return -1;
            return aLap.compareTo(bLap);
          });

    // compute pagination, clamping the current page if the list shrank
    final int totalPages =
        (records.length / _recordsPageSize).ceil().clamp(1, 1 << 30);
    final int currentPage = _recordsPage.clamp(0, totalPages - 1);
    final int start = currentPage * _recordsPageSize;
    final int end = (start + _recordsPageSize).clamp(0, records.length);
    final List<Record> pageRecords = records.sublist(start, end);

    // fastest lap time used as the reference to compute the gap displayed
    // on every other row (records are sorted ascending so it's the first
    // record with a non-null lap time, regardless of pagination)
    final int? fastestLapTime = records
        .firstWhere(
          (r) => r.lapTime != null,
          orElse: () => records.first,
        )
        .lapTime;

    return Container(
      decoration: CustomDecorations.cardLight,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // record rows
          for (int i = 0; i < pageRecords.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.black.withValues(alpha: 0.10),
              ),
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
    Provider.of<EventDetailProvider>(context, listen: false)
        .fetchEvent(event)
        .then((value) => Navigator.pushNamed(context, '/eventDetail'));
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
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Widget value,
    VoidCallback? onTap,
  }) {
    final Widget content = Container(
      height: 110,
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: CustomDecorations.cardLight,
      child: Stack(
        children: <Widget>[
          // outward arrow in the top-right (only when tappable)
          if (onTap != null)
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.arrow_outward,
                size: 14.0,
                color: iconColor.withValues(alpha: 0.7),
              ),
            ),
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

    return Expanded(
      flex: 1,
      child: onTap != null ? InkWell(onTap: onTap, child: content) : content,
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
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.black.withValues(alpha: 0.15),
        ),
        Container(
          color: Colors.black.withValues(alpha: 0.04),
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.chevron_left),
                iconSize: 22,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                color: Colors.black.withValues(alpha: 0.8),
                onPressed: currentPage > 0
                    ? () => onPageChanged(currentPage - 1)
                    : null,
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
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(currentPage + 1)
                    : null,
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
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            date != null ? DateFormat('dd', 'fr').format(date) : "?",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 1.0),
          Text(
            date != null
                ? DateFormat('MMM', 'fr').format(date).toUpperCase()
                : "—",
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
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 9.0,
              height: 1.0,
            ),
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
                    (event.organizer != null && event.organizer!.isNotEmpty)
                        ? event.organizer!
                        : "—",
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
                      Icon(
                        Icons.euro_symbol,
                        size: 12.0,
                        color: Colors.purple[700],
                      ),
                      const SizedBox(width: 2.0),
                      Text(
                        StringUtils.formatPrice(event.price ?? 0.0),
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.75),
                          fontSize: 12.0,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            // participants chip
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7.0,
                vertical: 3.0,
              ),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    participantsCount > 1 ? Icons.group : Icons.person,
                    size: 12.0,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 3.0),
                  Text(
                    "$participantsCount",
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
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
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(3.0),
      ),
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
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.7),
              fontSize: 12.0,
              height: 1.1,
            ),
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
        ? "${record.member!.firstName ?? ""} ${record.member!.lastName ?? ""}"
            .trim()
        : "—";
    final int? riderNumber = record.member?.riderNumber;
    final String lapTime =
        AppDateUtils.toLapTimeString(record.lapTime) ?? "";
    // Display the bike used for this record if available, otherwise fall
    // back to the member's currently marked bike.
    Bike? displayBike = record.bike;
    if (displayBike == null && record.member?.bikes != null) {
      final List<Bike> memberBikes = record.member!.bikes!;
      if (memberBikes.isNotEmpty) {
        displayBike = memberBikes.firstWhere(
          (b) => b.current ?? false,
          orElse: () => memberBikes.first,
        );
      }
    }
    final String? bikeStr = _bikeText(displayBike);

    // gap with the fastest record (only shown when this record is not the
    // fastest itself and both lap times are known)
    final bool isFastest = record.lapTime != null &&
        fastestLapTime != null &&
        record.lapTime == fastestLapTime;
    final int? gapMs =
        (record.lapTime != null && fastestLapTime != null && !isFastest)
            ? record.lapTime! - fastestLapTime
            : null;

    return Padding(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(5.0),
                ),
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
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
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
                    if (riderNumber != null) ...[
                      const SizedBox(width: 6.0),
                      _riderNumberBadge(riderNumber),
                    ],
                  ],
                ),
                if (bikeStr != null) ...[
                  const SizedBox(height: 2.0),
                  _chronoMetaItem(
                    CustomIcons.motorbike,
                    Colors.deepPurple,
                    bikeStr,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6.0),
          // weather icon on the right
          Icon(
            record.conditions == "dry" ? Icons.wb_sunny : CustomIcons.rain,
            color: record.conditions == "dry"
                ? Colors.orange[600]
                : Colors.blueGrey[400],
            size: 16.0,
          ),
        ],
      ),
    );
  }

  Widget _eventsTable(EventDetailProvider eventDetailProvider) {
    if (eventDetailProvider.loadingStatus == LoadingStatus.loading) {
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
    final int totalPages =
        (sortedEvents.length / _eventsPageSize).ceil().clamp(1, 1 << 30);
    final int currentPage = _eventsPage.clamp(0, totalPages - 1);
    final int start = currentPage * _eventsPageSize;
    final int end =
        (start + _eventsPageSize).clamp(0, sortedEvents.length);
    final List<Event> pageEvents = sortedEvents.sublist(start, end);

    return Container(
      decoration: CustomDecorations.cardLight,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // event rows
          for (int i = 0; i < pageEvents.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.black.withValues(alpha: 0.10),
              ),
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
    final RecordListProvider _recordListProvider =
        Provider.of<RecordListProvider>(context, listen: true);
    final TrackDetailProvider _trackDetailProvider =
        Provider.of<TrackDetailProvider>(context, listen: true);
    final EventDetailProvider _eventDetailProvider =
        Provider.of<EventDetailProvider>(context, listen: true);
    final LoginProvider _loginProvider =
        Provider.of<LoginProvider>(context, listen: false);

    // if currentTrack is null (e.g. after session expiration), don't render content
    if (_trackDetailProvider.currentTrack == null) {
      return Scaffold(
        body: Container(decoration: CustomDecorations.mainContent),
      );
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
                    _trackDetailProvider
                        .currentTrack!.website!.isNotEmpty)
                  IconButton(
                    tooltip: "Site web",
                    icon: const Icon(Icons.public, color: Colors.white),
                    onPressed: () => AppUtils.launchURL(
                      _trackDetailProvider.currentTrack!.website!,
                    ),
                  ),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final FlexibleSpaceBarSettings settings =
                      context
                          .dependOnInheritedWidgetOfExactType<
                            FlexibleSpaceBarSettings
                          >()!;
                  final double deltaExtent =
                      settings.maxExtent - settings.minExtent;
                  final double t = (1.0 -
                          (settings.currentExtent - settings.minExtent) /
                              deltaExtent)
                      .clamp(0.0, 1.0);

                  // t est 0.0 quand complètement déployé, 1.0 quand complètement replié
                  // smoothly fade the country line out as the header collapses,
                  // so it never overlaps the standard AppBar title
                  final double countryOpacity =
                      ((1.0 - t * 2.0).clamp(0.0, 1.0)).toDouble();
                  final track = _trackDetailProvider.currentTrack;
                  final bool showCountry = track?.country != null &&
                      countryOpacity > 0.0;
                  return FlexibleSpaceBar(
                    // shift the title to the right of the circular badge
                    // when expanded; slide it back to the standard AppBar
                    // position as the header collapses
                    titlePadding: EdgeInsetsDirectional.only(
                      start: 90.0 - t * 30.0,
                      bottom: 16.0,
                    ),
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
                                ? const [
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Colors.black,
                                    ),
                                  ]
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
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Colors.black,
                                    ),
                                  ],
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
                              TrackUtils.trackCoverImageUrlFromName(
                                _trackDetailProvider.currentTrack!.name,
                              ),
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
                              opacity:
                                  (1.0 - t * 1.5).clamp(0.0, 1.0).toDouble(),
                              child: Container(
                                width: 64.0,
                                height: 64.0,
                                padding: const EdgeInsets.all(8.0),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: CircleBorder(
                                    side: BorderSide(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      width: 2.0,
                                    ),
                                  ),
                                  shadows: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.25),
                                      blurRadius: 6.0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: TrackUtils.getTrackIcon(
                                    _trackDetailProvider.currentTrack!.name ??
                                        "",
                                  ),
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
              padding: EdgeInsets.all(8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                _buildStatCard(
                                  icon: Icons.timer,
                                  iconColor: Colors.blue[700]!,
                                  label: AppString.lapRecord,
                                  value: Text(
                                    AppDateUtils.toLapTimeString(
                                          _trackDetailProvider
                                              .currentTrack!.lapRecord,
                                        ) ??
                                        "—",
                                    style: const TextStyle(
                                      fontFamily: "AlarmClock",
                                      fontSize: 17.0,
                                      letterSpacing: -1.0,
                                      height: 1.0,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                _buildStatCard(
                                  icon: Icons.straighten,
                                  iconColor: Colors.teal[600]!,
                                  label: AppString.length,
                                  value: Text(
                                    _trackDetailProvider
                                                .currentTrack!.distance !=
                                            null
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
                                        _trackDetailProvider
                                                    .currentTrack!.latitude !=
                                                null
                                            ? _trackDetailProvider
                                                .currentTrack!.latitude!
                                                .toStringAsFixed(4)
                                            : "—",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          height: 1.1,
                                          fontFeatures: <FontFeature>[
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _trackDetailProvider
                                                    .currentTrack!.longitude !=
                                                null
                                            ? _trackDetailProvider
                                                .currentTrack!.longitude!
                                                .toStringAsFixed(4)
                                            : "—",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          height: 1.1,
                                          fontFeatures: <FontFeature>[
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: _trackDetailProvider
                                                  .currentTrack!.latitude !=
                                              null &&
                                          _trackDetailProvider
                                                  .currentTrack!.longitude !=
                                              null
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
                                Icon(
                                  Icons.description,
                                  size: 16,
                                  color: Colors.black.withAlpha(204),
                                ),
                                SizedBox(width: 5.0),
                                Text(
                                  AppString.trackEvents,
                                  textScaler: TextScaler.linear(1.2),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black.withAlpha(204),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            _eventsTable(_eventDetailProvider),
                            SizedBox(height: 10),
                            if (_loginProvider.isMember) ...[
                              SizedBox(height: 10),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.group,
                                    size: 18,
                                    color: Colors.black.withAlpha(163),
                                  ),
                                  SizedBox(width: 5.0),
                                  Text(
                                    AppString.chronos,
                                    textScaler: TextScaler.linear(1.2),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black.withAlpha(163),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              _recordsTable(_recordListProvider),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 400),
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
