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

  /// Insert the server-persisted [track] into the in-memory list and
  /// re-sort alphabetically so the list looks like a freshly fetched
  /// one. Memory-only: callers run the GraphQL mutation via
  /// [TrackCreationProvider] first, then push the returned entity here.
  void addTrackInList(Track track) {
    _tracks.add(track);
    _tracks.sort((a, b) => (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));
    // flip the loading status back to `loaded`
    _loadingStatus = LoadingStatus.loaded;
    _log.info("Notifying listeners of TrackListProvider");
    notifyListeners();
  }

  /// Replace the in-memory copy of the [track] with the freshly
  /// updated entity returned by the server, then re-sort (the name may
  /// have changed). Memory-only, see [addTrackInList].
  void updateTrackInList(Track track) {
    final int idx = _tracks.indexWhere((t) => t.id == track.id);
    if (idx != -1) {
      _tracks[idx] = track;
    }
    _tracks.sort((a, b) => (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));
    _log.info("Notifying listeners of TrackListProvider");
    notifyListeners();
  }

  /// Drop the track with the specified [trackId] from the in-memory
  /// list and re-derive the empty/loaded status so the UI flips to
  /// the empty placeholder when the last track is removed.
  /// Memory-only, see [addTrackInList].
  void removeTrackFromList(int trackId) {
    _tracks.removeWhere((t) => t.id == trackId);
    _loadingStatus = _tracks.isEmpty ? LoadingStatus.empty : LoadingStatus.loaded;
    _log.info("Notifying listeners of TrackListProvider");
    notifyListeners();
  }
}
