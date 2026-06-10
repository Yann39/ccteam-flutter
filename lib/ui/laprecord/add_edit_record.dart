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
import 'package:ccteam/models/track.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/providers/record_creation_provider.dart';
import 'package:ccteam/services/tracks_service.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/form_scaffold.dart';
import 'package:ccteam/widgets/info_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/enums.dart';

class AddEditRecord extends StatefulWidget {
  const AddEditRecord({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddEditRecordState();
  }
}

class _AddEditRecordState extends State<AddEditRecord> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final TextEditingController _datePickerController = new TextEditingController();
  final TracksService _tracksService = new TracksService();

  Future<List<Track>>? _futureTracks;
  Track? _selectedTrack;

  // local state for the record visibility switch
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    _futureTracks = _tracksService.fetchTracks();

    final record = Provider.of<RecordCreationProvider>(context, listen: false).record;
    if (record.recordDate != null) {
      _datePickerController.text = DateFormat(DATE_FORMAT_DAY).format(record.recordDate!);
    }
    _isPublic = record.isPublic ?? true;
  }

  /// Initialize and display a Date picker related to the specified
  /// [controller] in the specified [context]. The chrono form only
  /// captures the day (time-of-day isn't meaningful for a chrono).
  Future _chooseDate(BuildContext context, TextEditingController controller, DateTime? defaultValue) async {
    final DateTime currentDate = DateTime.now();
    final DateTime initialDate = defaultValue ?? currentDate;

    final DateTime? dateResult = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime.now(),
    );

    if (dateResult != null) {
      setState(() {
        controller.text = DateFormat(DATE_FORMAT_DAY).format(dateResult);
      });
    }
  }

  /// Validate the form then submit data to backend
  void submitForm() {
    final FormState form = _formKey.currentState!;

    if (!form.validate()) {
      Provider.of<MessageProvider>(context, listen: false).setMessage(AppString.formNotValid, MessageType.ERROR);
    } else {
      // this invokes each onSaved event
      form.save();

      Provider.of<RecordCreationProvider>(context, listen: false).record.member = Provider.of<LoginProvider>(
        context,
        listen: false,
      ).loggedMember;

      // the visibility switch is not a form field, apply it explicitly
      Provider.of<RecordCreationProvider>(context, listen: false).record.isPublic = _isPublic;

      // submit data to backend, if id is set this is an update, else a creation
      if (Provider.of<RecordCreationProvider>(context, listen: false).record.id != null) {
        // update the news go back with a message, the result is awaited in caller
        Provider.of<RecordCreationProvider>(context, listen: false).updateRecord().then(
          (value) {
            Navigator.pop(context, AppString.recordUpdated);
          },
          onError: (error) {
            Navigator.pop(context, AppString.recordUpdateFailed);
          },
        );
      } else {
        // create the record go back with a message, the result is awaited in caller
        Provider.of<RecordCreationProvider>(context, listen: false).createRecord().then(
          (value) {
            Navigator.pop(context, AppString.recordCreated);
          },
          onError: (error) {
            Navigator.pop(context, AppString.recordCreationFailed);
          },
        );
      }
    }
  }

  Widget build(BuildContext context) {
    RecordCreationProvider _recordCreationProvider = Provider.of<RecordCreationProvider>(context, listen: true);

    final _dateField = GestureDetector(
      onTap: () => _chooseDate(context, _datePickerController, _recordCreationProvider.record.recordDate),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            icon: const Icon(Icons.calendar_today),
            hintText: AppString.recordDateHint,
            labelText: AppString.recordDate,
          ),
          controller: _datePickerController,
          keyboardType: TextInputType.datetime,
          validator: (val) => (val == null || val.isEmpty)
              ? AppString.recordDateMandatory
              : (AppDateUtils.isAfterNow(val, DATE_FORMAT_DAY) ? AppString.recordDateNotValid : null),
          onSaved: (val) => _recordCreationProvider.record.recordDate = DateFormat(DATE_FORMAT_DAY).parseStrict(val!),
        ),
      ),
    );

    final _trackField = FutureBuilder<List<Track>>(
      future: _futureTracks,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: <Widget>[
              DropdownButtonFormField<Track>(
                initialValue: _selectedTrack != null
                    ? _selectedTrack
                    : _recordCreationProvider.record.id != null
                    ? snapshot.data!.firstWhere(
                        (Track t) => t.id == _recordCreationProvider.record.track!.id,
                        orElse: () => snapshot.data!.first,
                      )
                    : snapshot.data!.isNotEmpty
                    ? snapshot.data!.first
                    : null,
                decoration: const InputDecoration(
                  icon: const Icon(CustomIcons.track),
                  hintText: AppString.eventTrackIdHint,
                  labelText: AppString.eventTrackId,
                ),
                items: snapshot.data!.map((Track val) {
                  return DropdownMenuItem<Track>(value: val, child: Text(val.name!));
                }).toList(),
                onChanged: (Track? val) {
                  setState(() {
                    _selectedTrack = val;
                  });
                },
                onSaved: (val) => _recordCreationProvider.record.track = val,
                validator: (val) => val == null ? AppString.eventTrackIdMandatory : null,
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a loading spinner
        return CircularProgressIndicator();
      },
    );

    final _lapTimeField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.timer),
        hintText: AppString.recordLapTimeHint,
        labelText: AppString.recordLapTime,
      ),
      keyboardType: TextInputType.number,
      maxLines: 1,
      inputFormatters: <TextInputFormatter>[LapTimeTextInputFormatter()],
      validator: (val) {
        if (val == null || val.isEmpty) return AppString.recordLapTimeMandatory;
        final RegExpMatch? m = RegExp("^(\\d{2})'(\\d{2})\"(\\d{1,3})\$").firstMatch(val);
        if (m == null) return AppString.recordLapTimeNotValid;
        final int seconds = int.parse(m.group(2)!);
        if (seconds >= 60) return AppString.recordLapTimeNotValid;
        return null;
      },
      onSaved: (val) => _recordCreationProvider.record.lapTime = AppDateUtils.toLapTimeDuration(val),
      initialValue: AppDateUtils.toLapTimeString(_recordCreationProvider.record.lapTime),
    );

    final _conditions = DropdownButtonFormField<TrackCondition>(
      initialValue: _recordCreationProvider.selectedTrackCondition,
      decoration: const InputDecoration(
        icon: Icon(Icons.sunny_snowing),
        hintText: AppString.recordConditionHint,
        labelText: AppString.recordConditionLabel,
      ),
      items: TrackCondition.values.map((TrackCondition value) {
        return DropdownMenuItem<TrackCondition>(value: value, child: Text(value.name));
      }).toList(),
      onChanged: (TrackCondition? value) {
        _recordCreationProvider.selectTrackCondition(value!);
      },
      onSaved: (val) => _recordCreationProvider.record.conditions = val!.name,
      validator: (val) => val == null ? AppString.recordConditionMandatory : null,
    );

    final _bikeField = DropdownButtonFormField<Bike>(
      initialValue: _recordCreationProvider.selectedBike,
      decoration: const InputDecoration(
        icon: Icon(CustomIcons.motorbike_plain),
        hintText: AppString.recordBikeHint,
        labelText: AppString.recordBikeLabel,
      ),
      items: Provider.of<LoginProvider>(context, listen: false).loggedMember!.bikes!.map((Bike bike) {
        return DropdownMenuItem<Bike>(value: bike, child: Text("${bike.manufacturer} ${bike.modelName}"));
      }).toList(),
      onChanged: (Bike? val) {
        _recordCreationProvider.selectBike(val!);
      },
      validator: (val) => val == null ? AppString.recordBikeMandatory : null,
    );

    final _commentsField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.comment),
        hintText: AppString.recordCommentsHint,
        labelText: AppString.recordCommentsLabel,
      ),
      keyboardType: TextInputType.text,
      maxLines: 3,
      onSaved: (val) => _recordCreationProvider.record.comments = val,
      initialValue: _recordCreationProvider.record.comments,
    );

    final _isPublicField = SwitchListTile(
      title: const Text(AppString.recordIsPublicLabel),
      subtitle: const Text(AppString.recordIsPublicHelp),
      value: _isPublic,
      onChanged: (bool value) => setState(() => _isPublic = value),
      secondary: Icon(_isPublic ? Icons.public : Icons.lock),
      contentPadding: EdgeInsets.zero,
    );

    return FormScaffold(
      title: AppString.recordEdit,
      formKey: _formKey,
      loadingStatus: _recordCreationProvider.loadingStatus,
      onSave: submitForm,
      fields: <Widget>[
        const InfoBanner(message: AppString.recordFormHelp),
        _dateField,
        _trackField,
        _bikeField,
        _lapTimeField,
        _conditions,
        _commentsField,
        _isPublicField,
      ],
    );
  }
}

/// Input formatter that turns raw digit input into a lap-time string
/// of the form `MM'SS"mmm`.
///
/// The user types digits 0–9 only; this formatter:
///  1. strips anything that isn't a digit (so paste, autocorrect and
///     leftover separators from the previous render can't smuggle
///     anything in),
///  2. caps the digit count at 7 (2 minutes + 2 seconds + 3 ms),
///  3. inserts `'` after the 2nd digit and `"` after the 4th — but
///     only when there is an actual digit to "anchor" them, so
///     backspacing past a digit naturally drops the trailing
///     separator instead of leaving it stranded,
///  4. re-positions the caret so it lands at exactly the same logical
///     position relative to the digits (typing, backspacing and
///     mid-string editing all behave naturally).
///
/// Two additional details make backspace feel right:
///  - The caret formula only counts a separator as "before the caret"
///    if that separator is actually rendered. Without this guard the
///    caret can land beyond the text length, which Flutter silently
///    rejects — that was the cause of the "delete stops at \"" bug.
///  - When the user deletes a separator (text gets shorter but the
///    digit count is unchanged), we also drop the digit just before
///    it. Otherwise we'd re-insert the same separator at the same
///    position on every render and backspace would look like a no-op.
class LapTimeTextInputFormatter extends TextInputFormatter {
  static const int _maxDigits = 7; // MM (2) + SS (2) + mmm (3)

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String raw = newValue.text;
    final int originalCaret = newValue.selection.end.clamp(0, raw.length);

    // pull out digits from the new value + count how many sit to the left of the caret
    final StringBuffer digitsBuf = StringBuffer();
    int digitsBeforeCaret = 0;
    for (int i = 0; i < raw.length; i++) {
      if (_isDigit(raw.codeUnitAt(i))) {
        digitsBuf.write(raw[i]);
        if (i < originalCaret) digitsBeforeCaret++;
      }
    }
    String digits = digitsBuf.toString();

    // count digits in the old value too, so we can detect a
    // "separator-only deletion" — i.e. the user backspaced a `'` or `"`
    // in the middle of the text. In that case the digit count is
    // unchanged, but the text shrank. We absorb the deletion by also
    // dropping the digit immediately to the left of the caret, so
    // backspace "eats through" the separator rather than letting it
    // re-grow at the same spot.
    int oldDigitCount = 0;
    for (int i = 0; i < oldValue.text.length; i++) {
      if (_isDigit(oldValue.text.codeUnitAt(i))) oldDigitCount++;
    }
    if (digits.length == oldDigitCount && raw.length < oldValue.text.length && digitsBeforeCaret > 0) {
      digits = digits.substring(0, digitsBeforeCaret - 1) + digits.substring(digitsBeforeCaret);
      digitsBeforeCaret -= 1;
    }

    // cap at 7 digits = MM + SS + mmm
    if (digits.length > _maxDigits) {
      digits = digits.substring(0, _maxDigits);
      if (digitsBeforeCaret > _maxDigits) digitsBeforeCaret = _maxDigits;
    }

    // re-assemble with `'` after the 2nd digit and `"` after the 4th.
    // The separators are only emitted right before a digit, so a
    // 4-digit input renders as `01'31` (no trailing `"`) and a 2-digit
    // input as `01` — letting backspace naturally drop the separator
    // along with the preceding digit segment.
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) out.write("'");
      if (i == 4) out.write('"');
      out.write(digits[i]);
    }

    // caret position in the formatted text
    final int caret =
        digitsBeforeCaret +
        (digitsBeforeCaret >= 2 && digits.length > 2 ? 1 : 0) +
        (digitsBeforeCaret >= 4 && digits.length > 4 ? 1 : 0);

    return TextEditingValue(
      text: out.toString(),
      selection: TextSelection.collapsed(offset: caret),
    );
  }

  static bool _isDigit(int codeUnit) => codeUnit >= 0x30 && codeUnit <= 0x39;
}
