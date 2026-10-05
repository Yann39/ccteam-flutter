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
import 'package:ccteam/ui/members/maintenance_dialogs.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/maintenance_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// "Entretien" card of the bike detail page: maintenance plan, next due maintenance, odometer and last maintenance,
/// with the entry points to record a maintenance and to the maintenance history.
class BikeMaintenanceCard extends StatefulWidget {
  final Bike bike;

  const BikeMaintenanceCard({Key? key, required this.bike}) : super(key: key);

  @override
  State<BikeMaintenanceCard> createState() => _BikeMaintenanceCardState();
}

class _BikeMaintenanceCardState extends State<BikeMaintenanceCard> {
  @override
  void initState() {
    super.initState();
    // always reload when the page opens, a reminder may have been triggered by a change made on another device
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Provider.of<BikeMaintenanceProvider>(context, listen: false).load(widget.bike.id!);
    });
  }

  Widget _divider() => Container(height: 1, color: Colors.white.withValues(alpha: 0.6));

  /// Info row, same idiom as the other cards of the bike detail page, optionally tappable.
  Widget _row({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
    Widget? below,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withValues(alpha: 0.15)),
              child: Icon(icon, color: iconColor, size: 20.0),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(label, style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 12.0)),
                  const SizedBox(height: 2.0),
                  Text(
                    value,
                    style: TextStyle(
                      color: valueColor ?? Colors.black.withAlpha(220),
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (below != null) ...[const SizedBox(height: 6.0), below],
                ],
              ),
            ),
            if (onTap != null)
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Icon(Icons.chevron_right, size: 18.0, color: Colors.black.withAlpha(110)),
              ),
          ],
        ),
      ),
    );
  }

  /// Next due row, colored by status with a progress bar of the elapsed maintenance period.
  Widget _buildNextDueRow(BikeMaintenance data) {
    final MaintenanceDue due = data.nextDue;
    // the plan counts from the last service, one-off repairs in between don't restart it
    final Maintenance? last = data.lastService;
    final Color color = MaintenanceUtils.statusColor(due.status);

    final String value;
    if (last == null) {
      value = AppString.maintenanceDueNoMaintenance;
    } else {
      value = MaintenanceUtils.formatRemaining(due) ?? AppString.maintenanceDueNoOdometer;
    }

    final double? share = MaintenanceUtils.consumedShare(data.plan, due, last);
    final List<String> dueDetails = [
      if (due.dueKm != null) MaintenanceUtils.formatKm(due.dueKm!),
      if (due.dueDate != null) DateFormat(DATE_FORMAT_DAY).format(due.dueDate!),
    ];

    return _row(
      icon: due.status == MaintenanceDueStatus.overdue ? Icons.warning_amber_rounded : Icons.schedule,
      iconColor: color,
      label: AppString.maintenanceNextDue,
      value: value,
      valueColor: due.status == MaintenanceDueStatus.unknown ? null : color,
      below: share == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(3.0),
                  child: LinearProgressIndicator(
                    value: share,
                    minHeight: 6.0,
                    color: color,
                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                if (dueDetails.isNotEmpty) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    dueDetails.join(AppString.maintenanceOr),
                    style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 12.0),
                  ),
                ],
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BikeMaintenanceProvider provider = Provider.of<BikeMaintenanceProvider>(context, listen: true);
    final int bikeId = widget.bike.id!;
    final BikeMaintenance? data = provider.maintenanceOf(bikeId);

    final List<Widget> rows;
    if (data == null) {
      rows = <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: provider.statusOf(bikeId) == LoadingStatus.loading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                : TextButton.icon(
                    onPressed: () => provider.load(bikeId),
                    icon: const Icon(Icons.refresh),
                    label: Text(AppString.contentNotLoaded),
                  ),
          ),
        ),
      ];
    } else {
      final Maintenance? last = data.maintenances.isEmpty ? null : data.maintenances.first;
      rows = <Widget>[
        _row(
          icon: Icons.event_repeat,
          iconColor: Colors.indigo[600]!,
          label: AppString.maintenancePlan,
          value: data.plan != null ? MaintenanceUtils.formatPlan(data.plan!) : AppString.maintenancePlanNone,
          onTap: () => MaintenanceDialogs.showPlanDialog(context, bikeId, data.plan),
        ),
        if (data.plan != null) ...[_divider(), _buildNextDueRow(data)],
        _divider(),
        _row(
          icon: Icons.speed,
          iconColor: Colors.red[700]!,
          label: AppString.odometer,
          value: data.odometerKm == null
              ? AppString.odometerUnknown
              : data.odometerUpdatedOn == null
              ? MaintenanceUtils.formatKm(data.odometerKm!)
              : AppString.format(AppString.odometerReadOn, [
                  MaintenanceUtils.formatKm(data.odometerKm!),
                  DateFormat(DATE_FORMAT_DAY).format(data.odometerUpdatedOn!),
                ]),
          onTap: () => MaintenanceDialogs.showOdometerDialog(context, bikeId, data.odometerKm),
        ),
        _divider(),
        _row(
          icon: Icons.build,
          iconColor: Colors.teal[700]!,
          label: AppString.maintenanceLast,
          value: last == null
              ? AppString.maintenanceNone
              : "${DateFormat(DATE_FORMAT_DAY).format(last.maintenanceDate!)} · "
                    "${last.operations.map((o) => o.displayName).join(', ')}",
          onTap: last == null
              ? null
              : () => Navigator.pushNamed(context, '/maintenanceHistory', arguments: widget.bike),
        ),
      ];
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.blue[100],
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(25), spreadRadius: 0.5, blurRadius: 0.5, offset: const Offset(2, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 4.0, 4.0, 4.0),
              child: Row(
                children: <Widget>[
                  Icon(Icons.build_circle, color: Colors.teal[700], size: 18.0),
                  const SizedBox(width: 6.0),
                  Expanded(
                    child: Text(
                      AppString.maintenanceTitle,
                      style: TextStyle(
                        color: Colors.black.withAlpha(170),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: data == null || data.maintenances.isEmpty
                        ? null
                        : () => Navigator.pushNamed(context, '/maintenanceHistory', arguments: widget.bike),
                    child: Text(AppString.maintenanceSeeHistory),
                  ),
                ],
              ),
            ),
            _divider(),
            ...rows,
            if (data != null) ...[
              _divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/addEditMaintenance',
                      arguments: MaintenanceFormArguments(bike: widget.bike),
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(AppString.maintenanceCreate),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
