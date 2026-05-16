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

import 'package:ccteam/models/member.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/members_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

class MemberListProvider extends ChangeNotifier {
  final Logger _log = new Logger('MemberListProvider');
  final MembersService _membersService = new MembersService();

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  // login provider that can be set from the proxy provider
  late LoginProvider _loginProvider;

  // current members list
  List<Member> _memberList = [];

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  // total number of members in the database
  int? _totalCount;

  UnmodifiableListView<Member> get memberList => UnmodifiableListView(_memberList);

  LoadingStatus get loadingStatus => _loadingStatus;

  // total members count, or `null` if we haven't fetched it yet
  int? get totalCount => _totalCount;

  /// Update message provider with the specified [messageProvider].
  void updateMessageProvider(MessageProvider messageProvider) {
    _messageProvider = messageProvider;
    _notifyListeners();
  }

  /// Update login provider with the specified [loginProvider].
  void updateLoginProvider(LoginProvider loginProvider) {
    _loginProvider = loginProvider;

    if (_loginProvider.isMember && _loadingStatus == LoadingStatus.notLoaded) {
      // fetch members once the login provider is injected and user is a member
      fetchMemberList(null);
    } else if (!_loginProvider.isMember) {
      // clear the list if the user is not a member (e.g. logged out)
      _memberList = [];
      _loadingStatus = LoadingStatus.notLoaded;
    }

    // always (re)fetch the lightweight total count
    if (_loginProvider.loggedMember != null) {
      fetchCount();
    } else {
      _totalCount = null;
    }

    _notifyListeners();
  }

  /// Add the specified [member] to the current member list.
  void addMemberInList(Member member) {
    _memberList.add(member);

    // re-sort the list by first name
    _memberList.sort((a, b) => a.firstName!.compareTo(b.firstName!));

    // flip the loading status back to `loaded`
    _loadingStatus = LoadingStatus.loaded;
    _notifyListeners();
  }

  /// Update the specified [member] in the current member list.
  void updateMemberInList(Member member) {
    final int index = _memberList.indexWhere((m) => m.id == member.id);
    if (index != -1) {
      _memberList[index] = member;
      _notifyListeners();
    }
  }

  /// Remove the specified [member] from the current members list.
  void removeMemberFromList(Member member) {
    _memberList.removeWhere((n) => n.id == member.id);
    // re-derive the empty/loaded status so the UI shows the "no members" placeholder when the last row was removed
    _loadingStatus = _memberList.isEmpty ? LoadingStatus.empty : LoadingStatus.loaded;
    _notifyListeners();
  }

  /// Fetch only the total members count (lightweight; USER-accessible).
  Future<void> fetchCount() async {
    try {
      final int? count = await _membersService.fetchMembersCount();
      _totalCount = count;
      _notifyListeners();
    } catch (e) {
      _log.warning("Failed to fetch members count: $e");
    }
  }

  /// Fetch the list of all members according to the specified [text] filter.
  Future<void> fetchMemberList(String? text) async {
    // guard against unauthorized access
    if (!_loginProvider.isMember) {
      _log.info("User not member, skipping member list fetch");
      _memberList = [];
      _updateLoadingStatus(LoadingStatus.empty);
      return;
    }
    _updateLoadingStatus(LoadingStatus.loading);
    await _membersService
        .fetchMembers(text)
        .then(
          (value) async {
            _log.fine("Members list of ${value.length} members retrieved successfully");
            _memberList = value;
            _updateLoadingStatus(_memberList.isEmpty ? LoadingStatus.empty : LoadingStatus.loaded);
          },
          onError: (error) {
            _log.warning("Error when retrieving members list ($error)");
            _memberList = [];
            AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
            _updateLoadingStatus(LoadingStatus.notLoaded);
          },
        );
  }

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of MemberListProvider");
    notifyListeners();
  }

  /// Update the current loading status
  void _updateLoadingStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of MemberListProvider");
    _notifyListeners();
  }
}
