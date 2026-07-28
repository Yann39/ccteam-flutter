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

import 'package:ccteam/models/circuit.dart';
import 'package:ccteam/models/country.dart';
import 'package:ccteam/providers/circuit_creation_provider.dart';
import 'package:ccteam/providers/circuit_detail_provider.dart';
import 'package:ccteam/providers/circuit_list_provider.dart';
import 'package:ccteam/providers/country_list_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/form_scaffold.dart';
import 'package:ccteam/widgets/info_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Add / edit form for a [Circuit] (venue). Holds the identity shared by every
/// version: name, country, GPS coordinates and website. The caller seeds
/// [CircuitCreationProvider] with either a fresh `Circuit()` (creation) or a
/// cloned existing instance (edit) before pushing this route.
class AddEditCircuit extends StatefulWidget {
  const AddEditCircuit({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddEditCircuitState();
  }
}

class _AddEditCircuitState extends State<AddEditCircuit> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  Country? _selectedCountry;
  bool _countriesBootstrapped = false;

  @override
  void initState() {
    super.initState();
    final CircuitCreationProvider provider =
        Provider.of<CircuitCreationProvider>(context, listen: false);
    _selectedCountry = provider.circuit.country;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_countriesBootstrapped) return;
    _countriesBootstrapped = true;
    Provider.of<CountryListProvider>(context, listen: false).ensureLoaded();
  }

  /// Validate + submit. On success the new / updated circuit is pushed to the
  /// list + currently-displayed detail so the rest of the app picks it up.
  void submitForm(Circuit circuit) async {
    final FormState _form = _formKey.currentState!;
    if (!_form.validate()) {
      Provider.of<MessageProvider>(
        context,
        listen: false,
      ).setMessage(AppString.formNotValid, MessageType.ERROR);
      return;
    }
    _form.save();

    final CircuitCreationProvider _creationProvider =
        Provider.of<CircuitCreationProvider>(context, listen: false);
    final CircuitListProvider _listProvider = Provider.of<CircuitListProvider>(
      context,
      listen: false,
    );
    final CircuitDetailProvider _detailProvider =
        Provider.of<CircuitDetailProvider>(context, listen: false);

    if (circuit.id != null) {
      await _creationProvider.updateCircuit();
      _listProvider.updateCircuitInList(_creationProvider.circuit);
      _detailProvider.setCurrentCircuit(_creationProvider.circuit);
    } else {
      await _creationProvider.createCircuit();
      _listProvider.addCircuitInList(_creationProvider.circuit);
    }
    if (mounted) Navigator.pop(context);
  }

  /// Delete the current circuit after confirmation. The server rejects the
  /// deletion when the circuit still has versions, surfaced as a clear message.
  void _deleteCircuit() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppString.confirmation),
          content: Text(AppString.circuitDeletionAreYouSure),
          actions: <Widget>[
            TextButton(
              child: Text(AppString.cancel),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(AppString.confirm),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final CircuitCreationProvider creationProvider =
                    Provider.of<CircuitCreationProvider>(
                      context,
                      listen: false,
                    );
                final CircuitListProvider listProvider =
                    Provider.of<CircuitListProvider>(context, listen: false);
                final int circuitId = creationProvider.circuit.id!;
                try {
                  await creationProvider.deleteCircuit();
                  listProvider.removeCircuitFromList(circuitId);
                  if (!mounted) return;
                  // back to the circuit list (pop the form AND the detail page)
                  Navigator.pop(context);
                  Navigator.pop(context);
                } catch (_) {
                  // the most common failure is "circuit still has versions": make it explicit
                  if (mounted) {
                    Provider.of<MessageProvider>(
                      context,
                      listen: false,
                    ).setMessage(
                      AppString.circuitDeletionHasVersions,
                      MessageType.ERROR,
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final CircuitCreationProvider _creationProvider =
        Provider.of<CircuitCreationProvider>(context, listen: true);
    final Circuit circuit = _creationProvider.circuit;
    final bool isEditing = circuit.id != null;

    final _nameField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(CustomIcons.track),
        hintText: AppString.trackNameHint,
        labelText: AppString.trackName,
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(128)],
      validator: (val) => (val == null || val.trim().isEmpty)
          ? AppString.trackNameMandatory
          : null,
      onSaved: (val) => circuit.name = val?.trim(),
      initialValue: circuit.name,
    );

    final _countryField = Consumer<CountryListProvider>(
      builder: (_, countryListProvider, __) {
        if (countryListProvider.loadingStatus == LoadingStatus.loading &&
            countryListProvider.countries.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final List<Country> options = countryListProvider.countries;
        final Country? currentValue = _selectedCountry == null
            ? null
            : options.firstWhere(
                (c) => c.code == _selectedCountry!.code,
                orElse: () => _selectedCountry!,
              );
        final String lang = Localizations.localeOf(context).languageCode;
        return DropdownButtonFormField<Country>(
          initialValue: currentValue,
          decoration: const InputDecoration(
            icon: Icon(Icons.public),
            hintText: AppString.trackCountry,
            labelText: AppString.trackCountry,
          ),
          isExpanded: true,
          items: options.map((Country c) {
            return DropdownMenuItem<Country>(
              value: c,
              child: Text(
                "${c.flagEmoji}  ${c.localizedName(lang)}",
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (Country? val) => setState(() => _selectedCountry = val),
          onSaved: (val) => circuit.country = val,
          validator: (val) =>
              val == null ? AppString.trackCountryMandatory : null,
        );
      },
    );

    final _websiteField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.public),
        hintText: AppString.trackWebsiteHint,
        labelText: AppString.trackWebsite,
      ),
      maxLines: 1,
      keyboardType: TextInputType.url,
      inputFormatters: [LengthLimitingTextInputFormatter(255)],
      onSaved: (val) => circuit.website = (val == null || val.trim().isEmpty)
          ? null
          : val.trim(),
      initialValue: circuit.website,
    );

    final _latitudeField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.place),
        hintText: '46.5197',
        labelText: AppString.trackLatitude,
      ),
      maxLines: 1,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
        LengthLimitingTextInputFormatter(16),
      ],
      validator: (val) {
        if (val == null || val.isEmpty) return AppString.trackLatitudeMandatory;
        final double? parsed = double.tryParse(val);
        if (parsed == null || parsed < -90.0 || parsed > 90.0)
          return AppString.trackLatitudeInvalid;
        return null;
      },
      onSaved: (val) => circuit.latitude = double.parse(val!),
      initialValue: circuit.latitude?.toString(),
    );

    final _longitudeField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.place_outlined),
        hintText: '6.6323',
        labelText: AppString.trackLongitude,
      ),
      maxLines: 1,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
        LengthLimitingTextInputFormatter(16),
      ],
      validator: (val) {
        if (val == null || val.isEmpty)
          return AppString.trackLongitudeMandatory;
        final double? parsed = double.tryParse(val);
        if (parsed == null || parsed < -180.0 || parsed > 180.0)
          return AppString.trackLongitudeInvalid;
        return null;
      },
      onSaved: (val) => circuit.longitude = double.parse(val!),
      initialValue: circuit.longitude?.toString(),
    );

    return FormScaffold(
      title: isEditing ? AppString.circuitEdit : AppString.circuitCreate,
      formKey: _formKey,
      loadingStatus: _creationProvider.loadingStatus,
      onSave: () => submitForm(circuit),
      onDelete: isEditing ? _deleteCircuit : null,
      fields: <Widget>[
        if (!isEditing)
          const InfoBanner(message: AppString.trackAssetsReminder),
        _nameField,
        _countryField,
        _websiteField,
        _latitudeField,
        _longitudeField,
      ],
    );
  }
}
