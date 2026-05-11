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

import 'package:ccteam/utils/enums.dart';
import 'package:flutter/material.dart';

/// Loading indicator widget
class LoadingContent extends StatelessWidget {
  const LoadingContent({
    Key? key,
    required this.defaultText,
    required this.emptyText,
    required this.child,
    required this.loadingStatus,
  }) : super(key: key);

  final String defaultText;
  final String emptyText;
  final Widget child;
  final LoadingStatus loadingStatus;

  static final Widget _loader = Center(child: SizedBox(child: CircularProgressIndicator(), height: 20.0, width: 20.0));

  /// Centered, padded text used for the `notLoaded` and `empty` states.
  Widget _centeredMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loadingStatus == LoadingStatus.notLoaded) {
      return _centeredMessage(defaultText);
    } else if (loadingStatus == LoadingStatus.loading) {
      return _loader;
    } else if (loadingStatus == LoadingStatus.empty) {
      return _centeredMessage(emptyText);
    } else {
      return child;
    }
  }
}
