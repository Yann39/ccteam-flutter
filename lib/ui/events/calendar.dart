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
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$_result")));
    }
  }

  Widget build(BuildContext context) {
    _log.info("Building Event list");
    final _eventProvider = Provider.of<EventProvider>(context, listen: true);

    onSelect(date, calendarMode) {
      _eventProvider.fetchDateEvents(
          date, calendarMode == CalendarMode.year ? "year" : "month");
    }

    final List<Event> _currEvents = _eventProvider.eventModeSelectorIndex == 0
        ? _eventProvider.events
        : _eventProvider.eventModeSelectorIndex == 1
            ? _eventProvider.yearEvents
            : _eventProvider.calendarEvents;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.tabCalendar),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _navigateToAddEventScreen(context);
            },
          ),
          MainActionMenu(),
        ],
      ),
      drawer: MainDrawer(),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: CustomDecorations.mainContent,
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.red[700], width: 1)),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        _eventProvider.changeEventModeSelectorIndex(0);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 6.0),
                        decoration: BoxDecoration(
                            color: _eventProvider.eventModeSelectorIndex == 0
                                ? Colors.red[700]
                                : Colors.white70,
                            border: Border(
                                right: BorderSide(
                                    color: Colors.red[700], width: 1))),
                        child: Text(
                          AppString.all,
                          style: TextStyle(
                              color: _eventProvider.eventModeSelectorIndex == 0
                                  ? Colors.white
                                  : Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        _eventProvider.fetchCurrentYearEvents();
                        _eventProvider.changeEventModeSelectorIndex(1);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 6.0),
                        decoration: BoxDecoration(
                            color: _eventProvider.eventModeSelectorIndex == 1
                                ? Colors.red[700]
                                : Colors.white70,
                            border: Border(
                                right: BorderSide(
                                    color: Colors.red[700], width: 1))),
                        child: Text(
                          AppString.currentYear,
                          style: TextStyle(
                              color: _eventProvider.eventModeSelectorIndex == 1
                                  ? Colors.white
                                  : Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        _eventProvider.changeEventModeSelectorIndex(2);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: _eventProvider.eventModeSelectorIndex == 2
                              ? Colors.red[700]
                              : Colors.white70,
                        ),
                        child: Text(
                          AppString.byDate,
                          style: TextStyle(
                              color: _eventProvider.eventModeSelectorIndex == 2
                                  ? Colors.white
                                  : Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_eventProvider.eventModeSelectorIndex == 2)
              Column(
                children: <Widget>[
                  SizedBox(height: 8.0),
                  CalendarSelector(
                    onDateSelected: onSelect,
                    eventsDates: Map.fromIterable(_eventProvider.events,
                        key: (v) => v.title, value: (v) => v.startDate),
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
              child: RefreshIndicator(
                onRefresh: () => _eventProvider.fetchEvents(),
                child: LoadingContent(
                  emptyText: AppString.eventsNotFound,
                  loadingStatus: _eventProvider.loadingStatus,
                  child: ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(height: 8.0),
                    itemCount: _currEvents.length,
                    itemBuilder: (context, index) {
                      if (index > 0 &&
                          _currEvents[index].startDate.year <
                              _currEvents[index - 1].startDate.year) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.arrow_downward,
                                  size: 16,
                                ),
                                Text("${_currEvents[index].startDate.year}"),
                              ],
                            ),
                            SizedBox(height: 4.0),
                            EventCard(_currEvents[index]),
                          ],
                        );
                      } else {
                        return EventCard(_currEvents[index]);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
