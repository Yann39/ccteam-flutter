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
import 'package:chachatte_team/ui/events/event_card.dart';
import 'package:chachatte_team/ui/main/main_action_menu.dart';
import 'package:chachatte_team/ui/main/main_drawer.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class Calendar extends StatelessWidget {
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
    _log.info("Building Event list");
    final _eventProvider = Provider.of<EventProvider>(context, listen: true);

    // if user wants to display more events per line
    final _eventsPerLine = _eventProvider.eventsPerLine;

    // icon to display for the number of event per line option
    final Icon nbColIcon = _eventsPerLine == 1 ? Icon(Icons.filter_1) : (_eventsPerLine == 2 ? Icon(Icons.filter_2) : Icon(Icons.filter_3));

    final String nbColIconTooltip = _eventsPerLine == 1 ? AppString.eventDisplay1ItemTooltip : (_eventsPerLine == 2 ? AppString.eventDisplay2ItemsTooltip : AppString.eventDisplay3ItemsTooltip);

    onSelect(date, calendarMode) {
      _eventProvider.setDisplayEvents(date, calendarMode == CalendarMode.year ? "year" : "month");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.tabCalendar),
        actions: <Widget>[
          IconButton(
            icon: nbColIcon,
            tooltip: nbColIconTooltip,
            onPressed: () {
              _eventProvider.changeEventsPerLine();
            },
          ),
          MainActionMenu()
        ],
      ),
      drawer: MainDrawer(),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: _eventProvider.events != null && _eventProvider.events.length > 0
            ? Column(
                children: <Widget>[
                  CalendarSelector(
                    onDateSelected: onSelect,
                    eventsDates: Map.fromIterable(_eventProvider.events, key: (v) => v.title, value: (v) => v.eventDate),
                  ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: _eventsPerLine,
                      childAspectRatio: _eventsPerLine == 1 ? 2 : 1,
                      children: List.generate(_eventProvider.displayEvents.length, (index) {
                        return EventCard(_eventProvider.displayEvents[index], _eventsPerLine);
                      }),
                    ) /*ListView.builder(
                      itemCount: _eventProvider.displayEvents.length,
                      itemBuilder: (context, i) {
                        return EventCard(_eventProvider.events[i], nbCol);
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          color: Colors.pink,
                          child: ListTile(title: Text(_eventProvider.displayEvents[i].title),),
                        );
                      },
                    ),*/
                  ),
                ],
              )
            : Center(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                  height: 20.0,
                  width: 20.0,
                ),
              ),
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
