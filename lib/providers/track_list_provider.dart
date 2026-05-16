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

import 'dart:collection';

import 'package:ccteam/models/track.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/tracks_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

class TrackListProvider extends ChangeNotifier {
  final Logger _log = new Logger('TrackListProvider');
  final TracksService _tracksService = new TracksService();

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  late LoginProvider _loginProvider;

  // current list of tracks
  List<Track> _tracks = [];

  // current selected track
  Track? _selectedTrack;

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  // constructor
  TrackListProvider() {
    // as soon as it is instantiated, we fetch all news
    fetchTracks();
  }

  UnmodifiableListView<Track> get tracks => UnmodifiableListView(_tracks);

  LoadingStatus get loadingStatus => _loadingStatus;

  Track? get selectedTrack => _selectedTrack;

  /// Update the current loading status
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of TrackListProvider");
    notifyListeners();
  }

  /// Set the specified [track] as the current selected track
  void selectTrack(Track track) {
    _selectedTrack = track;
    _log.info("Notifying listeners of TrackListProvider");
    notifyListeners();
  }

  /// Update message provider with the specified [messageProvider].
  void updateMessageProvider(MessageProvider messageProvider) {
    _messageProvider = messageProvider;
    notifyListeners();
  }

  /// Update login provider with the specified [loginProvider].
  void updateLoginProvider(LoginProvider loginProvider) {
    _loginProvider = loginProvider;
    notifyListeners();
  }

  /// Get the list of all tracks.
  Future<void> fetchTracks() async {
    _updateStatus(LoadingStatus.loading);
    await _tracksService.fetchTracks().then(
      (value) async {
        _log.fine("Tracks list of ${value.length} tracks retrieved successfully");
        _tracks = value;
        _updateStatus(_tracks.isEmpty ? LoadingStatus.empty : LoadingStatus.loaded);
      },
      onError: (error) {
        _log.warning("Error when retrieving tracks list ($error)");
        _tracks = [];
        AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
        _updateStatus(LoadingStatus.notLoaded);
      },
    );
  }

  /// Search for tracks according to the specified [text].
  void searchTracks(String text) async {
    _updateStatus(LoadingStatus.loading);
    await _tracksService
        .searchTracks(text)
        .then(
          (value) async {
            _log.fine("Tracks search list retrieved successfully");
            _tracks = value;
            _updateStatus(_tracks.isEmpty ? LoadingStatus.empty : LoadingStatus.loaded);
          },
          onError: (error) {
            _log.warning("Error when searching tracks ($error)");
            _tracks = [];
            _updateStatus(LoadingStatus.notLoaded);
            throw (error);
          },
        );
  }

  /// Create the specified [track]
  Future<void> createTrack(Track track) async {
    await _tracksService
        .createTrack(track)
        .then(
          (value) {
            _log.fine("New track created : ${track.name}");
            _tracks.add(track);
            // flip the loading status back to `loaded`
            _loadingStatus = LoadingStatus.loaded;
            _log.info("Notifying listeners of TrackListProvider");
            notifyListeners();
          },
          onError: (error) {
            _log.severe("Failed to create new track ($error)");
            throw (error);
          },
        );
  }

  /// Update the specified [track]
  Future<void> updateTrack(Track track) async {
    await _tracksService
        .updateTrack(track)
        .then(
          (value) {
            _log.fine("Track successfully updated : ${track.name}");
            _tracks[_tracks.indexWhere((m) => m.id == track.id)] = track;
            _log.info("Notifying listeners of TrackListProvider");
            notifyListeners();
          },
          onError: (error) {
            _log.severe("Failed to update track ($error)");
            throw (error);
          },
        );
  }
}
