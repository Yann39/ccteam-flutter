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

import 'package:ccteam/providers/avatar_provider.dart';
import 'package:ccteam/providers/member_creation_provider.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditAvatar extends StatelessWidget {
  const EditAvatar({Key? key}) : super(key: key);

  /// Allow user to select an image from the gallery
  Future _selectImageFromGallery(BuildContext context, AvatarProvider avatarProvider) async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 50);
    if (image != null) {
      avatarProvider.setPickedImage(File(image.path));
      avatarProvider.setPickedImageName(image.name);
      Navigator.of(context).pushNamed('/imageCrop');
    }
  }

  /// Allow user to select an image from the camera
  Future _selectImageFromCamera(BuildContext context, AvatarProvider avatarProvider) async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 512, maxHeight: 512, imageQuality: 50);
    if (image != null) {
      avatarProvider.setPickedImage(File(image.path));
      avatarProvider.setPickedImageName(image.name);
      Navigator.of(context).pushNamed('/imageCrop');
    }
  }

  /// Display a confirmation popup when trying to reset an avatar
  void _showConfirmation(BuildContext context, AvatarProvider avatarProvider, String value) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppString.confirmation),
        content: Text(value),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _dialogueResult(context, avatarProvider, ConfirmDialogAction.yes);
            },
            child: Text(AppString.confirm),
          ),
          TextButton(
            onPressed: () {
              _dialogueResult(context, avatarProvider, ConfirmDialogAction.no);
            },
            child: Text(AppString.cancel),
          ),
        ],
      ),
    );
  }

  /// Handle result of the avatar reset confirmation dialog
  void _dialogueResult(BuildContext context, AvatarProvider avatarProvider, ConfirmDialogAction value) {
    if (value == ConfirmDialogAction.yes) {
      avatarProvider.setPickedImage(null);
      avatarProvider.setPickedImageName(null);
      avatarProvider.setCroppedImage(null);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _avatarProvider = Provider.of<AvatarProvider>(context, listen: true);
    final _memberCreationProvider = Provider.of<MemberCreationProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.profilePhoto),
      ),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
                        child: _avatarProvider.croppedImage != null
                            ? Image.memory(
                                _avatarProvider.croppedImage!,
                                alignment: Alignment.topCenter,
                                fit: BoxFit.contain,
                              )
                            : _avatarProvider.pickedImage != null
                                ? Image.memory(
                                    _avatarProvider.pickedImage!.readAsBytesSync(),
                                    alignment: Alignment.topCenter,
                                    fit: BoxFit.contain,
                                  )
                                : ShaderMask(
                                    blendMode: BlendMode.srcATop,
                                    shaderCallback: (bounds) => LinearGradient(
                                      begin: const FractionalOffset(0.0, 0.0),
                                      end: const FractionalOffset(0.0, 1.0),
                                      stops: [0.0, 1.0],
                                      colors: [Colors.red[700]!, Colors.blue[700]!],
                                    ).createShader(bounds),
                                    child: Icon(CustomIcons.pilot, size: 225, color: Colors.white),
                                  ),
                      ),
                    ),
                    AspectRatio(
                      aspectRatio: 1,
                      child: CustomPaint(
                        painter: HolePainter(),
                      ),
                    ),
                  ],
                ),
                Text(
                  AppString.selectPhoto,
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(1.3),
                ),
                Text(AppString.maxAvatarSize, textAlign: TextAlign.center),
                Text(AppString.avatarFormats, textAlign: TextAlign.center),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.blue[700],
                        padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                      ),
                      onPressed: () {
                        _selectImageFromGallery(context, _avatarProvider);
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.photo_library, color: Colors.white, size: 15),
                          SizedBox(width: 5),
                          Text(
                            AppString.gallery,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.blue[700],
                        padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                      ),
                      onPressed: () {
                        _selectImageFromCamera(context, _avatarProvider);
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.photo_camera, color: Colors.white, size: 15),
                          SizedBox(width: 5),
                          Text(
                            AppString.camera,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_avatarProvider.pickedImage != null)
                  TextButton(
                    child: Text(AppString.initProfilePhoto),
                    onPressed: () => _showConfirmation(context, _avatarProvider, AppString.avatarResetAreYouSure),
                  ),
                SizedBox(height: 10),
                FittedBox(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.green[700],
                      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                    ),
                    onPressed: () {
                      if (_avatarProvider.croppedImage != null) {
                        _memberCreationProvider.currentMember.avatar = base64Encode(_avatarProvider.croppedImage!);
                        _memberCreationProvider.currentMember.avatarName = _avatarProvider.pickedImageName;
                      } else {
                        _memberCreationProvider.currentMember.avatar = null;
                        _memberCreationProvider.currentMember.avatarName = null;
                      }
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.check, color: Colors.white, size: 15),
                        SizedBox(width: 5),
                        Text(AppString.confirmSelection, style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.black12;
    paint.blendMode = BlendMode.darken;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(24, 24, size.width - 48, size.height - 48)),
        Path()
          ..addOval(Rect.fromCircle(center: Offset(size.width / 2, (size.height) / 2), radius: (size.width - 48) / 2))
          ..close(),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
