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

import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/services/members_service.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

class MemberProvider extends ChangeNotifier {
  final Logger _log = new Logger('MemberProvider');
  final MembersService _membersService = new MembersService();

  // members list
  List<Member> _members = [];

  // current members
  Member _currentMember;

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  // constructor
  MemberProvider() {
    // as soon as it is instantiated, we fetch members
    fetchMembers(null);
  }

  UnmodifiableListView<Member> get members => UnmodifiableListView(_members);

  Member get currentMember => _currentMember;

  LoadingStatus get loadingStatus => _loadingStatus;

  /// Update the current loading status
  /// todo Should we have different variables for all members and events members so that it does not refresh all ?
  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of MemberProvider");
    notifyListeners();
  }

  /// Fetch the list of all members according to specified filter [text]
  void fetchMembers(String text) async {
    _updateStatus(LoadingStatus.loading);
    await _membersService.fetchMembers(text).then((value) async {
      _log.fine("Members list of ${value.length} members retrieved successfully");
      _members = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving members list ($error)");
      _members = [];
      _updateStatus(LoadingStatus.notLoaded);
      throw (error);
    });
  }

  /// Fetch the specified [member]
  Future<void> fetchCurrentMember(Member member) async {
    _log.fine("Fetching member ${member.email}");
    _updateStatus(LoadingStatus.loading);
    await _membersService.getMemberById(member.id).then((value) async {
      _log.fine("Member with ID ${member.id} retrieved successfully");
      _currentMember = value;
      _updateStatus(LoadingStatus.loaded);
    }, onError: (error) {
      _log.warning("Error when retrieving member ($error)");
      _currentMember = null;
      _updateStatus(LoadingStatus.notLoaded);
      throw (error);
    });
  }

  /// Update the avatar of the specified [member] in the current member list
  void updateMemberAvatar(Member member) {
    // do the update only if member is in the current member list (list could has not been fetched yet or could be filtered)
    if (_members.any((m) => m.id == member.id)) {
      _members.singleWhere((m) => m.id == member.id).avatarUrl = member.avatarUrl;
      _log.info("Notifying listeners of MemberProvider");
      notifyListeners();
    }
  }

  /// Remove the avatar of the specified [member] in the current member list
  void resetMemberAvatar(Member member) {
    // do the update only if member is in the current member list (list could has not been fetched yet or could be filtered)
    if (_members.any((m) => m.id == member.id)) {
      _members.singleWhere((m) => m.id == member.id).avatarUrl = null;
      _log.info("Notifying listeners of MemberProvider");
      notifyListeners();
    }
  }

  /// Create the specified [member]
  Future<void> createMember(Member member) async {
    await _membersService.createMember(member).then((value) {
      _log.fine("Member user created : ${member.email}");
      _members.add(member);
      _log.info("Notifying listeners of MemberProvider");
      notifyListeners();
    }, onError: (error) {
      _log.severe("Failed to create new member ($error)");
      throw (error);
    });
  }

  /// Update the specified [member]
  Future<void> updateMember(Member member) async {
    await _membersService.createMember(member).then((value) {
      _log.fine("Member successfully updated : ${member.email}");
      _members[_members.indexWhere((m) => m.id == member.id)] = member;
      _log.info("Notifying listeners of MemberProvider");
      notifyListeners();
    }, onError: (error) {
      _log.severe("Failed to update member ($error)");
      throw (error);
    });
  }

  /// Delete the specified [member]
  Future<void> deleteMember(Member member) async {
    await _membersService.deleteMember(member).then((value) {
      _log.fine("Member deleted successfully : ${member.email}");
      _members.remove(member);
      _log.info("Notifying listeners of MemberProvider");
      notifyListeners();
    }, onError: (error) {
      _log.severe("Failed to delete member ($error)");
      throw (error);
    });
  }
}
