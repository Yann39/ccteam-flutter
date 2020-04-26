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

import 'package:chachatte_team/providers/track_provider.dart';
import 'package:chachatte_team/ui/main/main_action_menu.dart';
import 'package:chachatte_team/ui/main/main_drawer.dart';
import 'package:chachatte_team/utils/custom_icons_icons.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class Tracks extends StatelessWidget {
  Widget build(BuildContext context) {
    final _trackProvider = Provider.of<TrackProvider>(context, listen: true);

    List<String> trackFiles = List();
    trackFiles.add("images/ales.png");
    trackFiles.add("images/bourbonnais.png");
    trackFiles.add("images/bresse.png");
    trackFiles.add("images/carole.png");
    trackFiles.add("images/dijon.png");
    trackFiles.add("images/la-ferte-gaucher.png");
    trackFiles.add("images/le-mans.png");
    trackFiles.add("images/ledenon.png");
    trackFiles.add("images/magny-cours.png");
    trackFiles.add("images/vaison.png");

    Icon getTrackIcon(String trackName) {
      if (trackName == 'Alès') {
        return Icon(CustomIcons.track_ales, color: Colors.red[700], size: 90);
      } else if (trackName == 'Bresse') {
        return Icon(CustomIcons.track_bresse, color: Colors.red[700], size: 60);
      } else if (trackName == 'Bourbonnais') {
        return Icon(CustomIcons.track_bourbonnais, color: Colors.red[700], size: 70);
      } else if (trackName == 'Carole') {
        return Icon(CustomIcons.track_carole, color: Colors.red[700], size: 60);
      } else if (trackName == 'Dijon-Prenois') {
        return Icon(CustomIcons.track_dijon_prenois, color: Colors.red[700], size: 90);
      } else if (trackName == 'La Ferté-Gaucher') {
        return Icon(CustomIcons.track_la_ferte_gaucher, color: Colors.red[700], size: 78);
      } else if (trackName == 'Le Mans') {
        return Icon(CustomIcons.track_le_mans, color: Colors.red[700], size: 80);
      } else if (trackName == 'Lédenon') {
        return Icon(CustomIcons.track_ledenon, color: Colors.red[700], size: 70);
      } else if (trackName == 'Magny-Cours') {
        return Icon(CustomIcons.track_magny_cours, color: Colors.red[700], size: 65);
      } else if (trackName == 'Vaison') {
        return Icon(CustomIcons.track_vaison, color: Colors.red[700], size: 52);
      } else {
        return Icon(CustomIcons.track_sample, color: Colors.red[700], size: 40);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.tabTracks),
        actions: <Widget>[MainActionMenu()],
      ),
      drawer: MainDrawer(),
      body: Column(
        children: <Widget>[

          TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.blue[100],
              prefixIcon: Icon(Icons.search),
              hintText: AppString.tracksSearchHint,
            ),
            maxLines: 1,
            onChanged: (String text) {_trackProvider.searchTracks(text); },
          ),
          Expanded(
            child: Container(
              color: Colors.blue[200],
              child: GridView.builder(
                padding: EdgeInsets.all(4.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1
                ),
                itemCount: _trackProvider.tracks.length,
                itemBuilder: (BuildContext context, int index) => Card(
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        //colors: [Color.fromRGBO(0, 100, 200, 0.3), Color.fromRGBO(0, 100, 200, 0.5)],
                        colors: [Colors.blue[300], Colors.blue[500]],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.0, 1.0],
                      ),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Text(_trackProvider.tracks[index].name, style: TextStyle(color: Colors.white), textScaleFactor: 1.1),
                        ),
                        Divider(height: 1.0, color: Colors.white,),
                        Container(
                          height: 90.0,
                          padding: EdgeInsets.all(0),
                          child: getTrackIcon(_trackProvider.tracks[index].name),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(Icons.straighten, size: 13, color: Colors.white),
                                SizedBox(width: 6.0),
                                Text("Longueur : ${(_trackProvider.tracks[index].distance/1000).toStringAsFixed(2)} km", style: TextStyle(color: Colors.white), textScaleFactor: 0.9),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Icon(Icons.timer, size: 13, color: Colors.white),
                                SizedBox(width: 6.0),
                                Text("Record : ${DateUtils.toLapTime(_trackProvider.tracks[index].lapRecord)}", style: TextStyle(color: Colors.white), textScaleFactor: 0.9),
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
        ],
      ),
    );
  }
}
