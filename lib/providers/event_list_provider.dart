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

import 'dart:async';
import 'dart:collection';

import 'package:ccteam/models/event.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/events_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class EventListProvider extends ChangeNotifier {
  final Logger _log = new Logger('EventListProvider');
  final EventsService _eventsService = new EventsService();

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  late LoginProvider _loginProvider;

  // list of all events
  List<Event> _allEvents = [];

  // list of all events of specific year
  List<Event> _yearEvents = [];

  // list of all events of specific day
  List<Event> _dayEvents = [];

  // current selected date in the calendar selector
  DateTime _selectedDate = DateTime.now();

  // index of the selected top filter, to display events for current year or per date
  int _eventModeSelectorIndex = 0;

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  // constructor
  EventListProvider() {
    // as soon as it is instantiated, we fetch the event list
    fetchEventList();
  }

  UnmodifiableListView<Event> get allEvents => UnmodifiableListView(_allEvents);

  UnmodifiableListView<Event> get yearEvents => UnmodifiableListView(_yearEvents);

  UnmodifiableListView<Event> get dayEvents => UnmodifiableListView(_dayEvents);

  DateTime get selectedDate => _selectedDate;

  int get eventModeSelectorIndex => _eventModeSelectorIndex;

  LoadingStatus get loadingStatus => _loadingStatus;

  /// Update message provider with the specified [messageProvider].
  void updateMessageProvider(MessageProvider messageProvider) {
    _messageProvider = messageProvider;
    _notifyListeners();
  }

  /// Update login provider with the specified [loginProvider].
  void updateLoginProvider(LoginProvider loginProvider) {
    _loginProvider = loginProvider;
    _notifyListeners();
  }

  /// Update the current selected date to the specified [date].
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _notifyListeners();
  }

  /// Change the [index] of the selected top filter, to display events for the current year or per date.
  void changeEventModeSelectorIndex(int? index) {
    _eventModeSelectorIndex = index ?? 0;
    _notifyListeners();
  }

  /// Add the specified [event] to the current event list.
  void addEventInList(Event event) {
    _allEvents.add(event);

    // re-sort the list by date
    _allEvents.sort((a, b) => a.startDate!.compareTo(b.startDate!));

    _notifyListeners();
  }

  /// Update the specified [event] in the current event list.
  void updateEventInList(Event event) {
    final int index = _allEvents.indexWhere((n) => n.id == event.id);
    if (index != -1) {
      _allEvents[index] = event;
      _notifyListeners();
    }
  }

  /// Remove the specified [event] from the current event list.
  void removeEventFromList(Event event) {
    _allEvents.removeWhere((n) => n.id == event.id);
    _notifyListeners();
  }

  /// Fetch the list of all events.
  Future<void> fetchEventList() async {
    _updateLoadingStatus(LoadingStatus.loading);
    await _eventsService.fetchEvents().then((value) async {
      _log.fine("Events list of ${value.length} events retrieved successfully");
      _allEvents = value;
      _updateLoadingStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving events list ($error)");
      _allEvents = [];
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateLoadingStatus(LoadingStatus.notLoaded);
    });
  }

  /// Filter current events list to retrieve only event of the specified [year].
  Future<void> fetchEventListForYear(int year) async {
    _updateLoadingStatus(LoadingStatus.loading);
    await _eventsService.fetchEventsForYear(year).then((value) async {
      _log.fine("Events list for year $year retrieved successfully");
      _yearEvents = value;
      _updateLoadingStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving events list for year $year ($error)");
      _yearEvents = [];
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateLoadingStatus(LoadingStatus.notLoaded);
    });
  }

  /// Filter current events list to retrieve only event of the specified [month] and [year].
  Future<void> fetchEventListForMonthAndYear(int month, int year) async {
    _updateLoadingStatus(LoadingStatus.loading);
    await _eventsService.fetchEventsForMonthAndYear(month, year).then((value) async {
      _log.fine("Events list for month $month and year $year retrieved successfully");
      _dayEvents = value;
      _updateLoadingStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving events list for month $month and year $year ($error)");
      _dayEvents = [];
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateLoadingStatus(LoadingStatus.notLoaded);
    });
  }

  /// Filter current events list to retrieve only event of the specified [day], [month] and [year].
  Future<void> fetchEventListForDayAndMonthAndYear(int day, int month, int year) async {
    _updateLoadingStatus(LoadingStatus.loading);
    await _eventsService.fetchEventsForDayAndMonthAndYear(day, month, year).then((value) async {
      _log.fine("Events list for day $day, month $month and year $year retrieved successfully");
      _dayEvents = value;
      _updateLoadingStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving events list for day $day, month $month and year $year ($error)");
      _dayEvents = [];
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateLoadingStatus(LoadingStatus.notLoaded);
    });
  }

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of EventListProvider");
    notifyListeners();
  }

  /// Update the current loading [status].
  void _updateLoadingStatus(LoadingStatus status) {
    _loadingStatus = status;
    _notifyListeners();
  }
}
