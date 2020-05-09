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

import 'package:chachatte_team/models/photo.dart';
import 'package:chachatte_team/services/photos_service.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

class PhotoProvider extends ChangeNotifier {
  final Logger _log = new Logger('PhotoProvider');
  final PhotosService _photosService = new PhotosService();

  // current list of photos
  List<Photo> _photos = [];

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  LoadingStatus get loadingStatus => _loadingStatus;

  // constructor
  PhotoProvider() {
    // as soon as it is instantiated, we fetch all news
    _fetchPhotos();
  }

  UnmodifiableListView<Photo> get photos => UnmodifiableListView(_photos);

  /// Update the current loading status
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of NewsProvider");
    notifyListeners();
  }

  /// Get the list of all photos
  void _fetchPhotos() async {
    _updateStatus(LoadingStatus.loading);
    await _photosService.fetchPhotos().then((value) async {
      _log.fine("Photos list retrieved successfully");
      _photos = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving photos list ($error)");
      _photos = [];
      _updateStatus(LoadingStatus.notLoaded);
      throw (error);
    });
  }

  /// Create the specified [photo]
  Future<void> createPhoto(Photo photo) async {
    await _photosService.createPhoto(photo).then((value) {
      _log.fine("New photo created : ${photo.title}");
      _photos.add(photo);
      _log.info("Notifying listeners of PhotoProvider");
      notifyListeners();
    }, onError: (error) {
      _log.severe("Failed to create new photo ($error)");
      throw (error);
    });
  }

  /// Update the specified [photo]
  Future<void> updatePhoto(Photo photo) async {
    await _photosService.createPhoto(photo).then((value) {
      _log.fine("Photo successfully updated : ${photo.title}");
      _photos[_photos.indexWhere((m) => m.id == photo.id)] = photo;
      _log.info("Notifying listeners of PhotoProvider");
      notifyListeners();
    }, onError: (error) {
      _log.severe("Failed to update photo ($error)");
      throw (error);
    });
  }

  /// Delete the specified [photo]
  Future<void> deletePhoto(Photo photo) async {
    await _photosService.deletePhoto(photo).then((value) {
      _log.fine("Photo deleted successfully : ${photo.title}");
      _photos.remove(photo);
      _log.info("Notifying listeners of PhotoProvider");
      notifyListeners();
    }, onError: (error) {
      _log.severe("Failed to delete photo ($error)");
      throw (error);
    });
  }
}
