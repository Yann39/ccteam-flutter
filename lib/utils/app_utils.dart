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

import 'dart:async';

import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/providers/message_provider.dart';
import 'package:chachatte_team/utils/custom_graphql_exception.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

/// Application utility functions.
class AppUtils {
  static final Logger _log = new Logger('AppUtils');

  /// Launch the specified [url].
  static void launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Return the message string from a given [Exception].
  /// By default the [Exception]'s [toString] method appends "Exception: " string before the message,
  /// so simply remove it.
  static String extractExceptionMessage(Exception exception) {
    return exception.toString().substring(11);
  }

  /// Handle exception encountered during a GraphQL request.
  /// It parses the specified [QueryResult] and return the appropriate exception.
  static Exception handleGraphQlException(QueryResult result) {
    // error encountered during execution such as network or cache errors
    if (result.exception.linkException != null) {
      // network exception, usually server down or not accessible
      if (result.exception.linkException is NetworkException) {
        // simply return the network exception
        return result.exception.linkException;
      }
      // server exception, usually invalid or expired token
      else if (result.exception.linkException is ServerException) {
        // try to get first GraphQL error
        final GraphQLError first = (result.exception.linkException as ServerException)?.parsedResponse?.errors?.first;
        if (first != null) {
          // custom GraphQl exception from our server should return an error code
          _log.info("message : ${first.message}, errorCode : ${first.extensions["errorCode"]}");
          return CustomGraphQlException(first.extensions["errorCode"], first.message);
        }
        // simply return the server exception
        return result.exception.linkException;
      }
      // any other link exception
      else {
        return result.exception.linkException;
      }
    }
    // error encountered during operation
    else if (result.exception.graphqlErrors != null && result.exception.graphqlErrors.isNotEmpty) {
      final GraphQLError first = result.exception.graphqlErrors.first;
      // custom GraphQl exception from our server should return an error code
      _log.info("message : ${first.message}, errorCode : ${first.extensions["errorCode"]}");
      return CustomGraphQlException(first.extensions["errorCode"], first.message);
    }
    // any other error
    else {
      return Exception(result.exception.toString());
    }
  }

  /// Handle specified [error] from service call.
  static void handleServiceException(dynamic error, MessageProvider messageProvider, LoginProvider loginProvider) {
    if (error is CustomGraphQlException) {
      if (error.code == "token_expired") {
        messageProvider.setMessage(AppString.errorTokenExpired, MessageType.INFO);
        loginProvider.logoutMember();
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
        messageProvider.setMessage(AppString.format(AppString.errorUnknown, [error.message]), MessageType.ERROR);
      }
    } else if (error is TimeoutException) {
      messageProvider.setMessage(AppString.errorServerTimeOut, MessageType.ERROR);
    } else {
      messageProvider.setMessage(AppString.format(AppString.errorUnknown, [error.toString()]), MessageType.ERROR);
    }
  }

}
