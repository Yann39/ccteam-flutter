import 'dart:convert';

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

  /// Convert specified [news] object to the corresponding JSON string
  String _toJson(News news) {
    final Map map = new Map();
    map["title"] = news.title;
    map["content"] = news.content;
    map["news_date"] = new DateFormat("y-M-d H:m:s.S").format(news.newsDate);
    return json.encode(map);
  }

  /// Convert specified [json] map to the corresponding News object
  News _fromJson(Map<String, dynamic> json) {
    return News(id: int.parse(json['id']), title: json['title'], content: json['content'], newsDate: new DateFormat("y-M-d H:m:s").parseStrict(json['news_date']));
  }
}
