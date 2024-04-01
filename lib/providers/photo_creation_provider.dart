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

import 'package:ccteam/models/photo.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../services/photos_service.dart';

class PhotoCreationProvider extends ChangeNotifier {
  final Logger _log = new Logger('PhotoCreationProvider');
  final PhotosService _photosService = new PhotosService();

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  late LoginProvider _loginProvider;

  // current photo
  Photo _photo = new Photo();

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  Photo get photo => _photo;

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

  /// Set the [Photo] to be edited.
  void setPhotoToEdit(Photo photo) {
    _photo = photo;
    _updateStatus(LoadingStatus.loaded);
  }

  /// Create the current photo being edited.
  Future<void> createPhoto() async {
    _updateStatus(LoadingStatus.loading);
    await _photosService.createPhoto(_photo).then((value) async {
      _log.fine("Photo created successfully");
      //_photo = value;
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(AppString.photoCreated, MessageType.SUCCESS);
    }, onError: (error) {
      _log.warning("Error when creating photo ($error)");
      _messageProvider.setMessage(AppString.photoCreationFailed, MessageType.ERROR);
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    });
  }

  /// Update the current photo being edited.
  Future<void> updatePhoto() async {
    _updateStatus(LoadingStatus.loading);
    await _photosService.updatePhoto(_photo).then((value) {
      _log.fine("Photo successfully updated : ${_photo.title}");
      //_photo = value;
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(AppString.photoUpdated, MessageType.SUCCESS);
    }, onError: (error) {
      // todo here we should reload the original photo as it has not been updated in db ?
      _log.warning("Error when updating photo ($error)");
      _messageProvider.setMessage(AppString.photoUpdateFailed, MessageType.ERROR);
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    });
  }

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of PhotoCreationProvider");
    notifyListeners();
  }

  /// Update the current loading [status].
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _notifyListeners();
  }
}
