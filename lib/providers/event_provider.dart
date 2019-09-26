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
import 'package:logging/logging.dart';

class EventProvider extends ChangeNotifier {
  final Logger _log = new Logger('EventProvider');
  final EventsService _eventsService = new EventsService();
  List<Event> _events = [];
  bool _more = false;

  EventProvider() {
    fetchEvents();
  }

  UnmodifiableListView<Event> get events => UnmodifiableListView(_events);
  bool get more => _more;

  /// Get the list of all news
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

  toggleMore() {
    _more = !_more;
    notifyListeners();
  }

}
