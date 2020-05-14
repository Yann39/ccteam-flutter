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
import 'package:chachatte_team/utils/custom_decorations.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:chachatte_team/widgets/loading_content.dart';
import 'package:flutter/cupertino.dart';
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

    onSelect(date, calendarMode) {
      _eventProvider.fetchDateEvents(date, calendarMode == CalendarMode.year ? "year" : "month");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.tabCalendar),
        actions: <Widget>[MainActionMenu()],
      ),
      drawer: MainDrawer(),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: CustomDecorations.mainContent,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _eventProvider.changeEventModeSelectorIndex(0);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: _eventProvider.eventModeSelectorIndex == 0 ? Colors.red[700] : Colors.white70,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_note, color: _eventProvider.eventModeSelectorIndex == 0 ? Colors.white : Colors.black54),
                          SizedBox(width: 3.0),
                          Flexible(
                            child: Text("Année courante", style: TextStyle(color: _eventProvider.eventModeSelectorIndex == 0 ? Colors.white : Colors.black54)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _eventProvider.changeEventModeSelectorIndex(1);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: _eventProvider.eventModeSelectorIndex == 1 ? Colors.red[700] : Colors.white70,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event, color: _eventProvider.eventModeSelectorIndex == 1 ? Colors.white : Colors.black54),
                          SizedBox(width: 3.0),
                          Flexible(
                            child: Text("Par date", style: TextStyle(color: _eventProvider.eventModeSelectorIndex == 1 ? Colors.white : Colors.black54)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_eventProvider.eventModeSelectorIndex == 1)
              Column(
                children: <Widget>[
                  SizedBox(height: 8.0),
                  CalendarSelector(
                    onDateSelected: onSelect,
                    eventsDates: Map.fromIterable(_eventProvider.events, key: (v) => v.title, value: (v) => v.startDate),
                    onlyMonthDays: false,
                    locale: "fr",
                    weekEndDayColor: Colors.blue[700],
                    mode: CalendarMode.week,
                    expandable: true,
                    firstWeekDay: DateTime.monday,
                  ),
                ],
              ),
            SizedBox(height: 8.0),
            Expanded(
              child: LoadingContent(
                emptyText: AppString.eventsNotFound,
                loadingStatus: _eventProvider.loadingStatus,
                child: ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(height: 8.0),
                  itemCount: _eventProvider.eventModeSelectorIndex == 1 ? _eventProvider.calendarEvents.length : _eventProvider.events.length,
                  itemBuilder: (context, index) {
                    return EventCard(_eventProvider.events[index]);
                  },
                ),
              ),
            ),
          ],
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


