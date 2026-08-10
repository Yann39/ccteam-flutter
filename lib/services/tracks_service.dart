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

import 'package:ccteam/models/track.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';

/// Service for tracks, a track is a single version (layout) of a circuit.
class TracksService {
  static final Logger _log = new Logger('TracksService');

  /// GraphQL projection for a Track (version), including its parent circuit
  /// (venue) so the label and the venue delegates on the model resolve.
  static const String _trackOutputFields = """
        id
        variantName
        distance
        lapRecord
        lapRecordInfo
        iconKey
        circuit {
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
        }
  """;

  /// Fetch all tracks (versions) from the database.
  Future<List<Track>> fetchTracks() async {
    _log.info("Getting all tracks from database...");

    final String allTracksQuery =
        """
      query GetAllTracks {
        getAllTracks {
$_trackOutputFields
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(QueryOptions(document: parseString(allTracksQuery), fetchPolicy: FetchPolicy.noCache))
        .then(
          (result) {
            final List<Track> tracks = [];
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              dynamic trackList = result.data!['getAllTracks'];
              if (trackList == null) {
                _log.info("getAllTracks returned null data");
              } else if (trackList is Map<String, dynamic> && trackList.isEmpty) {
                _log.info("getAllTracks returned empty data");
              } else {
                for (dynamic oneTrack in trackList) {
                  tracks.add(Track.fromJson(oneTrack));
                }
              }
              return tracks;
            }
          },
          onError: (error) {
            _log.severe("Error while fetching track list : $error");
            throw Exception(error);
          },
        );
  }

  /// Get a track (version) from the database given its [id].
  Future<Track?> getTrackById(int id) async {
    _log.info("Getting track $id from database...");

    final String trackByIdQuery =
        """
      query GetTrackById(\$id: Long!) {
        getTrackById(id: \$id) {
$_trackOutputFields
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(
          QueryOptions(document: parseString(trackByIdQuery), variables: {'id': id}, fetchPolicy: FetchPolicy.noCache),
        )
        .then(
          (result) {
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              if (result.data!['getTrackById'] == null) {
                return null;
              }
              return Track.fromJson(result.data!['getTrackById']);
            }
          },
          onError: (error) {
            throw Exception(error);
          },
        );
  }

  /// Create the specified [track] (version) via the GraphQL mutation. The
  /// version is attached to its `circuit`. Returns the persisted entity with
  /// its server-assigned id. Throws on server error.
  Future<Track> createTrack(Track track) async {
    _log.info("Creating track ${track.displayName}...");

    final String mutation =
        """
      mutation CreateTrack(\$circuitId: Long!, \$variantName: String, \$distance: Int!, \$lapRecord: Int!, \$lapRecordInfo: String, \$iconKey: String) {
        createTrack(
          circuitId: \$circuitId
          variantName: \$variantName
          distance: \$distance
          lapRecord: \$lapRecord
          lapRecordInfo: \$lapRecordInfo
          iconKey: \$iconKey
        ) {
$_trackOutputFields
        }
      }
    """;

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: <String, dynamic>{
        'circuitId': track.circuit?.id,
        'variantName': track.variantName,
        'distance': track.distance,
        'lapRecord': track.lapRecord ?? 0,
        'lapRecordInfo': track.lapRecordInfo,
        'iconKey': track.iconKey,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(options);
    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    }
    return Track.fromJson(result.data!['createTrack']);
  }

  /// Update the specified [track] (version). Same projection / shape as
  /// [createTrack]; the server returns the up-to-date entity.
  Future<Track> updateTrack(Track track) async {
    _log.info("Updating track ${track.displayName}...");

    final String mutation =
        """
      mutation UpdateTrack(\$trackId: Long!, \$circuitId: Long!, \$variantName: String, \$distance: Int!, \$lapRecord: Int!, \$lapRecordInfo: String, \$iconKey: String) {
        updateTrack(
          trackId: \$trackId
          circuitId: \$circuitId
          variantName: \$variantName
          distance: \$distance
          lapRecord: \$lapRecord
          lapRecordInfo: \$lapRecordInfo
          iconKey: \$iconKey
        ) {
$_trackOutputFields
        }
      }
    """;

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: <String, dynamic>{
        'trackId': track.id,
        'circuitId': track.circuit?.id,
        'variantName': track.variantName,
        'distance': track.distance,
        'lapRecord': track.lapRecord ?? 0,
        'lapRecordInfo': track.lapRecordInfo,
        'iconKey': track.iconKey,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(options);
    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    }
    return Track.fromJson(result.data!['updateTrack']);
  }

  /// Delete the track (version) with the given [trackId]. Returns the deleted
  /// entity (useful for logging / success snackbars).
  Future<Track> deleteTrack(int trackId) async {
    _log.info("Deleting track $trackId...");

    final String mutation =
        """
      mutation DeleteTrack(\$trackId: Long!) {
        deleteTrack(trackId: \$trackId) {
$_trackOutputFields
        }
      }
    """;

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: <String, dynamic>{'trackId': trackId},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(options);
    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    }
    return Track.fromJson(result.data!['deleteTrack']);
  }
}
