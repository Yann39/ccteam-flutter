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

import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum QuickActions { about, contact, logout }

class MainActionMenu extends StatelessWidget {
  /// Launch URL to contact user
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Handle menu item click
  void _select(QuickActions choice) async {
    if (choice == QuickActions.contact) {
      _launchURL("mailto:rockyracer@mailfence.com");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<QuickActions>(
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<QuickActions>(
            child: Text(AppString.about),
            value: QuickActions.about,
          ),
          PopupMenuItem<QuickActions>(
            child: Text(AppString.contact),
            value: QuickActions.contact,
          ),
        ];
      },
      onSelected: _select,
    );
  }
}
