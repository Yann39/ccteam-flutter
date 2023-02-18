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
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/services/news_service.dart';
import 'package:chachatte_team/utils/custom_graphql_exception.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class NewsListProvider extends ChangeNotifier {
  final Logger _log = new Logger('NewsListProvider');
  final NewsService _newsService = new NewsService();

  LoginProvider _loginProvider;

  // current news list
  List<News> _news = [];

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  // constructor
  NewsListProvider() {
    // as soon as it is instantiated, we fetch all news
    fetchNewsList();
  }

  bool _logout = false;

  bool get logout => _logout;

  UnmodifiableListView<News> get news => UnmodifiableListView(_news);

  LoadingStatus get loadingStatus => _loadingStatus;

  void update(LoginProvider loginProvider) {
    // Do some custom work based on myModel that may call `notifyListeners`
    _log.info("Calling update");
    _loginProvider = loginProvider;
    notifyListeners();
  }

  /// Update the current loading status
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of NewsListProvider");
    notifyListeners();
  }

  void updateNews(News news) {
    final int index = _news.indexWhere((n) => n.id == news.id);
    if (index != -1) {
      _news[index] = news;
      _log.info("Notifying listeners of NewsListProvider");
      notifyListeners();
    }
  }

  /// Get the list of all news
  Future<void> fetchNewsList() async {
    _updateStatus(LoadingStatus.loading);
    await _newsService.fetchNews().then((value) async {
      _log.fine("News list retrieved successfully");
      _news = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving news list ($error)");
      _news = [];
      _updateStatus(LoadingStatus.notLoaded);
      if (error is CustomGraphQlException) {
        //_loginProvider.logoutMember();
        //_setLoginStatus(LoginStatus.PasscodeStep);
        //_setAuthStatus(AuthStatus.Unauthenticated);
        // Member not found
        if (error.code == "member_not_found") {
          //_setErrorMessage(AppString.format(AppString.errorEmailNotFoundInDatabase, [_email]));
        }
        // JWT token has expired
        else if (error.code == "token_expired") {
          //_prefs.remove('jwt');
          //_setErrorMessage(AppString.errorTokenExpired);
          _logout = true;
          notifyListeners();
          _loginProvider.errorMessage = AppString.errorTokenExpired;
          _loginProvider.logoutMember();
        }
        // JWT token has expired
        else if (error.code == "wrong_token_format") {
          //_prefs.remove('jwt');
          //_setErrorMessage(AppString.errorTokenExpired);
        }
      }
    });
  }
}
