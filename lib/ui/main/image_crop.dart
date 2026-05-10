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

import 'package:ccteam/providers/avatar_provider.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageCrop extends StatelessWidget {
  final _controller = CropController();

  @override
  Widget build(BuildContext context) {
    final _avatarProvider = Provider.of<AvatarProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(elevation: 0, title: Text(AppString.zoomAndCrop)),
      body: Center(
        child: Crop(
          image: _avatarProvider.pickedImage!.readAsBytesSync(),
          controller: _controller,
          progressIndicator: CircularProgressIndicator(),
          onCropped: (image) {
            switch (image) {
              case CropSuccess(:final croppedImage):
                _avatarProvider.setCroppedImage(croppedImage);
                Navigator.pop(context);
              case CropFailure(:final cause):
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text('Failed to crop image: ${cause.toString()}'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
                  ),
                );
            }
          },
          withCircleUi: true,
          radius: 20,
          initialRectBuilder: InitialRectBuilder.withBuilder((viewportRect, imageRect) {
            final double side = imageRect.shortestSide;
            return Rect.fromCenter(center: imageRect.center, width: side, height: side);
          }),
          baseColor: Colors.black54,
          clipBehavior: Clip.none,
          interactive: true,
          cornerDotBuilder: (size, edgeAlignment) => const DotControl(color: Colors.blue),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red[700],
        onPressed: () => _controller.cropCircle(),
        child: Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}
