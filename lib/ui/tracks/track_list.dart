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

import 'package:ccteam/models/track.dart';
import 'package:ccteam/providers/track_detail_provider.dart';
import 'package:ccteam/providers/track_list_provider.dart';
import 'package:ccteam/ui/main/main_action_menu.dart';
import 'package:ccteam/ui/main/main_drawer.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/utils/track_utils.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:flutter/material.dart';
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
  TextField buildSearchField(TrackListProvider _trackListProvider) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blue[100],
        prefixIcon: Icon(Icons.search),
        hintText: AppString.tracksSearchHint,
      ),
      maxLines: 1,
      onChanged: (String text) {
        _trackListProvider.searchTracks(text);
      },
    );
  }

  /// Method that launches the Track detail screen and awaits the result from Navigator.pop
  void _navigateToTrackDetailScreen(BuildContext context, Track track) async {
    Provider.of<TrackDetailProvider>(
      context,
      listen: false,
    ).setCurrentTrack(track);
    Navigator.pushNamed(context, '/trackDetail');
  }

  Widget build(BuildContext context) {
    final _trackListProvider = Provider.of<TrackListProvider>(
      context,
      listen: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.tabTracks),
        actions: <Widget>[MainActionMenu()],
      ),
      drawer: MainDrawer(),
      body: Column(
        children: <Widget>[
          buildSearchField(_trackListProvider),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.topCenter,
              decoration: CustomDecorations.mainContent,
              child: LoadingContent(
                loadingStatus:
                    _trackListProvider.tracks.isEmpty
                        ? LoadingStatus.empty
                        : _trackListProvider.loadingStatus,
                defaultText: AppString.tracksNotFound,
                emptyText: AppString.tracksNotFound,
                child: GridView.builder(
                  padding: EdgeInsets.all(4.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? 2
                            : 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 1,
                  ),
                  itemCount: _trackListProvider.tracks.length,
                  itemBuilder:
                      (BuildContext context, int index) => InkWell(
                        onTap:
                            () => _navigateToTrackDetailScreen(
                              context,
                              _trackListProvider.tracks[index],
                            ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
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
                                  child: Text(
                                    _trackListProvider.tracks[index].name!,
                                    style: TextStyle(color: Colors.white),
                                    textScaler: TextScaler.linear(1.1),
                                  ),
                                ),
                                Divider(height: 1.0, color: Colors.white),
                                Container(
                                  height: 86.0,
                                  padding: EdgeInsets.all(0),
                                  child: TrackUtils.getTrackIcon(
                                    _trackListProvider.tracks[index].name!,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.straighten,
                                          size: 13,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 6.0),
                                        Text(
                                          "${AppString.length} : ${(_trackListProvider.tracks[index].distance! / 1000).toStringAsFixed(2)} km",
                                          style: TextStyle(color: Colors.white),
                                          textScaler: TextScaler.linear(0.9),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.timer,
                                          size: 13,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 6.0),
                                        Text(
                                          "${AppString.record} : ${AppDateUtils.toLapTimeString(_trackListProvider.tracks[index].lapRecord)}",
                                          style: TextStyle(color: Colors.white),
                                          textScaler: TextScaler.linear(0.9),
                                        ),
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
