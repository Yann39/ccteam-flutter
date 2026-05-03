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
import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class PhotoCard extends StatelessWidget {
  final Photo photo;

  PhotoCard(this.photo);

  /// Method that launches the Photo detail screen and awaits the result from Navigator.pop
  _navigateToPhotoDetailScreen(BuildContext context, Photo photo) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final result = await Navigator.pushNamed(
      context,
      "/photoDetail",
      arguments: photo,
    );

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: InkWell(
        onTap: () => _navigateToPhotoDetailScreen(context, photo),
        child: Hero(
          flightShuttleBuilder: (
            BuildContext flightContext,
            Animation<double> animation,
            HeroFlightDirection flightDirection,
            BuildContext fromHeroContext,
            BuildContext toHeroContext,
          ) {
            final Widget toHero = toHeroContext.widget;
            return RotationTransition(turns: animation, child: toHero);
          },
          tag: photo.id!,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                placeholder: (context, url) => CircularProgressIndicator(),
                imageUrl: SERVER_PHOTOS_FOLDER + photo.link!,
                fit: BoxFit.fitWidth,
              ),
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  height: 20.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.black.withAlpha(128),
                  ),
                  child: Text(
                    photo.title!,
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
