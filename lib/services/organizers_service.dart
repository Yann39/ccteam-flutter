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

import 'package:ccteam/models/organizer.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';

/// Network layer for the Organizer GraphQL endpoints. Mirrors the
/// shape of the other small services (bikes, tracks, …), single
/// service class with one method per GraphQL operation.
class OrganizersService {
  static final Logger _log = new Logger('OrganizersService');

  /// Fetch every organizer, sorted by name (server-side). Used by the
  /// event-creation/edit picker to populate the dropdown.
  Future<List<Organizer>> fetchOrganizers() async {
    _log.info("Getting all organizers from database...");

    final String query = """
      query GetAllOrganizers {
        getAllOrganizers {
          id
          name
        }
      }
    """;

    final QueryResult result = await GraphQLConnection().graphQLClient.query(
      QueryOptions(document: parseString(query), fetchPolicy: FetchPolicy.noCache),
    );

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    }
    final List<Organizer> organizers = [];
    final dynamic list = result.data?['getAllOrganizers'];
    if (list is Iterable) {
      for (final dynamic item in list) {
        organizers.add(Organizer.fromJson(item));
      }
    }
    return organizers;
  }

  /// Create a new organizer from a free-text name. Server-side trims,
  /// rejects empty values, and refuses to create a duplicate (case
  /// insensitive). On duplicate the server returns the
  /// `organizer_already_exists` error code, surfaced as a regular
  /// exception here for the caller to message accordingly.
  Future<Organizer> createOrganizer(String name) async {
    _log.info("Creating organizer with name '$name'...");

    final String mutation = """
      mutation CreateOrganizer(\$name: String!) {
        createOrganizer(name: \$name) {
          id
          name
        }
      }
    """;

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: {'name': name},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(options);
    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    }
    return Organizer.fromJson(result.data!['createOrganizer']);
  }
}
