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

import 'dart:collection';

import 'package:ccteam/models/record.dart';
import 'package:ccteam/services/records_service.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

class RecordListProvider extends ChangeNotifier {
  final Logger _log = new Logger('RecordListProvider');
  final RecordsService _recordsService = new RecordsService();
  late LoginProvider _loginProvider;

  // list of all track records
  List<Record> _trackRecords = [];

  // list of all member records
  List<Record> _memberRecords = [];

  // list of all records of the logged member, private ones included. Kept in
  // its own slot because `_memberRecords` only ever holds public records
  List<Record> _myRecords = [];

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  UnmodifiableListView<Record> get trackRecords => UnmodifiableListView(_trackRecords);

  UnmodifiableListView<Record> get memberRecords => UnmodifiableListView(_memberRecords);

  UnmodifiableListView<Record> get myRecords => UnmodifiableListView(_myRecords);

  LoadingStatus get loadingStatus => _loadingStatus;

  /// Update the current loading status
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of RecordListProvider");
    notifyListeners();
  }

  /// Update login provider with the specified [loginProvider].
  ///
  /// Auto-fetches the logged member's records the first time the
  /// provider sees an authenticated user. The records are needed by
  /// the home stats panel (km estimate) before the user has navigated
  /// to "Mes chronos", and pre-loading them also makes the records
  /// page instant on later visits. Mirrors the pattern used by
  /// NewsListProvider / MemberListProvider.
  void updateLoginProvider(LoginProvider loginProvider) {
    _loginProvider = loginProvider;
    if (_loginProvider.isMember &&
        _loginProvider.loggedMember?.id != null &&
        _loadingStatus == LoadingStatus.notLoaded) {
      fetchMyRecords();
    } else if (!_loginProvider.isMember) {
      // clear the cached records on logout so the next user doesn't
      // see stale data
      _memberRecords = [];
      _myRecords = [];
      _loadingStatus = LoadingStatus.notLoaded;
    }
    _log.info("LoginProvider injected into RecordListProvider");
  }

  /// Get the list of all records for the specified [trackId]
  void fetchTrackRecords(int trackId) async {
    // guard against unauthorized access
    if (!_loginProvider.isMember) {
      _log.info("User not member, skipping track records fetch");
      _trackRecords = [];
      _updateStatus(LoadingStatus.loaded);
      return;
    }
    // clear stale data so the UI doesn't briefly show records from a
    // previous track while the new ones are being fetched
    _trackRecords = [];
    _updateStatus(LoadingStatus.loading);
    await _recordsService.fetchTrackRecords(trackId).then((value) async {
      _log.fine("Track records list retrieved successfully");
      _trackRecords = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving track records list ($error)");
      _trackRecords = [];
      _updateStatus(LoadingStatus.notLoaded);
      throw (error);
    });
  }

  /// Reset the track records list and mark it as loading. Useful when
  /// navigating to a screen whose data depends on a fresh fetch (e.g.
  /// track detail), so the UI displays a loader instead of the previous
  /// track's records.
  ///
  /// The state mutation is synchronous so the calling widget's first
  /// build sees the cleared list. The notification is deferred via
  /// [_scheduleNotify] because this method is typically called from
  /// a descendant's `initState`, where notifying eagerly would trip
  /// `setState() called during build`.
  void clearTrackRecords() {
    _trackRecords = [];
    _loadingStatus = LoadingStatus.loading;
    _scheduleNotify();
  }

  /// Reset the member records list and mark it as loading. Used when
  /// navigating to a member detail screen so the UI doesn't briefly
  /// show the previous member's records. Same deferred-notification
  /// contract as [clearTrackRecords].
  void clearMemberRecords() {
    _memberRecords = [];
    _loadingStatus = LoadingStatus.loading;
    _scheduleNotify();
  }

  /// Defer [notifyListeners] to the next post-frame callback when the
  /// framework is mid-build, otherwise notify immediately. Lets
  /// state-mutation methods stay safe to call from anywhere
  /// (including `initState`) without polluting their call sites with
  /// scheduling boilerplate.
  void _scheduleNotify() {
    final SchedulerPhase phase = SchedulerBinding.instance.schedulerPhase;
    final bool inBuildPhase = phase == SchedulerPhase.persistentCallbacks || phase == SchedulerPhase.midFrameMicrotasks;
    if (inBuildPhase) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  /// Get the list of all records (public and private) of the logged member.
  Future<void> fetchMyRecords() async {
    // guard against unauthorized access
    if (!_loginProvider.isMember) {
      _log.info("User not member, skipping my records fetch");
      _myRecords = [];
      _updateStatus(LoadingStatus.loaded);
      return;
    }
    // clear stale data so the UI doesn't briefly show outdated records while the fresh ones are being fetched
    _myRecords = [];
    _updateStatus(LoadingStatus.loading);
    await _recordsService.fetchMyRecords().then((value) async {
      _log.fine("My records list retrieved successfully");
      _myRecords = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving my records list ($error)");
      _myRecords = [];
      _updateStatus(LoadingStatus.notLoaded);
      throw (error);
    });
  }

  /// Get the list of all public records for the specified [memberId]
  Future<void> fetchMemberRecords(int memberId) async {
    // guard against unauthorized access
    if (!_loginProvider.isMember) {
      _log.info("User not member, skipping member records fetch");
      _memberRecords = [];
      _updateStatus(LoadingStatus.loaded);
      return;
    }
    // clear stale data so the UI doesn't briefly show records from a
    // previous member while the new ones are being fetched
    _memberRecords = [];
    _updateStatus(LoadingStatus.loading);
    await _recordsService.fetchMemberRecords(memberId).then((value) async {
      _log.fine("Member records list retrieved successfully");
      _memberRecords = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving member records list ($error)");
      _memberRecords = [];
      _updateStatus(LoadingStatus.notLoaded);
      throw (error);
    });
  }

}
