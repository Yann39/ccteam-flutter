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
import 'package:ccteam/models/bike_equipment.dart';
import 'package:ccteam/models/bike_maintenance.dart';
import 'package:ccteam/providers/bike_equipment_provider.dart';
import 'package:ccteam/utils/maintenance_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/form_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Route arguments of the [AddEditEquipment] page: the [bike] the part is fitted to, and the [equipment] to edit
/// (`null` to add a new one).
class EquipmentFormArguments {
  final Bike bike;
  final BikeEquipment? equipment;

  const EquipmentFormArguments({required this.bike, this.equipment});
}

/// Form to add or edit an equipment of a bike: designation, optional price with its currency, and a comment.
class AddEditEquipment extends StatefulWidget {
  const AddEditEquipment({Key? key}) : super(key: key);

  @override
  State<AddEditEquipment> createState() => _AddEditEquipmentState();
}

class _AddEditEquipmentState extends State<AddEditEquipment> {
  /// Maximum lengths, the sizes of the backend columns.
  static const int _maxDesignationLength = 128;
  static const int _maxCommentLength = 500;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Bike _bike;
  late BikeEquipment _equipment;
  bool _isEditing = false;
  bool _initialized = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final EquipmentFormArguments args = ModalRoute.of(context)!.settings.arguments as EquipmentFormArguments;
    _bike = args.bike;
    if (args.equipment != null) {
      // edit a copy, so cancelling leaves the displayed data untouched
      _equipment = args.equipment!.copy();
      _isEditing = true;
    } else {
      // members usually buy their parts in the same country, start from the currency of the last one entered
      final List<BikeEquipment> equipments =
          Provider.of<BikeEquipmentProvider>(context, listen: false).equipmentsOf(_bike.id!) ?? const [];
      _equipment = BikeEquipment(
        designation: '',
        currency: equipments.isNotEmpty ? equipments.last.currency : CurrencyCode.chf,
      );
    }
  }

  Widget _buildDesignationField() {
    return TextFormField(
      initialValue: _equipment.designation,
      textCapitalization: TextCapitalization.sentences,
      inputFormatters: [LengthLimitingTextInputFormatter(_maxDesignationLength)],
      decoration: const InputDecoration(
        icon: Icon(Icons.handyman_outlined),
        labelText: AppString.equipmentDesignation,
        hintText: AppString.equipmentDesignationHint,
      ),
      onSaved: (value) => _equipment.designation = value?.trim() ?? '',
      validator: (value) => value == null || value.trim().isEmpty ? AppString.equipmentDesignationMandatory : null,
    );
  }

  /// Price, with its currency next to it rather than inside the field.
  Widget _buildPriceField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: TextFormField(
            initialValue: _equipment.price?.toStringAsFixed(2),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(icon: Icon(Icons.payments_outlined), labelText: AppString.equipmentPrice),
            onSaved: (value) => _equipment.price = MaintenanceUtils.parsePrice(value),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final double? price = MaintenanceUtils.parsePrice(value);
              return price == null || price < 0 ? AppString.priceInvalid : null;
            },
          ),
        ),
        const SizedBox(width: 12.0),
        SizedBox(
          width: 92.0,
          child: DropdownButtonFormField<CurrencyCode>(
            initialValue: _equipment.currency,
            isExpanded: true,
            decoration: const InputDecoration(labelText: AppString.equipmentCurrency),
            items: CurrencyCode.values
                .map((c) => DropdownMenuItem<CurrencyCode>(value: c, child: Text(c.code)))
                .toList(),
            onChanged: (value) => _equipment.currency = value ?? _equipment.currency,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentField() {
    return TextFormField(
      initialValue: _equipment.comment,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      minLines: 2,
      maxLines: 6,
      maxLength: _maxCommentLength,
      decoration: const InputDecoration(
        icon: Icon(Icons.comment),
        labelText: AppString.equipmentComment,
        hintText: AppString.equipmentCommentHint,
      ),
      onSaved: (value) => _equipment.comment = value == null || value.trim().isEmpty ? null : value.trim(),
    );
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    _saving = true;
    final bool ok = await Provider.of<BikeEquipmentProvider>(
      context,
      listen: false,
    ).saveEquipment(_bike.id!, _equipment);
    _saving = false;
    if (ok && mounted) Navigator.of(context).pop();
  }

  void _confirmAndDelete() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(AppString.confirmation),
        content: Text(AppString.equipmentDeletionAreYouSure),
        actions: <Widget>[
          TextButton(child: Text(AppString.cancel), onPressed: () => Navigator.of(dialogContext).pop()),
          TextButton(
            child: Text(AppString.confirm),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final bool ok = await Provider.of<BikeEquipmentProvider>(
                context,
                listen: false,
              ).deleteEquipment(_bike.id!, _equipment);
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
      title: _isEditing ? AppString.equipmentEdit : AppString.equipmentCreate,
      formKey: _formKey,
      onSave: _submit,
      onDelete: _isEditing ? _confirmAndDelete : null,
      fields: <Widget>[_buildDesignationField(), _buildPriceField(), _buildCommentField()],
    );
  }
}
