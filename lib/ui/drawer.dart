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
import 'package:chachatte_team/models/news.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'members/add_member.dart';

class MainDrawer extends StatefulWidget {
  final Member member;

  const MainDrawer({Key key, this.member}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MainDrawerState();
  }
}

class _MainDrawerState extends State<MainDrawer> {
  File _image;
  int _imageSize;

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
  }

  /// Method that launches the Edit Member screen and awaits the result from Navigator.pop
  _navigateToEditMemberScreen(BuildContext context, Member member) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddMember(member: member)));

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  Future _selectImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    /*File croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 512,
      maxHeight: 512,
    );*/

    FileStat fs = image.statSync();

    setState(() {
      _image = image;
      _imageSize = fs.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [Colors.blue[100], Colors.blue[300]],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            InkWell(
              onTap: () => _selectImage(),
              child: UserAccountsDrawerHeader(
                accountName: Text("${widget.member.firstName} ${widget.member.lastName}"),
                accountEmail: Text(widget.member.email),
                currentAccountPicture: new CircleAvatar(
                  backgroundColor: Colors.blue[300],
                  backgroundImage: new AssetImage("images/helmet-face.png"),
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Text("Image size : $_imageSize"),
                Center(
                  child: _image == null ? Text('No image selected.') : Image.file(_image),
                ),
                ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Colors.green[600],
                  ),
                  trailing: Icon(Icons.arrow_right),
                  title: Text('Profile'),
                  onTap: () {
                    _navigateToEditMemberScreen(context, widget.member);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: Colors.blue[600],
                  ),
                  trailing: Icon(Icons.arrow_right),
                  title: Text('Notifications'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Colors.teal[600],
                  ),
                  trailing: Icon(Icons.arrow_right),
                  title: Text('Préférences'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.lock,
                    color: Colors.purple[600],
                  ),
                  trailing: Icon(Icons.arrow_right),
                  title: Text('Déconnexion'),
                  onTap: () {
                    _logout();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
