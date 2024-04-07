/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of CCTeam application.
 *
 * CCTeam is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * CCTeam is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with CCTeam. If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:ccteam/models/news.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
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
              id
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
          throw AppUtils.handleGraphQlException(result)!;
        } else {
          dynamic newsList = result.data!['getAllNews'];
          if (newsList == null) {
            _log.info("GetAllNews returned null data");
          } else if (newsList is Map<String, dynamic> && newsList.isEmpty) {
            _log.info("GetAllNews returned empty data");
          } else {
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
  Future<News?> getNewsById(int id) async {
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
          throw AppUtils.handleGraphQlException(result)!;
        } else {
          if (result.data!['getNewsById'] == null) {
            return null;
          }
          return News.fromJson(result.data!['getNewsById']);
        }
      },
      onError: (error) {
        throw Exception(error);
      },
    );
  }

  /// Mark the news identified by the specified [newsId] as liked for the member identified by the specified [memberId].
  /// Return the up-to-date liked news.
  Future<News> likeNews(int newsId, int memberId) async {
    _log.info("Liking news $newsId for member $memberId ...");

    final String likeNewsMutation = """
      mutation LikeNews(\$newsId: Long!, \$memberId: Long!) {
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
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return News.fromJson(result.data!['likeNews']);
    }
  }

  /// Mark the news identified by the specified [newsId] as not liked for the member identified by the specified [memberId].
  /// Return the up-to-date unliked news.
  Future<News?> unlikeNews(int newsId, int memberId) async {
    _log.info("Unliking news $newsId for member $memberId ...");

    final String unlikeNewsMutation = """
      mutation UnlikeNews(\$newsId: Long!, \$memberId: Long!) {
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
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      if (result.data!['unlikeNews'] != null) {
        return News.fromJson(result.data!['unlikeNews']);
      }
      return null;
    }
  }

  /// Create the specified [news] into the database.
  /// Return the created news.
  Future<News> createNews(News news) async {
    _log.info("Creating news ${news.title} ...");

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
      variables: {
        'title': news.title,
        'catchLine': news.catchLine,
        'content': news.content,
        'newsDate': news.newsDate!.toIso8601String(),
        'memberId': news.createdBy!.id
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return News.fromJson(result.data!['createNews']);
    }
  }

  /// Update the specified [news] into the database.
  /// Return the updated news.
  Future<News> updateNews(News news) async {
    _log.info("Updating news ${news.title} ...");

    final String editNewsMutation = """
      mutation UpdateNews(\$newsId: Long!, \$title: String!, \$catchLine: String!, \$content: String!, \$newsDate: String!, \$memberId: Long!) {
        updateNews(
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
      document: parseString(editNewsMutation),
      variables: {
        'newsId': news.id,
        'title': news.title,
        'catchLine': news.catchLine,
        'content': news.content,
        'newsDate': news.newsDate!.toIso8601String(),
        'memberId': news.modifiedBy!.id
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return News.fromJson(result.data!['updateNews']);
    }
  }

  /// Delete the specified [news] from the database.
  /// return the original news that have been deleted.
  Future<News> deleteNews(News news) async {
    _log.info("Deleting news ${news.title} ...");

    final String editNewsMutation = """
      mutation DeleteNews(\$newsId: Long!) {
        deleteNews(
            newsId: \$newsId
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
      document: parseString(editNewsMutation),
      variables: {
        'newsId': news.id,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return News.fromJson(result.data!['deleteNews']);
    }
  }
}
