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

class DrawerProvider extends ChangeNotifier {
  final Logger _log = new Logger('DrawerProvider');

  File _image;
  int _imageSize;

  File get image => _image;

  int get imageSize => _imageSize;

  /// Check if the user needs to authenticate
  Future<void> loadImage(File imageFile) async {
    _log.info("Loading image");
    _image = imageFile;
    FileStat fs = imageFile.statSync();
    _imageSize = fs.size;
    notifyListeners();
  }
}
