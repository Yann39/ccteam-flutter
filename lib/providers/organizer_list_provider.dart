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

import 'package:ccteam/models/organizer.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/organizers_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

/// Lightweight cache of every {@link Organizer} known to the server,
/// fed by the event-form picker so the user can choose an existing
/// organizer or add a new one.
///
/// Fetched lazily on the first `ensureLoaded()` call rather than at
/// auth time, the list is only consulted from the event creation /
/// edit screen, no point in pulling it for users who never touch
/// that form.
class OrganizerListProvider extends ChangeNotifier {
  final Logger _log = new Logger('OrganizerListProvider');
  final OrganizersService _service = new OrganizersService();

  late MessageProvider _messageProvider;
  late LoginProvider _loginProvider;

  List<Organizer> _organizers = [];
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  List<Organizer> get organizers => _organizers;

  LoadingStatus get loadingStatus => _loadingStatus;

  void updateMessageProvider(MessageProvider messageProvider) {
    _messageProvider = messageProvider;
  }

  void updateLoginProvider(LoginProvider loginProvider) {
    _loginProvider = loginProvider;
    // Clear cache on logout so the next user doesn't see a stale list
    if (loginProvider.authStatus != AuthStatus.Authenticated) {
      _organizers = [];
      _loadingStatus = LoadingStatus.notLoaded;
    }
  }

  /// Fetch the list if it hasn't been loaded yet (or refresh was
  /// explicitly requested). Safe to call from a build cycle — the
  /// fetch is async and notifies listeners on completion.
  Future<void> ensureLoaded({bool force = false}) async {
    if (!force && _loadingStatus == LoadingStatus.loaded) return;
    await refresh();
  }

  /// Force a re-fetch from the server regardless of current state.
  Future<void> refresh() async {
    _updateStatus(LoadingStatus.loading);
    try {
      _organizers = await _service.fetchOrganizers();
      _updateStatus(LoadingStatus.loaded);
    } catch (e) {
      _log.severe("Error fetching organizers: $e");
      AppUtils.handleServiceException(e, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    }
  }

  /// Create a new organizer and append it to the cached list. Returns
  /// the new entity so the caller can immediately set it as the event's
  /// organizer (the typical UX in the picker: "Add new" → enter name →
  /// becomes the selected value).
  Future<Organizer?> createOrganizer(String name) async {
    try {
      final Organizer created = await _service.createOrganizer(name);
      _organizers.add(created);
      // keep the list sorted by name so the picker stays alphabetical without requiring the caller to re-fetch
      _organizers.sort((a, b) => (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));
      _scheduleNotify();
      return created;
    } catch (e) {
      _log.severe("Error creating organizer: $e");
      AppUtils.handleServiceException(e, _messageProvider, _loginProvider);
      return null;
    }
  }

  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _scheduleNotify();
  }

  /// Defer [notifyListeners] to the next post-frame callback when the
  /// framework is mid-build, otherwise notify immediately. Mirrors
  /// the helper in [EventDetailProvider]. Needed here because
  /// `ensureLoaded()` is typically called from a widget's
  /// `didChangeDependencies`, the first sync `notifyListeners()`
  /// (status → loading) would otherwise hit `setState() called
  /// during build` since the descendant's mount isn't finished yet.
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
