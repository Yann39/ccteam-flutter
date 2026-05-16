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

/// Organizer of one or more events. Was previously a free-text String
/// stored directly on Event; promoted to its own model so the same
/// organizer can be referenced from multiple events without duplicating
/// its name. Kept minimal, just id + name for now.
class Organizer {
  int? id;
  String? name;

  Organizer({this.id, this.name});

  @override
  String toString() => "{ id: ${id.toString()}, name: $name }";

  Organizer.fromJson(Map<String, dynamic> json)
    : id = json['id'] != null ? int.parse(json['id'].toString()) : null,
      name = json['name'];

  Map<String, dynamic> toJson() => {"id": id?.toString(), "name": name};
}
