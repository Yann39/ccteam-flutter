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

import 'package:chachatte_team/models/record.dart';
import 'package:chachatte_team/services/records_service.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class RecordProvider extends ChangeNotifier {
  final Logger _log = new Logger('RecordProvider');
  final RecordsService _recordsService = new RecordsService();

  // list of all track records
  List<Record> _trackRecords = [];

  // list of all member records
  List<Record> _memberRecords = [];

  UnmodifiableListView<Record> get trackRecords => UnmodifiableListView(_trackRecords);

  UnmodifiableListView<Record> get memberRecords => UnmodifiableListView(_memberRecords);

  /// Get the list of all records for the specified [trackId]
  void fetchTrackRecords(int trackId) async {
    await _recordsService.fetchTrackRecords(trackId).then((value) async {
      _log.fine("Track records list retrieved successfully");
      _trackRecords = value;
      _log.info("Notifying listeners of RecordProvider");
      notifyListeners();
    }, onError: (error) {
      _log.warning("Error when retrieving track records list ($error)");
      _trackRecords = [];
      _log.info("Notifying listeners of RecordProvider");
      notifyListeners();
      throw (error);
    });
  }

  /// Get the list of all records for the specified [memberId]
  void fetchMemberRecords(int memberId) async {
    await _recordsService.fetchMemberRecords(memberId).then((value) async {
      _log.fine("Member records list retrieved successfully");
      _memberRecords = value;
      _log.info("Notifying listeners of RecordProvider");
      notifyListeners();
    }, onError: (error) {
      _log.warning("Error when retrieving member records list ($error)");
      _memberRecords = [];
      _log.info("Notifying listeners of RecordProvider");
      notifyListeners();
      throw (error);
    });
  }
}
