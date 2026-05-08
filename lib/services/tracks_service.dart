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
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
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
            document: parseString(allTracksQuery),
            fetchPolicy: FetchPolicy.noCache,
          ),
        )
        .then(
          (result) {
            final List<Track> tracks = [];
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              dynamic trackList = result.data!['getAllTracks'];
              if (trackList == null) {
                _log.info("getAllTracks returned null data");
              } else if (trackList is Map<String, dynamic> &&
                  trackList.isEmpty) {
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
              } else if (trackList is Map<String, dynamic> &&
                  trackList.isEmpty) {
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
            document: parseString(trackByIdQuery),
            variables: {'id': id},
            fetchPolicy: FetchPolicy.noCache,
          ),
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

  /// Create the specified [track] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 201
  Future<void> createTrack(Track track) async {
    // call to API
    final response = await http.post(
      Uri.parse(API_BASE_URL + API_CREATE_TRACK_ENDPOINT),
      headers: {'Content-Type': 'application/json'},
      body: track.toJson(),
    );

    // handle server response code
    if (response.statusCode == 201) {
      return;
    } else if (response.statusCode == 503) {
      throw Exception('Failed to create the track');
    } else if (response.statusCode == 400) {
      throw Exception('Bad request, track has not been created');
    } else {
      throw Exception('Unexpected server response, track has not been created');
    }
  }

  /// Update the specified [track] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<void> updateTrack(Track track) async {
    // call to API
    final response = await http.post(
      Uri.parse(API_BASE_URL + API_UPDATE_TRACK_ENDPOINT),
      headers: {'Content-Type': 'application/json'},
      body: track.toJson(),
    );

    // handle server response code
    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 503) {
      throw Exception('Failed to update the track');
    } else {
      throw Exception('Unexpected server response, track has not been updated');
    }
  }

  /// Delete specified [track] from the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 204
  Future<void> deleteTrack(Track track) async {
    // call to API
    final response = await http.post(
      Uri.parse(API_BASE_URL + API_DELETE_TRACK_ENDPOINT),
      headers: {'Content-Type': 'application/json'},
      body: track.toJson(),
    );

    if (response.statusCode != 204) {
      throw Exception('Unexpected server response');
    }
  }
}
