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

import 'package:chachatte_team/models/news.dart';
import 'package:chachatte_team/services/news_service.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class NewsCreationProvider extends ChangeNotifier {
  final Logger _log = new Logger('NewsCreationProvider');
  final NewsService _newsService = new NewsService();

  // current news being created/edited
  News _news = new News();

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  News get news => _news;

  LoadingStatus get loadingStatus => _loadingStatus;

  /// Update the current loading status
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of NewsListProvider");
    notifyListeners();
  }

  void setNewsToEdit(News news) {
    _news = news;
  }

  /// Get the list of all news
  Future<void> createNews() async {
    _updateStatus(LoadingStatus.loading);
    await _newsService.createNews(news).then((value) async {
      _log.fine("News created successfully");
      _news = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when creating news ($error)");
      _news = null;
      _updateStatus(LoadingStatus.notLoaded);
      throw (error);
    });
  }
}
