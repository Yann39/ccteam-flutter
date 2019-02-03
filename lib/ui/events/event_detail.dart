import 'package:chachatte_team/models/event.dart';
import 'package:chachatte_team/services/events_service.dart';
import 'package:chachatte_team/ui/events/add_event.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';

class EventDetail extends StatefulWidget {
  final Event event;

  const EventDetail({Key key, this.event}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EventDetailState();
  }
}

enum ConfirmDialogAction { yes, no }

class _EventDetailState extends State<EventDetail> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(() => setState(() {}));
  }

  /// Method that launches the Edit New screen and awaits the result from Navigator.pop
  _navigateToEditEventScreen(BuildContext context, Event event) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the Add Event Screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddEvent(event: event)));

    // after the Edit New Screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  /// Display a confirmation popup when trying to delete a event
  void _showConfirmation(BuildContext context, String value) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
            title: new Text(AppString.confirmation),
            content: new Text(value),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  _dialogueResult(context, ConfirmDialogAction.yes);
                },
                child: new Text(AppString.confirm),
              ),
              new FlatButton(
                onPressed: () {
                  _dialogueResult(context, ConfirmDialogAction.no);
                },
                child: new Text(AppString.cancel),
              ),
            ],
          ),
    );
  }

  /// Handle result of the event deletion confirmation dialog
  void _dialogueResult(BuildContext context, ConfirmDialogAction value) {
    if (value == ConfirmDialogAction.yes) {
      final EventsService eventsService = new EventsService();
      // delete event
      eventsService.deleteEvent(widget.event).then((value) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AppString.eventDeleted)));
      }, onError: (error) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AppString.eventDeletionFailed)));
      });
    }
    Navigator.pop(context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => _navigateToEditEventScreen(context, widget.event),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Delete',
            onPressed: () => _showConfirmation(context, AppString.eventDeletionAreYouSure),
          )
        ],
        title: Text('Event detail'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: new EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(DateUtils.convertToString(widget.event.eventDate, AppConstants.DATE_FORMAT), textAlign: TextAlign.left),
            Text(widget.event.title, textScaleFactor: 2, textAlign: TextAlign.center),
            SizedBox(
              height: 10,
            ),
            Text(widget.event.description),
          ],
        ),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [Colors.blue[100], Colors.blue[400]],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
    );
  }
}
