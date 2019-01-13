import 'package:chachatte_team/models/event.dart';
import 'package:chachatte_team/services/events_service.dart';
import 'package:chachatte_team/ui/add_event.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:flutter/material.dart';

/// class representing the floating action button to edit a event
/// await the result from the "Add Event" screen to display a message
class _EditEventButton extends StatelessWidget {
  final Event event;

  const _EditEventButton({Key key, this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(
          Icons.edit,
          color: Colors.white,
        ),
        onPressed: () {
          _navigateAndDisplaySelection(context, event);
        });
  }

  /// Method that launches the Add Event screen and awaits the result from Navigator.pop
  _navigateAndDisplaySelection(BuildContext context, Event event) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the Add Event Screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddEvent(event: event)));

    // after the Add Event Screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final EventsService eventsService;

  EventCard(this.event, this.eventsService);

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: Colors.transparent,
        height: 60.0,
        margin: const EdgeInsets.symmetric(
          vertical: 8.0, // vertical space between cards
          horizontal: 18.0,
        ),
        child: new Stack(
          children: <Widget>[
            new Container(
              height: 60.0,
              padding: new EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              decoration: new BoxDecoration(color: new Color.fromRGBO(255, 255, 255, 0.4), shape: BoxShape.rectangle, borderRadius: new BorderRadius.circular(8.0)),
              child: new Row(children: <Widget>[
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  new Flexible(
                      child: new Row(children: <Widget>[
                    Icon(
                      Icons.date_range,
                      color: Colors.white,
                      size: 12.0,
                    ),
                    new SizedBox(width: 4.0), // fake horizontal space between the 2 lines of text
                    new Text(DateUtils.convertToString(event.eventDate, "d/M/y HH:mm"),
                        softWrap: false, textScaleFactor: 0.9, style: new TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)
                  ])),
                  new SizedBox(height: 4.0), // vertical space between the 2 lines of text
                  new Flexible(
                      child: new Text(event.trackId.toString() + " - " + event.title,
                          softWrap: false, textScaleFactor: 1.2, style: new TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis))
                ])),
                _EditEventButton(event: event),
                IconButton(
                    icon: Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // delete event
                      eventsService.deleteEvent(event);
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(SnackBar(content: Text("Event ${event.title} successfully deleted")));
                    })
              ]),
            ),
          ],
        ));
  }
}
