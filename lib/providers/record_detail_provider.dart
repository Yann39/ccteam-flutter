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

import 'package:ccteam/models/record.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/records_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Holds the record currently being viewed on the chrono-detail page.
/// Mirrors the shape of [TrackDetailProvider] / [NewsDetailProvider]:
/// stores a reference to the active record, plus a `delete` method
/// so the detail page can drop the record without juggling another
/// provider for the network call.
class RecordDetailProvider extends ChangeNotifier {
  final Logger _log = new Logger('RecordDetailProvider');
  final RecordsService _recordsService = new RecordsService();

  late MessageProvider _messageProvider;
  late LoginProvider _loginProvider;

  Record? _currentRecord;
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  Record? get currentRecord => _currentRecord;
  LoadingStatus get loadingStatus => _loadingStatus;

  void updateMessageProvider(MessageProvider messageProvider) {
    _messageProvider = messageProvider;
    _notifyListeners();
  }

  void updateLoginProvider(LoginProvider loginProvider) {
    _loginProvider = loginProvider;
    _notifyListeners();
  }

  /// Set the [record] currently being viewed. The page's `build`
  /// reads this directly, so calling this with the same instance
  /// after an in-place edit (the form's `onSaved` callbacks mutate
  /// the [Record] in place) is enough to trigger a rebuild that
  /// shows the new values.
  void setCurrentRecord(Record record) {
    _currentRecord = record;
    _notifyListeners();
  }

  /// Drop the cached record. Called right after the user confirms a
  /// delete so a stale reference isn't reused if the user navigates
  /// back via gestures.
  void clearCurrentRecord() {
    _currentRecord = null;
    _notifyListeners();
  }

  /// Delete the currently-viewed record via the GraphQL mutation.
  /// Throws on failure so the caller can keep the page open and
  /// react (a snackbar is also surfaced via the message provider).
  Future<void> deleteRecord() async {
    final Record? record = _currentRecord;
    if (record == null) return;
    _updateStatus(LoadingStatus.loading);
    try {
      await _recordsService.deleteRecord(record);
      _log.fine("Record ${record.id} deleted");
      _messageProvider.setMessage(AppString.recordDeleted, MessageType.SUCCESS);
      _currentRecord = null;
      _updateStatus(LoadingStatus.loaded);
    } catch (error) {
      _log.warning("Error when deleting record ($error)");
      _messageProvider.setMessage(AppString.recordDeletionFailed, MessageType.ERROR);
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
      rethrow;
    }
  }

  void _notifyListeners() {
    _log.info("Notifying listeners of RecordDetailProvider");
    notifyListeners();
  }

  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _notifyListeners();
  }
}
