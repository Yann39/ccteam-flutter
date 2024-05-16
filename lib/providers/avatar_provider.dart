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

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'login_provider.dart';
import 'message_provider.dart';

class AvatarProvider extends ChangeNotifier {
  final Logger _log = new Logger('AvatarProvider');

  // chosen image file representing the avatar
  File? _pickedImage;
  String? _pickedImageName;

  // cropped image of the avatar
  Uint8List? _croppedImage;

  // login provider that can be set from the proxy provider
  late LoginProvider _loginProvider;

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  File? get pickedImage => _pickedImage;

  String? get pickedImageName => _pickedImageName;

  Uint8List? get croppedImage => _croppedImage;

  /// Set the specified [imageFile] representing the avatar
  void setPickedImage(File? imageFile) async {
    _pickedImage = imageFile;
    _notifyListeners();
  }

  /// Set the specified [imageFileName] representing the avatar image file name
  void setPickedImageName(String? imageFileName) async {
    _pickedImageName = imageFileName;
    _notifyListeners();
  }

  /// Load the specified [croppedImage] representing the cropped image avatar
  void setCroppedImage(Uint8List? croppedImage) async {
    _croppedImage = croppedImage;
    _notifyListeners();
  }

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

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of MemberCreationProvider");
    notifyListeners();
  }
}
