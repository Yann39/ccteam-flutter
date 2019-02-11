import 'package:chachatte_team/models/event.dart';
import 'package:chachatte_team/services/events_service.dart';
import 'package:chachatte_team/ui/events/add_event.dart';
import 'package:chachatte_team/ui/events/event_card.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';

class Calendar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CalendarState();
  }
}

class _CalendarState extends State<Calendar> {
  static final EventsService eventsService = new EventsService();

  // if user wants to display more event per line
  bool more = false;

  /// Method that launches the Add Event screen and awaits the result from Navigator.pop
  _navigateToAddEventScreen(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddEvent()));

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  Widget build(BuildContext context) {
    // get screen orientation
    final Orientation orientation = MediaQuery.of(context).orientation;

    // number of events per line
    final int nbCol = orientation == Orientation.portrait ? (more ? 3 : 2) : (more ? 6 : 4);

    // icon to display for the number of event per line option
    final Icon nbColIcon = orientation == Orientation.portrait ? (more ? Icon(Icons.filter_2) : Icon(Icons.filter_3)) : (more ? Icon(Icons.filter_4) : Icon(Icons.filter_6));
    final String nbColIconTooltip = orientation == Orientation.portrait
        ? (more ? AppString.eventDisplay2ItemsTooltip : AppString.eventDisplay3ItemsTooltip)
        : (more ? AppString.eventDisplay4ItemsTooltip : AppString.eventDisplay6ItemsTooltip);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.eventScreenTitle),
        leading: new Icon(Icons.event),
        actions: <Widget>[
          IconButton(
            icon: nbColIcon,
            tooltip: nbColIconTooltip,
            onPressed: () {
              setState(() {
                more = !more;
              });
            },
          ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [PopupMenuItem(child: Text(AppString.about)), PopupMenuItem(child: Text(AppString.contact))];
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Event>>(
          future: eventsService.fetchEvents(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView.count(
                crossAxisCount: nbCol,
                children: List.generate(snapshot.data.length, (index) {
                  return new EventCard(snapshot.data[index], eventsService, nbCol);
                }),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner
            return CircularProgressIndicator();
          },
        ),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [Colors.blue[200], Colors.blue[300]],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        child: new Icon(Icons.add),
        backgroundColor: Colors.red[700],
        onPressed: () {
          _navigateToAddEventScreen(context);
        },
      ),
    );
  }
}
