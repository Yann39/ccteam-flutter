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

import 'package:ccteam/services/galleries_service.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import '../models/gallery.dart';
import '../models/photo.dart';

class PhotoProvider extends ChangeNotifier {
  final Logger _log = new Logger('PhotoProvider');
  final GalleriesService _galleriesService = new GalleriesService();

  // current list of photos
  List<Gallery> _galleries = [];

  // current list of photos
  List<Photo> _photos = [];

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  LoadingStatus get loadingStatus => _loadingStatus;

  // constructor
  PhotoProvider() {
    // as soon as it is instantiated, we fetch all galleries
    _fetchGalleries();
  }

  UnmodifiableListView<Photo> get photos => UnmodifiableListView(_photos);

  UnmodifiableListView<Gallery> get galleries => UnmodifiableListView(_galleries);

  /// Update the current loading status
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of PhotoProvider");
    notifyListeners();
  }

  /// Get the list of all photos for the specified [galleryId]
  /// Galleries must have be fetched before
  void fetchPhotosFromGallery(String galleryId) async {
    _updateStatus(LoadingStatus.loading);
    _log.fine("Fetching photos for gallery ID $galleryId");
    try {
      final photos = await _galleriesService.fetchPhotosForAlbum(galleryId);
      _photos = photos;
      _updateStatus(LoadingStatus.loaded);
    } catch (error) {
      _log.warning("Error when retrieving photos for gallery $galleryId ($error)");
      _photos = [];
      _updateStatus(LoadingStatus.notLoaded);
    }
  }

  /// Get the list of all galleries
  void _fetchGalleries() async {
    _updateStatus(LoadingStatus.loading);
    await _galleriesService.fetchGalleries().then(
      (value) async {
        _log.fine("Galleries list retrieved successfully");
        _galleries = value;
        _updateStatus(LoadingStatus.loaded);
      },
      onError: (error) {
        _log.warning("Error when retrieving galleries list ($error)");
        _galleries = [];
        _updateStatus(LoadingStatus.notLoaded);
        throw (error);
      },
    );
  }
}
