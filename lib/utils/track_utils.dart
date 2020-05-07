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

import 'package:chachatte_team/utils/custom_icons.dart';
import 'package:flutter/material.dart';

/// Track utility functions
class TrackUtils {
  /// Get the right track icon according to the specified [trackName]
  static Icon getTrackIcon(String trackName) {
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

  /// Get the right track icon according to the specified [trackName]
  static IconData trackIconFromName(String trackName) {
    if (trackName == 'Alès') {
      return CustomIcons.track_ales;
    } else if (trackName == 'Bresse') {
      return CustomIcons.track_bresse;
    } else if (trackName == 'Bourbonnais') {
      return CustomIcons.track_bourbonnais;
    } else if (trackName == 'Carole') {
      return CustomIcons.track_carole;
    } else if (trackName == 'Dijon-Prenois') {
      return CustomIcons.track_dijon_prenois;
    } else if (trackName == 'La Ferté-Gaucher') {
      return CustomIcons.track_la_ferte_gaucher;
    } else if (trackName == 'Le Mans') {
      return CustomIcons.track_le_mans;
    } else if (trackName == 'Lédenon') {
      return CustomIcons.track_ledenon;
    } else if (trackName == 'Magny-Cours') {
      return CustomIcons.track_magny_cours;
    } else if (trackName == 'Vaison') {
      return CustomIcons.track_vaison;
    } else {
      return CustomIcons.track_sample;
    }
  }
}
