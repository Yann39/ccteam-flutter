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

import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/services/members_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status { Unauthenticated, Authenticating, Authenticated }

class MemberProvider extends ChangeNotifier {
  final Logger _log = new Logger('MemberProvider');
  final MembersService _membersService = new MembersService();
  Member _member;
  Status _status = Status.Unauthenticated;

  MemberProvider() {
    checkUser();
  }

  Member get member => _member;

  Status get status => _status;

  void _setStatus(Status status) {
    _status = status;
    notifyListeners();
  }

  /// Check if the user needs to authenticate
  /// Used to be called on app start
  /// If email is found in shared preferences and exists in the database, user will be consider as logged in
  Future<void> checkUser() async {
    _log.info("Checking user...");
    _setStatus(Status.Authenticating);

    // read shared preference
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    final String _email = _prefs.getString('email');

    // if email is set, we will consider user is already logged in
    if (_email != null) {
      _log.fine("Email $_email found in shared preferences, let's get member from database");
      Member _mb = await _membersService.getMemberByEmail(_email);
      if (_mb == null || _mb.id < 0) {
        _log.severe("Email found in shared preferences but member not found in the database !");
        _setStatus(Status.Unauthenticated);
      } else {
        _log.fine("User $_email found in database, consider as logged in");
        _member = _mb;
        _setStatus(Status.Authenticated);
      }
    } else {
      _log.fine("No email found in shared preferences");
      _status = Status.Unauthenticated;
    }
  }

  /// log in the specified [member] from the database using the credentials
  Future<void> loginMember(Member member) async {
    _log.info("Logging in user ${member.email} with password ${member.password}");
    _setStatus(Status.Authenticating);
    await _membersService.loginMember(member).then((value) async {
      // store the user e-mail in the shared preferences
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      _prefs.setString('email', member.email);
      _log.fine("User ${member.email} logged in successfully");
      // get the full member from the database
      await _membersService.getMemberByEmail(member.email).then((value) async {
        _setStatus(Status.Authenticated);
        _member = value;
      }, onError: (error) {
        _setStatus(Status.Unauthenticated);
        _log.severe("Problem when getting user ${member.email} from database ($error)");
        throw (error);
      });
    }, onError: (error) {
      _log.warning("User ${member.email} failed to log in ($error)");
      _setStatus(Status.Unauthenticated);
      throw (error);
    });
  }

  Future<void> createMember(Member member) async {
    await _membersService.createMember(member).then((value) {
      _log.fine("New user registered : ${member.email}");
    }, onError: (error) {
      _log.severe("Failed to register new user ($error)");
      throw (error);
    });
  }

  Future<void> askPassword(String email) async {
    await _membersService.askPassword(email).then((value) {
      _log.fine("Forgot password requested for e-mail : $email");
    }, onError: (error) {
      _log.severe("Failed to request forgot password", error);
      throw (error);
    });
  }
}
