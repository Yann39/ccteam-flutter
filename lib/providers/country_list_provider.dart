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

import 'package:ccteam/models/country.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/countries_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

/// Cache of every {@link Country} known to the server. Same lazy
/// pattern as [OrganizerListProvider], fetched the first time the
/// track form is opened, then kept in memory for the session.
class CountryListProvider extends ChangeNotifier {
  final Logger _log = new Logger('CountryListProvider');
  final CountriesService _service = new CountriesService();

  late MessageProvider _messageProvider;
  late LoginProvider _loginProvider;

  List<Country> _countries = <Country>[];
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  List<Country> get countries => _countries;

  LoadingStatus get loadingStatus => _loadingStatus;

  void updateMessageProvider(MessageProvider messageProvider) {
    _messageProvider = messageProvider;
  }

  void updateLoginProvider(LoginProvider loginProvider) {
    _loginProvider = loginProvider;
    if (loginProvider.authStatus != AuthStatus.Authenticated) {
      _countries = <Country>[];
      _loadingStatus = LoadingStatus.notLoaded;
    }
  }

  /// Fetch the list if it hasn't been loaded yet (or force-refresh).
  /// Safe to call from a build cycle thanks to [_scheduleNotify].
  Future<void> ensureLoaded({bool force = false}) async {
    if (!force && _loadingStatus == LoadingStatus.loaded) return;
    await refresh();
  }

  /// Force a re-fetch from the server.
  Future<void> refresh() async {
    _updateStatus(LoadingStatus.loading);
    try {
      _countries = await _service.fetchCountries();
      _updateStatus(LoadingStatus.loaded);
    } catch (e) {
      _log.severe("Error fetching countries: $e");
      AppUtils.handleServiceException(e, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    }
  }

  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _scheduleNotify();
  }

  /// Defer notification when called mid-build (typically from a
  /// widget's `didChangeDependencies`). Same pattern as the other
  /// lazy-loading providers.
  void _scheduleNotify() {
    final SchedulerPhase phase = SchedulerBinding.instance.schedulerPhase;
    final bool inBuildPhase = phase == SchedulerPhase.persistentCallbacks || phase == SchedulerPhase.midFrameMicrotasks;
    if (inBuildPhase) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }
}
