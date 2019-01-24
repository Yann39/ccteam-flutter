import 'dart:convert';

import 'package:chachatte_team/models/event.dart';
import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EventsService {
  /// Fetch all events from the database
  /// Send a GET request to the Restful API
  /// Throw an exception if response status code is different from 200 or 404
  /// Return empty array if no data found (404)
  Future<List<Event>> fetchEvents() async {
    // call to API
    final response = await http.get(AppConstants.API_ROOT_URL + AppConstants.API_GET_ALL_EVENTS_ENDPOINT);

    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return (responseJson['records'] as List).map((p) => _fromJson(p)).toList();
    } else if (response.statusCode == 404) {
      // no data found, return empty array
      return new List<Event>();
    } else {
      throw Exception('Unexpected server response');
    }
  }

  /// Create the specified [event] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 201
  Future<void> createEvent(Event event) async {
    // convert Event object to JSON string
    final String jsonString = _toJson(event);

    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_CREATE_EVENT_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

    // handle server response code
    if (response.statusCode == 201) {
      return;
    } else if (response.statusCode == 503) {
      throw Exception('Failed to create the event');
    } else if (response.statusCode == 400) {
      throw Exception('Bad request, event has not been created');
    } else {
      throw Exception('Unexpected server response, event has not been created');
    }
  }

  /// Update the specified [event] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<void> updateEvent(Event event) async {
    // convert Event object to JSON string
    final String jsonString = _toJson(event);

    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_UPDATE_EVENT_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

    // handle server response code
    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 503) {
      throw Exception('Failed to update the event');
    } else {
      throw Exception('Unexpected server response, event has not been updated');
    }
  }

  /// Delete specified event from the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 204
  Future<void> deleteEvent(Event event) async {
    // convert Event object to JSON string
    final String jsonString = _toJson(event);

    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_DELETE_EVENT_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

    if (response.statusCode != 204) {
      throw Exception('Unexpected server response');
    }
  }

  /// Convert specified [event] object to the corresponding JSON string
  String _toJson(Event event) {
    final Map map = new Map();
    map["id"] = event.id;
    map["title"] = event.title;
    map["description"] = event.description;
    map["event_date"] = new DateFormat("y-M-d H:m:s.S").format(event.eventDate);
    map["track_id"] = event.trackId;
    map["organizer"] = event.organizer;
    map["price"] = event.price;

    List<Map> maps = <Map>[];
    for (Member m in event.members) {
      final Map map2 = new Map();
      map2["id"] = m.id;
      map2["first_name"] = m.firstName;
      map2["last_name"] = m.lastName;
      map2["email"] = m.email;
      map2["phone"] = m.phone;
      map2["bike"] = m.bike;
      map2["registration_date"] = new DateFormat("y-M-d H:m:s.S").format(m.registrationDate);
      maps.add(map2);
    }

    map["members"] = maps;

    print(json.encode(map));

    return json.encode(map);
  }

  /// Convert specified [json] map to the corresponding Event object
  Event _fromJson(Map<String, dynamic> json) {
    List<dynamic> jsonMembers = json['members'];
    List<Member> members = new List();

    if (jsonMembers != null) {
      for (dynamic jsonMember in jsonMembers) {
        members.add(new Member(
            id: int.parse(jsonMember['id']),
            firstName: jsonMember['first_name'],
            lastName: jsonMember['last_name'],
            email: jsonMember['email'],
            phone: jsonMember['phone'],
            bike: jsonMember['bike'],
            registrationDate: new DateFormat("y-M-d H:m:s").parseStrict(jsonMember['registration_date'])));
      }
    }

    return Event(
        id: int.parse(json['id']),
        title: json['title'],
        description: json['description'],
        eventDate: new DateFormat("y-M-d H:m:s").parseStrict(json['event_date']),
        trackId: int.parse(json['track_id']),
        organizer: json['organizer'],
        price: double.parse(json['price']),
        members: members);
  }
}
