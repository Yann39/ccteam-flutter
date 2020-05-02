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

import 'package:chachatte_team/models/record.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:http/http.dart' as http;

class RecordsService {
  /// Fetch all records from the database
  /// Send a GET request to the Restful API
  /// Throw an exception if response status code is different from 200 or 404
  /// Return empty array if no data found (404)
  Future<List<Record>> fetchRecords() async {
    // call to API
    final response = await http.get(AppConstants.API_ROOT_URL + AppConstants.API_GET_ALL_RECORDS_ENDPOINT);

    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return (responseJson['records'] as List).map((p) => Record.fromJson(p)).toList();
    } else if (response.statusCode == 404) {
      // no data found, return empty array
      return new List<Record>();
    } else {
      throw Exception('Unexpected server response');
    }
  }

  /// Fetch all records for the specified [trackId] from the database
  /// Send a GET request to the Restful API
  /// Throw an exception if response status code is different from 200 or 404
  /// Return empty array if no data found (404)
  Future<List<Record>> fetchTrackRecords(int trackId) async {
    // call to API
    final response = await http.get(AppConstants.API_ROOT_URL + AppConstants.API_GET_TRACK_RECORDS_ENDPOINT + "?trackId=$trackId");

    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return (responseJson['records'] as List).map((p) => Record.fromJson(p)).toList();
    } else if (response.statusCode == 404) {
      // no data found, return empty array
      return new List<Record>();
    } else if (response.statusCode == 400) {
      throw Exception('Bad request, check that parameter has been specified correctly');
    } else {
      throw Exception('Unexpected server response');
    }
  }

  /// Fetch all records for the specified [memberId] from the database
  /// Send a GET request to the Restful API
  /// Throw an exception if response status code is different from 200 or 404
  /// Return empty array if no data found (404)
  Future<List<Record>> fetchMemberRecords(int memberId) async {
    // call to API
    final response = await http.get(AppConstants.API_ROOT_URL + AppConstants.API_GET_MEMBER_RECORDS_ENDPOINT + "?memberId=$memberId");

    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return (responseJson['records'] as List).map((p) => Record.fromJson(p)).toList();
    } else if (response.statusCode == 404) {
      // no data found, return empty array
      return new List<Record>();
    } else if (response.statusCode == 400) {
      throw Exception('Bad request, check that parameter has been specified correctly');
    } else {
      throw Exception('Unexpected server response');
    }
  }

  /// Create the specified [record] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 201
  Future<void> createRecord(Record record) async {
    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_CREATE_RECORD_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: record.toJson());

    // handle server response code
    if (response.statusCode == 201) {
      return;
    } else if (response.statusCode == 503) {
      throw Exception('Failed to create the record');
    } else if (response.statusCode == 400) {
      throw Exception('Bad request, record has not been created');
    } else {
      throw Exception('Unexpected server response, record has not been created');
    }
  }

  /// Update the specified [record] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<void> updateRecord(Record record) async {
    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_UPDATE_RECORD_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: record.toJson());

    // handle server response code
    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 503) {
      throw Exception('Failed to update the record');
    } else {
      throw Exception('Unexpected server response, record has not been updated');
    }
  }

  /// Delete specified [record] from the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 204
  Future<void> deleteRecord(Record record) async {
    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_DELETE_RECORD_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: record.toJson());

    if (response.statusCode != 204) {
      throw Exception('Unexpected server response');
    }
  }
}
