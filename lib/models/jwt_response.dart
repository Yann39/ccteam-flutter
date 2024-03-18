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

/// Class representing a JWT response
class JwtResponse {
  String jwtToken;

  JwtResponse({
    this.jwtToken,
  });

  @override
  String toString() {
    return "{jwtToken: ${this.jwtToken}}";
  }

  JwtResponse.fromJson(Map<String, dynamic> json) : jwtToken = json['jwtToken'];

  Map<String, dynamic> toJson() => {
        'jwtToken': jwtToken,
      };
}
