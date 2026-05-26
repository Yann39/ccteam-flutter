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

import 'dart:async';

import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/utils/custom_graphql_exception.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/navigator_key.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Application utility functions.
class AppUtils {
  static final Logger _log = new Logger('AppUtils');

  /// Launch the specified [url] in an external application (browser, maps,
  /// etc.). Skips [canLaunchUrl] (unreliable across platforms / package
  /// visibility) and logs failures instead of throwing silently.
  static Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        _log.warning("launchUrl returned false for $url");
      }
    } catch (e, stack) {
      _log.severe("Failed to launch $url", e, stack);
    }
  }

  /// Launch mailto link for the specified [email].
  static Future<void> mailTo(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e, stack) {
      _log.severe("Failed to launch mailto:$email", e, stack);
    }
  }

  /// Handle exception encountered during a GraphQL request.
  /// It parses the specified [QueryResult] and return the appropriate exception.
  ///
  /// When the parsed exception turns out to be a `token_expired`
  /// [CustomGraphQlException], this method ALSO triggers the global
  /// session-expired flow (see [_triggerSessionExpiredIfNeeded]). That
  /// way, regardless of how the caller handles the returned exception
  /// (provider with `handleServiceException`, raw `FutureBuilder`,
  /// `.then(onError:)` callback, ...), the user is uniformly redirected
  /// to the passcode screen the next time the backend reports the JWT
  /// as expired.
  static Exception? handleGraphQlException(QueryResult result) {
    final Exception? exception = _parseGraphQlException(result);
    _triggerSessionExpiredIfNeeded(exception);
    return exception;
  }

  /// Inner pure parser — no side effects, just returns the most
  /// specific exception we can build from the [QueryResult].
  static Exception? _parseGraphQlException(QueryResult result) {
    // error encountered during execution such as network or cache errors
    if (result.exception?.linkException != null) {
      // network exception, usually server down or not accessible
      if (result.exception?.linkException is NetworkException) {
        // simply return the network exception
        return result.exception?.linkException;
      }
      // server exception, usually invalid or expired token
      else if (result.exception?.linkException is ServerException) {
        // try to get first GraphQL error
        final GraphQLError? first = (result.exception?.linkException as ServerException).parsedResponse?.errors?.first;
        if (first != null) {
          // custom GraphQl exception from our server should return an error code
          _log.info("message : ${first.message}, errorCode : ${first.extensions!["errorCode"]}");
          return CustomGraphQlException(first.extensions!["errorCode"], first.message);
        }
        // simply return the server exception
        return result.exception?.linkException;
      }
      // any other link exception
      else {
        return result.exception?.linkException;
      }
    }
    // error encountered during operation
    else if (result.exception?.graphqlErrors != null && result.exception!.graphqlErrors.isNotEmpty) {
      final GraphQLError first = result.exception!.graphqlErrors.first;
      // custom GraphQl exception from our server should return an error code
      _log.info("message : ${first.message}, errorCode : ${first.extensions!["errorCode"]}");
      return CustomGraphQlException(first.extensions!["errorCode"], first.message);
    }
    // any other error
    else {
      return Exception(result.exception.toString());
    }
  }

  /// If [exception] signals a stale authenticated session, either
  /// `token_expired` (JWT past its TTL) or `access_denied` (JWT still
  /// valid but its role claim no longer matches what the backend
  /// allows, typical after an admin role change), schedule a global
  /// SESSION_EXPIRED message on the [MessageProvider] (via the
  /// navigator key's current context). This makes the Consumer in
  /// `main.dart` pop up the re-authentication dialog and redirect to
  /// the passcode screen — regardless of who catches the exception
  /// or whether `handleServiceException` is called at all.
  static void _triggerSessionExpiredIfNeeded(Exception? exception) {
    if (exception is! CustomGraphQlException) return;
    final bool isStaleSession = exception.code == "token_expired" || exception.code == "access_denied";
    if (!isStaleSession) return;

    // defer to the next frame: we might be inside a build / setState
    // path right now (services are called from providers, themselves
    // observed by widgets), so directly calling notifyListeners on
    // MessageProvider would risk a "setState during build" error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? ctx = navigatorKey.currentContext;
      if (ctx == null) return;
      final MessageProvider messageProvider = Provider.of<MessageProvider>(ctx, listen: false);
      // skip if we've already fired the SESSION_EXPIRED flow, the
      // dialog is still up (waiting for the user) and we don't want to
      // stack a second one on top of it
      if (messageProvider.messageType == MessageType.SESSION_EXPIRED) {
        return;
      }
      final String label =
          exception.code == "access_denied" ? AppString.errorRoleChanged : AppString.errorTokenExpired;
      messageProvider.setMessage(label, MessageType.SESSION_EXPIRED);
    });
  }

  /// Handle specified [error] from service call.
  static void handleServiceException(dynamic error, MessageProvider messageProvider, LoginProvider loginProvider) {
    if (error is CustomGraphQlException) {
      if (error.code == "token_expired") {
        messageProvider.setMessage(AppString.errorTokenExpired, MessageType.SESSION_EXPIRED);
      } else if (error.code == "access_denied") {
        messageProvider.setMessage(AppString.errorRoleChanged, MessageType.SESSION_EXPIRED);
      } else if (error.code == "wrong_token_format") {
        messageProvider.setMessage(AppString.errorTokenWrongFormat, MessageType.ERROR);
        loginProvider.logoutMember();
      } else if (error.code == "no_token") {
        messageProvider.setMessage(AppString.errorTokenNotFound, MessageType.ERROR);
        loginProvider.logoutMember();
      } else if (error.code == "bad_credentials") {
        messageProvider.setMessage(AppString.errorBadCredentials, MessageType.ERROR);
        loginProvider.logoutMember();
      } else if (error.code == "internal_error") {
        messageProvider.setMessage(AppString.errorServerInternal, MessageType.ERROR);
      } else {
        messageProvider.setMessage(AppString.format(AppString.errorUnknown, [error.message!]), MessageType.ERROR);
      }
    } else if (error is TimeoutException) {
      messageProvider.setMessage(AppString.errorServerTimeOut, MessageType.ERROR);
    } else {
      messageProvider.setMessage(AppString.format(AppString.errorUnknown, [error.toString()]), MessageType.ERROR);
    }
  }
}
