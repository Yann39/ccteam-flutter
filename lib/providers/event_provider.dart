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

class EventProvider extends ChangeNotifier {
  final List<Event> _events = [];
  final EventsService _eventsService = new EventsService();

  /// An unmodifiable view of events.
  UnmodifiableListView<Event> get events => UnmodifiableListView(_events);

  /// Add an event
  void add(Event event) {
    _eventsService.createEvent(event);
    _events.add(event);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  /// Get the list of all events
  Future<List<Event>> fetchEvents() async {
    List<Event> evs = await _eventsService.fetchEvents();
    _events.clear();
    _events.addAll(evs);
    return evs;
    return _eventsService.fetchEvents();
  }
}
