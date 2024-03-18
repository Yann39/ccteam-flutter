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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ccteam/models/photo.dart';
import 'package:ccteam/providers/photo_provider.dart';
import 'package:ccteam/ui/photos/add_edit_photo.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/constants.dart';

class PhotoCard extends StatelessWidget {
  final Photo photo;

  PhotoCard(this.photo);

  /// Method that launches the photo form screen and awaits the result from Navigator.pop
  void _navigateAndDisplaySelection(BuildContext context, Photo photo) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the photo form Screen
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddEditPhoto(photo: photo)));

    // after the photo form Screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  /// Method that launches the Photo detail screen and awaits the result from Navigator.pop
  _navigateToPhotoDetailScreen(BuildContext context, Photo photo) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final result =
        await Navigator.pushNamed(context, "/photoDetail", arguments: photo);

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  /*void showPhoto(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(title: Text(photo.title)),
          body: SizedBox.expand(
            child: Hero(
              tag: photo.id,
              child: GridPhotoViewer(photo: photo),
            ),
          ),
        );
      }),
    );
  }*/

  /// Display a confirmation popup when trying to delete an photo
  void _showConfirmation(BuildContext context, String value) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppString.confirmation),
        content: Text(value),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _dialogueResult(context, ConfirmDialogAction.yes);
            },
            child: Text(AppString.confirm),
          ),
          TextButton(
            onPressed: () {
              _dialogueResult(context, ConfirmDialogAction.no);
            },
            child: Text(AppString.cancel),
          ),
        ],
      ),
    );
  }

  /// Handle result of the photo deletion confirmation dialog
  void _dialogueResult(BuildContext context, ConfirmDialogAction value) {
    if (value == ConfirmDialogAction.yes) {
      // delete photo
      Provider.of<PhotoProvider>(context, listen: false)
          .deletePhoto(photo)
          .then((value) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AppString.photoDeleted)));
      }, onError: (error) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
              SnackBar(content: Text(AppString.photoDeletionFailed)));
      });
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 4.0,
      ),
      child: InkWell(
        onTap: () => /*showPhoto(context),*/ _navigateToPhotoDetailScreen(
            context, photo),
        child: Hero(
          flightShuttleBuilder: (
            BuildContext flightContext,
            Animation<double> animation,
            HeroFlightDirection flightDirection,
            BuildContext fromHeroContext,
            BuildContext toHeroContext,
          ) {
            final Hero toHero = toHeroContext.widget;
            return RotationTransition(
              turns: animation,
              child: toHero.child,
            );
          },
          tag: photo.id,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                placeholder: (context, url) => CircularProgressIndicator(),
                imageUrl: SERVER_PHOTOS_FOLDER + photo.link,
                fit: BoxFit.fitWidth,
              ),
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  height: 20.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.black.withOpacity(0.5)),
                  child: Text(
                    photo.title,
                    softWrap: false,
                    style: TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
