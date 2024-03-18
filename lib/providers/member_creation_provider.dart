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

import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/providers/message_provider.dart';
import 'package:chachatte_team/services/members_service.dart';
import 'package:chachatte_team/utils/app_utils.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

class MemberCreationProvider extends ChangeNotifier {
  final Logger _log = new Logger('MemberCreationProvider');
  final MembersService _membersService = new MembersService();

  // message provider that can be set from the proxy provider
  MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  LoginProvider _loginProvider;

  // current member
  Member _currentMember = new Member();

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  Member get currentMember => _currentMember;

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

  /// Set the [member] to be edited.
  void setMemberToEdit(Member member) {
    _currentMember = member;
    _updateStatus(LoadingStatus.loaded);
  }

  /// Update the avatar of the specified [member] in the current member list
  void updateMemberAvatar(String avatarUrl) {
    _currentMember.avatarUrl = avatarUrl;
    _notifyListeners();
  }

  /// Remove the avatar of the specified [member] in the current member list
  void resetMemberAvatar() {
    _currentMember.avatarUrl = null;
    _notifyListeners();
  }

  /// Create the current member being edited.
  Future<void> createMember() async {
    _updateStatus(LoadingStatus.loading);
    await _membersService.createMember(_currentMember).then((value) async {
      _log.fine("Member ${_currentMember.email} created successfully");
      _currentMember = value;
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(AppString.memberCreated, MessageType.SUCCESS);
    }, onError: (error) {
      _log.warning("Error when creating member ($error)");
      _messageProvider.setMessage(AppString.memberCreationFailed, MessageType.ERROR);
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    });
  }

  /// Create the current member being edited.
  Future<void> updateMember() async {
    _updateStatus(LoadingStatus.loading);
    await _membersService.updateMember(_currentMember).then((value) {
      _log.fine("Member successfully updated : ${_currentMember.email}");
      _currentMember = value;
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(AppString.memberUpdated, MessageType.SUCCESS);
    }, onError: (error) {
      // todo here we should reload the member as it has not been updated in db ?
      _log.warning("Error when updating member ($error)");
      _messageProvider.setMessage(AppString.memberUpdateFailed, MessageType.ERROR);
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    });
  }

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of MemberCreationProvider");
    notifyListeners();
  }

  /// Update the current loading status
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of MemberCreationProvider");
    _notifyListeners();
  }
}
