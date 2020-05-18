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

import 'package:chachatte_team/providers/avatar_provider.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_image_crop/simple_image_crop.dart';

class ImageCrop extends StatelessWidget {
  final cropKey = GlobalKey<ImgCropState>();

  @override
  Widget build(BuildContext context) {
    final _drawerProvider = Provider.of<AvatarProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(AppString.zoomAndCrop),
      ),
      body: Center(
        child: ImgCrop(
          key: cropKey,
          maximumScale: 3,
          image: FileImage(_drawerProvider.image),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red[700],
        onPressed: () async {
          final crop = cropKey.currentState;
          final croppedFile = await crop.cropCompleted(_drawerProvider.image, pictureQuality: 600);
          _drawerProvider.loadImage(croppedFile);
          Navigator.pop(context);
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
