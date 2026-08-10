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

import 'package:ccteam/models/circuit.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';

/// Service for circuits (venues). A circuit groups one or more versions
/// (layouts), each of which is a [Track].
class CircuitsService {
  static final Logger _log = new Logger('CircuitsService');

  /// GraphQL projection for a Circuit, including its versions (tracks).
  static const String _circuitOutputFields = """
        id
        name
        latitude
        longitude
        website
        country {
          code
          nameFr
          nameEn
        }
        tracks {
          id
          variantName
          distance
          lapRecord
          lapRecordInfo
          iconKey
        }
  """;

  /// Fetch all circuits from the database.
  Future<List<Circuit>> fetchCircuits() async {
    _log.info("Getting all circuits from database...");

    final String query =
        """
      query GetAllCircuits {
        getAllCircuits {
$_circuitOutputFields
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(
          QueryOptions(
            document: parseString(query),
            fetchPolicy: FetchPolicy.noCache,
          ),
        )
        .then(
          (result) {
            final List<Circuit> circuits = [];
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              dynamic circuitList = result.data!['getAllCircuits'];
              if (circuitList == null) {
                _log.info("getAllCircuits returned null data");
              } else if (circuitList is Map<String, dynamic> &&
                  circuitList.isEmpty) {
                _log.info("getAllCircuits returned empty data");
              } else {
                for (dynamic oneCircuit in circuitList) {
                  circuits.add(Circuit.fromJson(oneCircuit));
                }
              }
              return circuits;
            }
          },
          onError: (error) {
            _log.severe("Error while fetching circuit list : $error");
            throw Exception(error);
          },
        );
  }

  /// Search for circuits according to the specified [text].
  Future<List<Circuit>> searchCircuits(String text) async {
    _log.info("Searching circuits with text: $text...");

    final String query =
        """
      query GetCircuitsFiltered(\$text: String) {
        getCircuitsFiltered(text: \$text) {
$_circuitOutputFields
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(
          QueryOptions(
            document: parseString(query),
            variables: {'text': text},
            fetchPolicy: FetchPolicy.noCache,
          ),
        )
        .then(
          (result) {
            final List<Circuit> circuits = [];
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              dynamic circuitList = result.data!['getCircuitsFiltered'];
              if (circuitList == null) {
                _log.info("getCircuitsFiltered returned null data");
              } else if (circuitList is Map<String, dynamic> &&
                  circuitList.isEmpty) {
                _log.info("getCircuitsFiltered returned empty data");
              } else {
                for (dynamic oneCircuit in circuitList) {
                  circuits.add(Circuit.fromJson(oneCircuit));
                }
              }
              return circuits;
            }
          },
          onError: (error) {
            _log.severe("Error while searching circuits : $error");
            throw Exception(error);
          },
        );
  }

  /// Get a circuit from the database given its [id].
  Future<Circuit?> getCircuitById(int id) async {
    _log.info("Getting circuit $id from database...");

    final String query =
        """
      query GetCircuitById(\$id: Long!) {
        getCircuitById(id: \$id) {
$_circuitOutputFields
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(
          QueryOptions(
            document: parseString(query),
            variables: {'id': id},
            fetchPolicy: FetchPolicy.noCache,
          ),
        )
        .then(
          (result) {
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              if (result.data!['getCircuitById'] == null) {
                return null;
              }
              return Circuit.fromJson(result.data!['getCircuitById']);
            }
          },
          onError: (error) {
            throw Exception(error);
          },
        );
  }

  /// Create the specified [circuit] via the GraphQL mutation. Returns the
  /// persisted entity with its server-assigned id. Throws on server error.
  Future<Circuit> createCircuit(Circuit circuit) async {
    _log.info("Creating circuit ${circuit.name}...");

    final String mutation =
        """
      mutation CreateCircuit(\$name: String!, \$countryCode: String!, \$latitude: Float!, \$longitude: Float!, \$website: String) {
        createCircuit(
          name: \$name
          countryCode: \$countryCode
          latitude: \$latitude
          longitude: \$longitude
          website: \$website
        ) {
$_circuitOutputFields
        }
      }
    """;

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: <String, dynamic>{
        'name': circuit.name,
        'countryCode': circuit.country?.code,
        'latitude': circuit.latitude,
        'longitude': circuit.longitude,
        'website': circuit.website,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(
      options,
    );
    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    }
    return Circuit.fromJson(result.data!['createCircuit']);
  }

  /// Update the specified [circuit]. Same projection / shape as [createCircuit].
  Future<Circuit> updateCircuit(Circuit circuit) async {
    _log.info("Updating circuit ${circuit.name}...");

    final String mutation =
        """
      mutation UpdateCircuit(\$circuitId: Long!, \$name: String!, \$countryCode: String!, \$latitude: Float!, \$longitude: Float!, \$website: String) {
        updateCircuit(
          circuitId: \$circuitId
          name: \$name
          countryCode: \$countryCode
          latitude: \$latitude
          longitude: \$longitude
          website: \$website
        ) {
$_circuitOutputFields
        }
      }
    """;

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: <String, dynamic>{
        'circuitId': circuit.id,
        'name': circuit.name,
        'countryCode': circuit.country?.code,
        'latitude': circuit.latitude,
        'longitude': circuit.longitude,
        'website': circuit.website,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(
      options,
    );
    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    }
    return Circuit.fromJson(result.data!['updateCircuit']);
  }

  /// Delete the circuit with the given [circuitId]. The server rejects the
  /// deletion when the circuit still has versions.
  Future<Circuit> deleteCircuit(int circuitId) async {
    _log.info("Deleting circuit $circuitId...");

    final String mutation =
        """
      mutation DeleteCircuit(\$circuitId: Long!) {
        deleteCircuit(circuitId: \$circuitId) {
$_circuitOutputFields
        }
      }
    """;

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: <String, dynamic>{'circuitId': circuitId},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(
      options,
    );
    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    }
    return Circuit.fromJson(result.data!['deleteCircuit']);
  }
}
