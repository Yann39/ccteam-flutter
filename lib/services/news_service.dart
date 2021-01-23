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

import 'package:chachatte_team/models/news.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/graphql_connection.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:gql/language.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class NewsService {
  static final Logger _log = new Logger('NewsService');

  /// Fetch all news from the database
  /// Send a request to the GraphQL endpoint
  Future<List<News>> fetchNews() async {
    _log.info("Getting all news from database...");

    final String allNewsQuery = """
      query GetNews() {
        allNews() {
          id
          title
          catchLine
          content
          newsDate
          likedMembers {
            firstName
            lastName
          }
          createdOn
          modifiedOn
        }
      }
    """;

    return GraphQLConnection().graphQLClient.query(QueryOptions(documentNode: parseString(allNewsQuery))).then(
      (result) {
        final List<News> news = new List();
        if (result.hasException) {
          // usually ClientException means invalid or expired token
          if (result.exception.clientException != null) {
            throw Exception(result.exception.clientException.message);
          } else if (result.exception.graphqlErrors != null && result.exception.graphqlErrors.isNotEmpty) {
            throw Exception(result.exception.graphqlErrors.first.message);
          } else {
            throw Exception(result.exception.toString());
          }
        } else {
          dynamic newsList = result.data['allNews'];
          if (newsList == null) {
            // returned { "data": { "allNews": null } }
            _log.info("GetNews returned null data");
          } else if (newsList is Map<String, dynamic> && newsList.isEmpty) {
            // returned { "data": { "allNews": [] } }
            _log.info("GetNews returned empty data");
          } else {
            // returned at least one data, build object from JSON
            for (dynamic oneNews in newsList) {
              news.add(News.fromJson(oneNews));
            }
          }
          return news;
        }
      },
      onError: (error) {
        _log.severe("Error while getting user events by status : $error");
        throw Exception(error);
      },
    );
  }

  /// Get a news from the database given it [id]
  /// Send a GET request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<News> getNewsById(int id) async {
    // call to API
    final response = await http.get(API_ROOT_URL + API_GET_ALL_NEWS_ENDPOINT);

    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the JSON and return content
      dynamic responseJson = json.decode(response.body);
      return News.fromJson(responseJson);
    } else if (response.statusCode == 404) {
      throw Exception('No news found with the specified id');
    } else {
      throw Exception('Unexpected server response');
    }
  }

  /// Create the specified [news] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 201
  Future<News> createNews(News news) async {
    // call to API
    final response = await http.post(API_ROOT_URL + API_CREATE_NEWS_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: json.encode(news.toJson()));

    final headers = response.headers;

    // handle server response code
    if (response.statusCode == 201) {
      // get the URI of the new created object from the location header
      String uri = headers["location"];
      final response = await http.get(API_ROOT_URL + uri);
      if (response.statusCode == 200) {
        // if the call to the server was successful, parse the JSON and return content
        dynamic responseJson = json.decode(response.body);
        return News.fromJson(responseJson);
      } else if (response.statusCode == 404) {
        throw Exception('No news found with the specified id');
      } else {
        throw Exception('Unexpected server response');
      }
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
    // call to API
    final response = await http.post(API_ROOT_URL + API_UPDATE_NEWS_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: json.encode(news.toJson()));

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
    // call to API
    final response = await http.post(API_ROOT_URL + API_DELETE_NEWS_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: json.encode(news.toJson()));

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
    final response = await http.post(API_ROOT_URL + API_LIKE_NEWS_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

    if (response.statusCode != 200) {
      throw Exception('Unexpected server response (code ${response.statusCode})');
    }
  }

  /// Set the news (identified by the specified [newsId]) as not liked for the user (identified by the specified [userId]) from the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<void> unlikeNews(int newsId, int memberId) async {
    // convert News object to JSON string
    final String jsonString = '{"news_id":$newsId,"member_id":$memberId}';

    // call to API
    final response = await http.post(API_ROOT_URL + API_UNLIKE_NEWS_ENDPOINT, headers: {'Content-Type': 'application/json'}, body: jsonString);

    if (response.statusCode != 200) {
      throw Exception('Unexpected server response (code ${response.statusCode})');
    }
  }
}
