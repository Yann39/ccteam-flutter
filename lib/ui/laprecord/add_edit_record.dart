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

import 'package:ccteam/models/track.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/record_creation_provider.dart';
import 'package:ccteam/providers/track_list_provider.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:ccteam/widgets/save_cancel_bar.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _datePickerController =
      new TextEditingController();

  /// Initialize and display a Date picker related to the specified [controller] in the specified [context]
  Future _chooseDate(
    BuildContext context,
    TextEditingController controller,
    DateTime? defaultValue,
  ) async {
    final DateTime currentDate = DateTime.now();
    final TimeOfDay currentTime = TimeOfDay.now();

    // define initial date and time from the specified default DateTime value if set
    final DateTime initialDate = defaultValue ?? currentDate;
    final TimeOfDay initialTime =
        defaultValue != null
            ? TimeOfDay.fromDateTime(defaultValue)
            : currentTime;

    // show the date picker and await for the chosen date
    final DateTime? dateResult = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(currentDate.year - 5),
      lastDate: DateTime(currentDate.year + 5),
    );

    // show the time picker and await for the chosen time
    final TimeOfDay? timeResult = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (dateResult != null && timeResult != null) {
      // build final date with time
      final DateTime finalDateTime = DateTime(
        dateResult.year,
        dateResult.month,
        dateResult.day,
        timeResult.hour,
        timeResult.minute,
      );

      // notify the framework that the internal state of this object has changed
      setState(() {
        controller.text = DateFormat(DATE_FORMAT).format(finalDateTime);
      });
    }
  }

  /// Validate the form then submit data to backend
  void submitForm() {
    final FormState form = _formKey.currentState!;

    if (!form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(AppString.formNotValid),
        ),
      );
    } else {
      // this invokes each onSaved event
      form.save();

      Provider.of<RecordCreationProvider>(
            context,
            listen: false,
          ).record.member =
          Provider.of<LoginProvider>(context, listen: false).loggedMember;

      // submit data to backend, if id is set this is an update, else a creation
      if (Provider.of<RecordCreationProvider>(
            context,
            listen: false,
          ).record.id !=
          null) {
        // update the news go back with a message, the result is awaited in caller
        Provider.of<RecordCreationProvider>(
          context,
          listen: false,
        ).updateRecord().then(
          (value) {
            Navigator.pop(context, AppString.recordUpdated);
          },
          onError: (error) {
            Navigator.pop(context, AppString.recordUpdateFailed);
          },
        );
      } else {
        // create the record go back with a message, the result is awaited in caller
        Provider.of<RecordCreationProvider>(
          context,
          listen: false,
        ).createRecord().then(
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
    RecordCreationProvider _recordCreationProvider =
        Provider.of<RecordCreationProvider>(context, listen: true);
    TrackListProvider _trackListProvider = Provider.of<TrackListProvider>(
      context,
      listen: true,
    );

    final _dateField = GestureDetector(
      onTap:
          () => _chooseDate(
            context,
            _datePickerController,
            _recordCreationProvider.record.recordDate,
          ),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            icon: const Icon(Icons.calendar_today),
            hintText: AppString.recordDateHint,
            labelText: AppString.recordDate,
          ),
          controller: _datePickerController,
          keyboardType: TextInputType.datetime,
          validator:
              (val) =>
                  (val == null || val.isEmpty)
                      ? AppString.recordDateMandatory
                      : (AppDateUtils.isAfterNow(val, DATE_FORMAT)
                          ? AppString.recordDateNotValid
                          : null),
          onSaved:
              (val) =>
                  _recordCreationProvider.record.recordDate = DateFormat(
                    DATE_FORMAT,
                  ).parseStrict(val!),
        ),
      ),
    );

    final _trackField = DropdownButtonFormField<Track>(
      value: _trackListProvider.selectedTrack,
      decoration: const InputDecoration(
        icon: const Icon(CustomIcons.track_sample),
        hintText: AppString.eventTrackIdHint,
        labelText: AppString.eventTrackId,
      ),
      items:
          _trackListProvider.tracks.map((Track value) {
            return DropdownMenuItem<Track>(
              value: value,
              child: Text(value.name!),
            );
          }).toList(),
      onChanged: (Track? value) {
        _trackListProvider.selectTrack(value!);
      },
      onSaved: (val) => _recordCreationProvider.record.track = val,
      validator: (val) => val == null ? AppString.eventTrackIdMandatory : null,
    );

    final _lapTimeField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.timer),
        hintText: AppString.recordLapTimeHint,
        labelText: AppString.recordLapTime,
      ),
      keyboardType: TextInputType.number,
      maxLines: 1,
      inputFormatters: <TextInputFormatter>[
        LengthLimitingTextInputFormatter(9),
        FilteringTextInputFormatter.digitsOnly,
        LapTimeTextInputFormatter(),
      ],
      validator:
          (val) =>
              (val == null || val.isEmpty)
                  ? AppString.recordLapTimeMandatory
                  : null,
      onSaved:
          (val) =>
              _recordCreationProvider
                  .record
                  .lapTime = AppDateUtils.toLapTimeDuration(val),
      initialValue: AppDateUtils.toLapTimeString(
        _recordCreationProvider.record.lapTime,
      ),
    );

    final _conditions = DropdownButtonFormField<TrackCondition>(
      value: _recordCreationProvider.selectedTrackCondition,
      decoration: const InputDecoration(
        icon: Icon(Icons.sunny_snowing),
        hintText: AppString.recordConditionHint,
        labelText: AppString.recordConditionLabel,
      ),
      items:
          TrackCondition.values.map((TrackCondition value) {
            return DropdownMenuItem<TrackCondition>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
      onChanged: (TrackCondition? value) {
        _recordCreationProvider.selectTrackCondition(value!);
      },
      onSaved: (val) => _recordCreationProvider.record.conditions = val!.name,
      validator:
          (val) => val == null ? AppString.recordConditionMandatory : null,
    );

    final listView = ListView(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(
            top: 0,
            left: 16.0,
            right: 16.0,
            bottom: 56.0,
          ),
          child: Form(
            autovalidateMode: AutovalidateMode.disabled,
            key: _formKey,
            child: Column(
              children: <Widget>[
                _dateField,
                _trackField,
                _lapTimeField,
                _conditions,
              ],
            ),
          ),
        ),
      ],
    );

    final List<Widget> actionMenu = [
      TextButton(
        child: Text(
          AppString.cancel.toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      TextButton(
        child: Text(
          AppString.save.toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => submitForm(),
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        title: Text(AppString.recordEdit),
        actions:
            MediaQuery.of(context).orientation == Orientation.portrait
                ? null
                : actionMenu,
      ),
      body:
          MediaQuery.of(context).orientation == Orientation.portrait
              ? Container(
                decoration: CustomDecorations.mainContent,
                child: LoadingContent(
                  loadingStatus: _recordCreationProvider.loadingStatus,
                  defaultText: AppString.contentNotLoaded,
                  emptyText: AppString.contentNotLoaded,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      listView,
                      SaveCancelBar(
                        saveFunction: () => submitForm(),
                        cancelFunction: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              )
              : listView,
    );
  }
}

/// Input formatter class for lap times
class LapTimeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int _newTextLength = newValue.text.length;
    int _selectionIndex = newValue.selection.end;
    int _usedSubstringIndex = 0;
    final StringBuffer _newText = new StringBuffer();
    // add a space after the 2nd character
    if (_newTextLength >= 3) {
      _newText.write(
        newValue.text.substring(0, _usedSubstringIndex = 2) + '\'',
      );
      if (newValue.selection.end >= 2) _selectionIndex++;
    }
    // add a space after the 4rd character
    if (_newTextLength >= 4) {
      _newText.write(newValue.text.substring(2, _usedSubstringIndex = 4) + '"');
      if (newValue.selection.end >= 3) _selectionIndex++;
    }
    // then write following characters
    if (_newTextLength >= _usedSubstringIndex)
      _newText.write(newValue.text.substring(_usedSubstringIndex));
    return TextEditingValue(
      text: _newText.toString(),
      selection: TextSelection.collapsed(offset: _selectionIndex),
    );
  }
}
