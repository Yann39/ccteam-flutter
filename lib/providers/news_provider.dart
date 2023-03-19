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

import 'package:chachatte_team/models/news.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class NewsProvider extends ChangeNotifier {
  final Logger _log = new Logger('NewsProvider');

  // current news list
  List<News> _news = [];

  // current news
  News _currentNews;

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  LoadingStatus _currentNewsLoadingStatus = LoadingStatus.notLoaded;

  UnmodifiableListView<News> get news => UnmodifiableListView(_news);

  News get currentNews => _currentNews;

  LoadingStatus get loadingStatus => _loadingStatus;

  LoadingStatus get currentNewsLoadingStatus => _currentNewsLoadingStatus;

  /// Update the current loading status
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of NewsProvider");
    notifyListeners();
  }

  /// Update the current news loading status
  void _updateCurrentNewsStatus(LoadingStatus status) {
    _currentNewsLoadingStatus = status;
    _log.info("Notifying listeners of NewsProvider");
    notifyListeners();
  }
}
