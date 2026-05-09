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
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class RecordListProvider extends ChangeNotifier {
  final Logger _log = new Logger('RecordListProvider');
  final RecordsService _recordsService = new RecordsService();
  late LoginProvider _loginProvider;

  // list of all track records
  List<Record> _trackRecords = [];

  // list of all member records
  List<Record> _memberRecords = [];

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  UnmodifiableListView<Record> get trackRecords => UnmodifiableListView(_trackRecords);

  UnmodifiableListView<Record> get memberRecords => UnmodifiableListView(_memberRecords);

  LoadingStatus get loadingStatus => _loadingStatus;

  /// Update the current loading status
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of RecordListProvider");
    notifyListeners();
  }

  /// Update login provider with the specified [loginProvider].
  void updateLoginProvider(LoginProvider loginProvider) {
    _loginProvider = loginProvider;
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
  void clearTrackRecords() {
    _trackRecords = [];
    _loadingStatus = LoadingStatus.loading;
    notifyListeners();
  }

  /// Reset the member records list and mark it as loading. Used when
  /// navigating to a member detail screen so the UI doesn't briefly
  /// show the previous member's records.
  void clearMemberRecords() {
    _memberRecords = [];
    _loadingStatus = LoadingStatus.loading;
    notifyListeners();
  }

  /// Get the list of all records for the specified [memberId]
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
