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
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bikeListProvider = Provider.of<BikeListProvider>(context);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppString.bikeEdit : AppString.bikeCreate),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildManufacturerField(),
              SizedBox(height: 16),
              _buildModelNameField(),
              SizedBox(height: 16),
              _buildEngineSizeField(),
              SizedBox(height: 16),
              _buildYearField(),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: Text(AppString.save),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManufacturerField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: AppString.bikeManufacturer,
        border: OutlineInputBorder(),
      ),
      value: _bike.manufacturer,
      items: BikeManufacturer.values.map((BikeManufacturer value) {
        return DropdownMenuItem<String>(
          value: value.name,
          child: Text(value.name[0].toUpperCase() + value.name.substring(1)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _bike.manufacturer = value;
        });
      },
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
      decoration: InputDecoration(
        labelText: AppString.bikeModel,
        border: OutlineInputBorder(),
      ),
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
      decoration: InputDecoration(
        labelText: AppString.bikeEngineSize,
        border: OutlineInputBorder(),
        suffixText: "cc",
      ),
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
      decoration: InputDecoration(
        labelText: AppString.bikeYear,
        border: OutlineInputBorder(),
      ),
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
}
