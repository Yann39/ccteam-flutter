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
    final response = await http.get(AppConstants.API_ROOT_URL + AppConstants.API_GET_ALL_TRACKS_ENDPOINT);

    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return (responseJson['records'] as List).map((p) => _fromJson(p)).toList();
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
    // convert Track object to JSON string
    final String jsonString = _toJson(track);

    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_CREATE_TRACK_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

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
    // convert Track object to JSON string
    final String jsonString = _toJson(track);

    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_UPDATE_TRACK_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

    // handle server response code
    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 503) {
      throw Exception('Failed to update the track');
    } else {
      throw Exception('Unexpected server response, track has not been updated');
    }
  }

  /// Delete specified track from the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 204
  Future<void> deleteMember(Track track) async {
    // convert Track object to JSON string
    final String jsonString = _toJson(track);

    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_DELETE_NEWS_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

    if (response.statusCode != 204) {
      throw Exception('Unexpected server response');
    }
  }

  /// Convert specified [track] object to the corresponding JSON string
  String _toJson(Track track) {
    final Map map = new Map();
    map["id"] = track.id;
    map["name"] = track.name;
    map["description"] = track.description;
    return json.encode(map);
  }

  /// Convert specified [json] map to the corresponding Track object
  Track _fromJson(Map<String, dynamic> json) {
    return Track(id: int.parse(json['id']), name: json['name'], description: json['description']);
  }
}
