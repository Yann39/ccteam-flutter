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
import 'package:ccteam/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class EventList extends StatefulWidget {
  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  final Logger _log = new Logger('EventsList');
  final Set<int> _expandedYears = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _eventListProvider = Provider.of<EventListProvider>(
      context,
      listen: false,
    );
    List<Event> _events = List<Event>.from(
      _eventListProvider.eventModeSelectorIndex == 0
          ? _eventListProvider.allEvents
          : _eventListProvider.eventModeSelectorIndex == 1
          ? _eventListProvider.yearEvents
          : _eventListProvider.dayEvents,
    );
    _events.sort((a, b) => b.startDate!.compareTo(a.startDate!));
    if (_events.isNotEmpty) {
      int lastYear = _events.first.startDate!.year;
      if (!_expandedYears.contains(lastYear)) {
        setState(() {
          _expandedYears.add(lastYear);
        });
      }
    }
  }

  /// Navigate to the event creation form screen to create a new event.
  void _navigateToAddEventScreen(BuildContext context) async {
    // set a new event to be created
    Provider.of<EventCreationProvider>(
      context,
      listen: false,
    ).setEventToEdit(new Event());

    // navigate to the event creation form screen
    Navigator.pushNamed(context, '/addEditEvent');
  }

  /// Navigate to the detail screen of the specified [event].
  void _navigateToEventDetailScreen(BuildContext context, Event event) async {
    // fetch the event to get complete data then navigate to event detail screen
    Provider.of<EventDetailProvider>(context, listen: false)
        .fetchEvent(event)
        .then((value) => Navigator.pushNamed(context, '/eventDetail'));
  }

  @override
  Widget build(BuildContext context) {
    _log.info("Building Event list");
    final _eventListProvider = Provider.of<EventListProvider>(
      context,
      listen: true,
    );

    // on date selection in calendar, fetch events for that date
    void onSelect(DateTime date, CalendarMode calendarMode) {
      _eventListProvider.setSelectedDate(date);
      calendarMode == CalendarMode.year
          ? _eventListProvider.fetchEventListForYear(date.year)
          : _eventListProvider.fetchEventListForDayAndMonthAndYear(
            date.day,
            date.month,
            date.year,
          );
    }

    // on refresh, fetch events depending on display mode
    Future<void> onRefresh() {
      if (_eventListProvider.eventModeSelectorIndex == 0) {
        return _eventListProvider.fetchEventList();
      } else if (_eventListProvider.eventModeSelectorIndex == 1) {
        return _eventListProvider.fetchEventListForYear(DateTime.now().year);
      } else if (_eventListProvider.eventModeSelectorIndex == 2) {
        return _eventListProvider.fetchEventListForDayAndMonthAndYear(
          _eventListProvider.selectedDate.day,
          _eventListProvider.selectedDate.month,
          _eventListProvider.selectedDate.year,
        );
      } else {
        return _eventListProvider.fetchEventList();
      }
    }

    // assign fetched events depending on display mode and sort them
    List<Event> _events = List<Event>.from(
      _eventListProvider.eventModeSelectorIndex == 0
          ? _eventListProvider.allEvents
          : _eventListProvider.eventModeSelectorIndex == 1
          ? _eventListProvider.yearEvents
          : _eventListProvider.dayEvents,
    );

    // Sort events by date in descending order
    _events.sort((a, b) => b.startDate!.compareTo(a.startDate!));

    // Group events by year
    Map<int, List<Event>> eventsByYear = {};
    for (var event in _events) {
      int year = event.startDate!.year;
      if (!eventsByYear.containsKey(year)) {
        eventsByYear[year] = [];
      }
      eventsByYear[year]!.add(event);
    }
    List<int> sortedYears =
        eventsByYear.keys.toList()..sort((a, b) => b.compareTo(a));

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
                border: Border.all(color: Colors.red[700]!, width: 1),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        _eventListProvider.changeEventModeSelectorIndex(0);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _eventListProvider.eventModeSelectorIndex == 0
                                  ? Colors.red[700]
                                  : Colors.white70,
                          border: Border(
                            right: BorderSide(
                              color: Colors.red[700]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          AppString.all,
                          style: TextStyle(
                            color:
                                _eventListProvider.eventModeSelectorIndex == 0
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        _eventListProvider.fetchEventListForYear(
                          DateTime.now().year,
                        );
                        _eventListProvider.changeEventModeSelectorIndex(1);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _eventListProvider.eventModeSelectorIndex == 1
                                  ? Colors.red[700]
                                  : Colors.white70,
                          border: Border(
                            right: BorderSide(
                              color: Colors.red[700]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          AppString.currentYear,
                          style: TextStyle(
                            color:
                                _eventListProvider.eventModeSelectorIndex == 1
                                    ? Colors.white
                                    : Colors.black87,
                          ),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _eventListProvider.eventModeSelectorIndex == 2
                                  ? Colors.red[700]
                                  : Colors.white70,
                        ),
                        child: Text(
                          AppString.byDate,
                          style: TextStyle(
                            color:
                                _eventListProvider.eventModeSelectorIndex == 2
                                    ? Colors.white
                                    : Colors.black87,
                          ),
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
                    eventsDates: Map.fromIterable(
                      _eventListProvider.allEvents,
                      key: (v) => v.title,
                      value: (v) => v.startDate,
                    ),
                    onlyMonthDays: false,
                    locale: "fr",
                    weekEndDayColor: Colors.blue[700]!,
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
                  defaultText: AppString.eventsNotFound,
                  emptyText:
                      _eventListProvider.eventModeSelectorIndex == 0
                          ? AppString.eventsNotFound
                          : _eventListProvider.eventModeSelectorIndex == 1
                          ? AppString.eventsNotFoundForYear
                          : AppString.eventsNotFoundForDate,
                  loadingStatus:
                      _events.isEmpty
                          ? LoadingStatus.empty
                          : _eventListProvider.loadingStatus,
                  child: ListView.builder(
                    itemCount: sortedYears.length,
                    itemBuilder: (context, yearIndex) {
                      int year = sortedYears[yearIndex];
                      List<Event> yearEvents = eventsByYear[year]!;
                      bool expanded = _expandedYears.contains(year);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (expanded) {
                                  _expandedYears.remove(year);
                                } else {
                                  _expandedYears.add(year);
                                }
                              });
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(vertical: 6.0),
                              elevation: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue[400]!,
                                      Colors.blue[600]!,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal: 16.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        "$year",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        yearEvents.length.toString(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        expanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (expanded)
                            ...yearEvents.map(
                              (event) => Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  right: 8.0,
                                  bottom: 8.0,
                                ),
                                child: InkWell(
                                  child: EventCard(event),
                                  onTap:
                                      () => _navigateToEventDetailScreen(
                                        context,
                                        event,
                                      ),
                                ),
                              ),
                            ),
                        ],
                      );
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
