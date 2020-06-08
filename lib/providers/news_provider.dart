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

import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/models/news.dart';
import 'package:chachatte_team/services/members_service.dart';
import 'package:chachatte_team/services/news_service.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class NewsProvider extends ChangeNotifier {
  final Logger _log = new Logger('NewsProvider');
  final NewsService _newsService = new NewsService();
  final MembersService _membersService = new MembersService();

  // current news list
  List<News> _news = [];

  // news member creator
  Member _createdBy;

  // news member last modifier
  Member _modifiedBy;

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  // constructor
  NewsProvider() {
    // as soon as it is instantiated, we fetch all news
    fetchNews();
  }

  UnmodifiableListView<News> get news => UnmodifiableListView(_news);

  Member get createdBy => _createdBy;

  Member get modifiedBy => _modifiedBy;

  LoadingStatus get loadingStatus => _loadingStatus;

  /// Update the current loading status
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of NewsProvider");
    notifyListeners();
  }

  /// Get the list of all news
  Future<void> fetchNews() async {
    _updateStatus(LoadingStatus.loading);
    await _newsService.fetchNews().then((value) async {
      _log.fine("News list retrieved successfully");
      _news = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving news list ($error)");
      _news = [];
      _updateStatus(LoadingStatus.notLoaded);
      throw (error);
    });
    return _news;
  }

  /// Fetch the member corresponding to the specified [memberId] representing the news creator
  void fetchCreatedByMember(int memberId) async {
    _createdBy = null;
    if (memberId == null) return null;
    await _membersService.getMemberById(memberId).then((value) async {
      _log.fine("News createdBy member retrieved successfully");
      _createdBy = value;
      notifyListeners();
    }, onError: (error) {
      _log.warning("Error when retrieving news createdBy member ($error)");
      _createdBy = null;
      notifyListeners();
      throw (error);
    });
  }

  /// Fetch the member corresponding to the specified [memberId] representing the news last modifier
  void fetchModifiedByMember(int memberId) async {
    _modifiedBy = null;
    if (memberId == null) return null;
    await _membersService.getMemberById(memberId).then((value) async {
      _log.fine("News modifiedBy member retrieved successfully");
      _modifiedBy = value;
      notifyListeners();
    }, onError: (error) {
      _log.warning("Error when retrieving news modifiedBy member ($error)");
      _modifiedBy = null;
      notifyListeners();
      throw (error);
    });
  }

  /// Create the specified [news]
  Future<void> createNews(News news) async {
    await _newsService.createNews(news).then((value) {
      _log.fine("New news created : ${value.title} (id=${value.id})");
      _news.add(value);
      _log.info("Notifying listeners of NewsProvider");
      notifyListeners();
    }, onError: (error) {
      _log.severe("Failed to create new news ($error)");
      throw (error);
    });
  }

  /// Update the specified [news]
  Future<void> updateNews(News news) async {
    await _newsService.updateNews(news).then((value) {
      _log.fine("News successfully updated : ${news.title}");
      _news[_news.indexWhere((m) => m.id == news.id)] = news;
      _log.info("Notifying listeners of NewsProvider");
      notifyListeners();
    }, onError: (error) {
      _log.severe("Failed to update news ($error)");
      throw (error);
    });
  }

  /// Delete the specified [news]
  Future<void> deleteNews(News news) async {
    await _newsService.deleteNews(news).then((value) {
      _log.fine("News deleted successfully : ${news.title}");
      _news.remove(news);
      _log.info("Notifying listeners of NewsProvider");
      notifyListeners();
    }, onError: (error) {
      _log.severe("Failed to delete news ($error)");
      throw (error);
    });
  }
}
