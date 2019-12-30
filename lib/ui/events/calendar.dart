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

import 'package:chachatte_team/providers/event_provider.dart';
import 'package:chachatte_team/ui/events/calendar_selector.dart';
import 'package:chachatte_team/ui/main/main_action_menu.dart';
import 'package:chachatte_team/ui/main/main_drawer.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CalendarState();
  }
}

class _CalendarState extends State<Calendar> {
  final Logger _log = new Logger('EventsList');

  /// Method that launches the Add Event screen and awaits the result from Navigator.pop
  _navigateToAddEventScreen(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final _result = await Navigator.pushNamed(context, '/addEditEvent');

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (_result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$_result")));
    }
  }

  Widget build(BuildContext context) {
    _log.info("Building News list");
    final _eventProvider = Provider.of<EventProvider>(context, listen: true);

    // get screen orientation
    final Orientation _orientation = MediaQuery.of(context).orientation;

    // if user wants to display more event per line
    final _more = _eventProvider.more;

    // number of events per line
    final int nbCol = _orientation == Orientation.portrait ? (_more ? 3 : 2) : (_more ? 6 : 4);

    // icon to display for the number of event per line option
    final Icon nbColIcon = _orientation == Orientation.portrait ? (_more ? Icon(Icons.filter_2) : Icon(Icons.filter_3)) : (_more ? Icon(Icons.filter_4) : Icon(Icons.filter_6));
    final String nbColIconTooltip = _orientation == Orientation.portrait
        ? (_more ? AppString.eventDisplay2ItemsTooltip : AppString.eventDisplay3ItemsTooltip)
        : (_more ? AppString.eventDisplay4ItemsTooltip : AppString.eventDisplay6ItemsTooltip);

    onSelect(data) {
      print("Selected Date -> $data");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.tabCalendar),
        actions: <Widget>[
          IconButton(
            icon: nbColIcon,
            tooltip: nbColIconTooltip,
            onPressed: () {
              _eventProvider.toggleMore();
            },
          ),
          MainActionMenu()
        ],
      ),
      drawer: MainDrawer(),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: _eventProvider.events != null && _eventProvider.events.length > 0
            ? /*GridView.count(
                crossAxisCount: nbCol,
                children: List.generate(_eventProvider.events.length, (index) {
                  return EventCard(_eventProvider.events[index], nbCol);
                }),
              )*/
                  Column(
                    children: <Widget>[
                      CalendarSelector(centerDate: DateTime(2019, 10, 03), onDateSelected: onSelect, eventsDates: { "event1" : DateTime(2019, 10, 03), "event2" : DateTime(2019, 10, 05), "event3" : DateTime(2019, 10, 05) },),
                      Text("Event x")
                    ],
                  )
            : Center(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                  height: 20.0,
                  width: 20.0,
                ),
              ),
        /*Consumer<EventProvider>(
          builder: (context, eventModel, child) {
            return FutureBuilder<List<Event>>(
              future: eventModel.fetchEvents(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView.count(
                    crossAxisCount: nbCol,
                    children: List.generate(snapshot.data.length, (index) {
                      return EventCard(snapshot.data[index], nbCol);
                    }),
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                // By default, show a loading spinner
                return Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(),
                    height: 20.0,
                    width: 20.0,
                  ),
                );
              },
            );*/
        /*return FutureProvider<List<Event>>.value(
                value: eventModel.fetchEvents(),
                child: Consumer<List<Event>>(
                  builder: (context, events, widget) {
                    return GridView.count(
                      crossAxisCount: nbCol,
                      children: List.generate(events.length, (index) {
                        return EventCard(events[index], eventsService, nbCol);
                      }),
                    );
                  },
                ),
              );*/
        //},
        //),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[100], Colors.blue[300]],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        child: Icon(Icons.add),
        backgroundColor: Colors.red[700],
        onPressed: () {
          _navigateToAddEventScreen(context);
        },
      ),
    );
  }
}
