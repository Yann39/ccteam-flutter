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
import 'package:flutter_svg/svg.dart';

/// Loading indicator widget
class CCTeamLogo extends StatelessWidget {
  final double? height;
  final EdgeInsetsGeometry padding;

  const CCTeamLogo({Key? key, this.height, this.padding = const EdgeInsets.fromLTRB(48, 64, 48, 16)}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: SvgPicture.asset(
        'images/app_logos/ccteam_logo_vertical_red_white.svg',
        width: height,
        fit: BoxFit.fitHeight,
      ),
    );
  }
}
