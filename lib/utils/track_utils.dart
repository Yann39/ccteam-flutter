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

import 'package:ccteam/models/circuit.dart';
import 'package:ccteam/models/track.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:flutter/material.dart';

/// Track utility functions
class TrackUtils {
  /// Map / shape icon for a track (version): its explicit [Track.iconKey] when
  /// set, otherwise derived from the parent circuit name so existing circuits
  /// keep their icon without any per-version configuration.
  static IconData iconForTrack(Track? track) {
    return trackIconFromName(track?.iconKey ?? track?.circuit?.name);
  }

  /// Cover image for a circuit (venue). The cover is shared by every version,
  /// so it is keyed on the circuit name.
  static String coverImageForCircuit(Circuit? circuit) {
    return trackCoverImageUrlFromName(circuit?.name);
  }

  /// Get the right track icon according to the specified [trackName]
  static IconData trackIconFromName(String? trackName) {
    if (trackName == 'Alès') {
      return CustomIcons.ales_track;
    } else if (trackName == 'Barcelone') {
      return CustomIcons.barcelone_track;
    } else if (trackName == 'Bresse') {
      return CustomIcons.bresse_track;
    } else if (trackName == 'Bourbonnais') {
      return CustomIcons.bourbonnais_track;
    } else if (trackName == 'Carole') {
      return CustomIcons.carole_track;
    } else if (trackName == 'Dijon-Prenois') {
      return CustomIcons.dijon_prenois_track;
    } else if (trackName == 'La Ferté-Gaucher') {
      return CustomIcons.la_ferte_gaucher_track;
    } else if (trackName == 'Le Mans') {
      return CustomIcons.le_mans_track;
    } else if (trackName == 'Lédenon') {
      return CustomIcons.ledenon_track;
    } else if (trackName == 'Magny-Cours') {
      return CustomIcons.magny_cours_track;
    } else if (trackName == 'Mirecourt') {
      return CustomIcons.mirecourt_track;
    } else if (trackName == 'Misano') {
      return CustomIcons.misano_track;
    } else if (trackName == 'Paul Ricard' || trackName == 'paul_ricard_38_track') {
      return CustomIcons.paul_ricard_38_track;
    } else if (trackName == 'paul_ricard_58_track)') {
      return CustomIcons.paul_ricard_58_track;
    } else if (trackName == 'Portimão') {
      return CustomIcons.portimao_track;
    } else if (trackName == 'Pouilly-en-Auxois') {
      return CustomIcons.pouilly_en_auxois_track;
    } else if (trackName == 'Vaison') {
      return CustomIcons.vaison_track;
    } else {
      return CustomIcons.default_track;
    }
  }

  /// Map a [TrackCondition] enum name (as stored on `Record.conditions`)
  /// to a representative weather icon. Returns `null` when the condition
  /// is unknown / not set — callers should treat that as "don't render
  /// anything" rather than fall back to a default, so missing data
  /// stays visibly missing.
  static IconData? trackConditionIconData(String? condition) {
    switch (condition) {
      case 'dry':
        return Icons.wb_sunny;
      case 'drying':
        return Icons.wb_cloudy;
      case 'wet':
        return Icons.water_drop;
      default:
        return null;
    }
  }

  /// Companion color for the icon returned by [trackConditionIconData].
  /// Picks a tone that matches the weather metaphor (warm for dry, cool
  /// for wet, neutral for drying).
  static Color trackConditionColor(String? condition) {
    switch (condition) {
      case 'dry':
        return Colors.amber;
      case 'drying':
        return Colors.blueGrey[300]!;
      case 'wet':
        return Colors.lightBlue[300]!;
      default:
        return Colors.white;
    }
  }

  /// Get the right track cover image according to the specified [trackName]
  static String trackCoverImageUrlFromName(String? trackName) {
    if (trackName == 'Alès') {
      return "images/tracks/ales_cover.jpg";
    } else if (trackName == 'Barcelone') {
      return "images/tracks/barcelone_cover.jpg";
    } else if (trackName == 'Bresse') {
      return "images/tracks/bresse_cover.jpg";
    } else if (trackName == 'Bourbonnais') {
      return "images/tracks/bourbonnais_cover.jpg";
    } else if (trackName == 'Carole') {
      return "images/tracks/carole_cover.jpg";
    } else if (trackName == 'Dijon-Prenois') {
      return "images/tracks/dijon-prenois_cover.jpg";
    } else if (trackName == 'La Ferté-Gaucher') {
      return "images/tracks/la-ferte-gaucher_cover.jpg";
    } else if (trackName == 'Le Mans') {
      return "images/tracks/le-mans_cover.jpg";
    } else if (trackName == 'Lédenon') {
      return "images/tracks/ledenon_cover.jpg";
    } else if (trackName == 'Magny-Cours') {
      return "images/tracks/magny-cours_cover.jpg";
    } else if (trackName == 'Mirecourt') {
      return "images/tracks/mirecourt_cover.jpg";
    } else if (trackName == 'Misano') {
      return "images/tracks/misano_cover.jpg";
    } else if (trackName == 'Paul Ricard') {
      return "images/tracks/paul-ricard_cover.jpg";
    } else if (trackName == 'Portimão') {
      return "images/tracks/portimao_cover.jpg";
    } else if (trackName == 'Pouilly-en-Auxois') {
      return "images/tracks/pouilly-en-auxois_cover.jpg";
    } else if (trackName == 'Vaison') {
      return "images/tracks/vaison_cover.jpg";
    } else {
      return "images/tracks/default_cover.jpg";
    }
  }
}
