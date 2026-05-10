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

import 'package:flutter/material.dart';

/// Small instructional banner shown at the top of personal pages
/// ("Mes roulages", "Mes motos", "Mes chronos", …) to briefly explain
/// what the page lists and what the floating action button does.
///
/// Visually styled as a subtle white-tinted rounded card with a blue
/// `info_outline` icon and a thin blue border, so it blends with the
/// `mainContent` gradient background while still calling attention to
/// itself.
class InfoBanner extends StatelessWidget {
  final String message;

  const InfoBanner({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue[200]!, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, size: 18.0, color: Colors.blue[700]),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13.0, color: Colors.black.withValues(alpha: 0.75), height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
