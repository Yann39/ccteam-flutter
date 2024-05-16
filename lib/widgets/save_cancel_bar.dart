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

import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';

/// Bottom action bar with cancel and save buttons, stuck to the bottom of the screen
class SaveCancelBar extends StatelessWidget {
  const SaveCancelBar({Key? key, required this.cancelFunction, required this.saveFunction}) : super(key: key);

  final VoidCallback cancelFunction;
  final VoidCallback saveFunction;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      height: 50,
      bottom: 0,
      left: 0,
      right: 0,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red[700],
                shape: LinearBorder(),
                fixedSize: Size.fromHeight(50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, color: Colors.white, size: 15),
                  SizedBox(width: 5),
                  Text(
                    AppString.cancel.toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              onPressed: cancelFunction,
            ),
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue[700],
                shape: LinearBorder(),
                fixedSize: Size.fromHeight(50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, color: Colors.white, size: 15),
                  SizedBox(width: 5),
                  Text(
                    AppString.save.toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              onPressed: saveFunction,
            ),
          ),
        ],
      ),
    );
  }
}
