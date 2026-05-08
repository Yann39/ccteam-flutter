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

import 'package:ccteam/models/bike.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';

/// Service that handles bike related operations
class BikesService {
  final Logger _log = new Logger('BikesService');

  /// Add a new bike for the specified [memberId].
  Future<Bike> addBike(int memberId, Bike bike) async {
    _log.info("Adding bike for member $memberId ...");

    final String query = """
      mutation AddBikeToMember(\$memberId: Long!, \$manufacturer: String!, \$modelName: String!, \$engineSize: Int, \$year: Int) {
        addBikeToMember(
          memberId: \$memberId
          manufacturer: \$manufacturer
          modelName: \$modelName
          engineSize: \$engineSize
          year: \$year
        ) {
          id
          manufacturer
          modelName
          engineSize
          year
          current
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(query),
      variables: {
        'memberId': memberId,
        'manufacturer': bike.manufacturer,
        'modelName': bike.modelName,
        'engineSize': bike.engineSize,
        'year': bike.year,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(
      mutationOptions,
    );

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Bike.fromJson(result.data!['addBikeToMember']);
    }
  }

  /// Update the specified [bike].
  Future<Bike> updateBike(Bike bike) async {
    _log.info("Updating bike ${bike.id} ...");

    final String query = """
      mutation UpdateBike(\$bikeId: Long!, \$manufacturer: String!, \$modelName: String!, \$engineSize: Int, \$year: Int, \$current: Boolean) {
        updateBike(
          bikeId: \$bikeId
          manufacturer: \$manufacturer
          modelName: \$modelName
          engineSize: \$engineSize
          year: \$year
          current: \$current
        ) {
          id
          manufacturer
          modelName
          engineSize
          year
          current
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(query),
      variables: {
        'bikeId': bike.id,
        'manufacturer': bike.manufacturer,
        'modelName': bike.modelName,
        'engineSize': bike.engineSize,
        'year': bike.year,
        'current': bike.current,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(
      mutationOptions,
    );

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Bike.fromJson(result.data!['updateBike']);
    }
  }

  /// Delete the specified bike with the given [bikeId].
  Future<Bike> deleteBike(int bikeId) async {
    _log.info("Deleting bike $bikeId ...");

    final String query = """
      mutation DeleteBike(\$bikeId: Long!) {
        deleteBike(
          bikeId: \$bikeId
        ) {
          id
          manufacturer
          modelName
          engineSize
          year
          current
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(query),
      variables: {'bikeId': bikeId},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(
      mutationOptions,
    );

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Bike.fromJson(result.data!['deleteBike']);
    }
  }
}
