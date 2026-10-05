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

import 'package:ccteam/models/bike_maintenance.dart';
import 'package:ccteam/providers/bike_maintenance_provider.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Dialogs of the bike maintenance card: maintenance plan and odometer reading.
class MaintenanceDialogs {
  /// Show the dialog defining (or editing, or deleting) the maintenance [plan] of the bike with the given [bikeId].
  static Future<void> showPlanDialog(BuildContext context, int bikeId, MaintenancePlan? plan) {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) => _PlanDialog(bikeId: bikeId, plan: plan),
    );
  }

  /// Show the dialog updating the current odometer reading of the bike with the given [bikeId].
  static Future<void> showOdometerDialog(BuildContext context, int bikeId, int? odometerKm) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController controller = TextEditingController(text: odometerKm?.toString() ?? '');
    final BikeMaintenanceProvider provider = Provider.of<BikeMaintenanceProvider>(context, listen: false);

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(AppString.odometerUpdate),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              icon: Icon(Icons.speed),
              labelText: AppString.odometerKm,
              suffixText: 'km',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return AppString.odometerMandatory;
              if (int.tryParse(value) == null) return AppString.odometerInvalid;
              return null;
            },
          ),
        ),
        actions: <Widget>[
          TextButton(child: Text(AppString.cancel), onPressed: () => Navigator.of(dialogContext).pop()),
          TextButton(
            child: Text(AppString.save),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final bool ok = await provider.updateOdometer(bikeId, int.parse(controller.text));
              if (ok && dialogContext.mounted) Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }
}

/// Unit in which the plan time interval is entered, stored in months either way.
enum _IntervalUnit { months, years }

class _PlanDialog extends StatefulWidget {
  final int bikeId;
  final MaintenancePlan? plan;

  const _PlanDialog({required this.bikeId, this.plan});

  @override
  State<_PlanDialog> createState() => _PlanDialogState();
}

class _PlanDialogState extends State<_PlanDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _kmController;
  late final TextEditingController _timeController;
  late _IntervalUnit _unit;
  String? _error;

  @override
  void initState() {
    super.initState();
    final int? months = widget.plan?.intervalMonths;
    // a whole number of years is displayed in years, "every 2 years" reads better than "every 24 months"
    _unit = months == null || months % 12 == 0 ? _IntervalUnit.years : _IntervalUnit.months;
    _kmController = TextEditingController(text: widget.plan?.intervalKm?.toString() ?? '');
    _timeController = TextEditingController(
      text: months == null ? '' : (_unit == _IntervalUnit.years ? (months ~/ 12).toString() : months.toString()),
    );
  }

  @override
  void dispose() {
    _kmController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final int? km = int.tryParse(_kmController.text);
    final int? time = int.tryParse(_timeController.text);
    if ((km == null || km <= 0) && (time == null || time <= 0)) {
      setState(() => _error = AppString.maintenancePlanMandatory);
      return;
    }
    final int? months = time == null || time <= 0 ? null : (_unit == _IntervalUnit.years ? time * 12 : time);
    final bool ok = await Provider.of<BikeMaintenanceProvider>(
      context,
      listen: false,
    ).setPlan(widget.bikeId, km == null || km <= 0 ? null : km, months);
    if (ok && mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmAndDelete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext confirmContext) => AlertDialog(
        title: Text(AppString.confirmation),
        content: Text(AppString.maintenancePlanDeleteAreYouSure),
        actions: <Widget>[
          TextButton(child: Text(AppString.cancel), onPressed: () => Navigator.of(confirmContext).pop(false)),
          TextButton(child: Text(AppString.confirm), onPressed: () => Navigator.of(confirmContext).pop(true)),
        ],
      ),
    );
    if (confirmed == true) await _delete();
  }

  Future<void> _delete() async {
    final bool ok = await Provider.of<BikeMaintenanceProvider>(context, listen: false).deletePlan(widget.bikeId);
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // lets the content scroll when the keyboard shrinks the available height
      scrollable: true,
      // delete lives in the title row, three actions don't fit on one line and would stack over the form
      title: Row(
        children: <Widget>[
          Expanded(child: Text(AppString.maintenancePlan)),
          if (widget.plan != null)
            IconButton(
              tooltip: AppString.delete,
              icon: Icon(Icons.delete_outline, color: Colors.red[700]),
              onPressed: _confirmAndDelete,
            ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppString.maintenancePlanHelp,
              style: TextStyle(fontSize: 13.0, color: Colors.black.withAlpha(160), height: 1.35),
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _kmController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                icon: Icon(Icons.route),
                labelText: AppString.maintenancePlanEvery,
                suffixText: 'km',
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      icon: Icon(Icons.event_repeat),
                      labelText: AppString.maintenancePlanEvery,
                    ),
                    onChanged: (_) => setState(() => _error = null),
                  ),
                ),
                const SizedBox(width: 12.0),
                DropdownButton<_IntervalUnit>(
                  value: _unit,
                  items: const <DropdownMenuItem<_IntervalUnit>>[
                    DropdownMenuItem(value: _IntervalUnit.months, child: Text('mois')),
                    DropdownMenuItem(value: _IntervalUnit.years, child: Text('ans')),
                  ],
                  onChanged: (value) => setState(() => _unit = value ?? _unit),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12.0),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12.5)),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(child: Text(AppString.cancel), onPressed: () => Navigator.of(context).pop()),
        TextButton(onPressed: _save, child: Text(AppString.save)),
      ],
    );
  }
}
