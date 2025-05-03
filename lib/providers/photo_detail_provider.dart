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
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../models/photo.dart';
import '../services/photos_service.dart';

class PhotoDetailProvider extends ChangeNotifier {
  final Logger _log = new Logger('PhotoDetailProvider');
  final PhotosService _photosService = new PhotosService();

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  late LoginProvider _loginProvider;

  // current photo
  late Photo _currentPhoto;

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  Photo get currentPhoto => _currentPhoto;

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

  /// Set the current photo to be the specified [photo].
  void setCurrentPhoto(Photo photo) {
    _currentPhoto = photo;
    _notifyListeners();
  }

  /// Delete the specified [photo].
  Future<void> deletePhoto(Photo photo) async {
    await _photosService
        .deletePhoto(photo)
        .then(
          (value) {
            _log.fine("Photo deleted successfully : ${photo.title}");
            _messageProvider.setMessage(
              AppString.photoDeleted,
              MessageType.SUCCESS,
            );
            _notifyListeners();
          },
          onError: (error) {
            _log.warning("Failed to delete photo ($error)");
            _messageProvider.setMessage(
              AppString.photoDeletionFailed,
              MessageType.ERROR,
            );
            AppUtils.handleServiceException(
              error,
              _messageProvider,
              _loginProvider,
            );
            _notifyListeners();
          },
        );
  }

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of PhotoDetailProvider");
    notifyListeners();
  }

  /// Update the current loading [status].
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _notifyListeners();
  }
}
