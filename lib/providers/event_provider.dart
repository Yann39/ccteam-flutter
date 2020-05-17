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
import 'package:chachatte_team/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

class EventProvider extends ChangeNotifier {
  final Logger _log = new Logger('EventProvider');
  final EventsService _eventsService = new EventsService();

  // list of all events
  List<Event> _events = [];

  // list of events to be displayed when filtering per date
  List<Event> _calendarEvents = [];

  // list of events of a member
  List<Event> _memberEvents = [];

  // list of events of a track
  List<Event> _trackEvents = [];

  // index of the selected top filter, to display events for current year or per date
  int _eventModeSelectorIndex = 0;

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  // constructor
  EventProvider() {
    // as soon as it is instantiated, we fetch events
    _fetchEvents();
  }

  UnmodifiableListView<Event> get events => UnmodifiableListView(_events);

  UnmodifiableListView<Event> get calendarEvents => UnmodifiableListView(_calendarEvents);

  UnmodifiableListView<Event> get memberEvents => UnmodifiableListView(_memberEvents);

  UnmodifiableListView<Event> get trackEvents => UnmodifiableListView(_trackEvents);

  int get eventModeSelectorIndex => _eventModeSelectorIndex;

  LoadingStatus get loadingStatus => _loadingStatus;

  /// Update the current loading status
  /// todo Should we have different variables for all events and member events so that it does not refresh all ?
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of EventProvider");
    notifyListeners();
  }

  /// Get the list of all events
  void _fetchEvents() async {
    _updateStatus(LoadingStatus.loading);
    await _eventsService.fetchEvents().then((value) async {
      _log.fine("Events list retrieved successfully");
      _events = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving events list ($error)");
      _events = [];
      _updateStatus(LoadingStatus.notLoaded);
      throw (error);
    });
  }

  /// Fetch events for the specified [date] according to [calendarMode]
  /// If [calendarMode] is 'year', retrieve all events of the [date] year, else retrieve events of the [date] month
  void fetchDateEvents(DateTime date, String calendarMode) {
    final String format = calendarMode == 'year' ? 'My' : 'dMy';
    if (date != null) {
      _calendarEvents = _events.where((event) => DateFormat(format).format(event.startDate) == DateFormat(format).format(date)).toList();
    } else {
      _calendarEvents = [];
    }
    _log.info("Notifying listeners of EventProvider");
    notifyListeners();
  }

  /// Change the index of the selected top filter, to display events for current year or per date
  void changeEventModeSelectorIndex(int index) {
    _eventModeSelectorIndex = index ?? 0;
    _log.info("Notifying listeners of EventProvider");
    notifyListeners();
  }

  /// Get the list of all events for the specified [memberId]
  void fetchMemberEvents(int memberId) async {
    _updateStatus(LoadingStatus.loading);
    await _eventsService.fetchMemberEvents(memberId).then((value) async {
      _log.fine("Member events list retrieved successfully");
      _memberEvents = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving member events list ($error)");
      _memberEvents = [];
      _updateStatus(LoadingStatus.notLoaded);
      throw (error);
    });
  }

  /// Get the list of all events for the specified [trackId]
  void fetchTrackEvents(int trackId) async {
    _updateStatus(LoadingStatus.loading);
    await _eventsService.fetchTrackEvents(trackId).then((value) async {
      _log.fine("Track events list retrieved successfully");
      _trackEvents = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving track events list ($error)");
      _trackEvents = [];
      _updateStatus(LoadingStatus.notLoaded);
      throw (error);
    });
  }
}
