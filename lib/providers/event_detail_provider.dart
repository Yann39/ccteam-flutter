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

import 'package:ccteam/models/event.dart';
import 'package:ccteam/models/track.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/events_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class EventDetailProvider extends ChangeNotifier {
  final Logger _log = new Logger('EventDetailProvider');
  final EventsService _eventsService = new EventsService();

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  late LoginProvider _loginProvider;

  // current event
  Event _currentEvent = Event();

  // list of events (for track detail)
  List<Event> _allEvents = [];

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  Event get currentEvent => _currentEvent;

  List<Event> get allEvents => _allEvents;

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

  /// Set the current event to be the specified [event].
  void setCurrentEvent(Event event) {
    _currentEvent = event;
    _notifyListeners();
  }

  /// Fetch the specified [event] from the database.
  Future<void> fetchEvent(Event event) async {
    _log.fine("Fetching event ${event.title}...");
    _updateStatus(LoadingStatus.loading);
    await _eventsService
        .getEventById(event.id!)
        .then(
          (value) async {
            _log.fine("Event ID ${event.id} retrieved successfully");
            _currentEvent = value;
            _updateStatus(LoadingStatus.loaded);
          },
          onError: (error) {
            _log.warning("Error when retrieving event ($error)");
            AppUtils.handleServiceException(
              error,
              _messageProvider,
              _loginProvider,
            );
            _updateStatus(LoadingStatus.notLoaded);
          },
        );
  }

  /// Delete the specified [event].
  Future<void> deleteEvent(Event event) async {
    await _eventsService
        .deleteEvent(event)
        .then(
          (value) {
            _log.fine("Event deleted successfully : ${event.title}");
            // this shouldn't be a problem to not set _currentEvent to null but keep the deleted event,
            // because _currentEvent is initialized before each display of the EventDetail view,
            // setting _currentEvent to null would require EventDetail view to handle a null event
            _currentEvent = value;
            _messageProvider.setMessage(
              AppString.eventDeleted,
              MessageType.SUCCESS,
            );
            _notifyListeners();
          },
          onError: (error) {
            _log.warning("Failed to delete event ($error)");
            _messageProvider.setMessage(
              AppString.eventDeletionFailed,
              MessageType.ERROR,
            );
            AppUtils.handleServiceException(
              error,
              _messageProvider,
              _loginProvider,
            );
            _notifyListeners();
          },
        );
  }

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of EventDetailProvider");
    notifyListeners();
  }

  /// Fetch events for the specified [track] from the database.
  Future<void> fetchEventsByTrack(Track track) async {
    _log.fine("Fetching events for track ${track.name}...");
    // clear stale data so the UI doesn't briefly show events from a
    // previous track while the new ones are being fetched
    _allEvents = [];
    _updateStatus(LoadingStatus.loading);
    await _eventsService
        .fetchEventsByTrack(track.id!)
        .then(
          (value) async {
            _log.fine(
              "${value.length} events for track ${track.id} retrieved successfully",
            );
            _allEvents = value;
            _updateStatus(LoadingStatus.loaded);
          },
          onError: (error) {
            _log.warning("Error when retrieving track events ($error)");
            _allEvents = [];
            AppUtils.handleServiceException(
              error,
              _messageProvider,
              _loginProvider,
            );
            _updateStatus(LoadingStatus.notLoaded);
          },
        );
  }

  /// Reset the events list and mark it as loading. Useful when navigating
  /// to a screen whose data depends on a fresh fetch (e.g. track detail),
  /// so the UI displays a loader instead of the previous track's events.
  void clearAllEvents() {
    _allEvents = [];
    _loadingStatus = LoadingStatus.loading;
    _notifyListeners();
  }

  /// Update the current loading [status].
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _notifyListeners();
  }

  /// Register the specified [member] to the specified [event].
  Future<void> registerToEvent(Event event, int memberId) async {
    _log.fine("Registering member $memberId to event ${event.title}...");
    await _eventsService
        .registerToEvent(event.id!, memberId)
        .then(
          (value) {
            _log.fine("Registered successfully to event : ${event.title}");
            _updateEventInList(value);
            _messageProvider.setMessage(
              AppString.eventRegistered,
              MessageType.SUCCESS,
            );
          },
          onError: (error) {
            _log.warning("Failed to register to event ($error)");
            AppUtils.handleServiceException(
              error,
              _messageProvider,
              _loginProvider,
            );
          },
        );
  }

  /// Unregister the specified [member] from the specified [event].
  Future<void> unregisterFromEvent(Event event, int memberId) async {
    _log.fine("Unregistering member $memberId from event ${event.title}...");
    await _eventsService
        .unregisterFromEvent(event.id!, memberId)
        .then(
          (value) {
            _log.fine("Unregistered successfully from event : ${event.title}");
            _updateEventInList(value);
            _messageProvider.setMessage(
              AppString.eventUnregistered,
              MessageType.SUCCESS,
            );
          },
          onError: (error) {
            _log.warning("Failed to unregister from event ($error)");
            AppUtils.handleServiceException(
              error,
              _messageProvider,
              _loginProvider,
            );
          },
        );
  }

  /// Update the specified [event] in the list of events.
  void _updateEventInList(Event event) {
    final int index = _allEvents.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _allEvents[index] = event;
    }
    if (_currentEvent.id == event.id) {
      _currentEvent = event;
    }
    _notifyListeners();
  }
}
