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

/// A widget that display a loading indicator when the specified condition is met.
/// It is designed to be used in buttons.
class LoadingButtonText extends StatelessWidget {
  const LoadingButtonText({Key key, this.text, this.loaderCondition}) : super(key: key);

  final Text text;
  final bool loaderCondition;

  static final Widget _loader = Center(
    child: SizedBox(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 2.0,
      ),
      height: 14.0,
      width: 14.0,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return loaderCondition ? _loader : text;
  }
}
