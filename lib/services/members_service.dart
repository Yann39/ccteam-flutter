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
import 'dart:io';

import 'package:async/async.dart';
import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class MembersService {
  /// Fetch all members from the database
  /// Send a GET request to the Restful API
  /// Throw an exception if response status code is different from 200 or 404
  /// Return empty array if no data found (404)
  Future<List<Member>> fetchMembers() async {
    // call to API
    final response = await http.get(API_ROOT_URL + API_GET_ALL_MEMBERS_ENDPOINT);

    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return (responseJson['records'] as List).map((p) => Member.fromJson(p)).toList();
    } else if (response.statusCode == 404) {
      // no data found, return empty array
      return new List<Member>();
    } else {
      throw Exception('Unexpected server response');
    }
  }

  /// Check if the specified [member] is allowed to log in
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<void> loginMember(Member member) async {
    // call to API
    final response = await http.post(API_ROOT_URL + API_LOGIN_MEMBER_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: json.encode(member.toJson()));

    // handle server response code
    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Wrong credentials');
    } else if (response.statusCode == 403) {
      throw Exception('Account is not activated');
    } else if (response.statusCode == 404) {
      throw Exception('No member found with the specified e-mail address');
    } else if (response.statusCode == 400) {
      throw Exception('Bad request, member has not been logged in');
    } else {
      throw Exception('Unexpected server response, member has not been logged in');
    }
  }

  /// Get the member corresponding to the specified [id]
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<Member> getMemberById(int id) async {
    // call to API
    final response = await http.post(API_ROOT_URL + API_GET_SINGLE_MEMBER_ENDPOINT + "?id=$id");

    // handle server response code
    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return Member.fromJson(responseJson);
    } else if (response.statusCode == 404) {
      throw Exception('No member found with the specified id');
    } else {
      throw Exception('Unexpected server response');
    }
  }

  /// Get the member corresponding to the specified [email]
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<Member> getMemberByEmail(String email) async {
    // convert Member object to JSON string
    final String jsonString = "{\"email\":\"$email\"}";

    // call to API
    final response = await http.post(API_ROOT_URL + API_GET_MEMBER_BY_EMAIL_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

    // handle server response code
    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return Member.fromJson(responseJson);
    } else if (response.statusCode == 403) {
      throw Exception('Account is not activated');
    } else if (response.statusCode == 404) {
      throw Exception('No member found with the specified e-mail address');
    } else if (response.statusCode == 400) {
      throw Exception('Bad request, missing email attribute');
    } else {
      throw Exception('Unexpected server response');
    }
  }

  /// Search for members according to the specified [text]
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<List<Member>> searchMembers(String text) async {
    // format text as URL parameter string
    final String urlParameters = "?s=${Uri.encodeComponent(text)}";

    // call to API
    final response = await http.get(API_ROOT_URL + API_SEARCH_MEMBERS_ENDPOINT + urlParameters, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return (responseJson['records'] as List).map((p) => Member.fromJson(p)).toList();
    } else if (response.statusCode == 404) {
      // no data found, return empty array
      return new List<Member>();
    } else {
      throw Exception('Unexpected server response');
    }
  }

  /// Create the specified [member] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 201
  Future<void> createMember(Member member) async {
    // call to API
    final response = await http.post(API_ROOT_URL + API_CREATE_MEMBER_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: member.toJson());

    // handle server response code
    if (response.statusCode == 201) {
      return;
    } else if (response.statusCode == 503) {
      throw Exception('Failed to create the member');
    } else if (response.statusCode == 400) {
      throw Exception('Bad request, member has not been created');
    } else {
      throw Exception('Unexpected server response, member has not been created');
    }
  }

  /// Update the specified [member] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<void> updateMember(Member member) async {
    // call to API
    final response = await http.post(API_ROOT_URL + API_UPDATE_MEMBER_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: json.encode(member.toJson()));

    // handle server response code
    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 503) {
      throw Exception('Failed to update the member');
    } else {
      throw Exception('Unexpected server response, member has not been updated');
    }
  }

  /// Delete specified [member] from the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 204
  Future<void> deleteMember(Member member) async {
    // call to API
    final response = await http.post(API_ROOT_URL + API_DELETE_MEMBER_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: json.encode(member.toJson()));

    if (response.statusCode != 204) {
      throw Exception('Unexpected server response');
    }
  }

  /// Ask for a password reset for the account related to the specified [email]
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 201
  Future<void> askPassword(String email) async {
    // convert Member object to JSON string
    final String jsonString = '{email:$email}';

    // call to API
    final response = await http.post(API_ROOT_URL + API_ASK_PASSWORD_MEMBER_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

    // handle server response code
    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return Member.fromJson(responseJson);
    } else if (response.statusCode == 403) {
      throw Exception('Account is not activated');
    } else if (response.statusCode == 404) {
      throw Exception('No member found with the specified e-mail address');
    } else if (response.statusCode == 400) {
      throw Exception('Bad request, missing email attribute');
    } else {
      throw Exception('Unexpected server response');
    }
  }

  /// Upload the specified avatar [file] for the specified [memberId]
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  /// Return the uploaded avatar relative path
  Future<String> uploadAvatar(File file, int memberId) async {
    final http.ByteStream stream = new http.ByteStream(DelegatingStream.typed(file.openRead()));
    final int length = await file.length();
    final Uri uri = Uri.parse(API_ROOT_URL + API_UPLOAD_MEMBER_AVATAR_ENDPOINT);
    final http.MultipartRequest request = new http.MultipartRequest("POST", uri);
    final http.MultipartFile multipartFile = new http.MultipartFile('avatar', stream, length, filename: basename(file.path));
    request.files.add(multipartFile);

    Map<String, String> params = new Map();
    params.putIfAbsent("memberId", () => "$memberId");
    request.fields.addAll(params);

    // call to API
    final response = await request.send();

    // handle server response code
    if (response.statusCode == 200) {
      String path;
      await for (String value in response.stream.transform(utf8.decoder)) {
        path = value;
      }
      return path;
    } else if (response.statusCode == 400) {
      throw Exception('File too big ($length) or wrong type');
    } else {
      throw Exception('Unexpected server response');
    }
  }

  /// Delete avatar for the specified [memberId]
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<void> deleteAvatar(int memberId) async {
    // convert Member object to JSON string
    final String jsonString = '{\"memberId\":$memberId}';

    // call to API
    final response = await http.post(API_ROOT_URL + API_DELETE_MEMBER_AVATAR_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

    // handle server response code
    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Member avatar file not found');
    } else if (response.statusCode == 400) {
      throw Exception('Missing member id');
    } else {
      throw Exception('Unexpected server response, member avatar has not been deleted');
    }
  }
}
