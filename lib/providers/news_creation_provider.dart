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

import 'package:chachatte_team/models/news.dart';
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/providers/message_provider.dart';
import 'package:chachatte_team/services/news_service.dart';
import 'package:chachatte_team/utils/custom_graphql_exception.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class NewsCreationProvider extends ChangeNotifier {
  final Logger _log = new Logger('NewsCreationProvider');
  final NewsService _newsService = new NewsService();

  // message provider that can be set from the proxy provider
  MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  LoginProvider _loginProvider;

  // current news being created/edited
  News _news = new News();

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  News get news => _news;

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

  /// Set the [news] to be edited.
  void setNewsToEdit(News news) {
    _news = news;
  }

  /// Create the current news being edited.
  Future<void> createNews() async {
    _updateStatus(LoadingStatus.loading);
    await _newsService.createNews(news).then((value) async {
      _log.fine("News created successfully");
      _news = value;
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(AppString.newsCreated, MessageType.SUCCESS);
    }, onError: (error) {
      _log.warning("Error when creating news ($error)");
      _news = null;
      _messageProvider.setMessage(AppString.newsCreationFailed, MessageType.ERROR);
      _handleServiceException(error);
      _updateStatus(LoadingStatus.notLoaded);
      throw (error);
    });
  }

  /// Update the current news being edited.
  Future<void> updateNews() async {
    await _newsService.updateNews(news).then((value) {
      _log.fine("News successfully updated : ${news.title}");
      _news = value;
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(AppString.newsUpdated, MessageType.SUCCESS);
    }, onError: (error) {
      _log.warning("Error when updating news ($error)");
      _news = null;
      _messageProvider.setMessage(AppString.newsUpdateFailed, MessageType.ERROR);
      _handleServiceException(error);
      _updateStatus(LoadingStatus.notLoaded);
      throw (error);
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
