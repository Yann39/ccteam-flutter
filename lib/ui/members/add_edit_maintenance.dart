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

  /// Maximum length of an operation precision, the size of the backend column.
  static const int _maxLabelLength = 500;

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

  /// Compact outlined decoration of the operation fields, same look as the session steppers of the event form.
  static InputDecoration _operationFieldDecoration({String? hintText, Widget? suffixIcon}) {
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.black.withAlpha(40)),
    );
    return InputDecoration(
      hintText: hintText,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(borderSide: BorderSide(color: Colors.blue[700]!, width: 1.5)),
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    );
  }

  /// One operation: the kind of operation on a first line with the remove button, then the optional precision, then
  /// the price with its own currency (parts of a same maintenance may be bought in different countries).
  Widget _buildOperation(MaintenanceOperation operation) {
    final bool isOther = operation.type == MaintenanceOperationType.other;
    return Padding(
      key: ObjectKey(operation),
      padding: const EdgeInsets.only(left: 38.0, bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                DropdownButtonFormField<MaintenanceOperationType>(
                  initialValue: operation.type,
                  isExpanded: true,
                  decoration: _operationFieldDecoration(),
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Colors.black87),
                  items: MaintenanceOperationType.values
                      .map((t) => DropdownMenuItem<MaintenanceOperationType>(value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (value) => setState(() => operation.type = value ?? operation.type),
                ),
                const SizedBox(height: 6.0),
                // multiline: the precision may list several things (oil brand, references...), one per line.
                // Grows up to 5 lines then scrolls, capped to the backend column size.
                TextFormField(
                  initialValue: operation.label,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5,
                  inputFormatters: [LengthLimitingTextInputFormatter(_maxLabelLength)],
                  style: const TextStyle(fontSize: 14.0),
                  decoration: _operationFieldDecoration(
                    hintText: isOther ? AppString.maintenanceOperationLabelOther : AppString.maintenanceOperationLabel,
                  ),
                  onChanged: (value) => operation.label = value.trim().isEmpty ? null : value.trim(),
                  validator: (value) => isOther && (value == null || value.trim().isEmpty)
                      ? AppString.maintenanceOperationLabelMandatory
                      : null,
                ),
                const SizedBox(height: 6.0),
                // the price gets the whole line, its currency sits next to it rather than inside the field
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        initialValue: operation.price?.toStringAsFixed(2),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 14.0),
                        decoration: _operationFieldDecoration(hintText: AppString.maintenanceOperationPrice),
                        onChanged: (value) => setState(() => operation.price = _parsePrice(value)),
                        validator: (value) =>
                            value != null && value.trim().isNotEmpty && _parsePrice(value) == null
                            ? AppString.priceInvalid
                            : null,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    SizedBox(
                      width: 92.0,
                      child: DropdownButtonFormField<CurrencyCode>(
                        initialValue: operation.currency,
                        isExpanded: true,
                        decoration: _operationFieldDecoration(),
                        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.black87),
                        items: CurrencyCode.values
                            .map((c) => DropdownMenuItem<CurrencyCode>(value: c, child: Text(c.code)))
                            .toList(),
                        onChanged: (value) => setState(() => operation.currency = value ?? operation.currency),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: AppString.maintenanceOperationRemove,
            onPressed: () => setState(() => _maintenance.operations.remove(operation)),
            icon: Icon(Icons.close, size: 20.0, color: Colors.black.withAlpha(140)),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  /// Operations editor, laid out like the session schedule of the event form: section title with the total below
  /// it, one indented block per operation, and an "add" button at the bottom.
  Widget _buildOperationsSection() {
    final String? total = MaintenanceUtils.formatAmounts(MaintenanceUtils.sumOperations(_maintenance.operations));

    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.build_outlined, size: 26.0, color: Colors.black.withAlpha(160)),
              const SizedBox(width: 16.0),
              Text(
                AppString.maintenanceOperations,
                style: TextStyle(fontSize: 16.0, color: Colors.black87, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          // total in place of a hint text: it says what the operations add up to
          if (total != null)
            Padding(
              padding: const EdgeInsets.only(left: 38.0, top: 2.0),
              child: Text(
                "${AppString.maintenanceTotal} : $total",
                style: TextStyle(fontSize: 12.0, color: Colors.black.withAlpha(120)),
              ),
            ),
          const SizedBox(height: 10.0),
          for (final MaintenanceOperation operation in _maintenance.operations) _buildOperation(operation),
          if (_operationsError != null)
            Padding(
              padding: const EdgeInsets.only(left: 38.0, bottom: 4.0),
              child: Text(
                _operationsError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12.5),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: TextButton.icon(
              onPressed: () => setState(() {
                _operationsError = null;
                // same currency as the previous line, parts bought in the same shop are entered in a row
                _maintenance.operations.add(
                  _newOperation(
                    _maintenance.operations.isNotEmpty ? _maintenance.operations.last.currency : _defaultCurrency,
                  ),
                );
              }),
              icon: const Icon(Icons.add, size: 18.0),
              label: Text(AppString.maintenanceOperationAdd),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8.0)),
            ),
          ),
        ],
      ),
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
