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
import 'package:chachatte_team/utils/app_utils.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/graphql_connection.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class NewsService {
  static final Logger _log = new Logger('NewsService');

  /// Fetch all news from the database.
  Future<List<News>> fetchNews() async {
    _log.info("Getting all news from database...");

    final String allNewsQuery = """
      query GetAllNews() {
        getAllNews() {
          id
          title
          catchLine
          newsDate
          likedNews {
            id
            member {
              email
            }
          }
        }
      }
    """;

    return GraphQLConnection()
        .graphQLClient
        .query(
          QueryOptions(
            document: parseString(allNewsQuery),
            fetchPolicy: FetchPolicy.noCache,
          ),
        )
        .then(
      (result) {
        final List<News> news = [];
        if (result.hasException) {
          throw AppUtils.handleGraphQlException(result);
        } else {
          dynamic newsList = result.data['getAllNews'];
          if (newsList == null) {
            // returned { "data": { "allNews": null } }
            _log.info("GetAllNews returned null data");
          } else if (newsList is Map<String, dynamic> && newsList.isEmpty) {
            // returned { "data": { "allNews": [] } }
            _log.info("GetAllNews returned empty data");
          } else {
            // returned at least one record, build object from JSON
            for (dynamic oneNews in newsList) {
              news.add(News.fromJson(oneNews));
            }
          }
          return news;
        }
      },
      onError: (error) {
        _log.severe("Error while fetching news list : $error");
        throw Exception(error);
      },
    );
  }

  /// Get a news from the database given its [id].
  Future<News> getNewsById(int id) async {
    _log.info("Getting news $id from database...");

    final String newsByIdQuery = """
      query GetNewsById(\$id: Long!) {
        getNewsById(id: \$id) {
          id
          title
          catchLine
          content
          newsDate
          likedNews {
            member {
              id
              firstName
              lastName
            }
          }
          createdOn
          createdBy {
            firstName
            lastName
          }
          modifiedOn
          modifiedBy {
            firstName
            lastName
          }
        }
      }
    """;

    return GraphQLConnection()
        .graphQLClient
        .query(
          QueryOptions(
            document: parseString(newsByIdQuery),
            variables: {'id': id},
            fetchPolicy: FetchPolicy.noCache,
          ),
        )
        .then(
      (result) {
        if (result.hasException) {
          // usually ClientException means invalid or expired token
          if (result.exception.linkException != null) {
            throw Exception(result.exception.linkException.toString());
          } else if (result.exception.graphqlErrors != null && result.exception.graphqlErrors.isNotEmpty) {
            throw Exception(result.exception.graphqlErrors.first.message);
          } else {
            throw Exception(result.exception.toString());
          }
        } else {
          // if no news found, newsById will be null
          if (result.data['getNewsById'] == null) {
            return null;
          }
          return News.fromJson(result.data['getNewsById']);
        }
      },
      onError: (error) {
        throw Exception(error);
      },
    );
  }

  /// Mark the news identified by the specified [newsId] as liked for the member identified by the specified [memberId]
  Future<News> likeNews(int newsId, int memberId) async {
    _log.info("Liking news $newsId for member $memberId ...");

    final String likeNewsMutation = """
      mutation LikeNews(\$newsId: Int!, \$memberId: Int!) {
        likeNews(
            newsId: \$newsId
            memberId: \$memberId
        )
        {
          id
          title
          catchLine
          content
          newsDate
          likedNews {
            id
            member {
              id
              firstName
              lastName
            }
          }
          createdOn
          createdBy {
            firstName
            lastName
          }
          modifiedOn
          modifiedBy {
            firstName
            lastName
          }
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(likeNewsMutation),
      variables: {'newsId': newsId, 'memberId': memberId},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      // usually ClientException means invalid or expired token
      if (result.exception.linkException != null) {
        throw Exception(result.exception.linkException.toString());
      } else if (result.exception.graphqlErrors != null && result.exception.graphqlErrors.isNotEmpty) {
        throw Exception(result.exception.graphqlErrors.first.message);
      } else {
        throw Exception(result.exception.toString());
      }
    } else {
      return News.fromJson(result.data['likeNews']);
    }
  }

  /// Mark the news identified by the specified [newsId] as not liked for the member identified by the specified [memberId]
  Future<News> unlikeNews(int newsId, int memberId) async {
    _log.info("Unliking news $newsId for member $memberId ...");

    final String unlikeNewsMutation = """
      mutation UnlikeNews(\$newsId: Int!, \$memberId: Int!) {
        unlikeNews(
            newsId: \$newsId
            memberId: \$memberId
        )
        {
          id
          title
          catchLine
          content
          newsDate
          likedNews {
            member {
              id
              firstName
              lastName
            }
          }
          createdOn
          createdBy {
            firstName
            lastName
          }
          modifiedOn
          modifiedBy {
            firstName
            lastName
          }
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(unlikeNewsMutation),
      variables: {'newsId': newsId, 'memberId': memberId},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      // usually ClientException means invalid or expired token
      if (result.exception.linkException != null) {
        throw Exception(result.exception.linkException.toString());
      } else if (result.exception.graphqlErrors != null && result.exception.graphqlErrors.isNotEmpty) {
        throw Exception(result.exception.graphqlErrors.first.message);
      } else {
        throw Exception(result.exception.toString());
      }
    } else {
      if (result.data['unlikeNews'] != null) {
        return News.fromJson(result.data['unlikeNews']);
      }
    }
  }

  /// Create the specified [news] into the database.
  Future<News> createNews(News news) async {
    _log.info("Creating news ${news.title}...");

    final String newNewsMutation = """
      mutation CreateNews(\$title: String!, \$catchLine: String!, \$content: String!, \$newsDate: String!, \$memberId: Long!) {
        createNews(
            title: \$title
            catchLine: \$catchLine
            content: \$content
            newsDate: \$newsDate
            memberId: \$memberId
        )
        {
          id
          title
          catchLine
          content
          newsDate
          likedNews {
            member {
              id
              firstName
              lastName
            }
          }
          createdOn
          createdBy {
            firstName
            lastName
          }
          modifiedOn
          modifiedBy {
            firstName
            lastName
          }          
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(newNewsMutation),
      variables: {'title': news.title, 'catchLine': news.catchLine, 'content': news.content, 'newsDate': news.newsDate, 'memberId': news.createdBy},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      // usually ClientException means invalid or expired token
      if (result.exception.linkException != null) {
        throw Exception(result.exception.linkException.toString());
      } else if (result.exception.graphqlErrors != null && result.exception.graphqlErrors.isNotEmpty) {
        throw Exception(result.exception.graphqlErrors.first.message);
      } else {
        throw Exception(result.exception.toString());
      }
    } else {
      _log.info("Query result value : ${result.data}");
      return News.fromJson(result.data['createNews']);
    }
  }

  /// Update the specified [news] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<void> updateNews(News news) async {
    _log.info("Updating news ${news.title}...");

    final String newNewsMutation = """
      mutation UpdateNews(\$newsId: Long!, \$title: String!, \$catchLine: String!, \$content: String!, \$newsDate: String!, \$memberId: Long!) {
        newNews(
            newsId: \$newsId
            title: \$title
            catchLine: \$catchLine
            content: \$content
            newsDate: \$newsDate
            memberId: \$memberId
        )
        {
          id
          title
          catchLine
          content
          newsDate
          likedNews {
            member {
              id
              firstName
              lastName
            }
          }
          createdOn
          createdBy {
            firstName
            lastName
          }
          modifiedOn
          modifiedBy {
            firstName
            lastName
          }          
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(newNewsMutation),
      variables: {'newsId': news.id, 'title': news.title, 'catchLine': news.catchLine, 'content': news.content, 'newsDate': news.newsDate, 'memberId': news.modifiedBy},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      // usually ClientException means invalid or expired token
      if (result.exception.linkException != null) {
        throw Exception(result.exception.linkException.toString());
      } else if (result.exception.graphqlErrors != null && result.exception.graphqlErrors.isNotEmpty) {
        throw Exception(result.exception.graphqlErrors.first.message);
      } else {
        throw Exception(result.exception.toString());
      }
    } else {
      _log.info("Query result value : ${result.data}");
      return News.fromJson(result.data['newNews']);
    }
  }
  /*Future<void> updateNews(News news) async {
    // call to API
    final response = await http.post(Uri.parse(API_ROOT_URL + API_UPDATE_NEWS_ENDPOINT),
        headers: {'Content-Type': 'application/json'}, body: json.encode(news.toJson()));

    // handle server response code
    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 503) {
      throw Exception('Failed to update the news');
    } else {
      throw Exception('Unexpected server response, news has not been updated');
    }
  }*/

  /// Delete specified [news] from the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 204
  Future<void> deleteNews(News news) async {
    // call to API
    final response = await http.post(Uri.parse(API_ROOT_URL + API_DELETE_NEWS_ENDPOINT),
        headers: {'Content-Type': 'application/json'}, body: json.encode(news.toJson()));

    if (response.statusCode != 204) {
      throw Exception('Unexpected server response');
    }
  }
}
