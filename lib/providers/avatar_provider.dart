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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import '../models/member.dart';
import '../services/members_service.dart';
import 'login_provider.dart';
import 'message_provider.dart';

class AvatarProvider extends ChangeNotifier {
  final Logger _log = new Logger('AvatarProvider');
  final MembersService _membersService = new MembersService();

  // chosen image file representing the avatar
  File? _image;

  // login provider that can be set from the proxy provider
  late LoginProvider _loginProvider;

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  // current member
  late Member _currentMember;

  Member get currentMember => _currentMember;

  File? get image => _image;

  /// Load the specified [imageFile] representing the avatar
  void loadImage(File? imageFile) async {
    _image = imageFile;
    _notifyListeners();
  }

  /// Set the [member] to be edited.
  void setMemberToEdit(Member member) {
    _currentMember = member;
    _notifyListeners();
  }

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

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of MemberCreationProvider");
    notifyListeners();
  }

  /// Upload the specified [avatar] file for the specified [member].
  /// If the specified [member] is different from the current logged user, it means we are uploading an avatar as admin for a member.
  /// If the specified [member] is the same as the current logged user, it means the current logged user is uploading an avatar.
  Future<void> uploadAvatar(File avatar) async {
    if (_loginProvider.loggedMember!.id != _currentMember.id) {
      _log.fine("Uploaded avatar as admin for user ${_currentMember.email}");
    }

    final Member tmpMember = _currentMember;

    await _membersService.uploadAvatar(avatar, tmpMember.id!).then((value) async {
      _log.fine("Avatar uploaded successfully");

      dynamic responseJson = json.decode(value);
      final String uploadedFileName = responseJson['file'];

      _log.fine("Avatar uploaded file name is : $uploadedFileName");

      tmpMember.avatarUrl = uploadedFileName;
      tmpMember.modifiedOn = DateTime.now();

      _log.info("Sending user with new avatar : ${tmpMember.toString()}");

      await _membersService.updateMember(tmpMember).then((value) {
        _log.fine("Avatar updated for member : ${tmpMember.email}");
        // current logged user avatar changed, update it
        if (_loginProvider.loggedMember!.id == _currentMember.id) {
          _loginProvider.loggedMember!.avatarUrl = tmpMember.avatarUrl;
          _loginProvider.loggedMember!.modifiedOn = tmpMember.modifiedOn;
          _notifyListeners();
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

  /// Delete the avatar of the specified [member].
  /// If the current member is different from the current logged user, it means we are deleting an avatar as admin for a member.
  /// If the current member is the same as the current logged user, it means the current logged user is deleting its avatar.
  Future<void> deleteAvatar() async {
    if (_loginProvider.loggedMember!.id != _currentMember.id) {
      _log.fine("Deleting avatar as admin for user ${_currentMember.email}");
    }

    final Member tmpMember = _currentMember;

    await _membersService.deleteAvatar(_currentMember.id!).then((value) async {
      _log.fine("Avatar file deleted successfully from server");

      tmpMember.avatarUrl = null;
      tmpMember.modifiedOn = DateTime.now();

      await _membersService.updateMember(tmpMember).then((value) {
        _log.fine("Avatar deleted for member : ${tmpMember.email}");
        // current logged user avatar deleted, update it
        if (_loginProvider.loggedMember!.id == _currentMember.id) {
          _loginProvider.loggedMember!.avatarUrl = null;
          _loginProvider.loggedMember!.modifiedOn = tmpMember.modifiedOn;
        }
        _notifyListeners();
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
