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

import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MembersService {
  /// Fetch all members from the database
  /// Send a GET request to the Restful API
  /// Throw an exception if response status code is different from 200 or 404
  /// Return empty array if no data found (404)
  Future<List<Member>> fetchMembers() async {
    // call to API
    final response = await http.get(AppConstants.API_ROOT_URL + AppConstants.API_GET_ALL_MEMBERS_ENDPOINT);

    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return (responseJson['records'] as List).map((p) => _fromJson(p)).toList();
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
    // convert Member object to JSON string
    final String jsonString = _toJson(member);

    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_LOGIN_MEMBER_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

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

  /// Create the specified [member] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 201
  Future<void> createMember(Member member) async {
    // convert Member object to JSON string
    final String jsonString = _toJson(member);

    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_CREATE_MEMBER_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

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
    // convert Member object to JSON string
    final String jsonString = _toJson(member);

    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_UPDATE_MEMBER_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

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
    // convert Member object to JSON string
    final String jsonString = _toJson(member);

    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_DELETE_MEMBER_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

    if (response.statusCode != 204) {
      throw Exception('Unexpected server response');
    }
  }

  /// Convert specified [member] object to the corresponding JSON string
  String _toJson(Member member) {
    final Map map = new Map();
    map["id"] = member.id;
    map["first_name"] = member.firstName;
    map["last_name"] = member.lastName;
    map["email"] = member.email;
    map["password"] = member.password;
    map["active"] = member.active;
    map["admin"] = member.admin;
    map["phone"] = member.phone;
    map["bike"] = member.bike;
    map["registration_date"] = member.registrationDate != null ? new DateFormat("yyyy-MM-dd HH:mm:ss").format(member.registrationDate) : null;
    return json.encode(map);
  }

  /// Convert specified [json] map to the corresponding Member object
  Member _fromJson(Map<String, dynamic> json) {
    return Member(
        id: int.parse(json['id']),
        firstName: json['first_name'],
        lastName: json['last_name'],
        email: json['email'],
        password: json['password'],
        active: json['active'] == '1',
        admin: json['admin'] == '1',
        phone: json['phone'],
        bike: json['bike'],
        registrationDate: json['registration_date'] != null ? new DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['registration_date']) : null);
  }
}
