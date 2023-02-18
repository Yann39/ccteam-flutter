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

import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/models/news.dart';
import 'package:chachatte_team/services/news_service.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class NewsDetailProvider extends ChangeNotifier {
  final Logger _log = new Logger('NewsDetailProvider');
  final NewsService _newsService = new NewsService();

  // current news
  News _currentNews;

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  News get currentNews => _currentNews;

  LoadingStatus get loadingStatus => _loadingStatus;

  /// Update the current loading status
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of NewsDetailProvider");
    notifyListeners();
  }

  /// Fetch the specified [news]
  Future<void> fetchCurrentNews(News news) async {
    _log.fine("Fetching news ${news.title}...");
    _updateStatus(LoadingStatus.loading);
    await _newsService.getNewsById(news.id).then((value) async {
      _log.fine("News with ID ${news.id} retrieved successfully");
      _currentNews = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving news ($error)");
      _currentNews = null;
      _updateStatus(LoadingStatus.notLoaded);
      throw (error);
    });
  }

  /// Like the specified [news] for the specified [member]
  Future<void> likeNews(News news, Member member) async {
    _log.fine("Liking news ${news.title}...");
    await _newsService.likeNews(news.id, member.id).then((value) async {
      _log.fine("News ${news.title} liked by user ${member.email}");
      _currentNews = value;
      _log.info("Notifying listeners of NewsDetailProvider");
      notifyListeners();
    }, onError: (error) {
      _log.warning(
          "Error when liking news ${news.title} for user ${member.email} ($error)");
      throw (error);
    });
  }

  /// Unlike the specified [news] for the specified [member]
  Future<void> unlikeNews(News news, Member member) async {
    await _newsService.unlikeNews(news.id, member.id).then((value) async {
      _log.fine("News ${news.title} unliked by user ${member.email}");
      _currentNews = value;
      _log.info("Notifying listeners of NewsDetailProvider");
      notifyListeners();
    }, onError: (error) {
      _log.warning(
          "Error when unliking news ${news.title} for user ${member.email} ($error)");
      throw (error);
    });
  }
}
