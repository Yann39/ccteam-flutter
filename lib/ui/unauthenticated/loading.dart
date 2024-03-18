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

import 'package:ccteam/utils/custom_decorations.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class Loading extends StatelessWidget {
  final Logger _log = new Logger('Loading');

  Widget build(BuildContext context) {
    _log.info("Building Loading...");

    return Scaffold(
      key: Key("loadingPage"),
      body: Container(
        decoration: CustomDecorations.bluePurpleGradient,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                  height: 20.0,
                  width: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
