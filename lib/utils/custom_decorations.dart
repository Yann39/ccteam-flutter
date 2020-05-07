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

import 'package:flutter/material.dart';

/// class that holds date utility functions
class CustomDecorations {

  /// Decoration for main content
  static BoxDecoration mainContent = BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue[100], Colors.blue[300]],
      begin: const FractionalOffset(0.0, 0.0),
      end: const FractionalOffset(0.0, 1.0),
      tileMode: TileMode.clamp,
    ),
  );

  /// Decoration for cards content
  static BoxDecoration cardFull = BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue[300], Colors.blue[500]],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 1.0],
    ),
    shape: BoxShape.rectangle,
    borderRadius: BorderRadius.circular(6.0),
  );

  /// Decoration for cards body content (for cards with header)
  static BoxDecoration cardBody = BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue[300], Colors.blue[500]],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 1.0],
    ),
    shape: BoxShape.rectangle,
    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6.0), bottomRight: Radius.circular(6.0)),
  );

}
