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

import 'package:ccteam/models/record.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';

class RecordsService {
  static final Logger _log = new Logger('LapRecordService');

  /// Fetch all records from the database.
  Future<List<Record>> fetchRecords() async {
    _log.info("Getting all lap records from database...");

    final String query = """
      query GetAllLapRecords() {
        getAllLapRecords {
          id
          recordDate
          lapTime
          conditions
          isPublic
          member {
            id
            email
          }
          bike {
            id
            manufacturer
            modelName
          }
          track {
            id
            name
            lapRecord
          }
          comments
          createdOn
          modifiedOn
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(
          QueryOptions(
            document: parseString(query),
            fetchPolicy: FetchPolicy.noCache,
          ),
        )
        .then(
          (result) {
            final List<Record> records = [];
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              dynamic lapRecordList = result.data!['getAllLapRecords'];
              if (lapRecordList == null) {
                _log.info("getAllLapRecords returned null data");
              } else if (lapRecordList is Map<String, dynamic> &&
                  lapRecordList.isEmpty) {
                _log.info("getAllLapRecords returned empty data");
              } else {
                for (dynamic record in lapRecordList) {
                  records.add(Record.fromJson(record));
                }
              }
              return records;
            }
          },
          onError: (error) {
            _log.severe("Error while fetching lap record list : $error");
            throw Exception(error);
          },
        );
  }

  /// Fetch all records for the specified [trackId] from the database.
  Future<List<Record>> fetchTrackRecords(int trackId) async {
    _log.info("Getting lap records from database for track ID $trackId...");

    final String query = """
      query GetTrackLapRecords(\$trackId: Long!) {
        getTrackLapRecords(trackId: \$trackId) {
          id
          recordDate
          lapTime
          conditions
          isPublic
          member {
            id
            firstName
            lastName
            email
          }
          bike {
            id
            manufacturer
            modelName
          }
          track {
            id
            name
            lapRecord
          }
          comments
          createdOn
          modifiedOn
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(
          QueryOptions(
            document: parseString(query),
            variables: {'trackId': trackId},
            fetchPolicy: FetchPolicy.noCache,
          ),
        )
        .then(
          (result) {
            final List<Record> records = [];
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              dynamic lapRecordList = result.data!['getTrackLapRecords'];
              if (lapRecordList == null) {
                _log.info("getTrackLapRecords returned null data");
              } else if (lapRecordList is Map<String, dynamic> &&
                  lapRecordList.isEmpty) {
                _log.info("getTrackLapRecords returned empty data");
              } else {
                for (dynamic record in lapRecordList) {
                  records.add(Record.fromJson(record));
                }
              }
              return records;
            }
          },
          onError: (error) {
            _log.severe(
              "Error while fetching lap record list for track ID $trackId: $error",
            );
            throw Exception(error);
          },
        );
  }

  /// Fetch all records for the specified [memberId] from the database.
  Future<List<Record>> fetchMemberRecords(int memberId) async {
    _log.info("Getting lap records from database for member ID $memberId...");

    final String query = """
      query GetMemberLapRecords(\$memberId: Long!) {
        getMemberLapRecords(memberId: \$memberId) {
          id
          recordDate
          lapTime
          conditions
          isPublic
          member {
            id
            email
          }
          bike {
            id
            manufacturer
            modelName
          }
          track {
            id
            name
            lapRecord
          }
          comments
          createdOn
          modifiedOn
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(
          QueryOptions(
            document: parseString(query),
            variables: {'memberId': memberId},
            fetchPolicy: FetchPolicy.noCache,
          ),
        )
        .then(
          (result) {
            final List<Record> records = [];
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              dynamic lapRecordList = result.data!['getMemberLapRecords'];
              if (lapRecordList == null) {
                _log.info("getMemberLapRecords returned null data");
              } else if (lapRecordList is Map<String, dynamic> &&
                  lapRecordList.isEmpty) {
                _log.info("getMemberLapRecords returned empty data");
              } else {
                for (dynamic record in lapRecordList) {
                  records.add(Record.fromJson(record));
                }
              }
              return records;
            }
          },
          onError: (error) {
            _log.severe(
              "Error while fetching lap record list for member ID $memberId: $error",
            );
            throw Exception(error);
          },
        );
  }

  /// Fetch all records (public and private) of the logged member from the database.
  /// This is the only query returning private records, the server resolves the member from the authentication token.
  Future<List<Record>> fetchMyRecords() async {
    _log.info("Getting lap records from database for the logged member...");

    final String query = """
      query GetMyLapRecords {
        getMyLapRecords {
          id
          recordDate
          lapTime
          conditions
          isPublic
          member {
            id
            email
          }
          bike {
            id
            manufacturer
            modelName
          }
          track {
            id
            name
            lapRecord
          }
          comments
          createdOn
          modifiedOn
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(
          QueryOptions(
            document: parseString(query),
            fetchPolicy: FetchPolicy.noCache,
          ),
        )
        .then(
          (result) {
            final List<Record> records = [];
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              dynamic lapRecordList = result.data!['getMyLapRecords'];
              if (lapRecordList == null) {
                _log.info("getMyLapRecords returned null data");
              } else if (lapRecordList is Map<String, dynamic> &&
                  lapRecordList.isEmpty) {
                _log.info("getMyLapRecords returned empty data");
              } else {
                for (dynamic record in lapRecordList) {
                  records.add(Record.fromJson(record));
                }
              }
              return records;
            }
          },
          onError: (error) {
            _log.severe(
              "Error while fetching lap record list for the logged member: $error",
            );
            throw Exception(error);
          },
        );
  }

  /// Create the specified [record] into the database.
  Future<Record> createRecord(Record record) async {
    _log.info(
      "Creating lap record for member ID ${record.member!.id} on track ID ${record.track!.id} ...",
    );

    final String newLapRecordMutation = """
      mutation CreateLapRecord(\$memberId: Long!, \$trackId: Long!, \$bikeId: Long!, \$recordDate: String!, \$lapTime: Int!, \$conditions: String!, \$comments: String, \$isPublic: Boolean!) {
        createLapRecord(
          memberId: \$memberId
          trackId: \$trackId
          bikeId: \$bikeId
          recordDate: \$recordDate
          lapTime: \$lapTime
          conditions: \$conditions
          comments: \$comments
          isPublic: \$isPublic
        ) {
          id
          recordDate
          lapTime
          conditions
          isPublic
          member {
            id
            email
          }
          bike {
            id
            manufacturer
            modelName
          }
          track {
            id
            name
            lapRecord
          }
          comments
          createdOn
          modifiedOn
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(newLapRecordMutation),
      variables: {
        'memberId': record.member!.id,
        'trackId': record.track!.id,
        'bikeId': record.bike!.id,
        'recordDate': record.recordDate!.toIso8601String(),
        'lapTime': record.lapTime,
        'conditions': record.conditions,
        'comments': record.comments,
        // a record whose visibility was never set explicitly is public
        'isPublic': record.isPublic ?? true,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(
      mutationOptions,
    );

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Record.fromJson(result.data!['createLapRecord']);
    }
  }

  /// Update the specified [record] into the database.
  Future<Record> updateRecord(Record record) async {
    _log.info("Updating lap record with ID ${record.id} ...");

    final String newLapRecordMutation = """
      mutation UpdateLapRecord(\$lapRecordId: Long!, \$trackId: Long!, \$bikeId: Long!, \$recordDate: String!, \$lapTime: Int!, \$conditions: String!, \$comments: String, \$isPublic: Boolean!) {
        updateLapRecord(
          lapRecordId: \$lapRecordId
          trackId: \$trackId
          bikeId: \$bikeId
          recordDate: \$recordDate
          lapTime: \$lapTime
          conditions: \$conditions
          comments: \$comments
          isPublic: \$isPublic
        ) {
          id
          recordDate
          lapTime
          conditions
          isPublic
          member {
            id
            email
          }
          bike {
            id
            manufacturer
            modelName
          }
          track {
            id
            name
            lapRecord
          }
          comments
          createdOn
          modifiedOn
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(newLapRecordMutation),
      variables: {
        'lapRecordId': record.id,
        'trackId': record.track!.id,
        'bikeId': record.bike!.id,
        'recordDate': record.recordDate!.toIso8601String(),
        'lapTime': record.lapTime,
        'conditions': record.conditions,
        'comments': record.comments,
        // a record whose visibility was never set explicitly is public
        'isPublic': record.isPublic ?? true,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(
      mutationOptions,
    );

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Record.fromJson(result.data!['updateLapRecord']);
    }
  }

  /// Delete specified [record] from the database.
  Future<Record> deleteRecord(Record record) async {
    _log.info("Deleting lap record with ID ${record.id} ...");

    final String lapRecordMutation = """
      mutation DeleteLapRecord(\$lapRecordId: Long!) {
        deleteLapRecord(
          lapRecordId: \$lapRecordId
        ) {
          id
          recordDate
          lapTime
          conditions
          isPublic
          member {
            id
            email
          }
          track {
            id
            name
            lapRecord
          }
          comments
          createdOn
          modifiedOn
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(lapRecordMutation),
      variables: {'lapRecordId': record.id},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(
      mutationOptions,
    );

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Record.fromJson(result.data!['deleteLapRecord']);
    }
  }
}
