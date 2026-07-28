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
import 'package:ccteam/models/track.dart';
import 'package:ccteam/providers/circuit_detail_provider.dart';
import 'package:ccteam/providers/circuit_list_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/providers/track_creation_provider.dart';
import 'package:ccteam/providers/track_detail_provider.dart';
import 'package:ccteam/providers/track_list_provider.dart';
import 'package:ccteam/ui/laprecord/add_edit_record.dart' show LapTimeTextInputFormatter;
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/utils/track_utils.dart';
import 'package:ccteam/widgets/form_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Add / edit form for a [Track], a single version (layout) of a circuit. The
/// caller seeds [TrackCreationProvider] with either a fresh `Track()` (creation,
/// optionally with its `circuit` pre-set when adding from a circuit) or a cloned
/// existing instance (edit).
class AddEditTrack extends StatefulWidget {
  const AddEditTrack({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddEditTrackState();
  }
}

class _AddEditTrackState extends State<AddEditTrack> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  /// Currently selected parent circuit, tracked locally so the dropdown
  /// re-renders immediately on change.
  Circuit? _selectedCircuit;

  @override
  void initState() {
    super.initState();
    _selectedCircuit = Provider.of<TrackCreationProvider>(context, listen: false).track.circuit;
  }

  /// Validate + submit. On success the new / updated version is mirrored into
  /// the version list, the currently-shown version detail (edit flow) and the
  /// parent circuit detail so its versions list refreshes.
  void submitForm(Track track) async {
    final FormState _form = _formKey.currentState!;
    if (!_form.validate()) {
      Provider.of<MessageProvider>(context, listen: false).setMessage(AppString.formNotValid, MessageType.ERROR);
      return;
    }
    _form.save();

    final TrackCreationProvider _creationProvider = Provider.of<TrackCreationProvider>(context, listen: false);
    final TrackListProvider _listProvider = Provider.of<TrackListProvider>(context, listen: false);
    final TrackDetailProvider _detailProvider = Provider.of<TrackDetailProvider>(context, listen: false);
    final CircuitDetailProvider _circuitDetailProvider = Provider.of<CircuitDetailProvider>(context, listen: false);

    if (track.id != null) {
      await _creationProvider.updateTrack();
      _listProvider.updateTrackInList(_creationProvider.track);
      _detailProvider.setCurrentTrack(_creationProvider.track);
    } else {
      await _creationProvider.createTrack();
      _listProvider.addTrackInList(_creationProvider.track);
    }

    // refresh the parent circuit detail so the new / updated version shows up
    final Circuit? shownCircuit = _circuitDetailProvider.currentCircuit;
    if (shownCircuit != null && _creationProvider.track.circuit?.id == shownCircuit.id) {
      _circuitDetailProvider.fetchCircuit(shownCircuit);
    }

    if (mounted) Navigator.pop(context);
  }

  /// Delete the current version after confirmation. Only reachable in the edit flow.
  void _deleteTrack() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppString.confirmation),
          content: Text(AppString.trackDeletionAreYouSure),
          actions: <Widget>[
            TextButton(child: Text(AppString.cancel), onPressed: () => Navigator.of(dialogContext).pop()),
            TextButton(
              child: Text(AppString.confirm),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final TrackCreationProvider creationProvider = Provider.of<TrackCreationProvider>(
                  context,
                  listen: false,
                );
                final TrackListProvider listProvider = Provider.of<TrackListProvider>(context, listen: false);
                final CircuitDetailProvider circuitDetailProvider = Provider.of<CircuitDetailProvider>(
                  context,
                  listen: false,
                );
                final Track track = creationProvider.track;
                final int trackId = track.id!;
                final Circuit? shownCircuit = circuitDetailProvider.currentCircuit;
                try {
                  await creationProvider.deleteTrack();
                  listProvider.removeTrackFromList(trackId);
                  if (shownCircuit != null && track.circuit?.id == shownCircuit.id) {
                    circuitDetailProvider.fetchCircuit(shownCircuit);
                  }
                  if (!mounted) return;
                  // back to whatever opened the form (circuit detail refreshes itself above)
                  Navigator.pop(context);
                } catch (_) {
                  // snackbar already raised by TrackCreationProvider.deleteTrack
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
    final TrackCreationProvider _trackCreationProvider = Provider.of<TrackCreationProvider>(context, listen: true);
    final Track track = _trackCreationProvider.track;
    final bool isEditing = track.id != null;

    final _circuitField = Consumer<CircuitListProvider>(
      builder: (_, circuitListProvider, __) {
        if (circuitListProvider.loadingStatus == LoadingStatus.loading && circuitListProvider.circuits.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final List<Circuit> options = circuitListProvider.circuits;
        // resolve the seeded circuit against the freshly-loaded list so the
        // dropdown matches by identity (id) even across instances
        final Circuit? currentValue = _selectedCircuit == null
            ? null
            : options.firstWhere((c) => c.id == _selectedCircuit!.id, orElse: () => _selectedCircuit!);
        return DropdownButtonFormField<Circuit>(
          initialValue: currentValue,
          isExpanded: true,
          decoration: const InputDecoration(
            icon: Icon(CustomIcons.track),
            hintText: AppString.trackCircuitLabel,
            labelText: AppString.trackCircuitLabel,
          ),
          items: options.map((Circuit c) {
            return DropdownMenuItem<Circuit>(
              value: c,
              child: Text(c.name ?? '', overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (Circuit? val) => setState(() => _selectedCircuit = val),
          onSaved: (val) => track.circuit = val,
          validator: (val) => val == null ? AppString.trackCircuitMandatory : null,
        );
      },
    );

    final _variantNameField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.alt_route),
        hintText: AppString.trackVariantNameHint,
        labelText: AppString.trackVariantName,
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(128)],
      onSaved: (val) => track.variantName = (val == null || val.trim().isEmpty) ? null : val.trim(),
      initialValue: track.variantName,
    );

    final _distanceField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.straighten),
        hintText: AppString.trackDistanceHint,
        labelText: AppString.trackDistance,
        suffixText: 'm',
      ),
      maxLines: 1,
      keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
      validator: (val) {
        if (val == null || val.isEmpty) return AppString.trackDistanceMandatory;
        final int? parsed = int.tryParse(val);
        if (parsed == null || parsed <= 0) return AppString.trackDistanceMandatory;
        return null;
      },
      onSaved: (val) => track.distance = int.parse(val!),
      initialValue: track.distance?.toString(),
    );

    final _lapRecordField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.timer),
        hintText: AppString.trackLapRecordHint,
        labelText: AppString.trackLapRecord,
      ),
      maxLines: 1,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[LapTimeTextInputFormatter()],
      validator: (val) {
        if (val == null || val.isEmpty) return null; // optional
        final RegExpMatch? m = RegExp("^(\\d{2})'(\\d{2})\"(\\d{1,3})\$").firstMatch(val);
        if (m == null) return AppString.trackLapRecordInvalid;
        final int seconds = int.parse(m.group(2)!);
        if (seconds >= 60) return AppString.trackLapRecordInvalid;
        return null;
      },
      onSaved: (val) {
        if (val == null || val.isEmpty) {
          track.lapRecord = null;
        } else {
          track.lapRecord = AppDateUtils.toLapTimeDuration(val);
        }
      },
      initialValue: AppDateUtils.toLapTimeString(track.lapRecord),
    );

    final _lapRecordInfoField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.person_outline),
        hintText: AppString.trackLapRecordInfoHint,
        labelText: AppString.trackLapRecordInfo,
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(255)],
      onSaved: (val) => track.lapRecordInfo = (val == null || val.trim().isEmpty) ? null : val.trim(),
      initialValue: track.lapRecordInfo,
    );

    final _iconKeyField = TextFormField(
      decoration: InputDecoration(
        icon: Icon(TrackUtils.iconForTrack(track)),
        hintText: AppString.trackIconKeyHint,
        labelText: AppString.trackIconKey,
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      onSaved: (val) => track.iconKey = (val == null || val.trim().isEmpty) ? null : val.trim(),
      initialValue: track.iconKey,
    );

    return FormScaffold(
      title: isEditing ? AppString.trackEdit : AppString.trackCreate,
      formKey: _formKey,
      loadingStatus: _trackCreationProvider.loadingStatus,
      onSave: () => submitForm(track),
      onDelete: isEditing ? _deleteTrack : null,
      fields: <Widget>[
        _circuitField,
        _variantNameField,
        _distanceField,
        _lapRecordField,
        _lapRecordInfoField,
        _iconKeyField,
      ],
    );
  }
}
