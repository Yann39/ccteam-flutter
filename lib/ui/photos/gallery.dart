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

import 'package:chachatte_team/models/photo.dart';
import 'package:chachatte_team/services/photos_service.dart';
import 'package:chachatte_team/ui/main/main_action_menu.dart';
import 'package:chachatte_team/ui/main/main_drawer.dart';
import 'package:chachatte_team/ui/photos/add_photo.dart';
import 'package:chachatte_team/ui/photos/photo_card.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';

class Gallery extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GalleryState();
  }
}

class _GalleryState extends State<Gallery> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static final PhotosService photosService = new PhotosService();

  /// Method that launches the Add Photo screen and awaits the result from Navigator.pop
  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the Add News Screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddPhoto()));

    // after the Add Photo Screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppString.tabGallery),
        actions: <Widget>[MainActionMenu()],
      ),
      drawer: MainDrawer(),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Photo>>(
          future: photosService.fetchPhotos(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView.count(
                childAspectRatio: 1.5,
                crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
                children: List.generate(snapshot.data.length, (index) {
                  return new PhotoCard(snapshot.data[index], photosService);
                }),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner
            return Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                height: 20.0,
                width: 20.0,
              ),
            );
          },
        ),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [Colors.blue[100], Colors.blue[300]],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        child: new Icon(Icons.add),
        backgroundColor: Colors.red[700],
        onPressed: () {
          _navigateAndDisplaySelection(context);
        },
      ),
    );
  }
}
