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

import 'package:ccteam/models/news.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/news_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class NewsCreationProvider extends ChangeNotifier {
  final Logger _log = new Logger('NewsCreationProvider');
  final NewsService _newsService = new NewsService();

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  late LoginProvider _loginProvider;

  // current news being created/edited
  News _news = new News();

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  News get news => _news;

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

  /// Set the [news] to be edited.
  void setNewsToEdit(News news) {
    _news = news;
    _updateStatus(LoadingStatus.loaded);
  }

  /// Create the current news being edited.
  Future<void> createNews() async {
    _updateStatus(LoadingStatus.loading);
    _news.createdBy = _loginProvider.loggedMember;

    await _newsService.createNews(_news).then((value) async {
      _log.fine("News created successfully");
      _news = value;
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(AppString.newsCreated, MessageType.SUCCESS);
    }, onError: (error) {
      _log.severe("Error when creating news ($error)");
      _messageProvider.setMessage(AppString.newsCreationFailed, MessageType.ERROR);
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    });
  }

  /// Update the current news being edited.
  Future<News?> updateNews() async {
    try {
      _updateStatus(LoadingStatus.loading);
      _news.modifiedBy = _loginProvider.loggedMember;

      final value = await _newsService.updateNews(_news);
      _log.fine("News successfully updated : ${_news.title}");
      _news = value;
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(AppString.newsUpdated, MessageType.SUCCESS);
      return value;
    } catch (error) {
      _log.severe("Error when updating news ($error)");
      _messageProvider.setMessage(AppString.newsUpdateFailed, MessageType.ERROR);
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
      return null;
    }
  }

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of NewsCreationProvider");
    notifyListeners();
  }

  /// Update the current loading [status].
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _notifyListeners();
  }
}
