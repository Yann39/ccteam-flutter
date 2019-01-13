import 'package:chachatte_team/models/event.dart';
import 'package:chachatte_team/models/track.dart';
import 'package:chachatte_team/services/events_service.dart';
import 'package:chachatte_team/services/tracks_service.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddEvent extends StatefulWidget {
  final Event event;

  const AddEvent({Key key, this.event}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddEventState();
  }
}

class _AddEventState extends State<AddEvent> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _datePickerController = new TextEditingController();
  final TracksService tracksService = new TracksService();

  Future<List<Track>> _futureTracks;
  Track _selectedTrack;

  // fetch the tracks in initState so it is not fetch each time the state change
  initState() {
    _futureTracks = tracksService.fetchTracks();
    return super.initState();
  }

  // the Event to be created
  final Event newEvent = new Event();

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
      controller.text = DateFormat(AppConstants.DATE_FORMAT).format(finalDateTime);
    });
  }

  /// Validate the form then submit data to backend
  void submitForm(Event event) {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(backgroundColor: Colors.red, content: new Text(AppString.formNotValid)));
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
        }, onError: (error) {
          Navigator.pop(context, AppString.eventCreationFailed);
        });
      }
    }
  }

  Widget build(BuildContext context) {
    // the current Event to be edited
    final Event currEvent = widget.event != null ? widget.event : newEvent;

    // set controller text
    _datePickerController.text = DateUtils.convertToString(currEvent.eventDate, AppConstants.DATE_FORMAT);

    final priceFormatter = new NumberFormat("####.##");

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(AppString.createEvent),
          bottom: PreferredSize(
            child: Container(
              child: Row(
                children: <Widget>[
                  new Expanded(
                      child: new FlatButton(
                    child: Text(AppString.cancel.toUpperCase()),
                    onPressed: () => Navigator.pop(context),
                  )),
                  new Expanded(
                      child: new FlatButton(
                    child: Text(AppString.save.toUpperCase()),
                    onPressed: () => submitForm(currEvent),
                  )),
                ],
              ),
              decoration: new BoxDecoration(color: Colors.green[400]),
              height: 50.0,
            ),
            preferredSize: Size.fromHeight(50.0),
          ),
        ),
        body: Container(
          child: new SafeArea(
              top: false,
              bottom: false,
              child: new Form(
                  key: _formKey,
                  autovalidate: false,
                  child: new ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: <Widget>[
                      new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.title),
                          hintText: AppString.eventTitleHint,
                          labelText: AppString.eventTitle,
                        ),
                        maxLines: 1,
                        inputFormatters: [new LengthLimitingTextInputFormatter(128)],
                        validator: (val) => val.isEmpty ? AppString.eventTitleMandatory : null,
                        onSaved: (val) => currEvent.title = val,
                        initialValue: currEvent.title,
                      ),
                      new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.description),
                          hintText: AppString.eventDescriptionHint,
                          labelText: AppString.eventDescription,
                        ),
                        maxLines: 1,
                        inputFormatters: [new LengthLimitingTextInputFormatter(2048)],
                        validator: (val) => val.isEmpty ? AppString.eventDescriptionMandatory : null,
                        onSaved: (val) => currEvent.description = val,
                        initialValue: currEvent.description,
                      ),
                      new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.attach_money),
                          hintText: AppString.eventPriceHint,
                          labelText: AppString.eventPrice,
                        ),
                        maxLines: 1,
                        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                        inputFormatters: [new LengthLimitingTextInputFormatter(7)],
                        validator: (val) => val.isEmpty ? AppString.eventPriceMandatory : (StringUtils.isValidPrice(val) ? null : AppString.eventPriceNotValid),
                        onSaved: (val) => currEvent.price = double.parse(val),
                        initialValue: currEvent.price != null ? priceFormatter.format(currEvent.price) : "",
                      ),
                      new FutureBuilder<List<Track>>(
                        future: _futureTracks,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return new Column(
                              children: <Widget>[
                                new DropdownButtonFormField<Track>(
                                  value: _selectedTrack != null ? _selectedTrack : widget.event != null ? snapshot.data.firstWhere((Track t) => t.id == widget.event.trackId) : null,
                                  decoration: const InputDecoration(
                                    icon: const Icon(Icons.gesture),
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
                                  onSaved: (val) => currEvent.trackId = val.id,
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
                      new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.person),
                          hintText: AppString.eventOrganizerHint,
                          labelText: AppString.eventOrganizer,
                        ),
                        maxLines: 1,
                        inputFormatters: [new LengthLimitingTextInputFormatter(64)],
                        validator: (val) => val.isEmpty ? AppString.eventOrganizerMandatory : null,
                        onSaved: (val) => currEvent.organizer = val,
                        initialValue: currEvent.organizer,
                      ),
                      new GestureDetector(
                          onTap: () => _chooseDate(context, _datePickerController, currEvent.eventDate),
                          child: AbsorbPointer(
                              child: new TextFormField(
                            decoration: new InputDecoration(
                              icon: const Icon(Icons.calendar_today),
                              hintText: AppString.eventDateHint,
                              labelText: AppString.eventDate,
                            ),
                            controller: _datePickerController,
                            keyboardType: TextInputType.datetime,
                            validator: (val) => DateUtils.isBeforeNow(val, AppConstants.DATE_FORMAT) ? (val.isEmpty ? AppString.eventDateMandatory : null) : AppString.eventDateNotValid,
                            onSaved: (val) => currEvent.eventDate = new DateFormat(AppConstants.DATE_FORMAT).parseStrict(val),
                          ))),
                    ],
                  ))),
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [Colors.green[300], Colors.blue[300]],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ));
  }
}
