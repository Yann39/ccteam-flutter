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

import 'package:ccteam/models/bike_equipment.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';

/// Service that handles the equipments of a bike.
///
/// Every operation returns the whole, fresh list of equipments of the bike, so the caller simply replaces what it
/// displays.
class BikeEquipmentService {
  final Logger _log = new Logger('BikeEquipmentService');

  /// Selection set of the `BikeEquipment` type, shared by every operation.
  static const String _equipmentFields = """
    id
    designation
    price
    currency
    comment
  """;

  /// Get the equipments of the bike with the given [bikeId].
  Future<List<BikeEquipment>> getBikeEquipments(int bikeId) async {
    _log.info("Getting equipments of bike $bikeId ...");

    final String query =
        """
      query GetBikeEquipments(\$bikeId: Long!) {
        getBikeEquipments(bikeId: \$bikeId) {
          $_equipmentFields
        }
      }
    """;

    final QueryOptions options = new QueryOptions(
      document: parseString(query),
      variables: {'bikeId': bikeId},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.query(options);
    return _parse(result, 'getBikeEquipments');
  }

  /// Add the given [equipment] to the bike with the given [bikeId].
  Future<List<BikeEquipment>> createBikeEquipment(int bikeId, BikeEquipment equipment) async {
    _log.info("Adding equipment to bike $bikeId ...");

    final String query =
        """
      mutation CreateBikeEquipment(\$bikeId: Long!, \$designation: String!, \$price: Float, \$currency: CurrencyCode!, \$comment: String) {
        createBikeEquipment(
          bikeId: \$bikeId
          designation: \$designation
          price: \$price
          currency: \$currency
          comment: \$comment
        ) {
          $_equipmentFields
        }
      }
    """;

    return _mutate(query, 'createBikeEquipment', {'bikeId': bikeId, ..._equipmentVariables(equipment)});
  }

  /// Update the given [equipment].
  Future<List<BikeEquipment>> updateBikeEquipment(BikeEquipment equipment) async {
    _log.info("Updating equipment ${equipment.id} ...");

    final String query =
        """
      mutation UpdateBikeEquipment(\$equipmentId: Long!, \$designation: String!, \$price: Float, \$currency: CurrencyCode!, \$comment: String) {
        updateBikeEquipment(
          equipmentId: \$equipmentId
          designation: \$designation
          price: \$price
          currency: \$currency
          comment: \$comment
        ) {
          $_equipmentFields
        }
      }
    """;

    return _mutate(query, 'updateBikeEquipment', {'equipmentId': equipment.id, ..._equipmentVariables(equipment)});
  }

  /// Delete the equipment with the given [equipmentId].
  Future<List<BikeEquipment>> deleteBikeEquipment(int equipmentId) async {
    _log.info("Deleting equipment $equipmentId ...");

    final String query =
        """
      mutation DeleteBikeEquipment(\$equipmentId: Long!) {
        deleteBikeEquipment(equipmentId: \$equipmentId) {
          $_equipmentFields
        }
      }
    """;

    return _mutate(query, 'deleteBikeEquipment', {'equipmentId': equipmentId});
  }

  /// Reorder the equipments of the bike with the given [bikeId], [equipmentIds] holding all their ids in the new order.
  Future<List<BikeEquipment>> reorderBikeEquipments(int bikeId, List<int> equipmentIds) async {
    _log.info("Reordering equipments of bike $bikeId ...");

    final String query =
        """
      mutation ReorderBikeEquipments(\$bikeId: Long!, \$equipmentIds: [Long!]!) {
        reorderBikeEquipments(bikeId: \$bikeId, equipmentIds: \$equipmentIds) {
          $_equipmentFields
        }
      }
    """;

    return _mutate(query, 'reorderBikeEquipments', {'bikeId': bikeId, 'equipmentIds': equipmentIds});
  }

  Map<String, dynamic> _equipmentVariables(BikeEquipment equipment) => {
    'designation': equipment.designation,
    'price': equipment.price,
    'currency': equipment.currency.code,
    'comment': equipment.comment,
  };

  Future<List<BikeEquipment>> _mutate(String query, String field, Map<String, dynamic> variables) async {
    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(query),
      variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);
    return _parse(result, field);
  }

  List<BikeEquipment> _parse(QueryResult result, String field) {
    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    }
    return ((result.data![field] as List?) ?? const [])
        .map((e) => BikeEquipment.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
