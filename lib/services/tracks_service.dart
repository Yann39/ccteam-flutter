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

class TracksService {
  static final Logger _log = new Logger('TracksService');

  /// Fetch all tracks from the database.
  Future<List<Track>> fetchTracks() async {
    _log.info("Getting all tracks from database...");

    final String allTracksQuery = """
      query GetAllTracks() {
        getAllTracks() {
          id
          name
          distance
          lapRecord
          lapRecordInfo
          website
          latitude
          longitude
          country {
            code
            nameFr
            nameEn
          }
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

  /// Search for tracks according to the specified [text]
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<List<Track>> searchTracks(String text) async {
    _log.info("Searching tracks with text: $text...");

    final String searchTracksQuery = """
      query GetTracksFiltered(\$text: String) {
        getTracksFiltered(text: \$text) {
          id
          name
          distance
          lapRecord
          lapRecordInfo
          website
          latitude
          longitude
          country {
            code
            nameFr
            nameEn
          }
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(
          QueryOptions(
            document: parseString(searchTracksQuery),
            variables: {'text': text},
            fetchPolicy: FetchPolicy.noCache,
          ),
        )
        .then(
          (result) {
            final List<Track> tracks = [];
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              dynamic trackList = result.data!['getTracksFiltered'];
              if (trackList == null) {
                _log.info("getTracksFiltered returned null data");
              } else if (trackList is Map<String, dynamic> && trackList.isEmpty) {
                _log.info("getTracksFiltered returned empty data");
              } else {
                for (dynamic oneTrack in trackList) {
                  tracks.add(Track.fromJson(oneTrack));
                }
              }
              return tracks;
            }
          },
          onError: (error) {
            _log.severe("Error while searching tracks : $error");
            throw Exception(error);
          },
        );
  }

  /// Get a track from the database given its [id].
  Future<Track?> getTrackById(int id) async {
    _log.info("Getting track $id from database...");

    final String trackByIdQuery = """
      query GetTrackById(\$id: Long!) {
        getTrackById(id: \$id) {
          id
          name
          distance
          lapRecord
          lapRecordInfo
          website
          latitude
          longitude
          country {
            code
            nameFr
            nameEn
          }
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

  /// GraphQL projection shared between the create / update / delete
  /// mutations on Track. Mirrors what [fetchTracks] returns so the
  /// caller can update its in-memory list with the returned entity.
  static const String _trackOutputFields = """
        id
        name
        distance
        lapRecord
        lapRecordInfo
        website
        latitude
        longitude
        country {
          code
          nameFr
          nameEn
        }
  """;

  /// Create the specified [track] via the GraphQL mutation. Returns
  /// the persisted entity with its server-assigned id so the caller
  /// can stash it in the in-memory list. Throws on server error.
  Future<Track> createTrack(Track track) async {
    _log.info("Creating track ${track.name}...");

    final String mutation =
        """
      mutation CreateTrack(\$name: String!, \$distance: Int!, \$lapRecord: Int!, \$website: String!, \$latitude: Float!, \$longitude: Float!, \$countryCode: String!) {
        createTrack(
          name: \$name
          distance: \$distance
          lapRecord: \$lapRecord
          website: \$website
          latitude: \$latitude
          longitude: \$longitude
          countryCode: \$countryCode
        ) {
$_trackOutputFields
        }
      }
    """;

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: <String, dynamic>{
        'name': track.name,
        'distance': track.distance,
        'lapRecord': track.lapRecord ?? 0,
        'website': track.website ?? '',
        'latitude': track.latitude,
        'longitude': track.longitude,
        'countryCode': track.country?.code,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(options);
    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    }
    return Track.fromJson(result.data!['createTrack']);
  }

  /// Update the specified [track]. Same GraphQL projection / shape as
  /// [createTrack]; the server returns the up-to-date entity which
  /// the caller swaps in its in-memory list.
  Future<Track> updateTrack(Track track) async {
    _log.info("Updating track ${track.name}...");

    final String mutation =
        """
      mutation UpdateTrack(\$trackId: Long!, \$name: String!, \$distance: Int!, \$lapRecord: Int!, \$website: String!, \$latitude: Float!, \$longitude: Float!, \$countryCode: String!) {
        updateTrack(
          trackId: \$trackId
          name: \$name
          distance: \$distance
          lapRecord: \$lapRecord
          website: \$website
          latitude: \$latitude
          longitude: \$longitude
          countryCode: \$countryCode
        ) {
$_trackOutputFields
        }
      }
    """;

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: <String, dynamic>{
        'trackId': track.id,
        'name': track.name,
        'distance': track.distance,
        'lapRecord': track.lapRecord ?? 0,
        'website': track.website ?? '',
        'latitude': track.latitude,
        'longitude': track.longitude,
        'countryCode': track.country?.code,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(options);
    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    }
    return Track.fromJson(result.data!['updateTrack']);
  }

  /// Delete the specified [track]. Returns the deleted entity (mostly
  /// useful for logging / success snackbars referring to the name).
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
