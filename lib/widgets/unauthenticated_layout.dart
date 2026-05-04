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

import 'package:ccteam/widgets/ccteam_logo.dart';
import 'package:flutter/material.dart';

/// Shared layout for the unauthenticated screens (email, registration,
/// OTP, passcode, etc.) so they all look consistent.
///
/// Vertical structure:
///  - Logo at the top
///  - Title (and optional description) just below the logo
///  - Form / body centered in the available middle space
///  - Action buttons anchored at the bottom
///
/// The layout adapts to the screen height: on tall screens the extra space
/// is distributed equally above and below the body; on small screens (or
/// when the keyboard is open) the content becomes scrollable so nothing is
/// ever clipped.
class UnauthenticatedLayout extends StatelessWidget {
  final String title;
  final Widget? description;
  final Widget body;
  final List<Widget> actions;
  final double logoHeight;

  const UnauthenticatedLayout({
    Key? key,
    required this.title,
    this.description,
    required this.body,
    this.actions = const [],
    this.logoHeight = 150.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // top: logo
                    CCTeamLogo(
                      height: logoHeight,
                      padding: const EdgeInsets.fromLTRB(48, 32, 48, 16),
                    ),
                    // title + optional description below the logo
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 12.0),
                      DefaultTextStyle.merge(
                        style: const TextStyle(color: Colors.black87),
                        textAlign: TextAlign.center,
                        child: description!,
                      ),
                    ],
                    // form / body, centered in the remaining space
                    const Spacer(),
                    const SizedBox(height: 8.0),
                    body,
                    const SizedBox(height: 8.0),
                    const Spacer(),
                    // action buttons at the bottom
                    ...actions,
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
