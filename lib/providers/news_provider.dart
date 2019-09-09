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
import 'package:chachatte_team/services/news_service.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class NewsProvider extends ChangeNotifier {
  final Logger _log = new Logger('NewsProvider');
  final NewsService _newsService = new NewsService();
  List<News> _news = [];

  NewsProvider() {
    fetchNews();
  }

  UnmodifiableListView<News> get news => UnmodifiableListView(_news);

  /// Get the list of all news
  Future<void> fetchNews() async {
    await _newsService.fetchNews().then((value) async {
      _log.fine("News list retrieved successfully");
      _news = value;
      notifyListeners();
    }, onError: (error) {
      _log.warning("Error when retrieving news list ($error)");
      _news = [];
      notifyListeners();
      throw (error);
    });
    return _news;
  }

  /// Create the specified news
  Future<void> createNews(News news) async {
    await _newsService.createNews(news).then((value) {
      _log.fine("New news created : ${news.title}");
      _news.add(news);
      notifyListeners();
    }, onError: (error) {
      _log.severe("Failed to create new news ($error)");
      throw (error);
    });
  }

  /// Update the specified news
  Future<void> updateNews(News news) async {
    await _newsService.createNews(news).then((value) {
      _log.fine("News successfully updated : ${news.title}");
      _news[_news.indexWhere((m) => m.id == news.id)] = news;
      notifyListeners();
    }, onError: (error) {
      _log.severe("Failed to update news ($error)");
      throw (error);
    });
  }

  /// Delete the specified news
  Future<void> deleteNews(News news) async {
    await _newsService.deleteNews(news).then((value) {
      _log.fine("News deleted successfully : ${news.title}");
      _news.remove(news);
      notifyListeners();
    }, onError: (error) {
      _log.severe("Failed to delete news ($error)");
      throw (error);
    });
  }
}
