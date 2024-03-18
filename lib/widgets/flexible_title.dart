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

/// Animated title to be used in a [FlexibleSpaceBar]
/// The custom animation allow to bypass any object placed at the left, especially a circle image
class FlexibleTitle extends StatelessWidget {
  const FlexibleTitle({
    Key key,
    this.text,
    this.padding,
  }) : super(key: key);

  final String text;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final double deltaExtent = settings.maxExtent - settings.minExtent;
    final double t = (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent).clamp(0.0, 1.0) as double;
    final double scaleValue = Tween<double>(begin: 1.5, end: 1.0).transform(t);
    final double leftPadding = (scaleValue - 1) * (padding.left * (8.5 - scaleValue * 5));
    final double bottomPadding = (scaleValue - 1) * (padding.bottom * (8.5 - scaleValue * 5));
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: constraints.maxWidth,
        height: 100,
        child: Padding(
          padding: EdgeInsets.only(left: leftPadding, bottom: bottomPadding),
          child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      );
    });
  }
}
