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

import 'package:ccteam/models/event.dart';
import 'package:ccteam/models/track.dart';
import 'package:ccteam/providers/event_creation_provider.dart';
import 'package:ccteam/providers/event_detail_provider.dart';
import 'package:ccteam/providers/event_list_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/services/tracks_service.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:ccteam/widgets/save_cancel_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddEditEvent extends StatefulWidget {
  const AddEditEvent({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddEditEventState();
  }
}

class _AddEditEventState extends State<AddEditEvent> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _startDatePickerController =
      new TextEditingController();
  final TextEditingController _endDatePickerController =
      new TextEditingController();
  final TracksService _tracksService = new TracksService();

  Future<List<Track>>? _futureTracks;
  Track? _selectedTrack;

  initState() {
    final EventCreationProvider _eventCreationProvider =
        Provider.of<EventCreationProvider>(context, listen: false);
    // fetch the tracks in initState so it is not fetch each time the state change
    _futureTracks = _tracksService.fetchTracks();
    // set date picker text
    _startDatePickerController.text =
        AppDateUtils.convertToString(
          _eventCreationProvider.event.startDate != null
              ? _eventCreationProvider.event.startDate!
              : DateTime.now(),
          DATE_FORMAT,
        )!;
    _endDatePickerController.text =
        AppDateUtils.convertToString(
          _eventCreationProvider.event.startDate != null
              ? _eventCreationProvider.event.endDate!
              : DateTime.now().add(Duration(days: 1)),
          DATE_FORMAT,
        )!;
    return super.initState();
  }

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
    if (dateResult == null) return;

    // show the time picker and await for the chosen time
    final TimeOfDay? timeResult = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (timeResult == null) return;

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

  /// Validate the form then submit data to backend
  void submitForm(Event event) {
    final FormState _form = _formKey.currentState!;

    if (!_form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(AppString.formNotValid),
        ),
      );
    } else {
      // this invokes each onSaved event
      _form.save();

      final EventCreationProvider _eventCreationProvider =
          Provider.of<EventCreationProvider>(context, listen: false);
      final EventListProvider _eventListProvider =
          Provider.of<EventListProvider>(context, listen: false);
      final EventDetailProvider _eventDetailProvider =
          Provider.of<EventDetailProvider>(context, listen: false);
      final LoginProvider _loginProvider = Provider.of<LoginProvider>(
        context,
        listen: false,
      );

      // submit data to backend, if id is set this is an update, else a creation
      if (event.id != null) {
        event.modifiedBy = _loginProvider.loggedMember;
        _eventCreationProvider.updateEvent().then((value) {
          // update event in related UIs
          _eventListProvider.updateEventInList(_eventCreationProvider.event);
          _eventDetailProvider.setCurrentEvent(_eventCreationProvider.event);
        });
      } else {
        event.createdBy = _loginProvider.loggedMember;
        _eventCreationProvider.createEvent().then((value) {
          _eventListProvider.addEventInList(_eventCreationProvider.event);
        });
      }
      Navigator.pop(context);
    }
  }

  Widget build(BuildContext context) {
    final _eventCreationProvider = Provider.of<EventCreationProvider>(
      context,
      listen: true,
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(AppString.eventCreate)),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: LoadingContent(
          loadingStatus: _eventCreationProvider.loadingStatus,
          defaultText: AppString.contentNotLoaded,
          emptyText: AppString.contentNotLoaded,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Form(
                  autovalidateMode: AutovalidateMode.disabled,
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UI_FORM_PADDING,
                    ),
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.title),
                          hintText: AppString.eventTitleHint,
                          labelText: AppString.eventTitle,
                        ),
                        maxLines: 1,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(128),
                        ],
                        validator:
                            (val) =>
                                (val == null || val.isEmpty)
                                    ? AppString.eventTitleMandatory
                                    : null,
                        onSaved:
                            (val) => _eventCreationProvider.event.title = val!,
                        initialValue: _eventCreationProvider.event.title,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.description),
                          hintText: AppString.eventDescriptionHint,
                          labelText: AppString.eventDescription,
                        ),
                        maxLines: 2,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(2048),
                        ],
                        validator:
                            (val) =>
                                (val == null || val.isEmpty)
                                    ? AppString.eventDescriptionMandatory
                                    : null,
                        onSaved:
                            (val) =>
                                _eventCreationProvider.event.description = val,
                        initialValue: _eventCreationProvider.event.description,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.attach_money),
                          hintText: AppString.eventPriceHint,
                          labelText: AppString.eventPrice,
                        ),
                        maxLines: 1,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                          signed: false,
                        ),
                        inputFormatters: [LengthLimitingTextInputFormatter(7)],
                        validator:
                            (val) =>
                                (val == null || val.isEmpty)
                                    ? AppString.eventPriceMandatory
                                    : (StringUtils.isValidPrice(val)
                                        ? null
                                        : AppString.eventPriceNotValid),
                        onSaved:
                            (val) =>
                                _eventCreationProvider
                                    .event
                                    .price = double.parse(val!),
                        initialValue:
                            _eventCreationProvider.event.price != null
                                ? StringUtils.formatPrice(
                                  _eventCreationProvider.event.price!,
                                )
                                : "",
                      ),
                      FutureBuilder<List<Track>>(
                        future: _futureTracks,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: <Widget>[
                                DropdownButtonFormField<Track>(
                                  initialValue:
                                      _selectedTrack != null
                                          ? _selectedTrack
                                          : _eventCreationProvider.event.id !=
                                              null
                                          ? snapshot.data!.firstWhere(
                                            (Track t) =>
                                                t.id ==
                                                _eventCreationProvider
                                                    .event
                                                    .track!
                                                    .id,
                                            orElse: () => snapshot.data!.first,
                                          )
                                          : snapshot.data!.isNotEmpty
                                          ? snapshot.data!.first
                                          : null,
                                  decoration: const InputDecoration(
                                    icon: const Icon(CustomIcons.track_sample),
                                    hintText: AppString.eventTrackIdHint,
                                    labelText: AppString.eventTrackId,
                                  ),
                                  items:
                                      snapshot.data!.map((Track val) {
                                        return DropdownMenuItem<Track>(
                                          value: val,
                                          child: Text(val.name!),
                                        );
                                      }).toList(),
                                  onChanged: (Track? val) {
                                    setState(() {
                                      _selectedTrack = val;
                                    });
                                  },
                                  onSaved:
                                      (val) =>
                                          _eventCreationProvider.event.track =
                                              val,
                                  validator:
                                      (val) =>
                                          val == null
                                              ? AppString.eventTrackIdMandatory
                                              : null,
                                ),
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          // By default, show a loading spinner
                          return CircularProgressIndicator();
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.perm_contact_calendar),
                          hintText: AppString.eventOrganizerHint,
                          labelText: AppString.eventOrganizer,
                        ),
                        maxLines: 1,
                        inputFormatters: [LengthLimitingTextInputFormatter(64)],
                        validator:
                            (val) =>
                                (val == null || val.isEmpty)
                                    ? AppString.eventOrganizerMandatory
                                    : null,
                        onSaved:
                            (val) =>
                                _eventCreationProvider.event.organizer = val,
                        initialValue: _eventCreationProvider.event.organizer,
                      ),
                      GestureDetector(
                        onTap:
                            () => _chooseDate(
                              context,
                              _startDatePickerController,
                              _eventCreationProvider.event.startDate,
                            ),
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              icon: const Icon(Icons.event),
                              hintText: AppString.eventStartDateHint,
                              labelText: AppString.eventStartDate,
                            ),
                            controller: _startDatePickerController,
                            keyboardType: TextInputType.datetime,
                            validator:
                                (val) =>
                                    (val == null || val.isEmpty)
                                        ? AppString.eventStartDateMandatory
                                        : null,
                            onSaved:
                                (val) =>
                                    _eventCreationProvider
                                        .event
                                        .startDate = DateFormat(
                                      DATE_FORMAT,
                                    ).parseStrict(val!),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap:
                            () => _chooseDate(
                              context,
                              _endDatePickerController,
                              _eventCreationProvider.event.endDate,
                            ),
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              icon: const Icon(Icons.event),
                              hintText: AppString.eventEndDateHint,
                              labelText: AppString.eventEndDate,
                            ),
                            controller: _endDatePickerController,
                            keyboardType: TextInputType.datetime,
                            validator:
                                (val) =>
                                    (val == null || val.isEmpty)
                                        ? AppString.eventEndDateMandatory
                                        : null,
                            onSaved:
                                (val) =>
                                    _eventCreationProvider
                                        .event
                                        .endDate = DateFormat(
                                      DATE_FORMAT,
                                    ).parseStrict(val!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: SaveCancelBar(
                  saveFunction: () => submitForm(_eventCreationProvider.event),
                  cancelFunction: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
