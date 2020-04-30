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

import 'package:chachatte_team/models/track.dart';
import 'package:chachatte_team/services/tracks_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

class TrackProvider extends ChangeNotifier {
  final Logger _log = new Logger('TrackProvider');
  final TracksService _tracksService = new TracksService();
  List<Track> _tracks = [];
  bool _loading = true;

  TrackProvider() {
    fetchTracks();
  }

  UnmodifiableListView<Track> get tracks => UnmodifiableListView(_tracks);
  bool get loading => _loading;

  /// Get the list of all tracks
  Future<void> fetchTracks() async {
    _loading = true;
    notifyListeners();
    await _tracksService.fetchTracks().then((value) async {
      _log.fine("Tracks list retrieved successfully");
      _tracks = value;
      _loading = false;
      notifyListeners();
    }, onError: (error) {
      _log.warning("Error when retrieving tracks list ($error)");
      _tracks = [];
      _loading = false;
      notifyListeners();
      throw (error);
    });
  }

  /// Search for tracks according to the specified [text]
  Future<void> searchTracks(String text) async {
    _loading = true;
    notifyListeners();
    await _tracksService.searchTracks(text).then((value) async {
      _log.fine("Members search list retrieved successfully");
      _tracks = value;
      _loading = false;
      notifyListeners();
    }, onError: (error) {
      _log.warning("Error when searching tracks ($error)");
      _tracks = [];
      _loading = false;
      notifyListeners();
      throw (error);
    });
  }

  /// Create the specified [track]
  Future<void> createTrack(Track track) async {
    await _tracksService.createTrack(track).then((value) {
      _log.fine("New track created : ${track.name}");
      _tracks.add(track);
      notifyListeners();
    }, onError: (error) {
      _log.severe("Failed to create new track ($error)");
      throw (error);
    });
  }

  /// Update the specified [track]
  Future<void> updateTrack(Track track) async {
    await _tracksService.createTrack(track).then((value) {
      _log.fine("Track successfully updated : ${track.name}");
      _tracks[_tracks.indexWhere((m) => m.id == track.id)] = track;
      notifyListeners();
    }, onError: (error) {
      _log.severe("Failed to update track ($error)");
      throw (error);
    });
  }

  /// Delete the specified [track]
  Future<void> deleteTrack(Track track) async {
    await _tracksService.deleteTrack(track).then((value) {
      _log.fine("Track deleted successfully : ${track.name}");
      _tracks.remove(track);
      notifyListeners();
    }, onError: (error) {
      _log.severe("Failed to delete track ($error)");
      throw (error);
    });
  }
}
