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

import 'package:ccteam/models/country.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';

/// Network layer for the Country GraphQL endpoint. Read-only, the
/// country reference table is seeded server-side and not edited from
/// the app.
class CountriesService {
  static final Logger _log = new Logger('CountriesService');

  /// Fetch every country (sorted by French name server-side). Used by
  /// the track creation/edit form to populate the country picker.
  Future<List<Country>> fetchCountries() async {
    _log.info("Getting all countries from database...");

    final String query = """
      query GetAllCountries {
        getAllCountries {
          code
          nameFr
          nameEn
        }
      }
    """;

    final QueryResult result = await GraphQLConnection().graphQLClient.query(
      QueryOptions(document: parseString(query), fetchPolicy: FetchPolicy.noCache),
    );

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    }
    final List<Country> countries = <Country>[];
    final dynamic list = result.data?['getAllCountries'];
    if (list is Iterable) {
      for (final dynamic item in list) {
        countries.add(Country.fromJson(item));
      }
    }
    return countries;
  }
}
