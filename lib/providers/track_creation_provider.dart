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

import 'package:ccteam/models/track.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/tracks_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Holds the edit copy of the [Track] being created or modified in
/// the add/edit track form. Mirrors [EventCreationProvider] /
/// [NewsCreationProvider] in shape and contract so the UI patterns
/// stay consistent.
class TrackCreationProvider extends ChangeNotifier {
  final Logger _log = new Logger('TrackCreationProvider');
  final TracksService _tracksService = new TracksService();

  late MessageProvider _messageProvider;
  late LoginProvider _loginProvider;

  Track _track = new Track();
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  Track get track => _track;

  LoadingStatus get loadingStatus => _loadingStatus;

  void updateMessageProvider(MessageProvider messageProvider) {
    _messageProvider = messageProvider;
    _notifyListeners();
  }

  void updateLoginProvider(LoginProvider loginProvider) {
    _loginProvider = loginProvider;
    _notifyListeners();
  }

  /// Seed the in-progress edit copy with the given [track]. Pass a
  /// fresh empty `Track()` for the creation flow, an existing track
  /// for the edit flow.
  void setTrackToEdit(Track track) {
    _track = track;
    _updateStatus(LoadingStatus.loaded);
  }

  /// Persist the in-progress track as a new row via the GraphQL
  /// mutation. On success the entity is replaced by the server
  /// response (so the caller picks up the assigned id).
  Future<void> createTrack() async {
    _updateStatus(LoadingStatus.loading);
    try {
      _track = await _tracksService.createTrack(_track);
      _log.fine("Track created successfully: ${_track.name}");
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(AppString.trackCreated, MessageType.SUCCESS);
    } catch (error) {
      _log.warning("Error when creating track ($error)");
      _messageProvider.setMessage(AppString.trackCreationFailed, MessageType.ERROR);
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    }
  }

  /// Persist the in-progress track changes via the GraphQL mutation.
  Future<void> updateTrack() async {
    _updateStatus(LoadingStatus.loading);
    try {
      _track = await _tracksService.updateTrack(_track);
      _log.fine("Track successfully updated: ${_track.name}");
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(AppString.trackUpdated, MessageType.SUCCESS);
    } catch (error) {
      _log.warning("Error when updating track ($error)");
      _messageProvider.setMessage(AppString.trackUpdateFailed, MessageType.ERROR);
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    }
  }

  /// Delete the in-progress track via the GraphQL mutation. Throws on
  /// failure so the caller can keep the form open and surface the
  /// error message; mirrors [RecordCreationProvider.deleteRecord].
  Future<void> deleteTrack() async {
    _updateStatus(LoadingStatus.loading);
    try {
      await _tracksService.deleteTrack(_track.id!);
      _log.fine("Track successfully deleted: ${_track.name}");
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(AppString.trackDeleted, MessageType.SUCCESS);
    } catch (error) {
      _log.warning("Error when deleting track ($error)");
      _messageProvider.setMessage(AppString.trackDeletionFailed, MessageType.ERROR);
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
      rethrow;
    }
  }

  void _notifyListeners() {
    _log.info("Notifying listeners of TrackCreationProvider");
    notifyListeners();
  }

  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _notifyListeners();
  }
}
