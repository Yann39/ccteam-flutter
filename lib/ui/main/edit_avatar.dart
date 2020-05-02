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

import 'dart:io';

import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/providers/avatar_provider.dart';
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/custom_icons_icons.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

enum ConfirmDialogAction { yes, no }

class EditAvatar extends StatelessWidget {
  final Member member;

  const EditAvatar({Key key, this.member}) : super(key: key);

  /// Allow user to select an image from the gallery
  Future _selectImageFromGallery(BuildContext context, AvatarProvider avatarProvider) async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      avatarProvider.loadImage(image);
      Navigator.of(context).pushNamed('/imageCrop');
    }
  }

  /// Allow user to select an image from the camera
  Future _selectImageFromCamera(BuildContext context, AvatarProvider avatarProvider) async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      avatarProvider.loadImage(image);
      Navigator.of(context).pushNamed('/imageCrop');
    }
  }

  /// Display a confirmation popup when trying to reset an avatar
  void _showConfirmation(BuildContext context, String value) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppString.confirmation),
        content: Text(value),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              _dialogueResult(context, ConfirmDialogAction.yes);
            },
            child: Text(AppString.confirm),
          ),
          FlatButton(
            onPressed: () {
              _dialogueResult(context, ConfirmDialogAction.no);
            },
            child: Text(AppString.cancel),
          ),
        ],
      ),
    );
  }

  /// Handle result of the avatar reset confirmation dialog
  void _dialogueResult(BuildContext context, ConfirmDialogAction value) {
    if (value == ConfirmDialogAction.yes) {
      Provider.of<LoginProvider>(context, listen: false).deleteAvatar(member);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final _loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final _avatarProvider = Provider.of<AvatarProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Photo de profil'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[100], Colors.blue[300]],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(0.0, 1.0),
            stops: [0.0, 1.0],
          ),
        ),
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
                        child: _avatarProvider.image != null
                            ? Image.file(_avatarProvider.image, alignment: Alignment.topCenter, fit: BoxFit.contain)
                            : member.avatar != null && member.avatar.length > 0 ? Image(
                                alignment: Alignment.topCenter,
                                fit: BoxFit.contain,
                                image: NetworkImage("${AppConstants.SERVER_ROOT_PATH}${AppConstants.SERVER_AVATAR_FOLDER}${member.avatar}"),
                              ) : ShaderMask(
                          blendMode: BlendMode.srcATop,
                                shaderCallback: (bounds) => LinearGradient(
                                  begin: const FractionalOffset(0.0, 0.0),
                                  end: const FractionalOffset(0.0, 1.0),
                                  stops: [0.0, 1.0],
                                  colors: [Colors.red[700], Colors.blue[700]],
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
                  "Sélectionnez une photo",
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.3,
                ),
                Text("Max. 500 Ko", textAlign: TextAlign.center),
                Text("Formats JPG, GIF, PNG", textAlign: TextAlign.center),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onPressed: () {
                        _selectImageFromGallery(context, _avatarProvider);
                      },
                      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                      color: Colors.blue[700],
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.photo_library, color: Colors.white, size: 15),
                          SizedBox(width: 5),
                          Text(
                            "Gallerie",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onPressed: () {
                        _selectImageFromCamera(context, _avatarProvider);
                      },
                      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                      color: Colors.blue[700],
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.photo_camera, color: Colors.white, size: 15),
                          SizedBox(width: 5),
                          Text(
                            "Appareil photo",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                FlatButton(
                  child: Text("Réinitialiser la photo de profil"),
                  onPressed: () => _showConfirmation(context, AppString.avatarResetAreYouSure),
                ),
                if (_avatarProvider.image != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onPressed: () {
                          _loginProvider.uploadAvatar(_avatarProvider.image, member).then((value) {
                            Navigator.pop(context);
                          }, onError: (error) {
                            Scaffold.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(AppString.avatarUploadFailed)));
                          });
                        },
                        padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                        color: Colors.red[700],
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check, color: Colors.white, size: 15),
                            SizedBox(width: 5),
                            Text("Confirmer le changement", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
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
    print("${size.height} ${size.width}");
    final paint = Paint();
    paint.color = Colors.black38;
    paint.blendMode = BlendMode.colorBurn;
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
