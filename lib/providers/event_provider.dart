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

import 'dart:collection';

import 'package:chachatte_team/models/event.dart';
import 'package:chachatte_team/services/events_service.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

class EventProvider extends ChangeNotifier {
  final Logger _log = new Logger('EventProvider');
  final EventsService _eventsService = new EventsService();
  List<Event> _events = [];
  List<Event> _displayEvents = [];
  List<Event> _memberEvents = [];
  int _eventsPerLine = 1;
  int _eventModeSelectorIndex = 0;

  EventProvider() {
    fetchEvents();
  }

  UnmodifiableListView<Event> get events => UnmodifiableListView(_events);
  UnmodifiableListView<Event> get displayEvents => UnmodifiableListView(_displayEvents);
  UnmodifiableListView<Event> get memberEvents => UnmodifiableListView(_memberEvents);
  int get eventsPerLine => _eventsPerLine;
  int get eventModeSelectorIndex => _eventModeSelectorIndex;

  setDisplayEvents(DateTime date, String calendarMode) {
    final String format = calendarMode == 'year' ? 'My' : 'dMy';
    if (date != null) {
      _displayEvents = _events.where((event) => DateFormat(format).format(event.eventDate) == DateFormat(format).format(date)).toList();
    } else {
      _displayEvents = [];
    }
    notifyListeners();
  }

  changeEventsPerLine() {
    _eventsPerLine = _eventsPerLine < 3 ? _eventsPerLine+1 : 1;
    notifyListeners();
  }

  changeEventModeSelectorIndex(int index) {
    _eventModeSelectorIndex = index ?? 0;
    notifyListeners();
  }

  /// Get the list of all events
  Future<void> fetchEvents() async {
    await _eventsService.fetchEvents().then((value) async {
      _log.fine("Events list retrieved successfully");
      _events = value;
      notifyListeners();
    }, onError: (error) {
      _log.warning("Error when retrieving events list ($error)");
      _events = [];
      notifyListeners();
      throw (error);
    });
    return _events;
  }

  /// Get the list of all events for the specified [memberId]
  Future<void> fetchMemberEvents(int memberId) async {
    await _eventsService.fetchMemberEvents(memberId).then((value) async {
      _log.fine("Member events list retrieved successfully");
      _memberEvents = value;
      notifyListeners();
    }, onError: (error) {
      _log.warning("Error when retrieving member events list ($error)");
      _memberEvents = [];
      notifyListeners();
      throw (error);
    });
    return _memberEvents;
  }

}
