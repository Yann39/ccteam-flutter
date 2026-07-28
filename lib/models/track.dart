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
import 'package:ccteam/models/country.dart';

/// Class representing a track, a single version (layout) of a [Circuit], e.g.
/// the 5.8 km GP layout, the 3.8 km short layout, or a reversed direction. The
/// venue-level identity (name, country, GPS, website) lives on the parent
/// [Circuit]; a track only carries what is specific to the version. Chronos and
/// events reference a track, so a lap time is always tied to a version.
class Track {
  int? id;

  /// Parent circuit (venue) this version belongs to.
  Circuit? circuit;

  /// Version / layout label within the circuit (e.g. "5,8 km GP", "Sens inversé").
  /// Null or empty when the circuit has a single version.
  String? variantName;

  int? distance;
  int? lapRecord;

  /// Free-form context about the lap record (rider, bike, year, …).
  String? lapRecordInfo;

  /// Key selecting the version's map/shape icon (see [TrackUtils]); null falls
  /// back to the circuit's default icon.
  String? iconKey;

  Track({
    this.id,
    this.circuit,
    this.variantName,
    this.distance,
    this.lapRecord,
    this.lapRecordInfo,
    this.iconKey,
  });

  /// Shallow copy constructor used by the edit flow to avoid mutating the
  /// original [Track] referenced by the list / detail provider when the user
  /// cancels the form.
  Track.clone(Track track)
    : this.id = track.id,
      this.circuit = track.circuit,
      this.variantName = track.variantName,
      this.distance = track.distance,
      this.lapRecord = track.lapRecord,
      this.lapRecordInfo = track.lapRecordInfo,
      this.iconKey = track.iconKey;

  /// Full display label for this version: the circuit name, followed by the
  /// version label when the circuit has more than one version
  /// (e.g. "Circuit Paul Ricard — 5,8 km GP").
  String get displayName {
    final String base = circuit?.name ?? '';
    final String variant = variantName?.trim() ?? '';
    if (variant.isNotEmpty) {
      return base.isEmpty ? variant : "$base — $variant";
    }
    return base;
  }

  /// Back-compat convenience: many views read `track.name` as the label to
  /// show. Returns the [displayName], or null when nothing is known yet.
  String? get name {
    final String label = displayName;
    return label.isEmpty ? null : label;
  }

  /// Venue attributes, delegated to the parent [circuit] so the many views
  /// that read them straight off a track keep working.
  Country? get country => circuit?.country;

  double? get latitude => circuit?.latitude;

  double? get longitude => circuit?.longitude;

  String? get website => circuit?.website;

  @override
  String toString() {
    return """{
      id: ${this.id.toString()},
      circuit: ${this.circuit?.name},
      variantName: ${this.variantName},
      distance: ${this.distance},
      lapRecord: ${this.lapRecord},
      lapRecordInfo: ${this.lapRecordInfo},
      iconKey: ${this.iconKey},
    }""";
  }

  /// Convert [json] map to the corresponding object
  Track.fromJson(Map<String, dynamic> json)
    : id = json['id'] != null ? int.parse(json['id'].toString()) : null,
      circuit = json['circuit'] != null
          ? Circuit.fromJson(json['circuit'])
          : null,
      variantName = json['variantName'],
      distance = json['distance'] != null ? json['distance'] : null,
      lapRecord = json['lapRecord'] != null ? json['lapRecord'] : null,
      lapRecordInfo = json['lapRecordInfo'],
      iconKey = json['iconKey'];

  /// Convert [Track] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
    "id": id.toString(),
    "circuit": circuit?.toJson(),
    "variantName": variantName,
    "distance": distance,
    "lapRecord": lapRecord,
    "lapRecordInfo": lapRecordInfo,
    "iconKey": iconKey,
  };

  /// Override == operator to compare tracks by id
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
