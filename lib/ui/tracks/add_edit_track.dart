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

import 'package:ccteam/models/country.dart';
import 'package:ccteam/models/track.dart';
import 'package:ccteam/providers/country_list_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/providers/track_creation_provider.dart';
import 'package:ccteam/providers/track_detail_provider.dart';
import 'package:ccteam/providers/track_list_provider.dart';
import 'package:ccteam/ui/laprecord/add_edit_record.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/form_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Add / edit form for a [Track]. Mirrors [AddEditEvent] / [AddEditNews]
/// in shape and contract: the caller seeds [TrackCreationProvider] with
/// either a fresh `Track()` (creation flow) or a cloned existing
/// instance (edit flow) before pushing this route.
class AddEditTrack extends StatefulWidget {
  const AddEditTrack({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddEditTrackState();
  }
}

class _AddEditTrackState extends State<AddEditTrack> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  /// Currently selected country in the dropdown. We track it locally so
  /// the dropdown re-renders immediately on change (the
  /// [TrackCreationProvider] copy only matters at save time).
  Country? _selectedCountry;

  /// Prime the country list once, after the State is attached to the
  /// tree (initState can't safely call providers that need a context
  /// hop). The provider keeps the list cached, so reopening the form
  /// later doesn't re-fetch.
  bool _countriesBootstrapped = false;

  @override
  void initState() {
    super.initState();
    final TrackCreationProvider trackCreationProvider = Provider.of<TrackCreationProvider>(context, listen: false);
    _selectedCountry = trackCreationProvider.track.country;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_countriesBootstrapped) return;
    _countriesBootstrapped = true;
    // kick off the country fetch the first time the page is built.
    // The provider's `ensureLoaded` is a no-op when already cached.
    final CountryListProvider countryListProvider = Provider.of<CountryListProvider>(context, listen: false);
    countryListProvider.ensureLoaded();
  }

  /// Validate the form then submit data to backend. On success the new
  /// or updated track is pushed to the list / detail providers so the
  /// rest of the app picks it up without an extra fetch.
  void submitForm(Track track) async {
    final FormState _form = _formKey.currentState!;

    if (!_form.validate()) {
      Provider.of<MessageProvider>(context, listen: false).setMessage(AppString.formNotValid, MessageType.ERROR);
      return;
    }
    // this invokes each onSaved event
    _form.save();

    final TrackCreationProvider _trackCreationProvider = Provider.of<TrackCreationProvider>(context, listen: false);
    final TrackListProvider _trackListProvider = Provider.of<TrackListProvider>(context, listen: false);
    final TrackDetailProvider _trackDetailProvider = Provider.of<TrackDetailProvider>(context, listen: false);

    // submit data to backend, if id is set this is an update, else a creation
    if (track.id != null) {
      await _trackCreationProvider.updateTrack();
      // mirror server response into the list + currently-displayed detail
      _trackListProvider.updateTrackInList(_trackCreationProvider.track);
      _trackDetailProvider.setCurrentTrack(_trackCreationProvider.track);
    } else {
      await _trackCreationProvider.createTrack();
      _trackListProvider.addTrackInList(_trackCreationProvider.track);
    }
    if (mounted) Navigator.pop(context);
  }

  /// Delete the current track after user confirmation. Only reachable
  /// in the edit flow (the FormScaffold only shows the trash icon when
  /// [onDelete] is non-null, which we only wire when `track.id != null`).
  void _deleteTrack() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppString.confirmation),
          content: Text(AppString.trackDeletionAreYouSure),
          actions: <Widget>[
            TextButton(
              child: Text(AppString.cancel),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(AppString.confirm),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // close the dialog
                final TrackCreationProvider trackCreationProvider = Provider.of<TrackCreationProvider>(
                  context,
                  listen: false,
                );
                final TrackListProvider trackListProvider = Provider.of<TrackListProvider>(context, listen: false);
                final int trackId = trackCreationProvider.track.id!;
                try {
                  await trackCreationProvider.deleteTrack();
                  trackListProvider.removeTrackFromList(trackId);
                  // back to the track list (pop the form AND the detail page)
                  if (!mounted) return;
                  Navigator.pop(context);
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

    final _nameField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(CustomIcons.track),
        hintText: AppString.trackNameHint,
        labelText: AppString.trackName,
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(128)],
      validator: (val) => (val == null || val.trim().isEmpty) ? AppString.trackNameMandatory : null,
      onSaved: (val) => track.name = val?.trim(),
      initialValue: track.name,
    );

    final _countryField = Consumer<CountryListProvider>(
      builder: (_, countryListProvider, __) {
        if (countryListProvider.loadingStatus == LoadingStatus.loading && countryListProvider.countries.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final List<Country> options = countryListProvider.countries;
        // Look up the current value in the freshly loaded list so the
        // dropdown can match by identity (the saved track may carry an
        // older Country instance with the same code).
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
              child: Text("${c.flagEmoji}  ${c.localizedName(lang)}", overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (Country? val) => setState(() => _selectedCountry = val),
          onSaved: (val) => track.country = val,
          validator: (val) => val == null ? AppString.trackCountryMandatory : null,
        );
      },
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
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
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

    final _websiteField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.public),
        hintText: AppString.trackWebsiteHint,
        labelText: AppString.trackWebsite,
      ),
      maxLines: 1,
      keyboardType: TextInputType.url,
      inputFormatters: [LengthLimitingTextInputFormatter(255)],
      onSaved: (val) => track.website = (val == null || val.trim().isEmpty) ? null : val.trim(),
      initialValue: track.website,
    );

    final _latitudeField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.place),
        hintText: '46.5197',
        labelText: AppString.trackLatitude,
      ),
      maxLines: 1,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
        LengthLimitingTextInputFormatter(16),
      ],
      validator: (val) {
        if (val == null || val.isEmpty) return AppString.trackLatitudeMandatory;
        final double? parsed = double.tryParse(val);
        if (parsed == null || parsed < -90.0 || parsed > 90.0) return AppString.trackLatitudeInvalid;
        return null;
      },
      onSaved: (val) => track.latitude = double.parse(val!),
      initialValue: track.latitude?.toString(),
    );

    final _longitudeField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.place_outlined),
        hintText: '6.6323',
        labelText: AppString.trackLongitude,
      ),
      maxLines: 1,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
        LengthLimitingTextInputFormatter(16),
      ],
      validator: (val) {
        if (val == null || val.isEmpty) return AppString.trackLongitudeMandatory;
        final double? parsed = double.tryParse(val);
        if (parsed == null || parsed < -180.0 || parsed > 180.0) return AppString.trackLongitudeInvalid;
        return null;
      },
      onSaved: (val) => track.longitude = double.parse(val!),
      initialValue: track.longitude?.toString(),
    );

    // Reminder shown only on the creation flow — once a track exists
    // the icon / cover image are presumably already bundled (or the
    // default ones are used) so we don't need to nag on every edit.
    final Widget _assetsReminder = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        border: Border.all(color: Colors.amber[300]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, size: 18.0, color: Colors.amber[800]),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              AppString.trackAssetsReminder,
              style: TextStyle(
                color: Colors.amber[900],
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );

    return FormScaffold(
      title: isEditing ? AppString.trackEdit : AppString.trackCreate,
      formKey: _formKey,
      loadingStatus: _trackCreationProvider.loadingStatus,
      onSave: () => submitForm(track),
      // delete action only when editing an existing track
      onDelete: isEditing ? _deleteTrack : null,
      fields: <Widget>[
        if (!isEditing) _assetsReminder,
        _nameField,
        _countryField,
        _distanceField,
        _lapRecordField,
        _websiteField,
        _latitudeField,
        _longitudeField,
      ],
    );
  }
}
