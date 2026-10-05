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
import 'package:ccteam/models/bike_maintenance.dart';
import 'package:ccteam/providers/bike_maintenance_provider.dart';
import 'package:ccteam/ui/members/add_edit_maintenance.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/maintenance_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/random_pattern_painter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Maintenance history of a bike: a summary (count, costs) followed by a vertical timeline of
/// the maintenances, most recent first, with the time and distance elapsed between two consecutive maintenances.
class MaintenanceHistory extends StatelessWidget {
  const MaintenanceHistory({Key? key}) : super(key: key);

  /// Width of the timeline rail on the left of the maintenance cards.
  static const double _railWidth = 36.0;

  static final Color _accent = Colors.teal[700]!;

  /// Open the maintenance form, prefilled with [maintenance] when editing.
  void _openForm(BuildContext context, Bike bike, [Maintenance? maintenance]) {
    Navigator.pushNamed(
      context,
      '/addEditMaintenance',
      arguments: MaintenanceFormArguments(bike: bike, maintenance: maintenance),
    );
  }

  /// One figure of the header: small label above a bold value, on a compact translucent pill (kept narrow so the
  /// figures usually fit on a single row).
  Widget _headerStat(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.20), borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 11.0),
              const SizedBox(width: 3.0),
              Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 10.5)),
            ],
          ),
          const SizedBox(height: 1.0),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  /// Hero header, same idiom as the news detail: the bike pattern (seeded by the bike id, like the bike detail
  /// header) behind the bike name, the number of maintenances and the summary figures (total cost, yearly
  /// cost).
  Widget _buildHeader(Bike bike, List<Maintenance> maintenances) {
    final String bikeLabel = "${(bike.manufacturer ?? '').toUpperCase()} ${bike.modelName ?? ''}".trim();

    String subtitle = AppString.maintenanceNone;
    final List<Widget> stats = <Widget>[];
    if (maintenances.isNotEmpty) {
      final Maintenance oldest = maintenances.last;
      final String since = DateFormat(DATE_FORMAT_DAY).format(oldest.maintenanceDate!);
      subtitle = maintenances.length == 1
          ? AppString.format(AppString.maintenanceHeaderCountOne, [since])
          : AppString.format(AppString.maintenanceHeaderCountMany, [maintenances.length, since]);

      final Map<CurrencyCode, double> totals = MaintenanceUtils.sumTotals(maintenances);
      final String? total = MaintenanceUtils.formatAmounts(totals);
      // yearly cost over the period from the first maintenance to today, at least one year so a single
      // maintenance does not get extrapolated to a huge yearly figure
      final double years = DateTime.now().difference(oldest.maintenanceDate!).inDays / 365.25;
      final String? perYear = MaintenanceUtils.formatAmounts(totals, divisor: years < 1 ? 1 : years);

      if (total != null) stats.add(_headerStat(Icons.payments, AppString.maintenanceSummaryTotal, total));
      if (perYear != null) stats.add(_headerStat(Icons.calendar_month, AppString.maintenanceSummaryPerYear, perYear));
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 12.0, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(painter: RandomPatternPainter(seed: bike.id ?? 0)),
          ),
          // soft dark overlay so the white text stays readable over any pattern
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.10), Colors.black.withValues(alpha: 0.35)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  bikeLabel.isEmpty ? AppString.notDefined : bikeLabel,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                    shadows: [
                      Shadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 4.0, offset: const Offset(0, 1)),
                    ],
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.92), fontSize: 12.5, fontStyle: FontStyle.italic),
                ),
                if (stats.isNotEmpty) ...[
                  const SizedBox(height: 10.0),
                  Wrap(alignment: WrapAlignment.center, spacing: 6.0, runSpacing: 6.0, children: stats),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Left rail of the timeline: a vertical line, with a dot when [dot] is set.
  Widget _rail({required bool lineAbove, required bool lineBelow, Widget? dot}) {
    final Color lineColor = _accent.withValues(alpha: 0.35);
    return SizedBox(
      width: _railWidth,
      child: Column(
        children: <Widget>[
          Container(width: 2.0, height: dot == null ? null : 14.0, color: lineAbove ? lineColor : Colors.transparent),
          if (dot != null) dot,
          Expanded(child: Container(width: 2.0, color: lineBelow ? lineColor : Colors.transparent)),
        ],
      ),
    );
  }

  /// Gap between two timeline cards, as a pill on the rail: "1 an 3 mois · 4 900 km".
  Widget _buildGap(DateTime from, DateTime to, int? fromKm, int? toKm, {String prefix = '', bool lineAbove = true}) {
    final String km = fromKm != null && toKm != null
        ? MaintenanceUtils.formatKm(toKm - fromKm)
        : AppString.maintenanceGapNoKm;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // the rail always continues down to the next card, the top half is left out at the head of the timeline
          SizedBox(
            width: _railWidth,
            child: Column(
              children: <Widget>[
                Expanded(child: Container(width: 2.0, color: lineAbove ? _accent.withValues(alpha: 0.35) : null)),
                Expanded(child: Container(width: 2.0, color: _accent.withValues(alpha: 0.35))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: _accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.swap_vert, size: 15.0, color: _accent),
                  const SizedBox(width: 4.0),
                  Text(
                    "$prefix${MaintenanceUtils.formatElapsed(from, to)} · $km",
                    style: TextStyle(color: Colors.black.withAlpha(200), fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceCard(BuildContext context, Bike bike, Maintenance maintenance, {required bool isLast}) {
    final Widget card = Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.white),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openForm(context, bike, maintenance),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 10.0, 8.0, 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                DateFormat(DATE_FORMAT_DAY).format(maintenance.maintenanceDate!),
                                style: TextStyle(
                                  color: Colors.black.withAlpha(225),
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (maintenance.resetsPlan) ...[
                                const SizedBox(width: 8.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
                                  decoration: BoxDecoration(
                                    color: _accent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    AppString.maintenanceServiceBadge,
                                    style: TextStyle(color: _accent, fontSize: 11.0, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (maintenance.odometerKm != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.speed, size: 14.0, color: Colors.black.withAlpha(130)),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    MaintenanceUtils.formatKm(maintenance.odometerKm!),
                                    style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 12.5),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 20.0, color: Colors.black.withAlpha(100)),
                  ],
                ),
                const SizedBox(height: 8.0),
                for (final MaintenanceOperation operation in maintenance.operations)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3.0, right: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 1.0),
                          child: Icon(Icons.check_circle, size: 14.0, color: _accent.withValues(alpha: 0.8)),
                        ),
                        const SizedBox(width: 6.0),
                        // name, then the precision under it, keeping the line breaks the member typed
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                operation.title,
                                style: TextStyle(color: Colors.black.withAlpha(210), fontSize: 13.5),
                              ),
                              if (operation.details != null)
                                Text(
                                  operation.details!,
                                  style: TextStyle(color: Colors.black.withAlpha(140), fontSize: 12.5),
                                ),
                            ],
                          ),
                        ),
                        if (operation.price != null)
                          Text(
                            MaintenanceUtils.formatPrice(operation.price!, operation.currency),
                            style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 12.5),
                          ),
                      ],
                    ),
                  ),
                if (maintenance.totals.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, right: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: Colors.green[700]!.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          "${AppString.maintenanceTotal} : ${MaintenanceUtils.formatAmounts(maintenance.totals)!}",
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.green[900], fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                if (maintenance.comment != null) ...[
                  const SizedBox(height: 6.0),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(right: 8.0),
                    padding: const EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(10),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      maintenance.comment!,
                      style: TextStyle(color: Colors.black.withAlpha(170), fontSize: 13.0, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _rail(
            lineAbove: true,
            lineBelow: !isLast,
            // plain dot for a service of the plan, hollow one for a one-off repair
            dot: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: maintenance.resetsPlan ? _accent : Colors.white,
                border: Border.all(color: maintenance.resetsPlan ? Colors.white : _accent, width: 2.5),
              ),
            ),
          ),
          Expanded(child: card),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Bike bike = ModalRoute.of(context)!.settings.arguments as Bike;
    final BikeMaintenanceProvider provider = Provider.of<BikeMaintenanceProvider>(context, listen: true);
    final BikeMaintenance? data = provider.maintenanceOf(bike.id!);
    final List<Maintenance> maintenances = data?.maintenances ?? const <Maintenance>[];

    // timeline items, laid out under the full-width header
    final List<Widget> children = <Widget>[];
    if (maintenances.isNotEmpty) {

      // elapsed since the last maintenance, up to today and the current odometer reading
      final Maintenance last = maintenances.first;
      children.add(
        _buildGap(
          last.maintenanceDate!,
          DateTime.now(),
          last.odometerKm,
          data!.odometerKm,
          prefix: AppString.maintenanceSinceLast,
          lineAbove: false,
        ),
      );

      for (int i = 0; i < maintenances.length; i++) {
        children.add(_buildMaintenanceCard(context, bike, maintenances[i], isLast: i == maintenances.length - 1));
        if (i < maintenances.length - 1) {
          final Maintenance older = maintenances[i + 1];
          children.add(
            _buildGap(
              older.maintenanceDate!,
              maintenances[i].maintenanceDate!,
              older.odometerKm,
              maintenances[i].odometerKm,
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppString.maintenanceHistoryTitle)),
      // same look as the other list pages ("Mes motos"...)
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        backgroundColor: Colors.red[700],
        tooltip: AppString.maintenanceCreate,
        onPressed: () => _openForm(context, bike),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: RefreshIndicator(
          onRefresh: () => provider.load(bike.id!),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 88.0),
            children: <Widget>[
              _buildHeader(bike, maintenances),
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
