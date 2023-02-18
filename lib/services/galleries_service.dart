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

import 'package:chachatte_team/models/gallery.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:http/http.dart' as http;

class GalleriesService {
  /// Fetch all galleries from the database
  /// Send a GET request to the Restful API
  /// Throw an exception if response status code is different from 200 or 404
  /// Return empty array if no data found (404)
  Future<List<Gallery>> fetchGalleries() async {
    // call to API
    final response = await http
        .get(Uri.parse(API_ROOT_URL + API_GET_ALL_GALLERIES_ENDPOINT));

    if (response.statusCode == 200) {
      print(response.body);
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return (responseJson['records'] as List)
          .map((p) => Gallery.fromJson(p))
          .toList();
    } else if (response.statusCode == 404) {
      // no data found, return empty array
      return [];
    } else {
      throw Exception('Unexpected server response');
    }
  }

  /// Create the specified [gallery] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 201
  Future<void> createGallery(Gallery gallery) async {
    // call to API
    final response = await http.post(
        Uri.parse(API_ROOT_URL + API_CREATE_GALLERY_ENDPOINT),
        headers: {'Content-Type': 'application/json'},
        body: gallery.toJson());

    // handle server response code
    if (response.statusCode == 201) {
      return;
    } else if (response.statusCode == 503) {
      throw Exception('Failed to create the gallery');
    } else if (response.statusCode == 400) {
      throw Exception('Bad request, gallery has not been created');
    } else {
      throw Exception(
          'Unexpected server response, gallery has not been created');
    }
  }

  /// Update the specified [gallery] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<void> updateGallery(Gallery gallery) async {
    // call to API
    final response = await http.post(
        Uri.parse(API_ROOT_URL + API_UPDATE_GALLERY_ENDPOINT),
        headers: {'Content-Type': 'application/json'},
        body: gallery.toJson());

    // handle server response code
    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 503) {
      throw Exception('Failed to update the gallery');
    } else {
      throw Exception(
          'Unexpected server response, gallery has not been updated');
    }
  }

  /// Delete specified [gallery] from the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 204
  Future<void> deleteGallery(Gallery gallery) async {
    // call to API
    final response = await http.post(
        Uri.parse(API_ROOT_URL + API_DELETE_GALLERY_ENDPOINT),
        headers: {'Content-Type': 'application/json'},
        body: gallery.toJson());

    if (response.statusCode != 204) {
      throw Exception('Unexpected server response');
    }
  }
}
