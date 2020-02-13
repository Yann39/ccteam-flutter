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
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_image_crop/simple_image_crop.dart';

class ImageCrop extends StatelessWidget {
  final cropKey = GlobalKey<ImgCropState>();

  Future<Null> showImage(BuildContext context, File file) async {
    return showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Image sélectionnée',
              style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w300, color: Theme.of(context).primaryColor, letterSpacing: 1.1),
            ),
            content: Image.file(file),
            actions: <Widget>[
              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                color: Colors.red[700],
                child: Text(
                  AppString.cancel,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onPressed: () {
                  Provider.of<LoginProvider>(context, listen: false).uploadAvatar(file);
                  Navigator.pop(context);
                },
                padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                color: Colors.blue[700],
                child: Text(
                  AppString.valid,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {

    final _drawerProvider = Provider.of<DrawerProvider>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Zoom and Crop',
            style: TextStyle(color: Colors.black),
          ),
          leading: new IconButton(
            icon: new Icon(Icons.navigate_before, color: Colors.black, size: 40),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: ImgCrop(
            key: cropKey,
            // chipRadius: 100,
            // chipShape: 'rect',
            maximumScale: 3,
            image: FileImage(_drawerProvider.image),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red[700],
          onPressed: () async {
            final crop = cropKey.currentState;
            final croppedFile = await crop.cropCompleted(_drawerProvider.image, pictureQuality: 600);
            showImage(context, croppedFile);
          },
          tooltip: 'Increment',
          child: Text('Crop'),
        ));
  }
}
