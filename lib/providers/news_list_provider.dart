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
import 'dart:collection';

import 'package:ccteam/models/news.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/news_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class NewsListProvider extends ChangeNotifier {
  final Logger _log = new Logger('NewsListProvider');
  final NewsService _newsService = new NewsService();

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  late LoginProvider _loginProvider;

  // current news list
  List<News> _newsList = [];

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  // constructor
  NewsListProvider() {
    // as soon as it is instantiated, we fetch the news list
    fetchNewsList();
  }

  UnmodifiableListView<News> get newsList => UnmodifiableListView(_newsList);

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

  /// Add the specified [news] to the current news list.
  void addNewsInList(News news) {
    _newsList.add(news);

    // re-sort the list by date
    _newsList.sort((a, b) => a.newsDate!.compareTo(b.newsDate!));

    _notifyListeners();
  }

  /// Update the specified [news] in the current news list.
  void updateNewsInList(News news) {
    final int index = _newsList.indexWhere((n) => n.id == news.id);
    if (index != -1) {
      _newsList[index] = news;
      _notifyListeners();
    }
  }

  /// Remove the specified [news] from the current news list.
  void removeNewsFromList(News news) {
    _newsList.removeWhere((n) => n.id == news.id);
    _notifyListeners();
  }

  /// Fetch the list of all news.
  Future<void> fetchNewsList() async {
    _updateLoadingStatus(LoadingStatus.loading);
    await _newsService.fetchNews().then((value) async {
      _log.fine("News list of ${value.length} news retrieved successfully");
      _newsList = value;
      _updateLoadingStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving news list ($error)");
      _newsList = [];
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateLoadingStatus(LoadingStatus.notLoaded);
    });
  }

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of NewsListProvider");
    notifyListeners();
  }

  /// Update the current loading [status].
  void _updateLoadingStatus(LoadingStatus status) {
    _loadingStatus = status;
    _notifyListeners();
  }
}
