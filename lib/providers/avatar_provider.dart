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

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

class AvatarProvider extends ChangeNotifier {
  final Logger _log = new Logger('AvatarProvider');

  File _image;

  File get image => _image;

  /// Load the specified [imageFile] representing the avatar
  Future<void> loadImage(File imageFile) async {
    _image = imageFile;
    _log.info("Notifying listeners of AvatarProvider");
    notifyListeners();
  }
}
