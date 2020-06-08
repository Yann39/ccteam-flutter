/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of Chachatte Team application.
 *
 * Chachatte Team is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Chachatte Team is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Chachatte Team. If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:chachatte_team/models/event.dart';
import 'package:chachatte_team/models/track.dart';
import 'package:chachatte_team/services/events_service.dart';
import 'package:chachatte_team/services/notifications_service.dart';
import 'package:chachatte_team/services/tracks_service.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/custom_decorations.dart';
import 'package:chachatte_team/utils/custom_icons.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:chachatte_team/widgets/save_cancel_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddEditEvent extends StatefulWidget {
  final Event event;

  const AddEditEvent({Key key, this.event}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddEditEventState();
  }
}

class _AddEditEventState extends State<AddEditEvent> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _startDatePickerController = new TextEditingController();
  final TextEditingController _endDatePickerController = new TextEditingController();
  final TracksService _tracksService = new TracksService();

  Future<List<Track>> _futureTracks;
  Track _selectedTrack;

  initState() {
    // fetch the tracks in initState so it is not fetch each time the state change
    _futureTracks = _tracksService.fetchTracks();
    // set date picker text if set
    if (widget.event != null) {
      _startDatePickerController.text = DateUtils.convertToString(widget.event.startDate, DATE_FORMAT);
      _endDatePickerController.text = DateUtils.convertToString(widget.event.endDate, DATE_FORMAT);
    }
    return super.initState();
  }

  // the Event to be created
  final Event _newEvent = new Event();

  /// Initialize and display a Date picker related to the specified [controller] in the specified [context]
  Future _chooseDate(BuildContext context, TextEditingController controller, DateTime defaultValue) async {
    final DateTime currentDate = DateTime.now();
    final TimeOfDay currentTime = TimeOfDay.now();

    // define initial date and time from the specified default DateTime value if set
    final DateTime initialDate = defaultValue ?? currentDate;
    final TimeOfDay initialTime = defaultValue != null ? TimeOfDay.fromDateTime(defaultValue) : currentTime;

    // show the date picker and await for the chosen date
    final DateTime dateResult =
        await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(currentDate.year - 5), lastDate: DateTime(currentDate.year + 5));
    if (dateResult == null) return;

    // show the time picker and await for the chosen time
    final TimeOfDay timeResult = await showTimePicker(context: context, initialTime: initialTime);
    if (timeResult == null) return;

    // build final date with time
    final DateTime finalDateTime = DateTime(dateResult.year, dateResult.month, dateResult.day, timeResult.hour, timeResult.minute);

    // notify the framework that the internal state of this object has changed
    setState(() {
      controller.text = DateFormat(DATE_FORMAT).format(finalDateTime);
    });
  }

  /// Validate the form then submit data to backend
  void submitForm(Event event) {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(AppString.formNotValid)));
    } else {
      // this invokes each onSaved event
      form.save();

      var eventsService = new EventsService();

      // submit data to backend, if id is set this is an update, else a creation
      if (event.id != null) {
        // update the event and go back with a message, the result is awaited in caller
        eventsService.updateEvent(event).then((value) {
          Navigator.pop(context, AppString.eventUpdated);
        }, onError: (error) {
          Navigator.pop(context, AppString.eventUpdateFailed);
        });
      } else {
        // create the event and go back with a message, the result is awaited in caller
        eventsService.createEvent(event).then((value) {
          Navigator.pop(context, AppString.eventCreated);
          // schedule a push notification 6 hours before the event starts
          NotificationsService.scheduleEventNotification(event);
        }, onError: (error) {
          Navigator.pop(context, AppString.eventCreationFailed + " : " + error.toString());
        });
      }
    }
  }

  Widget build(BuildContext context) {
    // the current Event to be edited
    final Event _currEvent = widget.event != null ? widget.event : _newEvent;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppString.eventCreate),
      ),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: Stack(
          children: <Widget>[
            Form(
              key: _formKey,
              autovalidate: false,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.title),
                      hintText: AppString.eventTitleHint,
                      labelText: AppString.eventTitle,
                    ),
                    maxLines: 1,
                    inputFormatters: [LengthLimitingTextInputFormatter(128)],
                    validator: (val) => val.isEmpty ? AppString.eventTitleMandatory : null,
                    onSaved: (val) => _currEvent.title = val,
                    initialValue: _currEvent.title,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.description),
                      hintText: AppString.eventDescriptionHint,
                      labelText: AppString.eventDescription,
                    ),
                    maxLines: 2,
                    inputFormatters: [LengthLimitingTextInputFormatter(2048)],
                    validator: (val) => val.isEmpty ? AppString.eventDescriptionMandatory : null,
                    onSaved: (val) => _currEvent.description = val,
                    initialValue: _currEvent.description,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.attach_money),
                      hintText: AppString.eventPriceHint,
                      labelText: AppString.eventPrice,
                    ),
                    maxLines: 1,
                    keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                    inputFormatters: [LengthLimitingTextInputFormatter(7)],
                    validator: (val) => val.isEmpty ? AppString.eventPriceMandatory : (StringUtils.isValidPrice(val) ? null : AppString.eventPriceNotValid),
                    onSaved: (val) => _currEvent.price = double.parse(val),
                    initialValue: _currEvent.price != null ? StringUtils.formatPrice(_currEvent.price) : "",
                  ),
                  FutureBuilder<List<Track>>(
                    future: _futureTracks,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: <Widget>[
                            DropdownButtonFormField<Track>(
                              value: _selectedTrack != null ? _selectedTrack : widget.event != null ? snapshot.data.firstWhere((Track t) => t.id == widget.event.track.id) : null,
                              decoration: const InputDecoration(
                                icon: const Icon(CustomIcons.track_sample),
                                hintText: AppString.eventTrackIdHint,
                                labelText: AppString.eventTrackId,
                              ),
                              items: snapshot.data.map((Track val) {
                                return DropdownMenuItem<Track>(value: val, child: Text(val.name));
                              }).toList(),
                              onChanged: (Track val) {
                                setState(() {
                                  _selectedTrack = val;
                                });
                              },
                              onSaved: (val) => _currEvent.track.id = val.id,
                              validator: (val) => val == null ? AppString.eventTrackIdMandatory : null,
                            )
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
                    validator: (val) => val.isEmpty ? AppString.eventOrganizerMandatory : null,
                    onSaved: (val) => _currEvent.organizer = val,
                    initialValue: _currEvent.organizer,
                  ),
                  GestureDetector(
                    onTap: () => _chooseDate(context, _startDatePickerController, _currEvent.startDate),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.event),
                          hintText: AppString.eventStartDateHint,
                          labelText: AppString.eventStartDate,
                        ),
                        controller: _startDatePickerController,
                        keyboardType: TextInputType.datetime,
                        validator: (val) => val.isEmpty ? AppString.eventStartDateMandatory : null,
                        onSaved: (val) => _currEvent.startDate = DateFormat(DATE_FORMAT).parseStrict(val),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _chooseDate(context, _endDatePickerController, _currEvent.endDate),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.event),
                          hintText: AppString.eventEndDateHint,
                          labelText: AppString.eventEndDate,
                        ),
                        controller: _endDatePickerController,
                        keyboardType: TextInputType.datetime,
                        validator: (val) => val.isEmpty ? AppString.eventEndDateMandatory : null,
                        onSaved: (val) => _currEvent.endDate = DateFormat(DATE_FORMAT).parseStrict(val),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SaveCancelBar(
              saveFunction: () => submitForm(_currEvent),
              cancelFunction: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
