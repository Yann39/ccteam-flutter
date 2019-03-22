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
import 'package:chachatte_team/models/news.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class NewsService {
  /// Fetch all news from the database
  /// Send a GET request to the Restful API
  /// Throw an exception if response status code is different from 200 or 404
  /// Return empty array if no data found (404)
  Future<List<News>> fetchNews() async {
    // call to API
    final response = await http.get(AppConstants.API_ROOT_URL + AppConstants.API_GET_ALL_NEWS_ENDPOINT);

    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return (responseJson['records'] as List).map((p) => _fromJson(p)).toList();
    } else if (response.statusCode == 404) {
      // no data found, return empty array
      return new List<News>();
    } else {
      throw Exception('Unexpected server response');
    }
  }

  /// Create the specified [news] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 201
  Future<void> createNews(News news) async {
    // convert News object to JSON string
    final String jsonString = _toJson(news);

    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_CREATE_NEWS_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

    // handle server response code
    if (response.statusCode == 201) {
      return;
    } else if (response.statusCode == 503) {
      throw Exception('Failed to create the news');
    } else if (response.statusCode == 400) {
      throw Exception('Bad request, news has not been created');
    } else {
      throw Exception('Unexpected server response, news has not been created');
    }
  }

  /// Update the specified [news] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<void> updateNews(News news) async {
    // convert News object to JSON string
    final String jsonString = _toJson(news);

    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_UPDATE_NEWS_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

    // handle server response code
    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 503) {
      throw Exception('Failed to update the news');
    } else {
      throw Exception('Unexpected server response, news has not been updated');
    }
  }

  /// Delete specified [news] from the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 204
  Future<void> deleteNews(News news) async {
    // convert News object to JSON string
    final String jsonString = _toJson(news);

    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_DELETE_NEWS_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

    if (response.statusCode != 204) {
      throw Exception('Unexpected server response');
    }
  }

  /// Set the news (identified by the specified [newsId]) as liked for the user (identified by the specified [userId]) from the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<void> likeNews(int newsId, int memberId) async {
    // convert News object to JSON string
    final String jsonString = '{"news_id":$newsId,"member_id":$memberId}';

    // call to API
    final response = await http.post(AppConstants.API_ROOT_URL + AppConstants.API_LIKE_NEWS_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

    if (response.statusCode != 200) {
      throw Exception('Unexpected server response');
    }
  }

  /// Convert specified [news] object to the corresponding JSON string
  String _toJson(News news) {
    final Map map = new Map();
    map["id"] = news.id;
    map["title"] = news.title;
    map["content"] = news.content;
    map["news_date"] = new DateFormat("y-M-d H:m:s.S").format(news.newsDate);

    if (news.members != null) {
      List<Map> maps = <Map>[];
      for (Member m in news.members) {
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
    }

    return json.encode(map);
  }

  /// Convert specified [json] map to the corresponding News object
  News _fromJson(Map<String, dynamic> json) {
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
          registrationDate: new DateFormat("y-M-d H:m:s").parseStrict(jsonMember['registration_date']),
        ));
      }
    }

    return News(
      id: int.parse(json['id']),
      title: json['title'],
      content: json['content'],
      newsDate: new DateFormat("y-M-d H:m:s").parseStrict(json['news_date']),
      members: members,
    );
  }
}
