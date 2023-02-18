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

import 'package:chachatte_team/utils/custom_graphql_exception.dart';
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

  /// Handle exception encountered during a GraphQL request.
  /// It parses the specified [QueryResult] and return the appropriate exception.
  static Exception handleGraphQlException(QueryResult result) {
    // error encountered during execution
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
}
