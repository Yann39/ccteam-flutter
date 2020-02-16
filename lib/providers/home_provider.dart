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

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class HomeProvider extends ChangeNotifier {
  static final Logger _log = new Logger('HomeProvider');
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  /// set the current page index
  setCurrentIndex(int currIndex) {
    _currentIndex = currIndex;
    _log.info("Notifying listeners of HomeProvider");
    notifyListeners();
  }
}
