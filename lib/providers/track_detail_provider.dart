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

import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/tracks_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'package:ccteam/models/track.dart';

class TrackDetailProvider extends ChangeNotifier {
  final Logger _log = new Logger('TrackDetailProvider');
  final TracksService _tracksService = new TracksService();

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  late LoginProvider _loginProvider;

  // current track
  Track? _currentTrack;

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  Track? get currentTrack => _currentTrack;

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

  /// Set the current track to be the specified [track].
  void setCurrentTrack(Track track) {
    _currentTrack = track;
    _notifyListeners();
  }

  /// Fetch the specified [track] from the database.
  Future<void> fetchTrack(Track track) async {
    _log.fine("Fetching track ${track.name}...");
    _updateStatus(LoadingStatus.loading);
    await _tracksService
        .getTrackById(track.id!)
        .then(
          (value) async {
            _log.fine("Track ID ${track.id} retrieved successfully");
            _currentTrack = value;
            _updateStatus(LoadingStatus.loaded);
          },
          onError: (error) {
            _log.warning("Error when retrieving track ($error)");
            _currentTrack = null;
            AppUtils.handleServiceException(
              error,
              _messageProvider,
              _loginProvider,
            );
            _updateStatus(LoadingStatus.notLoaded);
          },
        );
  }

  /// Delete the specified [track]
  Future<void> deleteTrack(Track track) async {
    await _tracksService
        .deleteTrack(track)
        .then(
          (value) {
            _log.fine("Track deleted successfully : ${track.name}");
            _currentTrack = null;
            _log.info("Notifying listeners of TrackListProvider");
            notifyListeners();
          },
          onError: (error) {
            _log.severe("Failed to delete track ($error)");
            throw (error);
          },
        );
  }

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of NewsDetailProvider");
    notifyListeners();
  }

  /// Update the current loading [status].
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _notifyListeners();
  }
}
