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

import 'package:ccteam/models/member.dart';
import 'package:ccteam/models/news.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/news_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class NewsDetailProvider extends ChangeNotifier {
  final Logger _log = new Logger('NewsDetailProvider');
  final NewsService _newsService = new NewsService();

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  late LoginProvider _loginProvider;

  // current news
  News? _currentNews;

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  News? get currentNews => _currentNews;

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

  /// Set the current news to be the specified [news].
  void setCurrentNews(News news) {
    _currentNews = news;
    _notifyListeners();
  }

  /// Fetch the specified [news] from the database.
  Future<void> fetchNews(News news) async {
    _log.fine("Fetching news ${news.title}...");
    _updateStatus(LoadingStatus.loading);
    await _newsService.getNewsById(news.id!).then((value) async {
      _log.fine("News with ID ${news.id} retrieved successfully");
      _currentNews = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving news ($error)");
      _currentNews = null;
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    });
  }

  /// Set the specified [news] as liked by the specified [member].
  Future<void> likeNews(News news, Member member) async {
    _log.fine("Liking news ${news.title}...");
    await _newsService.likeNews(news.id!, member.id!).then((value) async {
      _log.fine("News ${news.title} liked by user ${member.email}");
      _currentNews = value;
      _notifyListeners();
    }, onError: (error) {
      _log.warning("Error when liking news ${news.title} for user ${member.email} ($error)");
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _notifyListeners();
    });
  }

  /// Set the specified [news] as not liked by the specified [member].
  Future<void> unlikeNews(News news, Member member) async {
    await _newsService.unlikeNews(news.id!, member.id!).then((value) async {
      _log.fine("News ${news.title} unliked by user ${member.email}");
      _currentNews = value;
      _notifyListeners();
    }, onError: (error) {
      _log.warning("Error when unliking news ${news.title} for user ${member.email} ($error)");
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _notifyListeners();
    });
  }

  /// Delete the specified [news].
  Future<void> deleteNews(News news) async {
    await _newsService.deleteNews(news).then((value) {
      _log.fine("News deleted successfully : ${news.title}");
      // this shouldn't be a problem to not set _currentNews to null but keep the deleted news,
      // because _currentNews is initialized before each display of the NewsDetail view,
      // setting _currentNews to null would require NewsDetail view to handle a null news
       _currentNews = value;
      _messageProvider.setMessage(AppString.newsDeleted, MessageType.SUCCESS);
      _notifyListeners();
    }, onError: (error) {
      _log.warning("Failed to delete news ($error)");
      _messageProvider.setMessage(AppString.newsDeletionFailed, MessageType.ERROR);
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _notifyListeners();
    });
  }

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of NewsDetailProvider");
    notifyListeners();
  }

  /// Update the current loading [status].
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _notifyListeners();
  }
}
