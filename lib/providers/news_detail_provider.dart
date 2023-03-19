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

import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/models/news.dart';
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/providers/message_provider.dart';
import 'package:chachatte_team/services/news_service.dart';
import 'package:chachatte_team/utils/custom_graphql_exception.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class NewsDetailProvider extends ChangeNotifier {
  final Logger _log = new Logger('NewsDetailProvider');
  final NewsService _newsService = new NewsService();

  // message provider that can be set from the proxy provider
  MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  LoginProvider _loginProvider;

  // current news
  News _currentNews;

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  News get currentNews => _currentNews;

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

  /// Fetch the specified [news].
  Future<void> fetchNews(News news) async {
    _log.fine("Fetching news ${news.title}...");
    _updateStatus(LoadingStatus.loading);
    await _newsService.getNewsById(news.id).then((value) async {
      _log.fine("News with ID ${news.id} retrieved successfully");
      _currentNews = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving news ($error)");
      _currentNews = null;
      _handleServiceException(error);
      _updateStatus(LoadingStatus.notLoaded);
      throw (error);
    });
  }

  /// Set the specified [news] as liked by the specified [member].
  Future<void> likeNews(News news, Member member) async {
    _log.fine("Liking news ${news.title}...");
    await _newsService.likeNews(news.id, member.id).then((value) async {
      _log.fine("News ${news.title} liked by user ${member.email}");
      _currentNews = value;
      _log.info("Notifying listeners of NewsDetailProvider");
      notifyListeners();
    }, onError: (error) {
      _log.warning("Error when liking news ${news.title} for user ${member.email} ($error)");
      _handleServiceException(error);
      notifyListeners();
      throw (error);
    });
  }

  /// Set the specified [news] as not liked by the specified [member].
  Future<void> unlikeNews(News news, Member member) async {
    await _newsService.unlikeNews(news.id, member.id).then((value) async {
      _log.fine("News ${news.title} unliked by user ${member.email}");
      _currentNews = value;
      _log.info("Notifying listeners of NewsDetailProvider");
      notifyListeners();
    }, onError: (error) {
      _log.warning("Error when unliking news ${news.title} for user ${member.email} ($error)");
      _handleServiceException(error);
      notifyListeners();
      throw (error);
    });
  }

  /// Delete the specified [news].
  Future<void> deleteNews(News news) async {
    await _newsService.deleteNews(news).then((value) {
      _log.fine("News deleted successfully : ${news.title}");
      _currentNews = null;
      _log.info("Notifying listeners of NewsProvider");
      notifyListeners();
      _messageProvider.setMessage(AppString.newsDeleted, MessageType.SUCCESS);
    }, onError: (error) {
      _log.warning("Failed to delete news ($error)");
      _messageProvider.setMessage(AppString.newsDeletionFailed, MessageType.ERROR);
      _handleServiceException(error);
      notifyListeners();
      throw (error);
    });
  }

  /// Update the current loading [status].
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of NewsDetailProvider");
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
