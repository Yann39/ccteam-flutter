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
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/maintenance_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/form_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Route arguments of the [AddEditMaintenance] page: the serviced [bike], and the [maintenance] to edit
/// (`null` to record a new one).
class MaintenanceFormArguments {
  final Bike bike;
  final Maintenance? maintenance;

  const MaintenanceFormArguments({required this.bike, this.maintenance});
}

/// Form to record or edit a bike maintenance: date, odometer reading, currency, operations with their optional
/// price, and a comment.
class AddEditMaintenance extends StatefulWidget {
  const AddEditMaintenance({Key? key}) : super(key: key);

  @override
  State<AddEditMaintenance> createState() => _AddEditMaintenanceState();
}

class _AddEditMaintenanceState extends State<AddEditMaintenance> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();

  late Bike _bike;
  late Maintenance _maintenance;
  bool _isEditing = false;
  bool _initialized = false;
  bool _saving = false;
  String? _operationsError;

  // whether the member set the "service" switch by hand, until then it follows the operations
  // (see [MaintenanceOperationType.planServices]), afterwards their choice is kept
  bool _resetsPlanTouched = false;

  // currency proposed for a new operation: the one of the last price entered, see [_newOperation]
  CurrencyCode _defaultCurrency = CurrencyCode.chf;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final MaintenanceFormArguments args = ModalRoute.of(context)!.settings.arguments as MaintenanceFormArguments;
    _bike = args.bike;
    final BikeMaintenance? data = Provider.of<BikeMaintenanceProvider>(context, listen: false).maintenanceOf(_bike.id!);
    // start from the currency of the most recent operation of the bike, members usually buy in the same country
    for (final Maintenance m in data?.maintenances ?? const <Maintenance>[]) {
      if (m.operations.isNotEmpty) {
        _defaultCurrency = m.operations.last.currency;
        break;
      }
    }
    if (args.maintenance != null) {
      // edit a copy, so cancelling leaves the displayed data untouched
      _maintenance = args.maintenance!.copy();
      _isEditing = true;
      // an existing maintenance keeps what was saved
      _resetsPlanTouched = true;
    } else {
      _maintenance = Maintenance(
        maintenanceDate: DateUtils.dateOnly(DateTime.now()),
        odometerKm: data?.odometerKm,
        operations: [_newOperation(_defaultCurrency)],
      );
    }
    _dateController.text = DateFormat(DATE_FORMAT_DAY).format(_maintenance.maintenanceDate!);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: _maintenance.maintenanceDate ?? DateTime.now(),
      firstDate: DateTime(1990, 1, 1),
      lastDate: DateTime.now(),
    );
    if (result != null) {
      setState(() {
        _maintenance.maintenanceDate = result;
        _dateController.text = DateFormat(DATE_FORMAT_DAY).format(result);
      });
    }
  }

  /// New operation priced in [currency].
  static MaintenanceOperation _newOperation(CurrencyCode currency) =>
      MaintenanceOperation(type: MaintenanceOperationType.engineOil, currency: currency);

  static double? _parsePrice(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value.trim().replaceAll(',', '.').replaceAll(' ', '').replaceAll("'", ''));
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: _chooseDate,
      decoration: const InputDecoration(icon: Icon(Icons.calendar_today), labelText: AppString.maintenanceDate),
      validator: (value) => value == null || value.isEmpty ? AppString.maintenanceDateMandatory : null,
    );
  }

  Widget _buildOdometerField() {
    return TextFormField(
      initialValue: _maintenance.odometerKm?.toString(),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        icon: Icon(Icons.speed),
        labelText: AppString.maintenanceOdometer,
        helperText: AppString.maintenanceOdometerHelper,
        suffixText: 'km',
      ),
      onSaved: (value) => _maintenance.odometerKm = int.tryParse(value ?? ''),
    );
  }

  Widget _buildOperation(MaintenanceOperation operation) {
    final bool isOther = operation.type == MaintenanceOperationType.other;
    return Container(
      key: ObjectKey(operation),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.white),
      ),
      padding: const EdgeInsets.fromLTRB(12.0, 4.0, 4.0, 10.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<MaintenanceOperationType>(
                  initialValue: operation.type,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: AppString.maintenanceOperationType),
                  items: MaintenanceOperationType.values
                      .map((t) => DropdownMenuItem<MaintenanceOperationType>(value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (value) => setState(() => operation.type = value ?? operation.type),
                ),
              ),
              IconButton(
                tooltip: AppString.maintenanceOperationRemove,
                icon: Icon(Icons.close, color: Colors.black.withAlpha(140)),
                onPressed: () => setState(() => _maintenance.operations.remove(operation)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: operation.label,
                    decoration: InputDecoration(
                      labelText: isOther ? AppString.maintenanceOperationLabelOther : AppString.maintenanceOperationLabel,
                    ),
                    onChanged: (value) => operation.label = value.trim().isEmpty ? null : value.trim(),
                    validator: (value) => isOther && (value == null || value.trim().isEmpty)
                        ? AppString.maintenanceOperationLabelMandatory
                        : null,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: operation.price?.toStringAsFixed(2),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: AppString.maintenanceOperationPrice,
                      // currency picked per price, parts of a same maintenance may be bought in different countries
                      suffixIcon: DropdownButtonHideUnderline(
                        child: DropdownButton<CurrencyCode>(
                          value: operation.currency,
                          isDense: true,
                          items: CurrencyCode.values
                              .map((c) => DropdownMenuItem<CurrencyCode>(value: c, child: Text(c.code)))
                              .toList(),
                          onChanged: (value) => setState(() => operation.currency = value ?? operation.currency),
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                    onChanged: (value) => setState(() => operation.price = _parsePrice(value)),
                    validator: (value) =>
                        value != null && value.trim().isNotEmpty && _parsePrice(value) == null
                        ? AppString.priceInvalid
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsSection() {
    final String? total = MaintenanceUtils.formatAmounts(MaintenanceUtils.sumOperations(_maintenance.operations));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.build, color: Colors.black.withAlpha(115)),
            const SizedBox(width: 16.0),
            Text(
              AppString.maintenanceOperations,
              style: TextStyle(color: Colors.black.withAlpha(170), fontSize: 15.0),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        for (final MaintenanceOperation operation in _maintenance.operations) ...[
          _buildOperation(operation),
          const SizedBox(height: 8.0),
        ],
        if (_operationsError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              _operationsError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12.5),
            ),
          ),
        Row(
          children: <Widget>[
            TextButton.icon(
              onPressed: () => setState(() {
                _operationsError = null;
                // same currency as the previous line, parts bought in the same shop are entered in a row
                _maintenance.operations.add(
                  _newOperation(
                    _maintenance.operations.isNotEmpty ? _maintenance.operations.last.currency : _defaultCurrency,
                  ),
                );
              }),
              icon: const Icon(Icons.add),
              label: Text(AppString.maintenanceOperationAdd),
            ),
            const SizedBox(width: 8.0),
            if (total != null)
              Expanded(
                child: Text(
                  "${AppString.maintenanceTotal} : $total",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Checkbox telling whether the maintenance is a service of the plan, restarting its countdown. Until touched, it
  /// is checked when one of the operations is a plan service (oil change...) and not for one-off repairs (a tire...).
  Widget _buildResetsPlanField() {
    if (!_resetsPlanTouched) {
      _maintenance.resetsPlan = _maintenance.operations.any(
        (o) => MaintenanceOperationType.planServices.contains(o.type),
      );
    }
    return CheckboxListTile(
      value: _maintenance.resetsPlan,
      onChanged: (bool? value) => setState(() {
        _resetsPlanTouched = true;
        _maintenance.resetsPlan = value ?? false;
      }),
      title: const Text(AppString.maintenanceResetsPlan),
      subtitle: const Text(AppString.maintenanceResetsPlanHelp),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildCommentField() {
    return TextFormField(
      initialValue: _maintenance.comment,
      minLines: 2,
      maxLines: 6,
      maxLength: 1000,
      decoration: const InputDecoration(icon: Icon(Icons.comment), labelText: AppString.maintenanceComment),
      onSaved: (value) => _maintenance.comment = value == null || value.trim().isEmpty ? null : value.trim(),
    );
  }

  Future<void> _submit() async {
    if (_saving) return;
    final bool valid = _formKey.currentState!.validate();
    if (_maintenance.operations.isEmpty) {
      setState(() => _operationsError = AppString.maintenanceOperationsMandatory);
      return;
    }
    if (!valid) return;
    _formKey.currentState!.save();

    _saving = true;
    final bool ok = await Provider.of<BikeMaintenanceProvider>(
      context,
      listen: false,
    ).saveMaintenance(_bike.id!, _maintenance);
    _saving = false;
    if (ok && mounted) Navigator.of(context).pop();
  }

  void _confirmAndDelete() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(AppString.confirmation),
        content: Text(AppString.maintenanceDeletionAreYouSure),
        actions: <Widget>[
          TextButton(child: Text(AppString.cancel), onPressed: () => Navigator.of(dialogContext).pop()),
          TextButton(
            child: Text(AppString.confirm),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final bool ok = await Provider.of<BikeMaintenanceProvider>(
                context,
                listen: false,
              ).deleteMaintenance(_bike.id!, _maintenance);
              if (ok && mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormScaffold(
      title: _isEditing ? AppString.maintenanceEdit : AppString.maintenanceCreate,
      formKey: _formKey,
      onSave: _submit,
      onDelete: _isEditing ? _confirmAndDelete : null,
      fields: <Widget>[
        _buildDateField(),
        _buildOdometerField(),
        _buildOperationsSection(),
        _buildResetsPlanField(),
        _buildCommentField(),
      ],
    );
  }
}
