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

import 'package:ccteam/models/country.dart';
import 'package:ccteam/models/track.dart';

/// Class representing a circuit (venue). Holds the identity shared by every
/// version (layout) of a physical circuit: name, country, GPS coordinates and
/// website. The raceable unit — the one chronos and events reference — is the
/// [Track], which represents a single version of a circuit.
class Circuit {
  int? id;
  String? name;
  Country? country;
  double? latitude;
  double? longitude;
  String? website;

  /// Versions (layouts) available on this circuit.
  List<Track>? tracks;

  Circuit({
    this.id,
    this.name,
    this.country,
    this.latitude,
    this.longitude,
    this.website,
    this.tracks,
  });

  /// Shallow copy constructor used by the edit flow so cancelling the form
  /// doesn't mutate the original [Circuit] held by the list / detail provider.
  Circuit.clone(Circuit circuit)
    : this.id = circuit.id,
      this.name = circuit.name,
      this.country = circuit.country,
      this.latitude = circuit.latitude,
      this.longitude = circuit.longitude,
      this.website = circuit.website,
      this.tracks = circuit.tracks;

  @override
  String toString() {
    return """{
      id: ${this.id.toString()},
      name: ${this.name},
      country: ${this.country},
      latitude: ${this.latitude},
      longitude: ${this.longitude},
      website: ${this.website},
      tracks: ${this.tracks?.length ?? 0},
    }""";
  }

  /// Convert [json] map to the corresponding object. Each parsed version is
  /// back-linked to this circuit so `track.circuit` (and the display label /
  /// venue delegates it powers) resolves even when the version projection
  /// didn't repeat the circuit block.
  factory Circuit.fromJson(Map<String, dynamic> json) {
    final Circuit circuit = Circuit(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      name: json['name'],
      country: json['country'] != null
          ? Country.fromJson(json['country'])
          : null,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      website: json['website'],
    );
    if (json['tracks'] != null) {
      circuit.tracks = (json['tracks'] as List)
          .map((dynamic t) => Track.fromJson(t))
          .toList();
      for (final Track t in circuit.tracks!) {
        t.circuit = circuit;
      }
    }
    return circuit;
  }

  /// Convert [Circuit] object to the corresponding JSON map. The versions are
  /// intentionally omitted to keep the serialization acyclic (a version's JSON
  /// carries its circuit).
  Map<String, dynamic> toJson() => {
    "id": id.toString(),
    "name": name,
    "country": country?.toJson(),
    "latitude": latitude,
    "longitude": longitude,
    "website": website,
  };

  /// Compare circuits by id.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Circuit && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
