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

import 'dart:convert';
import 'dart:io';

import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/services/members_service.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  final Logger _log = new Logger('LoginProvider');
  final MembersService _membersService = new MembersService();

  // current authentication status
  AuthStatus _authStatus = AuthStatus.Unauthenticated;

  // logged member
  Member _loggedMember;

  // constructor
  LoginProvider() {
    // as soon as it is instantiated, we check if the user needs to authenticate
    _checkUser();
  }

  Member get loggedMember => _loggedMember;

  AuthStatus get status => _authStatus;

  /// Change the current authentication [status]
  void _setStatus(AuthStatus status) {
    _authStatus = status;
    _log.info("Notifying listeners of LoginProvider");
    notifyListeners();
  }

  /// Check if the user needs to authenticate
  /// Used to be called on app start
  /// If email is found in shared preferences and exists in the database, user will be consider as logged in
  void _checkUser() async {
    _log.info("Checking user...");
    _setStatus(AuthStatus.Initializing);

    // read shared preference
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    final String _email = _prefs.getString('email');

    // if email is set, we will consider user is already logged in
    if (_email != null) {
      _log.fine("Email $_email found in shared preferences, let's get member from database");
      await _membersService.getMemberByEmail(_email).then((value) {
        if (value == null || value.id < 0) {
          _log.severe("Email found in shared preferences but member not found in the database !");
          _setStatus(AuthStatus.Unauthenticated);
        } else {
          _log.fine("User $_email found in database, consider as logged in");
          _loggedMember = value;
          _setStatus(AuthStatus.Authenticated);
        }
      }, onError: (error) {
        _log.severe("Email found in shared preferences but member not found in the database !");
        _setStatus(AuthStatus.Unauthenticated);
      });
    } else {
      _log.fine("No email found in shared preferences");
      _authStatus = AuthStatus.Unauthenticated;
    }
  }

  /// Log in the specified [member] from the database using the credentials
  Future<void> loginMember(Member member) async {
    _log.info("Logging in user ${member.email} with password ${member.password}");
    _setStatus(AuthStatus.Authenticating);
    await _membersService.loginMember(member).then((value) async {
      // store the user e-mail in the shared preferences
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      _prefs.setString('email', member.email);
      _log.fine("User ${member.email} logged in successfully");

      // get the full member from the database
      await _membersService.getMemberByEmail(member.email).then((value) async {
        _setStatus(AuthStatus.Authenticated);
        _loggedMember = value;
      }, onError: (error) {
        _setStatus(AuthStatus.Unauthenticated);
        _log.severe("Problem when getting user ${member.email} from database ($error)");
        throw (error);
      });
    }, onError: (error) {
      _log.warning("User ${member.email} failed to log in ($error)");
      _setStatus(AuthStatus.Unauthenticated);
      throw (error);
    });
  }

  /// Log out the current member
  void logoutMember() async {
    _log.info("Logging out user ${_loggedMember.email}");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    _setStatus(AuthStatus.Unauthenticated);
  }

  /// Create the specified member
  Future<void> registerMember(Member member) async {
    await _membersService.createMember(member).then((value) {
      _log.fine("New user registered : ${member.email}");
    }, onError: (error) {
      _log.severe("Failed to register new user ($error)");
      throw (error);
    });
  }

  /// Ask for a new password
  Future<void> askPassword(String email) async {
    await _membersService.askPassword(email).then((value) {
      _log.fine("Forgot password requested for e-mail : $email");
    }, onError: (error) {
      _log.severe("Failed to request forgot password", error);
      throw (error);
    });
  }

  /// Upload the specified [avatar] file for the specified [member]
  /// If the specified [member] is different from the current logged user, it means we are uploading an avatar as admin for a member
  /// If the specified [member] is the same as the current logged user, it means the current logged user is uploading an avatar
  Future<void> uploadAvatar(File avatar, Member member) async {
    if (member.id != _loggedMember.id) {
      _log.fine("Uploaded avatar as admin for user ${member.email}");
    }

    final Member tmpMember = member;

    await _membersService.uploadAvatar(avatar, tmpMember.id).then((value) async {
      _log.fine("Avatar uploaded successfully");

      dynamic responseJson = json.decode(value);
      final String uploadedFileName = responseJson['file'];

      _log.fine("Avatar uploaded file name is : $uploadedFileName");

      tmpMember.avatar = uploadedFileName;
      tmpMember.modifiedOn = DateTime.now();

      _log.info("Sending user with new avatar : ${tmpMember.toString()}");

      await _membersService.updateMember(tmpMember).then((value) {
        _log.fine("Avatar updated for member : ${tmpMember.email}");
        if (member.id == _loggedMember.id) {
          _loggedMember.avatar = tmpMember.avatar;
          _loggedMember.modifiedOn = tmpMember.modifiedOn;
          _log.info("Notifying listeners of LoginProvider");
          notifyListeners();
        }
      }, onError: (error) {
        _log.severe("Failed to update avatar for member ${tmpMember.email} ($error)");
        throw (error);
      });
    }, onError: (error) {
      _log.severe("Failed to upload avatar ($error)");
      throw (error);
    });
  }

  /// Delete the avatar of the specified [member]
  /// If the specified [member] is different from the current logged user, it means we are deleting an avatar as admin for a member
  /// If the specified [member] is the same as the current logged user, it means the current logged user is deleting its avatar
  Future<void> deleteAvatar(Member member) async {
    if (member.id != _loggedMember.id) {
      _log.fine("Deleting avatar as admin for user ${member.email}");
    }

    final Member tmpMember = member;

    await _membersService.deleteAvatar(member.id).then((value) async {
      _log.fine("Avatar file deleted successfully from server");

      tmpMember.avatar = null;
      tmpMember.modifiedOn = DateTime.now();

      await _membersService.updateMember(tmpMember).then((value) {
        _log.fine("Avatar deleted for member : ${tmpMember.email}");
        if (member.id == _loggedMember.id) {
          _loggedMember.avatar = null;
          _loggedMember.modifiedOn = tmpMember.modifiedOn;
        }
        _log.info("Notifying listeners of LoginProvider");
        notifyListeners();
      }, onError: (error) {
        _log.severe("Failed to delete avatar for member ${tmpMember.email} ($error)");
        throw (error);
      });
    }, onError: (error) {
      _log.severe("Failed to delete avatar ($error)");
      throw (error);
    });
  }
}
