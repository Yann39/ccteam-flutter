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

import 'package:ccteam/models/bike_maintenance.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';

/// Service that handles bike maintenance related operations (plan, maintenances, odometer).
///
/// Every operation returns the whole, fresh [BikeMaintenance] of the bike, so the caller simply replaces what it
/// displays (the next due date depends on the plan, the last maintenance and the odometer altogether).
class MaintenanceService {
  final Logger _log = new Logger('MaintenanceService');

  /// Selection set of the `BikeMaintenance` type, shared by every operation.
  static const String _bikeMaintenanceFields = """
    bikeId
    odometerKm
    odometerUpdatedOn
    plan {
      id
      intervalKm
      intervalMonths
    }
    maintenances {
      id
      maintenanceDate
      odometerKm
      resetsPlan
      comment
      operations {
        id
        type
        label
        price
        currency
      }
      totals {
        currency
        amount
      }
    }
    nextDue {
      status
      dueDate
      dueKm
      remainingDays
      remainingKm
    }
  """;

  /// Get the maintenance data of the bike with the given [bikeId].
  Future<BikeMaintenance> getBikeMaintenance(int bikeId) async {
    _log.info("Getting maintenance of bike $bikeId ...");

    final String query = """
      query GetBikeMaintenance(\$bikeId: Long!) {
        getBikeMaintenance(bikeId: \$bikeId) {
          $_bikeMaintenanceFields
        }
      }
    """;

    final QueryOptions options = new QueryOptions(
      document: parseString(query),
      variables: {'bikeId': bikeId},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.query(options);
    return _parse(result, 'getBikeMaintenance');
  }

  /// Define or replace the maintenance plan of the bike with the given [bikeId].
  Future<BikeMaintenance> setMaintenancePlan(int bikeId, int? intervalKm, int? intervalMonths) async {
    _log.info("Setting maintenance plan of bike $bikeId ...");

    final String query = """
      mutation SetMaintenancePlan(\$bikeId: Long!, \$intervalKm: Int, \$intervalMonths: Int) {
        setMaintenancePlan(bikeId: \$bikeId, intervalKm: \$intervalKm, intervalMonths: \$intervalMonths) {
          $_bikeMaintenanceFields
        }
      }
    """;

    return _mutate(query, 'setMaintenancePlan', {
      'bikeId': bikeId,
      'intervalKm': intervalKm,
      'intervalMonths': intervalMonths,
    });
  }

  /// Delete the maintenance plan of the bike with the given [bikeId].
  Future<BikeMaintenance> deleteMaintenancePlan(int bikeId) async {
    _log.info("Deleting maintenance plan of bike $bikeId ...");

    final String query = """
      mutation DeleteMaintenancePlan(\$bikeId: Long!) {
        deleteMaintenancePlan(bikeId: \$bikeId) {
          $_bikeMaintenanceFields
        }
      }
    """;

    return _mutate(query, 'deleteMaintenancePlan', {'bikeId': bikeId});
  }

  /// Record a new [maintenance] for the bike with the given [bikeId].
  Future<BikeMaintenance> createMaintenance(int bikeId, Maintenance maintenance) async {
    _log.info("Creating maintenance for bike $bikeId ...");

    final String query = """
      mutation CreateMaintenance(\$bikeId: Long!, \$maintenanceDate: String!, \$odometerKm: Int, \$resetsPlan: Boolean, \$comment: String, \$operations: [MaintenanceOperationInput!]!) {
        createMaintenance(
          bikeId: \$bikeId
          maintenanceDate: \$maintenanceDate
          odometerKm: \$odometerKm
          resetsPlan: \$resetsPlan
          comment: \$comment
          operations: \$operations
        ) {
          $_bikeMaintenanceFields
        }
      }
    """;

    return _mutate(query, 'createMaintenance', {'bikeId': bikeId, ..._maintenanceVariables(maintenance)});
  }

  /// Update the existing [maintenance].
  Future<BikeMaintenance> updateMaintenance(Maintenance maintenance) async {
    _log.info("Updating maintenance ${maintenance.id} ...");

    final String query = """
      mutation UpdateMaintenance(\$maintenanceId: Long!, \$maintenanceDate: String!, \$odometerKm: Int, \$resetsPlan: Boolean, \$comment: String, \$operations: [MaintenanceOperationInput!]!) {
        updateMaintenance(
          maintenanceId: \$maintenanceId
          maintenanceDate: \$maintenanceDate
          odometerKm: \$odometerKm
          resetsPlan: \$resetsPlan
          comment: \$comment
          operations: \$operations
        ) {
          $_bikeMaintenanceFields
        }
      }
    """;

    return _mutate(query, 'updateMaintenance', {
      'maintenanceId': maintenance.id,
      ..._maintenanceVariables(maintenance),
    });
  }

  /// Delete the maintenance with the given [maintenanceId].
  Future<BikeMaintenance> deleteMaintenance(int maintenanceId) async {
    _log.info("Deleting maintenance $maintenanceId ...");

    final String query = """
      mutation DeleteMaintenance(\$maintenanceId: Long!) {
        deleteMaintenance(maintenanceId: \$maintenanceId) {
          $_bikeMaintenanceFields
        }
      }
    """;

    return _mutate(query, 'deleteMaintenance', {'maintenanceId': maintenanceId});
  }

  /// Set the current [odometerKm] reading of the bike with the given [bikeId].
  Future<BikeMaintenance> updateBikeOdometer(int bikeId, int odometerKm) async {
    _log.info("Updating odometer of bike $bikeId ...");

    final String query = """
      mutation UpdateBikeOdometer(\$bikeId: Long!, \$odometerKm: Int!) {
        updateBikeOdometer(bikeId: \$bikeId, odometerKm: \$odometerKm) {
          $_bikeMaintenanceFields
        }
      }
    """;

    return _mutate(query, 'updateBikeOdometer', {'bikeId': bikeId, 'odometerKm': odometerKm});
  }

  Map<String, dynamic> _maintenanceVariables(Maintenance maintenance) => {
    'maintenanceDate': maintenance.maintenanceDate!.toIso8601String(),
    'odometerKm': maintenance.odometerKm,
    'resetsPlan': maintenance.resetsPlan,
    'comment': maintenance.comment,
    'operations': maintenance.operations.map((o) => o.toInput()).toList(),
  };

  Future<BikeMaintenance> _mutate(String query, String field, Map<String, dynamic> variables) async {
    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(query),
      variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);
    return _parse(result, field);
  }

  BikeMaintenance _parse(QueryResult result, String field) {
    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    }
    return BikeMaintenance.fromJson(result.data![field]);
  }
}
