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
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/members_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class MemberDetailProvider extends ChangeNotifier {
  final Logger _log = new Logger('MemberDetailProvider');
  final MembersService _membersService = new MembersService();

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  late LoginProvider _loginProvider;

  // current member
  Member? _currentMember;

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  Member? get currentMember => _currentMember;

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

  /// Set the current member to be the specified [member].
  void setCurrentMember(Member member) {
    _currentMember = member;
    _notifyListeners();
  }

  /// Fetch the specified [member] from the database.
  Future<void> fetchMember(Member member) async {
    _log.fine("Fetching member ${member.email}...");
    _updateStatus(LoadingStatus.loading);
    await _membersService
        .getMemberById(member.id!)
        .then(
          (value) async {
            _log.fine("Member ID ${member.id} retrieved successfully");
            _currentMember = value;
            _updateStatus(LoadingStatus.loaded);
          },
          onError: (error) {
            _log.warning("Error when retrieving member ($error)");
            _currentMember = null;
            AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
            _updateStatus(LoadingStatus.notLoaded);
          },
        );
  }

  /// Refresh the current member from the database.
  Future<void> refreshCurrentMember() async {
    if (_currentMember != null) {
      await fetchMember(_currentMember!);
    }
  }

  /// Persist the header-palette choice for the current member, then
  /// refresh both the local `currentMember` and (if it's the same
  /// person) the cached `loggedMember` on LoginProvider — so any UI
  /// listening to either of those rebuilds with the new colours
  /// immediately.
  ///
  /// We deliberately re-fetch the full member after the mutation
  /// instead of binding to its response: the mutation only projects a
  /// few scalar fields, so reusing it as-is would wipe the avatar,
  /// bikes, fees, events… that the rest of the detail page needs.
  Future<void> updateHeaderPalette(int? headerPalette) async {
    final int? id = _currentMember?.id;
    if (id == null) return;
    try {
      await _membersService.setMemberPalette(id, headerPalette);
      // re-pull the complete member record so all fields stay populated
      await refreshCurrentMember();
      if (_loginProvider.loggedMember?.id == id) {
        await _loginProvider.refreshLoggedMember();
      }
    } catch (e) {
      _log.warning("Failed to update header palette: $e");
      AppUtils.handleServiceException(e, _messageProvider, _loginProvider);
    }
  }

  /// Delete the specified [member].
  Future<void> deleteMember(Member member) async {
    await _membersService
        .deleteMember(member)
        .then(
          (value) {
            _log.fine("Member deleted successfully : ${member.email}");
            _currentMember = null;
            _messageProvider.setMessage(AppString.memberDeleted, MessageType.SUCCESS);
            _notifyListeners();
          },
          onError: (error) {
            _log.warning("Failed to delete member ($error)");
            _messageProvider.setMessage(AppString.memberDeletionFailed, MessageType.ERROR);
            AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
            _notifyListeners();
          },
        );
  }

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of MemberDetailProvider");
    notifyListeners();
  }

  /// Update the current loading [status].
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _notifyListeners();
  }
}
