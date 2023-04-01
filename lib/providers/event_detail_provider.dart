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

import 'dart:async';

import 'package:chachatte_team/models/event.dart';
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/providers/message_provider.dart';
import 'package:chachatte_team/services/events_service.dart';
import 'package:chachatte_team/utils/custom_graphql_exception.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:chachatte_team/utils/strings.dart';
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
      _handleServiceException(error);
      _updateStatus(LoadingStatus.notLoaded);
    });
  }

  /// Delete the specified [event].
  Future<void> deleteEvent(Event event) async {
    await _eventsService.deleteEvent(event).then((value) {
      _log.fine("Event deleted successfully : ${event.title}");
      _currentEvent = null;
      _log.info("Notifying listeners of EventDetailProvider");
      _messageProvider.setMessage(AppString.eventDeleted, MessageType.SUCCESS);
      _notifyListeners();
    }, onError: (error) {
      _log.warning("Failed to delete event ($error)");
      _messageProvider.setMessage(AppString.eventDeletionFailed, MessageType.ERROR);
      _handleServiceException(error);
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

  /// Handle specified [error] from service call.
  void _handleServiceException(dynamic error) {
    if (error is CustomGraphQlException) {
      if (error.code == "token_expired") {
        _messageProvider.setMessage(AppString.errorTokenExpired, MessageType.INFO);
      } else if (error.code == "wrong_token_format") {
        _messageProvider.setMessage(AppString.errorTokenWrongFormat, MessageType.ERROR);
      } else if (error.code == "no_token") {
        _messageProvider.setMessage(AppString.errorTokenNotFound, MessageType.ERROR);
      } else if (error.code == "bad_credentials") {
        _messageProvider.setMessage(AppString.errorBadCredentials, MessageType.ERROR);
      } else if (error.code == "internal_error") {
        _messageProvider.setMessage(AppString.errorServerInternal, MessageType.ERROR);
      } else {
        _messageProvider.setMessage(AppString.format(AppString.errorUnknown, [error.toString()]), MessageType.ERROR);
      }
      _loginProvider.logoutMember();
    } else if (error is TimeoutException) {
      _messageProvider.setMessage(AppString.errorServerTimeOut, MessageType.ERROR);
    } else {
      _messageProvider.setMessage(AppString.format(AppString.errorUnknown, [error.toString()]), MessageType.ERROR);
    }
  }
}
