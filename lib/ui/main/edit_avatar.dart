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

import 'package:chachatte_team/providers/drawer_provider.dart';
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditAvatar extends StatelessWidget {
  /// Allow user to select an image from the gallery
  Future _selectImage(BuildContext context) async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Provider.of<DrawerProvider>(context, listen: false).loadImage(image);
      Navigator.of(context).pushNamed('/imageCrop');
    }
  }

  @override
  Widget build(BuildContext context) {
    final _loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final _drawerProvider = Provider.of<DrawerProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Avatar'),
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
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 16.0),
              Text("Votre avatar :", textAlign: TextAlign.left),
              Container(
                margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                child: _drawerProvider.image != null
                    ? Image.file(_drawerProvider.image, alignment: Alignment.topCenter, fit: BoxFit.contain)
                    : Image(
                        alignment: Alignment.topCenter,
                        fit: BoxFit.contain,
                        image: _loginProvider.loggedMember.avatar != null
                            ? NetworkImage("${AppConstants.SERVER_ROOT_PATH}${AppConstants.SERVER_AVATAR_FOLDER}${_loginProvider.loggedMember.avatar}")
                            : AssetImage("images/helmet-face.png"),
                      ),
              ),
              _drawerProvider.image == null
                  ? RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onPressed: () => _selectImage(context),
                      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                      color: Colors.red[700],
                      child: Text("Changer...", style: TextStyle(color: Colors.white)),
                    )
                  : Builder(
                      builder: (BuildContext context) {
                        return RaisedButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          onPressed: () {
                            _loginProvider.uploadAvatar(_drawerProvider.image, _loginProvider.loggedMember.id).then((value) {
                              Navigator.pop(context);
                            }, onError: (error) {
                              Scaffold.of(context)
                                ..removeCurrentSnackBar()
                                ..showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(AppString.avatarUploadFailed)));
                            });
                          },
                          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                          color: Colors.red[700],
                          child: Text("Valider", style: TextStyle(color: Colors.white)),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
