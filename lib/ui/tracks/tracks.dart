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

import 'package:chachatte_team/models/track.dart';
import 'package:chachatte_team/providers/event_provider.dart';
import 'package:chachatte_team/providers/track_provider.dart';
import 'package:chachatte_team/ui/main/main_action_menu.dart';
import 'package:chachatte_team/ui/main/main_drawer.dart';
import 'package:chachatte_team/utils/custom_decorations.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:chachatte_team/utils/track_utils.dart';
import 'package:chachatte_team/widgets/loading_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// We need stateful widget to keep search field value
class Tracks extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TracksState();
  }
}

class _TracksState extends State<Tracks> {
  /// Build the search field
  TextField buildSearchField(TrackProvider _trackProvider) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blue[100],
        prefixIcon: Icon(Icons.search),
        hintText: AppString.tracksSearchHint,
      ),
      maxLines: 1,
      onChanged: (String text) {
        _trackProvider.searchTracks(text);
      },
    );
  }

  /// Method that launches the Track detail screen and awaits the result from Navigator.pop
  void _navigateToTrackDetailScreen(BuildContext context, Track track) async {
    /*Provider.of<EventProvider>(context, listen: false)
        .fetchTrackEvents(track.id);*/

    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final _result =
        await Navigator.pushNamed(context, '/trackDetail', arguments: track);

    // after the target screen returns a result, hide any previous snack bars and show the result
    if (_result != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$_result")));
    }
  }

  Widget build(BuildContext context) {
    final _trackProvider = Provider.of<TrackProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.tabTracks),
        actions: <Widget>[MainActionMenu()],
      ),
      drawer: MainDrawer(),
      body: Column(
        children: <Widget>[
          buildSearchField(_trackProvider),
          Expanded(
            child: Container(
              decoration: CustomDecorations.mainContent,
              child: LoadingContent(
                emptyText: AppString.tracksNotFound,
                loadingStatus: _trackProvider.loadingStatus,
                child: GridView.builder(
                  padding: EdgeInsets.all(4.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? 2
                          : 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 1),
                  itemCount: _trackProvider.tracks.length,
                  itemBuilder: (BuildContext context, int index) => InkWell(
                    onTap: () => _navigateToTrackDetailScreen(
                        context, _trackProvider.tracks[index]),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0)),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: CustomDecorations.cardFull,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Text(_trackProvider.tracks[index].name,
                                  style: TextStyle(color: Colors.white),
                                  textScaleFactor: 1.1),
                            ),
                            Divider(
                              height: 1.0,
                              color: Colors.white,
                            ),
                            Container(
                              height: 90.0,
                              padding: EdgeInsets.all(0),
                              child: TrackUtils.getTrackIcon(
                                  _trackProvider.tracks[index].name),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.straighten,
                                        size: 13, color: Colors.white),
                                    SizedBox(width: 6.0),
                                    Text(
                                        "${AppString.length} : ${(_trackProvider.tracks[index].distance / 1000).toStringAsFixed(2)} km",
                                        style: TextStyle(color: Colors.white),
                                        textScaleFactor: 0.9),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.timer,
                                        size: 13, color: Colors.white),
                                    SizedBox(width: 6.0),
                                    Text(
                                        "${AppString.record} : ${AppDateUtils.toLapTimeString(_trackProvider.tracks[index].lapRecord)}",
                                        style: TextStyle(color: Colors.white),
                                        textScaleFactor: 0.9),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
