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

/// A device the member has verified and trusts for passcode-only login.
class TrustedDevice {
  final int id;
  final String? label;
  final DateTime? createdOn;
  final DateTime? lastUsedOn;

  /// Whether this is the device currently making the request.
  final bool current;

  TrustedDevice({
    required this.id,
    this.label,
    this.createdOn,
    this.lastUsedOn,
    this.current = false,
  });

  TrustedDevice.fromJson(Map<String, dynamic> json)
    : id = int.parse(json['id'].toString()),
      label = json['label'],
      createdOn = json['createdOn'] != null ? DateTime.parse(json['createdOn']) : null,
      lastUsedOn = json['lastUsedOn'] != null ? DateTime.parse(json['lastUsedOn']) : null,
      current = json['current'] == true;
}
