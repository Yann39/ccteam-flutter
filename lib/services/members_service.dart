import 'dart:convert';

import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MembersService {
  /// Fetch all MEMBERS from the database
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

  /// Create the specified [member] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 201
  Future<void> createMember(Member member) async {
    // convert Member object to JSON string
    final String jsonString = _toJson(member);

    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_CREATE_MEMBERS_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

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
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_UPDATE_MEMBERS_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

    // handle server response code
    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 503) {
      throw Exception('Failed to update the member');
    } else {
      throw Exception('Unexpected server response, member has not been updated');
    }
  }

  /// Convert specified [member] object to the corresponding JSON string
  String _toJson(Member member) {
    final Map map = new Map();
    map["id"] = member.id;
    map["first_name"] = member.firstName;
    map["last_name"] = member.lastName;
    map["email"] = member.email;
    map["phone"] = member.phone;
    map["bike"] = member.bike;
    map["registration_date"] = new DateFormat("y-M-d H:m:s.S").format(member.registrationDate);
    return json.encode(map);
  }

  /// Convert specified [json] map to the corresponding Member object
  Member _fromJson(Map<String, dynamic> json) {
    return Member(
        id: int.parse(json['id']),
        firstName: json['first_name'],
        lastName: json['last_name'],
        email: json['email'],
        phone: json['phone'],
        bike: json['bike'],
        registrationDate: new DateFormat("y-M-d H:m:s").parseStrict(json['registration_date']));
  }
}
