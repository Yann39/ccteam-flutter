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

/// Global navigator key. Used as `MaterialApp.navigatorKey` so anywhere
/// in the codebase (including non-widget code such as utility functions
/// and GraphQL error handlers) can reach the navigator state and the
/// current build context — typically to push routes or to look up
/// providers via `Provider.of(navigatorKey.currentContext!)`.
///
/// Lives in its own file so it can be imported from both `main.dart`
/// and helper modules without creating import cycles back into the
/// main entry point.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Global scaffold messenger key. Used as `MaterialApp.scaffoldMessengerKey`
/// so providers can dismiss/show snackbars without a `BuildContext` —
/// typically to clear a stale error notification (e.g. a "bad
/// credentials" snackbar from a failed login) when the auth state
/// transitions and the user lands on the home page.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
