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

class RecordCreationProvider extends ChangeNotifier {
  final Logger _log = new Logger('RecordCreationProvider');
  final RecordsService _recordsService = new RecordsService();

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  late LoginProvider _loginProvider;

  // current record
  Record _record = new Record();

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  Record get record => _record;

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

  /// Set the [Record] to be edited.
  void setRecordToEdit(Record record) {
    _record = record;
    _updateStatus(LoadingStatus.loaded);
  }

  /// Create the current record being edited.
  Future<void> createRecord() async {
    _updateStatus(LoadingStatus.loading);
    await _recordsService.createRecord(_record).then((value) async {
      _log.fine("Record created successfully");
      //_record = value;
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(AppString.recordCreated, MessageType.SUCCESS);
    }, onError: (error) {
      _log.warning("Error when creating record ($error)");
      _messageProvider.setMessage(AppString.recordCreationFailed, MessageType.ERROR);
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    });
  }

  /// Update the current record being edited.
  Future<void> updateRecord() async {
    _updateStatus(LoadingStatus.loading);
    await _recordsService.updateRecord(_record).then((value) {
      _log.fine("Record successfully updated : ${_record.id}");
      //_record = value;
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(AppString.recordUpdated, MessageType.SUCCESS);
    }, onError: (error) {
      // todo here we should reload the original record as it has not been updated in db ?
      _log.warning("Error when updating record ($error)");
      _messageProvider.setMessage(AppString.recordUpdateFailed, MessageType.ERROR);
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    });
  }

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of RecordCreationProvider");
    notifyListeners();
  }

  /// Update the current loading [status].
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _notifyListeners();
  }
}
