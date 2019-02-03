import 'package:chachatte_team/models/event.dart';
import 'package:chachatte_team/services/events_service.dart';
import 'package:chachatte_team/ui/events/event_detail.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:flutter/material.dart';

enum ConfirmDialogAction { yes, no }

class EventCard extends StatelessWidget {
  final Event event;
  final EventsService eventsService;
  final int nbCol;

  EventCard(this.event, this.eventsService, this.nbCol);

  /// Method that launches the Event detail screen and awaits the result from Navigator.pop
  _navigateToEventDetailScreen(BuildContext context, Event event) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the News detail screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetail(event: event)));

    // after the Edit Event Screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.transparent,
      height: 60.0,
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      child: InkWell(
        onTap: () => _navigateToEventDetailScreen(context, event),
        child: new Container(
          height: 60.0,
          decoration: new BoxDecoration(
            color: new Color.fromRGBO(255, 255, 255, 0.5),
            shape: BoxShape.rectangle,
            borderRadius: new BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    height: 60 / nbCol,
                    decoration: new BoxDecoration(
                      color: Colors.red[900],
                      shape: BoxShape.rectangle,
                      borderRadius: new BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      nbCol < 3 ? DateUtils.convertToString(event.eventDate, "MMMM yyyy") : DateUtils.convertToString(event.eventDate, "MMM yyyy"),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      textScaleFactor: 2.2 / nbCol,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: Icon(
                      Icons.date_range,
                      color: Colors.white,
                      size: 36 / nbCol,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16 / nbCol),
              new Text(
                DateUtils.convertToString(event.eventDate, "dd"),
                softWrap: false,
                textScaleFactor: 6 / nbCol,
                style: new TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12 / nbCol),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.place,
                    color: Colors.white,
                    size: 30 / nbCol,
                  ),
                  Text(
                    event.title,
                    softWrap: false,
                    textScaleFactor: 2.3 / nbCol,
                    style: new TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: 16 / nbCol),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    child: Text(
                      event.members.length.toString(),
                      textScaleFactor: 1.8 / nbCol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.all(2.0),
                    decoration: new BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(3.0))),
                  ),
                  Text(
                    event.members.length > 1 ? " participants" : " participant",
                    style: TextStyle(color: Colors.white),
                    textScaleFactor: 1.8 / nbCol,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
