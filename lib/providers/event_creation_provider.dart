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

class EventCreationProvider extends ChangeNotifier {
  final Logger _log = new Logger('EventCreationProvider');
  final EventsService _eventsService = new EventsService();

  // message provider that can be set from the proxy provider
  MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  LoginProvider _loginProvider;

  // current event
  Event _event = new Event();

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  Event get event => _event;

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

  /// Set the [Event] to be edited.
  void setEventToEdit(Event event) {
    _event = event;
    _updateStatus(LoadingStatus.loaded);
  }

  /// Create the current event being edited.
  Future<void> createEvent() async {
    _updateStatus(LoadingStatus.loading);
    await _eventsService.createEvent(_event).then((value) async {
      _log.fine("Event created successfully");
      _event = value;
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(AppString.eventCreated, MessageType.SUCCESS);
    }, onError: (error) {
      _log.warning("Error when creating event ($error)");
      _messageProvider.setMessage(AppString.eventCreationFailed, MessageType.ERROR);
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    });
  }

  /// Update the current event being edited.
  Future<void> updateEvent() async {
    _updateStatus(LoadingStatus.loading);
    await _eventsService.updateEvent(_event).then((value) {
      _log.fine("Event successfully updated : ${_event.title}");
      _event = value;
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(AppString.eventUpdated, MessageType.SUCCESS);
    }, onError: (error) {
      // todo here we should reload the original event as it has not been updated in db ?
      _log.warning("Error when updating event ($error)");
      _messageProvider.setMessage(AppString.eventUpdateFailed, MessageType.ERROR);
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    });
  }

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of EventCreationProvider");
    notifyListeners();
  }

  /// Update the current loading [status].
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _notifyListeners();
  }
}
