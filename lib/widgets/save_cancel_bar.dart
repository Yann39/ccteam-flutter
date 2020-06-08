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

/// Bottom action bar with cancel and save buttons, stuck to the bottom of the screen
class SaveCancelBar extends StatelessWidget {
  const SaveCancelBar({Key key, this.cancelFunction, this.saveFunction}) : super(key: key);

  final Function cancelFunction;
  final Function saveFunction;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.0),
        decoration: BoxDecoration(color: Colors.red[700]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                child: Text(
                  AppString.cancel.toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: cancelFunction,
              ),
            ),
            Expanded(
              child: FlatButton(
                child: Text(
                  AppString.save.toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: saveFunction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
