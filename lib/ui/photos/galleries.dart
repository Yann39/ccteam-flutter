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
import 'package:ccteam/providers/photo_provider.dart';
import 'package:ccteam/ui/main/main_action_menu.dart';
import 'package:ccteam/ui/main/main_drawer.dart';
import 'package:ccteam/ui/photos/add_edit_photo.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Galleries extends StatelessWidget {
  /// Method that launches the Add Photo screen and awaits the result from Navigator.pop
  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the Add News Screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditPhoto()));

    // after the Add Photo Screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  Widget build(BuildContext context) {
    final _photoProvider = Provider.of<PhotoProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.galleries),
        actions: <Widget>[MainActionMenu()],
      ),
      drawer: MainDrawer(),
      body: Container(
        decoration: CustomDecorations.mainContent,
        padding: EdgeInsets.all(4.0),
        child: LoadingContent(
          loadingStatus: _photoProvider.loadingStatus,
          emptyText: AppString.photosNotFound,
          child: GridView.builder(
            padding: EdgeInsets.all(4.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1.3,
            ),
            itemCount: _photoProvider.galleries.length,
            itemBuilder: (BuildContext context, int index) => InkWell(
              onTap: () {
                _photoProvider.fetchPhotosFromGallery(_photoProvider.galleries[index].id!);
                Navigator.pushNamed(context, "/gallery", arguments: _photoProvider.galleries[index].title);
              },
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                decoration: _photoProvider.galleries[index].photos!.length > 0
                                    ? BoxDecoration(
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              _photoProvider.galleries[index].photos![0].link!),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : BoxDecoration(),
                              ),
                            ),
                            SizedBox(width: 2),
                            Expanded(
                              child: Container(
                                decoration: _photoProvider.galleries[index].photos!.length > 1
                                    ? BoxDecoration(
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              _photoProvider.galleries[index].photos![1].link!),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : BoxDecoration(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2),
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                decoration: _photoProvider.galleries[index].photos!.length > 2
                                    ? BoxDecoration(
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              _photoProvider.galleries[index].photos![2].link!),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : BoxDecoration(),
                              ),
                            ),
                            SizedBox(width: 2),
                            Expanded(
                              child: Container(
                                decoration: _photoProvider.galleries[index].photos!.length > 3
                                    ? BoxDecoration(
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              _photoProvider.galleries[index].photos![3].link!),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : BoxDecoration(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 20.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.black.withOpacity(0.5)),
                    child: Text(
                      _photoProvider.galleries[index].title!,
                      softWrap: false,
                      style: TextStyle(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.red[700],
        onPressed: () {
          _navigateAndDisplaySelection(context);
        },
      ),
    );
  }
}
