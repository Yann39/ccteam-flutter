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
  MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  LoginProvider _loginProvider;

  // current event
  Event _currentEvent;

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  Event get currentEvent => _currentEvent;

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
    await _eventsService.getEventById(event.id).then((value) async {
      _log.fine("Event ID ${event.id} retrieved successfully");
      _currentEvent = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving event ($error)");
      _currentEvent = null;
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    });
  }

  /// Delete the specified [event].
  Future<void> deleteEvent(Event event) async {
    await _eventsService.deleteEvent(event).then((value) {
      _log.fine("Event deleted successfully : ${event.title}");
      _currentEvent = null;
      _messageProvider.setMessage(AppString.eventDeleted, MessageType.SUCCESS);
      _notifyListeners();
    }, onError: (error) {
      _log.warning("Failed to delete event ($error)");
      _messageProvider.setMessage(AppString.eventDeletionFailed, MessageType.ERROR);
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _notifyListeners();
    });
  }

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of EventDetailProvider");
    notifyListeners();
  }

  /// Update the current loading [status].
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _notifyListeners();
  }
}
