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
import 'package:ccteam/providers/bike_list_provider.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/form_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEditBike extends StatefulWidget {
  @override
  _AddEditBikeState createState() => _AddEditBikeState();
}

class _AddEditBikeState extends State<AddEditBike> {
  final _formKey = GlobalKey<FormState>();
  late Bike _bike;
  bool _isEditing = false;
  late BikeListProvider _bikeListProvider;

  /// One-shot guard for the init in [didChangeDependencies]. The
  /// callback can re-fire whenever an InheritedWidget we depend on
  /// updates (typically when [BikeListProvider] notifies after a
  /// fetch / add / update / delete). Without this guard the
  /// `_bike = Bike(manufacturer: honda)` line would silently wipe
  /// the user's dropdown selection mid-flow, causing every freshly
  /// created bike to come back as Honda regardless of the picked
  /// brand.
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _bikeListProvider = Provider.of<BikeListProvider>(context, listen: false);
    final Bike? bike = ModalRoute.of(context)!.settings.arguments as Bike?;
    if (bike != null) {
      _bike = bike;
      _isEditing = true;
    } else {
      _bike = Bike(manufacturer: BikeManufacturer.honda.name);
      _isEditing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormScaffold(
      title: _isEditing ? AppString.bikeEdit : AppString.bikeCreate,
      formKey: _formKey,
      onSave: _submit,
      onDelete: _isEditing ? _deleteBike : null,
      fields: <Widget>[_buildManufacturerField(), _buildModelNameField(), _buildEngineSizeField(), _buildYearField()],
    );
  }

  Widget _buildManufacturerField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(icon: Icon(Icons.factory), labelText: AppString.bikeManufacturer),
      initialValue: _bike.manufacturer,
      items: BikeManufacturer.values.map((BikeManufacturer value) {
        return DropdownMenuItem<String>(
          value: value.name,
          child: Text(
            value.name[0].toUpperCase() + value.name.substring(1),
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.normal),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _bike.manufacturer = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppString.bikeManufacturerMandatory;
        }
        return null;
      },
    );
  }

  Widget _buildModelNameField() {
    return TextFormField(
      initialValue: _bike.modelName,
      decoration: const InputDecoration(icon: Icon(CustomIcons.motorbike), labelText: AppString.bikeModel),
      onSaved: (value) => _bike.modelName = value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppString.bikeModelMandatory;
        }
        return null;
      },
    );
  }

  Widget _buildEngineSizeField() {
    return TextFormField(
      initialValue: _bike.engineSize?.toString(),
      decoration: const InputDecoration(icon: Icon(Icons.speed), labelText: AppString.bikeEngineSize, suffixText: "cc"),
      keyboardType: TextInputType.number,
      onSaved: (value) => _bike.engineSize = int.tryParse(value ?? ""),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppString.bikeEngineSizeMandatory;
        }
        if (int.tryParse(value) == null) {
          return AppString.error;
        }
        return null;
      },
    );
  }

  Widget _buildYearField() {
    return TextFormField(
      initialValue: _bike.year?.toString(),
      decoration: const InputDecoration(icon: Icon(Icons.calendar_today), labelText: AppString.bikeYear),
      keyboardType: TextInputType.number,
      onSaved: (value) => _bike.year = int.tryParse(value ?? ""),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppString.bikeYearMandatory;
        }
        if (int.tryParse(value) == null) {
          return AppString.error;
        }
        return null;
      },
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_isEditing) {
        await _bikeListProvider.updateBike(_bike);
      } else {
        await _bikeListProvider.addBike(_bike);
      }
      Navigator.of(context).pop();
    }
  }

  void _deleteBike() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppString.confirmation),
          content: Text(AppString.bikeDeletionAreYouSure),
          actions: <Widget>[
            TextButton(child: Text(AppString.cancel), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: Text(AppString.confirm),
              onPressed: () {
                Navigator.of(context).pop(); // close the dialog
                _bikeListProvider.deleteBike(_bike).then((value) {
                  Navigator.of(context).pop(); // close the page
                });
              },
            ),
          ],
        );
      },
    );
  }
}
