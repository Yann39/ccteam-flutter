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

import 'dart:convert';

import 'package:chachatte_team/models/track.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:http/http.dart' as http;

class TracksService {
  /// Fetch all tracks from the database
  /// Send a GET request to the Restful API
  /// Throw an exception if response status code is different from 200 or 404
  /// Return empty array if no data found (404)
  Future<List<Track>> fetchTracks() async {
    // call to API
    final response = await http.get(API_ROOT_URL + API_GET_ALL_TRACKS_ENDPOINT);

    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return (responseJson['records'] as List).map((p) => Track.fromJson(p)).toList();
    } else if (response.statusCode == 404) {
      // no data found, return empty array
      return new List<Track>();
    } else {
      throw Exception('Unexpected server response');
    }
  }

  /// Search for tracks according to the specified [text]
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<List<Track>> searchTracks(String text) async {
    // format text as URL parameter string
    final String urlParameters = "?s=${Uri.encodeComponent(text)}";

    // call to API
    final response = await http.get(API_ROOT_URL + API_SEARCH_TRACKS_ENDPOINT + urlParameters, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return (responseJson['records'] as List).map((p) => Track.fromJson(p)).toList();
    } else if (response.statusCode == 404) {
      // no data found, return empty array
      return new List<Track>();
    } else {
      throw Exception('Unexpected server response');
    }
  }

  /// Create the specified [track] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 201
  Future<void> createTrack(Track track) async {
    // call to API
    final response = await http.post(API_ROOT_URL + API_CREATE_TRACK_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: track.toJson());

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
    final response = await http.post(API_ROOT_URL + API_UPDATE_TRACK_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: track.toJson());

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
    final response = await http.post(API_ROOT_URL + API_DELETE_TRACK_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: track.toJson());

    if (response.statusCode != 204) {
      throw Exception('Unexpected server response');
    }
  }
}
