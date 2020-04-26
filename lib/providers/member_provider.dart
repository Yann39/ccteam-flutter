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
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

class MemberProvider extends ChangeNotifier {
  final Logger _log = new Logger('MemberProvider');
  final MembersService _membersService = new MembersService();
  List<Member> _members = [];
  bool _loading = true;

  MemberProvider() {
    fetchMembers();
  }

  UnmodifiableListView<Member> get members => UnmodifiableListView(_members);
  bool get loading => _loading;

  /// Get the list of all members
  Future<void> fetchMembers() async {
    _loading = true;
    notifyListeners();
    await _membersService.fetchMembers().then((value) async {
      _log.fine("Members list retrieved successfully");
      _members = value;
      _loading = false;
      notifyListeners();
    }, onError: (error) {
      _log.warning("Error when retrieving members list ($error)");
      _members = [];
      _loading = false;
      notifyListeners();
      throw (error);
    });
  }

  /// Search for members according to the specified [text]
  Future<void> searchMembers(String text) async {
    _loading = true;
    notifyListeners();
    await _membersService.searchMembers(text).then((value) async {
      _log.fine("Members search list retrieved successfully");
      _members = value;
      _loading = false;
      notifyListeners();
    }, onError: (error) {
      _log.warning("Error when searching members ($error)");
      _members = [];
      _loading = false;
      notifyListeners();
      throw (error);
    });
  }

  /// Create the specified [member]
  Future<void> createMember(Member member) async {
    await _membersService.createMember(member).then((value) {
      _log.fine("Member user created : ${member.email}");
      _members.add(member);
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
      notifyListeners();
    }, onError: (error) {
      _log.severe("Failed to delete member ($error)");
      throw (error);
    });
  }
}
