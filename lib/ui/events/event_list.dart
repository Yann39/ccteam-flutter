/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of CCTeam application.
 *
 * CCTeam is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * CCTeam is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with CCTeam. If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:ccteam/models/event.dart';
import 'package:ccteam/providers/event_creation_provider.dart';
import 'package:ccteam/providers/event_detail_provider.dart';
import 'package:ccteam/providers/event_list_provider.dart';
import 'package:ccteam/ui/events/calendar_selector.dart';
import 'package:ccteam/ui/events/event_card.dart';
import 'package:ccteam/ui/main/main_action_menu.dart';
import 'package:ccteam/ui/main/main_drawer.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class EventList extends StatelessWidget {
  final Logger _log = new Logger('EventsList');

  /// Navigate to the event creation form screen to create a new event.
  _navigateToAddEventScreen(BuildContext context) async {
    // set a new event to be created
    Provider.of<EventCreationProvider>(context, listen: false).setEventToEdit(new Event());

    // navigate to the event creation form screen
    Navigator.pushNamed(context, '/addEditEvent');
  }

  /// Navigate to the detail screen of the specified [event].
  _navigateToEventDetailScreen(BuildContext context, Event event) async {
    // fetch the event to get complete data
    Provider.of<EventDetailProvider>(context, listen: false).fetchEvent(event).then((value) =>
        // navigate to event detail screen
        Navigator.pushNamed(context, '/eventDetail'));
  }

  Widget build(BuildContext context) {
    _log.info("Building Event list");
    final _eventListProvider = Provider.of<EventListProvider>(context, listen: true);

    onSelect(DateTime date, CalendarMode calendarMode) {
      _eventListProvider.setSelectedDate(date);
      calendarMode == CalendarMode.year
          ? _eventListProvider.fetchEventListForYear(date.year)
          : _eventListProvider.fetchEventListForDayAndMonthAndYear(date.day, date.month, date.year);
    }

    onRefresh() {
      if (_eventListProvider.eventModeSelectorIndex == 0) {
        return _eventListProvider.fetchEventList();
      } else if (_eventListProvider.eventModeSelectorIndex == 1) {
        return _eventListProvider.fetchEventListForYear(DateTime.now().year);
      } else if (_eventListProvider.eventModeSelectorIndex == 2) {
        if (_eventListProvider.selectedDate != null) {
          return _eventListProvider.fetchEventListForDayAndMonthAndYear(_eventListProvider.selectedDate.day,
              _eventListProvider.selectedDate.month, _eventListProvider.selectedDate.year);
        } else {
          return new Future(() => null);
        }
      }
    }

    final List<Event> _events = _eventListProvider.eventModeSelectorIndex == 0
        ? _eventListProvider.allEvents
        : _eventListProvider.eventModeSelectorIndex == 1
            ? _eventListProvider.yearEvents
            : _eventListProvider.dayEvents;

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
              decoration: BoxDecoration(border: Border.all(color: Colors.red[700], width: 1)),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        _eventListProvider.changeEventModeSelectorIndex(0);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                        decoration: BoxDecoration(
                            color: _eventListProvider.eventModeSelectorIndex == 0 ? Colors.red[700] : Colors.white70,
                            border: Border(right: BorderSide(color: Colors.red[700], width: 1))),
                        child: Text(
                          AppString.all,
                          style: TextStyle(
                              color: _eventListProvider.eventModeSelectorIndex == 0 ? Colors.white : Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        _eventListProvider.fetchEventListForYear(DateTime.now().year);
                        _eventListProvider.changeEventModeSelectorIndex(1);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                        decoration: BoxDecoration(
                            color: _eventListProvider.eventModeSelectorIndex == 1 ? Colors.red[700] : Colors.white70,
                            border: Border(right: BorderSide(color: Colors.red[700], width: 1))),
                        child: Text(
                          AppString.currentYear,
                          style: TextStyle(
                              color: _eventListProvider.eventModeSelectorIndex == 1 ? Colors.white : Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        _eventListProvider.changeEventModeSelectorIndex(2);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: _eventListProvider.eventModeSelectorIndex == 2 ? Colors.red[700] : Colors.white70,
                        ),
                        child: Text(
                          AppString.byDate,
                          style: TextStyle(
                              color: _eventListProvider.eventModeSelectorIndex == 2 ? Colors.white : Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_eventListProvider.eventModeSelectorIndex == 2)
              Column(
                children: <Widget>[
                  SizedBox(height: 8.0),
                  CalendarSelector(
                    onDateSelected: onSelect,
                    eventsDates:
                        Map.fromIterable(_eventListProvider.allEvents, key: (v) => v.title, value: (v) => v.startDate),
                    onlyMonthDays: false,
                    locale: "fr",
                    weekEndDayColor: Colors.blue[700],
                    mode: CalendarMode.month,
                    expandable: true,
                    firstWeekDay: DateTime.monday,
                  ),
                ],
              ),
            SizedBox(height: 8.0),
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: LoadingContent(
                  emptyText: AppString.eventsNotFound,
                  loadingStatus: _eventListProvider.loadingStatus,
                  child: ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(height: 8.0),
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      if (index > 0 && _events[index].startDate.year < _events[index - 1].startDate.year) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.arrow_downward,
                                  size: 16,
                                ),
                                Text("${_events[index].startDate.year}"),
                              ],
                            ),
                            SizedBox(height: 4.0),
                            InkWell(
                              child: EventCard(index),
                              onTap: () => _navigateToEventDetailScreen(context, _eventListProvider.allEvents[index]),
                            ),
                          ],
                        );
                      } else {
                        return InkWell(
                          child: EventCard(index),
                          onTap: () => _navigateToEventDetailScreen(context, _eventListProvider.allEvents[index]),
                        );
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
