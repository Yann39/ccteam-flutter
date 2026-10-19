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

import 'dart:math' as math;

import 'package:ccteam/models/bike.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/maintenance_utils.dart';
import 'package:ccteam/utils/member_stats.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Two compact charts displayed inline in the "My account" stats card:
/// a donut showing how the member's past participations split across
/// their bikes, and a bar chart of participations per calendar year.
///
/// Both widgets render a slim inset (no card chrome) — the parent
/// stats card already provides the visual container. They early-out
/// to a zero-height `SizedBox` when the data isn't worth showing
/// (fewer than 2 bikes for the pie, fewer than 2 years for the bars):
/// a 1-slice pie or a 1-bar chart adds noise without adding info,
/// the matching plain "fact" row above the chart already conveys
/// everything in that degenerate case.

/// Generic donut + legend widget — used by both the bike-usage and
/// track-usage pie charts. Each "slice" of the input list becomes a
/// section of the donut + a row in the legend (color dot + label +
/// count). Early-outs to `SizedBox.shrink()` when there's less than
/// 2 items or the total count is zero (a one-slice pie or an empty
/// chart adds noise without info, the matching "favourite" row above
/// it already carries everything).
///
/// [labelFor] formats the label of a given entry — bike labels look
/// different from track labels so we let the caller decide.
/// [shades] is the list of Material shade stops (e.g. `[700, 400, …]`)
/// applied to [color] for each slice in order. The list is cycled
/// when there are more entries than shades, which in practice rarely
/// happens (a member won't have a dozen+ tracks or bikes).
class _UsagePieChart<T> extends StatelessWidget {
  const _UsagePieChart({
    Key? key,
    required this.entries,
    required this.countFor,
    required this.labelFor,
    required this.color,
    required this.shades,
  }) : super(key: key);

  final List<T> entries;
  final int Function(T entry) countFor;
  final String Function(T entry) labelFor;
  final MaterialColor color;
  final List<int> shades;

  Color _sliceColor(int idx) {
    final int shade = shades[idx % shades.length];
    return color[shade] ?? color;
  }

  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) return const SizedBox.shrink();

    final int total = entries.fold<int>(0, (sum, e) => sum + countFor(e));
    if (total <= 0) return const SizedBox.shrink();

    final List<PieChartSectionData> sections = <PieChartSectionData>[];
    for (int i = 0; i < entries.length; i++) {
      final int count = countFor(entries[i]);
      final double pct = count * 100 / total;
      sections.add(
        PieChartSectionData(
          color: _sliceColor(i),
          value: count.toDouble(),
          // pct only on slices wide enough to fit the label; very thin
          // ones stay clean and the legend on the right carries the info
          title: pct >= 12.0 ? '${pct.toStringAsFixed(0)}%' : '',
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 11.0,
            fontWeight: FontWeight.bold,
          ),
          radius: 36.0,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // the donut itself, fixed square so the legend on the right
          // has predictable room to wrap
          SizedBox(
            width: 110,
            height: 110,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2.0,
                centerSpaceRadius: 22.0,
                startDegreeOffset: -90.0,
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int i = 0; i < entries.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _sliceColor(i),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            labelFor(entries[i]),
                            style: TextStyle(
                              color: Colors.black.withAlpha(204),
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          countFor(entries[i]).toString(),
                          style: TextStyle(
                            color: Colors.black.withAlpha(140),
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Donut + legend for the breakdown of past participations per bike.
/// Uses the deep-purple palette to echo the bike-related accents
/// elsewhere in the app (the bike picker chip, the "moto la plus
/// utilisée" row icon, …).
class BikeUsagePieChart extends StatelessWidget {
  const BikeUsagePieChart({Key? key, required this.usages}) : super(key: key);

  final List<BikeUsage> usages;

  /// Compact bike label — same format as the rest of the app
  /// (uppercase manufacturer + model + optional year).
  static String _bikeLabel(Bike b) {
    final String base = "${b.manufacturer?.toUpperCase() ?? ''} ${b.modelName ?? ''}".trim();
    if (b.year == null) return base.isEmpty ? '—' : base;
    if (base.isEmpty) return b.year!.toString();
    return "$base ${b.year}";
  }

  @override
  Widget build(BuildContext context) {
    return _UsagePieChart<BikeUsage>(
      entries: usages,
      countFor: (u) => u.count,
      labelFor: (u) => _bikeLabel(u.bike),
      color: Colors.deepPurple,
      shades: const <int>[700, 400, 300, 600, 200, 800, 500, 900],
    );
  }
}

/// Bar chart of past participations per year. Bars use a teal/blue
/// gradient (matches the "Roulages effectués" icon a few rows above);
/// the X axis is the year, the Y axis is hidden — counts are rendered
/// as small tooltips directly above each bar so the user reads the
/// figure without an axis lookup.
class EventsPerYearBarChart extends StatelessWidget {
  const EventsPerYearBarChart({Key? key, required this.entries}) : super(key: key);

  final List<YearlyParticipation> entries;

  @override
  Widget build(BuildContext context) {
    // a one-year chart is just a single bar, useless next to the
    // "Roulages effectués" count above
    if (entries.length < 2) return const SizedBox.shrink();

    // fill the year gaps so the X axis stays continuous (a member
    // who rode in 2022 and 2024 should see an empty 2023 bar rather
    // than the two non-consecutive bars sitting side by side)
    final int firstYear = entries.first.year;
    final int lastYear = entries.last.year;
    final Map<int, int> byYear = <int, int>{for (final e in entries) e.year: e.count};
    final List<YearlyParticipation> filled = <YearlyParticipation>[
      for (int y = firstYear; y <= lastYear; y++) YearlyParticipation(year: y, count: byYear[y] ?? 0),
    ];

    final int maxCount = filled.fold<int>(0, (m, e) => e.count > m ? e.count : m);
    // pad the Y range a touch so the count label fits above the
    // tallest bar without clipping
    final double maxY = (maxCount + 1).toDouble();

    final List<BarChartGroupData> groups = <BarChartGroupData>[];
    for (int i = 0; i < filled.length; i++) {
      final YearlyParticipation e = filled[i];
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: <BarChartRodData>[
            BarChartRodData(
              toY: e.count.toDouble(),
              width: 18.0,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: <Color>[Colors.blue[700]!, Colors.teal[400]!],
              ),
            ),
          ],
          showingTooltipIndicators: e.count > 0 ? const <int>[0] : const <int>[],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 14.0),
      child: SizedBox(
        height: 130,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barGroups: groups,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  // Years are rendered vertically (bottom-to-top) so
                  // bars can stay close together without the labels
                  // colliding. `reservedSize` accommodates the rotated
                  // text height — ~32 px is enough for "YYYY" at 11 px.
                  reservedSize: 36.0,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final int idx = value.toInt();
                    if (idx < 0 || idx >= filled.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          filled[idx].year.toString(),
                          style: TextStyle(
                            color: Colors.black.withAlpha(180),
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // tooltip is rendered as the "always-on" count label above
            // each bar — no need for interactive tooltips on tap
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => Colors.transparent,
                tooltipPadding: EdgeInsets.zero,
                tooltipMargin: 4.0,
                getTooltipItem: (group, groupIdx, rod, rodIdx) {
                  return BarTooltipItem(
                    rod.toY.toInt().toString(),
                    TextStyle(
                      color: Colors.black.withAlpha(220),
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                    ),
                  );
                },
              ),
            ),
          ),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }
}

/// Step line chart of the estimated km accumulated over time, one dot per
/// track day. The X axis is the calendar (so the winter breaks show as flat
/// stretches), labelled by month or by year depending on the span; the Y
/// axis shows the km. Green, like the "Km estimés" row it unfolds under.
///
/// Tapping a dot pins a tooltip with its date, track and running total,
/// until another tap. Built-in touches are off for that: they would hide the
/// tooltip as soon as the finger lifts.
class KmProgressLineChart extends StatefulWidget {
  const KmProgressLineChart({Key? key, required this.points}) : super(key: key);

  final List<KmProgress> points;

  @override
  State<KmProgressLineChart> createState() => _KmProgressLineChartState();
}

class _KmProgressLineChartState extends State<KmProgressLineChart> {
  static final NumberFormat _axisKmFormat = NumberFormat('#,##0', 'fr_CH');

  /// Month steps the X labels may use, the first one leaving at most 4 labels wins.
  static const List<int> _monthSteps = <int>[1, 2, 3, 6, 12, 24, 36, 60];

  int? _selected;

  /// Position of [date] on the X axis, in months.
  static double _monthX(DateTime date) =>
      date.year * 12 + (date.month - 1) + (date.day - 1) / DateUtils.getDaysInMonth(date.year, date.month);

  /// Round step for the Y axis, about a quarter of [maxKm] (1, 2, 2.5 or 5 × a power of ten).
  static double _kmStep(int maxKm) {
    final double raw = maxKm / 4;
    if (raw <= 1) return 1;
    final double magnitude = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    for (final double factor in const <double>[1, 2, 2.5, 5, 10]) {
      if (factor * magnitude >= raw) return factor * magnitude;
    }
    return 10 * magnitude;
  }

  @override
  Widget build(BuildContext context) {
    final List<KmProgress> points = widget.points;
    // a single dot isn't a trend, the row above already gives the figure
    if (points.length < 2) return const SizedBox.shrink();

    final Color color = Colors.green[700]!;
    final TextStyle axisStyle = TextStyle(
      color: Colors.black.withAlpha(150),
      fontSize: 10.5,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );

    final List<FlSpot> spots = <FlSpot>[for (final p in points) FlSpot(_monthX(p.date), p.km.toDouble())];
    final double firstX = spots.first.x;
    final double lastX = spots.last.x;
    final double span = math.max(lastX - firstX, 1.0);
    final int monthStep = _monthSteps.firstWhere((step) => span / step <= 4, orElse: () => _monthSteps.last);

    final double kmStep = _kmStep(points.last.km);
    final double maxY = math.max(((points.last.km * 1.1) / kmStep).ceil() * kmStep, kmStep);

    final int? selected = _selected != null && _selected! < spots.length ? _selected : null;
    final LineChartBarData line = LineChartBarData(
      spots: spots,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      // steps: the km stay flat between two track days (winter breaks included) and jump on the day
      isStepLineChart: true,
      lineChartStepData: const LineChartStepData(stepDirection: LineChartStepData.stepDirectionForward),
      dotData: FlDotData(
        // dozens of dots would only blur the line
        show: spots.length <= 30,
        getDotPainter: (spot, percent, bar, index) =>
            FlDotCirclePainter(radius: 3.0, color: color, strokeWidth: 1.5, strokeColor: Colors.white),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Colors.green[400]!.withValues(alpha: 0.35), Colors.green[400]!.withValues(alpha: 0.02)],
        ),
      ),
      showingIndicators: selected == null ? const <int>[] : <int>[selected],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(6.0, 12.0, 18.0, 10.0),
      child: SizedBox(
        height: 160,
        child: LineChart(
          LineChartData(
            minX: firstX - span * 0.03,
            maxX: lastX + span * 0.03,
            minY: 0,
            maxY: maxY,
            lineBarsData: <LineChartBarData>[line],
            showingTooltipIndicators: selected == null
                ? const <ShowingTooltipIndicators>[]
                : <ShowingTooltipIndicators>[
                    ShowingTooltipIndicators(<LineBarSpot>[LineBarSpot(line, 0, spots[selected])]),
                  ],
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: kmStep,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: Colors.white.withValues(alpha: 0.8), strokeWidth: 1.0, dashArray: const <int>[4, 4]),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40.0,
                  interval: kmStep,
                  getTitlesWidget: (double value, TitleMeta meta) => SideTitleWidget(
                    meta: meta,
                    space: 6.0,
                    child: Text(_axisKmFormat.format(value.round()), style: axisStyle),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24.0,
                  interval: monthStep.toDouble(),
                  // calendar boundaries only (month starts, or January for yearly steps), not the range edges
                  minIncluded: false,
                  maxIncluded: false,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final int month = value.round();
                    final DateTime date = DateTime(month ~/ 12, month % 12 + 1);
                    return SideTitleWidget(
                      meta: meta,
                      space: 6.0,
                      fitInside: SideTitleFitInsideData.fromTitleMeta(meta, distanceFromEdge: 0),
                      child: Text(
                        monthStep >= 12 ? date.year.toString() : DateFormat('MMM yy', 'fr').format(date),
                        style: axisStyle,
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              handleBuiltInTouches: false,
              touchSpotThreshold: 24.0,
              touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                // a tap pins the nearest dot (or clears it away from the dots), a long press scrubs along the line
                if (event is! FlTapUpEvent && event is! FlLongPressStart && event is! FlLongPressMoveUpdate) return;
                final List<TouchLineBarSpot>? touched = response?.lineBarSpots;
                final int? index = touched == null || touched.isEmpty ? null : touched.first.spotIndex;
                if (index != _selected) setState(() => _selected = index);
              },
              getTouchedSpotIndicator: (LineChartBarData bar, List<int> indexes) => indexes
                  .map(
                    (_) => TouchedSpotIndicatorData(
                      FlLine(color: color.withValues(alpha: 0.5), strokeWidth: 1.5, dashArray: const <int>[3, 3]),
                      FlDotData(
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(radius: 5.0, color: color, strokeWidth: 2.0, strokeColor: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => Colors.blueGrey[800]!,
                tooltipBorderRadius: BorderRadius.circular(6.0),
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                maxContentWidth: 180.0,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItems: (List<LineBarSpot> touchedSpots) => touchedSpots.map((LineBarSpot spot) {
                  final KmProgress point = points[spot.spotIndex];
                  return LineTooltipItem(
                    DateFormat(DATE_FORMAT_DAY).format(point.date),
                    const TextStyle(color: Colors.white70, fontSize: 11.0),
                    children: <TextSpan>[
                      if (point.trackName != null && point.trackName!.isNotEmpty)
                        TextSpan(text: '\n${point.trackName}'),
                      TextSpan(
                        text: '\n≈ ${MaintenanceUtils.formatKm(point.km)}',
                        style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }
}

/// Generic horizontal bar-list ranking entries by a numeric value.
/// Each row shows a label (left, ellipsis-truncated), the formatted
/// value (right, tabular figures), and a thin bar underneath whose
/// width is the fraction of the leader's value.
///
/// Chosen over a pie chart for cases with many categories or long
/// labels because:
///  - a pie with 10+ slices becomes a colour-blob with unreadable
///    labels;
///  - long category names force ellipsis on a pie legend anyway;
///  - a ranked horizontal bar list is the canonical UX for "top-N
///    by magnitude" (Stripe Dashboard's "Top customers", Spotify's
///    "Top tracks", …) — readers parse it instantly.
///
/// [valueFor] returns the numeric magnitude used to drive the bar
/// length (and the descending sort already done by the caller).
/// [displayValueFor] returns the right-hand text — typically `"$n"`
/// for raw counts, `"X EUR"` for monetary amounts, …
/// [maxRows] caps the visible list; the remainder gets surfaced as
/// a discreet "+ N autres" footer.
class _UsageBarList<T> extends StatelessWidget {
  const _UsageBarList({
    Key? key,
    required this.entries,
    required this.labelFor,
    required this.valueFor,
    required this.displayValueFor,
    required this.color,
    this.maxRows = 10,
  }) : super(key: key);

  final List<T> entries;
  final String Function(T) labelFor;
  final num Function(T) valueFor;
  final String Function(T) displayValueFor;
  final Color color;
  final int maxRows;

  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) return const SizedBox.shrink();
    final double total = entries.fold<double>(0.0, (sum, e) => sum + valueFor(e).toDouble());
    if (total <= 0) return const SizedBox.shrink();

    // entries are assumed sorted descending — leader is at index 0
    final double maxValue = valueFor(entries.first).toDouble();
    final int rowsToShow = entries.length > maxRows ? maxRows : entries.length;
    final int remaining = entries.length - rowsToShow;

    final Color barColor = color;
    final Color barTrack = color.withValues(alpha: 0.10);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 14.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < rowsToShow; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: _UsageBarRow(
                name: labelFor(entries[i]),
                displayValue: displayValueFor(entries[i]),
                fraction: maxValue > 0 ? valueFor(entries[i]).toDouble() / maxValue : 0.0,
                barColor: barColor,
                barTrack: barTrack,
              ),
            ),
          if (remaining > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '+ $remaining autres',
                  style: TextStyle(
                    color: Colors.black.withAlpha(140),
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Single row of [_UsageBarList]: label (ellipsis-truncated) and the
/// pre-formatted display value on the top line, thin animated bar
/// underneath. The bar width is driven by a [TweenAnimationBuilder]
/// so every time the chart is "expanded" the bar grows from 0 to
/// its target fraction.
class _UsageBarRow extends StatelessWidget {
  const _UsageBarRow({
    Key? key,
    required this.name,
    required this.displayValue,
    required this.fraction,
    required this.barColor,
    required this.barTrack,
  }) : super(key: key);

  final String name;
  final String displayValue;
  final double fraction;
  final Color barColor;
  final Color barTrack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: Colors.black.withAlpha(204),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6.0),
            Text(
              displayValue,
              style: TextStyle(
                color: Colors.black.withAlpha(160),
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        // bar: animated from 0 to its target fraction on first build.
        // Since this widget is recreated each time the parent chart is
        // shown (the AnimatedSize wrapper swaps it for SizedBox.shrink
        // when collapsed), every "expand" replays the animation.
        ClipRRect(
          borderRadius: BorderRadius.circular(3.0),
          child: Stack(
            children: <Widget>[
              Container(height: 8.0, color: barTrack),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: fraction.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (BuildContext context, double value, Widget? _) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    child: Container(height: 8.0, color: barColor),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Ranked bar list of organizers the member has rolled with. Uses
/// teal to echo the "Organisateur favori" row icon a few rows above.
class OrganizerUsageBarList extends StatelessWidget {
  const OrganizerUsageBarList({Key? key, required this.usages}) : super(key: key);

  final List<OrganizerUsage> usages;

  @override
  Widget build(BuildContext context) {
    return _UsageBarList<OrganizerUsage>(
      entries: usages,
      labelFor: (u) => u.name,
      valueFor: (u) => u.count,
      displayValueFor: (u) => u.count.toString(),
      color: Colors.teal[600]!,
    );
  }
}

/// Ranked bar list of tracks the member has rolled on. Uses amber
/// to echo the trophy icon on the "Circuit favori" row right above,
/// keeping the visual association tight.
class TrackUsageBarList extends StatelessWidget {
  const TrackUsageBarList({Key? key, required this.usages}) : super(key: key);

  final List<TrackUsage> usages;

  @override
  Widget build(BuildContext context) {
    return _UsageBarList<TrackUsage>(
      entries: usages,
      labelFor: (u) => u.name,
      valueFor: (u) => u.count,
      displayValueFor: (u) => u.count.toString(),
      color: Colors.amber[700]!,
    );
  }
}

/// Ranked bar list of how the member's total spending splits across
/// the organizers they've rolled with. Uses red to echo the
/// "Total dépensé" row icon right above. Values are EUR amounts
/// (rounded to no decimal, same format as the row above it).
class OrganizerSpendingBarList extends StatelessWidget {
  const OrganizerSpendingBarList({Key? key, required this.spendings}) : super(key: key);

  final List<OrganizerSpending> spendings;

  @override
  Widget build(BuildContext context) {
    return _UsageBarList<OrganizerSpending>(
      entries: spendings,
      labelFor: (s) => s.name,
      valueFor: (s) => s.amount,
      displayValueFor: (s) => AppString.format(AppString.statsAmountEur, [s.amount.toStringAsFixed(0)]),
      color: Colors.red[600]!,
    );
  }
}
