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
  Widget buildSearchField(TrackListProvider _trackListProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
          hintText: AppString.tracksSearchHint,
          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.blue[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.blue[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 1.5),
          ),
        ),
        maxLines: 1,
        onChanged: (String text) {
          _trackListProvider.searchTracks(text);
        },
      ),
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

  /// Build a single track card for the grid: cover photo on top half + info
  /// (name, length, lap record) on a blue gradient on the bottom half. A
  /// circular track-shape badge sits in the top-right corner of the photo.
  Widget _buildTrackCard(BuildContext context, Track track) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: () => _navigateToTrackDetailScreen(context, track),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // top: cover photo (with track-shape badge)
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    TrackUtils.trackCoverImageUrlFromName(track.name),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[200]!, Colors.blue[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  // track-shape silhouette as a circular badge in top-right
                  Positioned(
                    top: 6.0,
                    right: 6.0,
                    child: Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 4.0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 32.0,
                        height: 32.0,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: TrackUtils.getTrackIcon(track.name ?? ""),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // bottom: name + stats on blue gradient (no inner border-radius
            // so the top edge is flush with the photo above; the parent
            // Card clips the visible bottom corners)
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[300]!, Colors.blue[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      track.name ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3.0),
                    if (track.distance != null)
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.straighten,
                            color: Colors.white,
                            size: 12.0,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            "${(track.distance! / 1000).toStringAsFixed(2)} km",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.0,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    if (track.country != null) ...[
                      const SizedBox(height: 1.0),
                      Row(
                        children: <Widget>[
                          Text(
                            track.country!.flagEmoji,
                            style: const TextStyle(fontSize: 12.0, height: 1.0),
                          ),
                          const SizedBox(width: 4.0),
                          Flexible(
                            child: Text(
                              track.country!.localizedName(
                                Localizations.localeOf(context).languageCode,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.0,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: Column(
          children: <Widget>[
            buildSearchField(_trackListProvider),
            Expanded(
              child: LoadingContent(
                loadingStatus: _trackListProvider.tracks.isEmpty
                    ? LoadingStatus.empty
                    : _trackListProvider.loadingStatus,
                defaultText: AppString.tracksNotFound,
                emptyText: AppString.tracksNotFound,
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? 2
                        : 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _trackListProvider.tracks.length,
                  itemBuilder: (BuildContext context, int index) =>
                      _buildTrackCard(
                    context,
                    _trackListProvider.tracks[index],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
