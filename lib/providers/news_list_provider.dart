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

import 'dart:async';
import 'dart:collection';

import 'package:chachatte_team/models/news.dart';
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/providers/message_provider.dart';
import 'package:chachatte_team/services/news_service.dart';
import 'package:chachatte_team/utils/custom_graphql_exception.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class NewsListProvider extends ChangeNotifier {
  final Logger _log = new Logger('NewsListProvider');
  final NewsService _newsService = new NewsService();

  // message provider that can be set from the proxy provider
  MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  LoginProvider _loginProvider;

  // current news list
  List<News> _newsList = [];

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  // constructor
  NewsListProvider() {
    // as soon as it is instantiated, we fetch all news
    fetchNewsList();
  }

  UnmodifiableListView<News> get newsList => UnmodifiableListView(_newsList);

  LoadingStatus get loadingStatus => _loadingStatus;

  /// Update message provider with the specified [messageProvider].
  void updateMessageProvider(MessageProvider messageProvider) {
    _messageProvider = messageProvider;
    notifyListeners();
  }

  /// Update login provider with the specified [loginProvider].
  void updateLoginProvider(LoginProvider loginProvider) {
    _loginProvider = loginProvider;
    notifyListeners();
  }

  /// Add the specified [news] to the current news list.
  void addNewsInList(News news) {
    _newsList.add(news);

    // re-sort the list by date
    _newsList.sort((a, b) => a.newsDate.compareTo(b.newsDate));

    _log.info("Notifying listeners of NewsListProvider");
    notifyListeners();
  }

  /// Update the specified [news] in the current news list.
  void updateNewsInList(News news) {
    final int index = _newsList.indexWhere((n) => n.id == news.id);
    if (index != -1) {
      _newsList[index] = news;
      _log.info("Notifying listeners of NewsListProvider");
      notifyListeners();
    }
  }

  /// Remove the specified [news] from the current news list.
  void removeNewsFromList(News news) {
    _newsList.removeWhere((n) => n.id == news.id);
    _log.info("Notifying listeners of NewsListProvider");
    notifyListeners();
  }

  /// Fetch the list of all news.
  Future<void> fetchNewsList() async {
    _updateStatus(LoadingStatus.loading);
    await _newsService.fetchNews().then((value) async {
      _log.fine("News list retrieved successfully");
      _newsList = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving news list ($error)");
      _newsList = [];
      _handleServiceException(error);
      _updateStatus(LoadingStatus.notLoaded);
    });
  }

  /// Update the current loading [status].
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of NewsListProvider");
    notifyListeners();
  }

  /// Handle specified [error] from service call.
  void _handleServiceException(dynamic error) {
    if (error is CustomGraphQlException) {
      if (error.code == "token_expired") {
        _messageProvider.setMessage(AppString.errorTokenExpired, MessageType.INFO);
      } else if (error.code == "wrong_token_format") {
        _messageProvider.setMessage(AppString.errorTokenWrongFormat, MessageType.ERROR);
      } else if (error.code == "no_token") {
        _messageProvider.setMessage(AppString.errorTokenNotFound, MessageType.ERROR);
      } else if (error.code == "bad_credentials") {
        _messageProvider.setMessage(AppString.errorBadCredentials, MessageType.ERROR);
      } else if (error.code == "internal_error") {
        _messageProvider.setMessage(AppString.errorServerInternal, MessageType.ERROR);
      } else {
        _messageProvider.setMessage(AppString.format(AppString.errorUnknown, [error.toString()]), MessageType.ERROR);
      }
      _loginProvider.logoutMember();
    } else if (error is TimeoutException) {
      _messageProvider.setMessage(AppString.errorServerTimeOut, MessageType.ERROR);
    } else {
      _messageProvider.setMessage(AppString.format(AppString.errorUnknown, [error.toString()]), MessageType.ERROR);
    }
  }
}
