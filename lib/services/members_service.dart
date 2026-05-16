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

import 'dart:convert';
import 'dart:io';

import 'package:ccteam/models/member.dart';
import 'package:ccteam/models/membership_fee.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_graphql_exception.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:path/path.dart';

class MembersService {
  static final Logger _log = new Logger('MembersService');

  /// Check the account associated to the specified member [email].
  /// It returns a specific status code according to the account current status.
  Future<http.Response> checkAccount(String email) {
    return http.post(
      Uri.parse(API_BASE_URL + API_CHECK_ACCOUNT_ENDPOINT),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{'email': email}),
    );
  }

  /// Pre-register a member given its e-mail address, first name and last name.
  /// It creates the account with minimal information, but the user will still need to
  /// confirm its e-mail address and create a passcode to complete the registration process.
  Future<http.Response> preRegister(String firstName, String lastName, String email) {
    return http.post(
      Uri.parse(API_BASE_URL + API_PRE_REGISTER_ENDPOINT),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{'firstName': firstName, 'lastName': lastName, 'email': email}),
    );
  }

  /// Send a new one-time password to the specified member e-mail address.
  /// It is used in case user has not entered the OTP in the given time, or if he manually ask a new OTP.
  Future<http.Response> resendOtp(String email) {
    return http.post(
      Uri.parse(API_BASE_URL + API_RESEND_OTP_ENDPOINT),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{'email': email}),
    );
  }

  /// Confirm the specified member e-mail address by checking the specified
  /// one-time password which was sent on registration.
  Future<http.Response> confirmEmail(String email, String otp) {
    return http.post(
      Uri.parse(API_BASE_URL + API_CONFIRM_EMAIL_ENDPOINT),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{'email': email, 'otp': otp}),
    );
  }

  /// Complete the registration for the specified member account, especially by setting the specified password.
  Future<http.Response> completeRegistration(String email, String passcode) {
    return http.post(
      Uri.parse(API_BASE_URL + API_COMPLETE_REGISTRATION_ENDPOINT),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{'email': email, 'password': passcode}),
    );
  }

  /// Authenticate the user according to the the specified [email] and [password].
  /// The response will contains the issued JWT token.
  Future<http.Response> authenticate(String email, String password) {
    return http.post(
      Uri.parse(API_BASE_URL + API_AUTHENTICATE_ENDPOINT),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );
  }

  /// Lightweight count of all members. Used by the home stats panel
  /// so non-MEMBER accounts (which can't fetch the full members list)
  /// still see a total.
  Future<int?> fetchMembersCount() async {
    _log.info("Getting members count from database...");

    final String query = """
      query GetMembersCount {
        getMembersCount
      }
    """;

    final QueryResult result = await GraphQLConnection().graphQLClient.query(
      QueryOptions(document: parseString(query), fetchPolicy: FetchPolicy.noCache),
    );
    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    }
    final dynamic v = result.data?['getMembersCount'];
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  /// Fetch all members from the database according to the specified text [filter].
  /// Returns all records if [filter] is null or empty.
  Future<List<Member>> fetchMembers(String? filter) async {
    _log.info("Getting all members from database...");

    final String query = """
      query GetMembersFiltered(\$text: String) {
        getMembersFiltered(text: \$text) {
          id
          firstName
          lastName
          hasAvatar
          riderNumber
          headerPalette
          bikes {
            id
            manufacturer
            modelName
            engineSize
            year
            current
          }
          active
          role
          boardRole
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(
          QueryOptions(document: parseString(query), variables: {'text': filter}, fetchPolicy: FetchPolicy.noCache),
        )
        .then(
          (result) {
            final List<Member> members = [];
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              dynamic memberList = result.data!['getMembersFiltered'];
              if (memberList == null) {
                _log.info("getMembersFiltered returned null data");
              } else if (memberList is Map<String, dynamic> && memberList.isEmpty) {
                _log.info("getMembersFiltered returned empty data");
              } else {
                for (dynamic member in memberList) {
                  members.add(Member.fromJson(member));
                }
              }
              return members;
            }
          },
          onError: (error) {
            throw Exception(error);
          },
        );
  }

  /// Get a member from the database given its [id].
  Future<Member> getMemberById(int id) async {
    _log.info("Getting member $id from database...");

    final String query = """
      query GetMemberById(\$id: Long!) {
        getMemberById(id: \$id) {
          id
          firstName
          lastName
          email
          phone
          hasAvatar
          riderNumber
          headerPalette
          bikes {
            id
            manufacturer
            modelName
            engineSize
            year
            current
          }
          membershipFees {
            id
            year
            amount
            paid
            createdOn
            modifiedOn
          }
          role
          boardRole
          active
          registrationDate
          eventMembers {
            id
            event {
              id
              title
              startDate
              endDate
              track {
                id
                name
                distance
                lapRecord
              }
              organizer {
                id
                name
              }
              price
              participants {
                id
              }
            }
            bike {
              id
              manufacturer
              modelName
              engineSize
              year
            }
          }
          createdOn
          modifiedOn
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(QueryOptions(document: parseString(query), variables: {'id': id}, fetchPolicy: FetchPolicy.noCache))
        .then(
          (result) {
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              if (result.data!['getMemberById'] == null) {
                throw CustomGraphQlException("member_not_found", "Member not found");
              }
              return Member.fromJson(result.data!['getMemberById']);
            }
          },
          onError: (error) {
            throw Exception(error);
          },
        );
  }

  /// Get the member corresponding to the specified [email].
  Future<Member> getMemberByEmail(String email) async {
    _log.info("Getting member $email from database...");

    final String query = """
      query GetMemberByEmail(\$email: String!) {
        getMemberByEmail(email: \$email) {
          id
          firstName
          lastName
          email
          phone
          hasAvatar
          riderNumber
          headerPalette
          bikes {
            id
            manufacturer
            modelName
            engineSize
            year
            current
          }
          membershipFees {
            id
            year
            amount
            paid
            createdOn
            modifiedOn
          }
          active
          role
          boardRole
          registrationDate
          eventMembers {
            id
            event {
              id
              title
              startDate
              endDate
              track {
                id
                name
                distance
                lapRecord
              }
              organizer {
                id
                name
              }
              price
              participants {
                id
              }
            }
            bike {
              id
              manufacturer
              modelName
              engineSize
              year
            }
          }
          likedNews {
            id
            news {
              id
              title
            }
          }
          createdOn
          modifiedOn
        }
      }
    """;

    return GraphQLConnection().graphQLClient
        .query(
          QueryOptions(document: parseString(query), variables: {'email': email}, fetchPolicy: FetchPolicy.noCache),
        )
        .then(
          (result) {
            if (result.hasException) {
              throw AppUtils.handleGraphQlException(result)!;
            } else {
              if (result.data!['getMemberByEmail'] == null) {
                throw CustomGraphQlException("member_not_found", "Member not found");
              }
              return Member.fromJson(result.data!['getMemberByEmail']);
            }
          },
          onError: (error) {
            throw Exception(error);
          },
        );
  }

  /// Create the specified [member] into the database.
  /// Return the created member.
  Future<Member> createMember(Member member) async {
    _log.info("Creating member ${member.email} ...");

    final String query = """
      mutation CreateMember(\$firstName: String!, \$lastName: String!, \$email: String!, \$phone: String, \$riderNumber: Int, \$avatarFile: String, \$avatarFileName: String, \$active: Boolean!, \$role: Role!) {
        createMember(
          firstName: \$firstName
          lastName: \$lastName
          email: \$email
          phone: \$phone
          riderNumber: \$riderNumber
          avatarFile: \$avatarFile
          avatarFileName: \$avatarFileName
          active: \$active
          role: \$role
        ) {
          id
          firstName
          lastName
          email
          phone
          hasAvatar
          riderNumber
          headerPalette
          bikes {
            id
            manufacturer
            modelName
            engineSize
            year
            current
          }
          membershipFees {
            id
            year
            amount
            paid
            createdOn
            modifiedOn
          }
          active
          role
          boardRole
          registrationDate
          eventMembers {
            id
            event {
              id
              title
              startDate
              endDate
              track {
                id
                name
                distance
                lapRecord
              }
              organizer {
                id
                name
              }
              price
              participants {
                id
              }
            }
            bike {
              id
              manufacturer
              modelName
              engineSize
              year
            }
          }
          likedNews {
            news {
              id
              title
            }
          }
          createdOn
          modifiedOn
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(query),
      variables: {
        'firstName': member.firstName,
        'lastName': member.lastName,
        'email': member.email,
        'phone': member.phone,
        'avatarFile': member.avatar,
        'avatarFileName': member.avatarName,
        'riderNumber': member.riderNumber,
        'active': member.active,
        'role': member.role?.toString().split('.').last,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Member.fromJson(result.data!['createMember']);
    }
  }

  /// Update the specified [member] into the database.
  /// Return the updated member.
  Future<Member> updateMember(Member member) async {
    _log.info("Updating member ${member.email} ...");

    final String query = """
      mutation UpdateMember(\$memberId: Long!, \$firstName: String!, \$lastName: String!, \$email: String!, \$phone: String, \$riderNumber: Int, \$avatarFile: String, \$avatarFileName: String, \$active: Boolean!, \$role: Role!) {
        updateMember(
          memberId: \$memberId
          firstName: \$firstName
          lastName: \$lastName
          email: \$email
          phone: \$phone
          riderNumber: \$riderNumber
          avatarFile: \$avatarFile
          avatarFileName: \$avatarFileName
          active: \$active
          role: \$role
        ) {
          id
          firstName
          lastName
          email
          phone
          hasAvatar
          riderNumber
          headerPalette
          bikes {
            id
            manufacturer
            modelName
            engineSize
            year
            current
          }
          membershipFees {
            id
            year
            amount
            paid
            createdOn
            modifiedOn
          }
          active
          role
          boardRole
          registrationDate
          eventMembers {
            id
            event {
              id
              title
              startDate
              endDate
              track {
                id
                name
                distance
                lapRecord
              }
              organizer {
                id
                name
              }
              price
              participants {
                id
              }
            }
            bike {
              id
              manufacturer
              modelName
              engineSize
              year
            }
          }
          likedNews {
            news {
              id
              title
            }
          }
          createdOn
          modifiedOn
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(query),
      variables: {
        'memberId': member.id,
        'firstName': member.firstName,
        'lastName': member.lastName,
        'email': member.email,
        'phone': member.phone,
        'avatarFile': member.avatar,
        'avatarFileName': member.avatarName,
        'riderNumber': member.riderNumber,
        'active': member.active,
        'role': member.role?.toString().split('.').last,
      },
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Member.fromJson(result.data!['updateMember']);
    }
  }

  /// Delete the specified [member] from the database.
  /// Return the original member that have been deleted.
  Future<Member> deleteMember(Member member) async {
    _log.info("Deleting member ${member.email} ...");

    final String query = """
      mutation DeleteMember(\$memberId: Long!) {
        deleteMember(
            memberId: \$memberId
        )
        {
          id
          firstName
          lastName
          email
          phone
          hasAvatar
          bikes {
            id
            manufacturer
            modelName
            engineSize
            year
            current
          }
          active
          role
          boardRole
          registrationDate
          likedNews {
            news {
              id
              title
            }
          }
          createdOn
          modifiedOn          
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(query),
      variables: {'memberId': member.id},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Member.fromJson(result.data!['deleteMember']);
    }
  }

  /// Assign (or clear, by passing null) the executive board role of the
  /// given [member]. Server-side enforces uniqueness of each role.
  Future<Member> setBoardRole(Member member, BoardRole? boardRole) async {
    _log.info("Setting board role of member ${member.email} to $boardRole");

    final String query = """
      mutation SetBoardRole(\$memberId: Long!, \$boardRole: BoardRole) {
        setBoardRole(memberId: \$memberId, boardRole: \$boardRole) {
          id
          firstName
          lastName
          email
          role
          boardRole
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(query),
      variables: {'memberId': member.id, 'boardRole': boardRole?.toString().split('.').last},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Member.fromJson(result.data!['setBoardRole']);
    }
  }

  /// Set the colour palette index the member has chosen for their
  /// detail-page header background. Passing `null` resets the choice.
  Future<Member> setMemberPalette(int memberId, int? headerPalette) async {
    _log.info("Setting palette of member $memberId to $headerPalette");

    final String query = """
      mutation SetMemberPalette(\$memberId: Long!, \$headerPalette: Int) {
        setMemberPalette(memberId: \$memberId, headerPalette: \$headerPalette) {
          id
          firstName
          lastName
          email
          headerPalette
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(query),
      variables: {'memberId': memberId, 'headerPalette': headerPalette},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return Member.fromJson(result.data!['setMemberPalette']);
    }
  }

  /// Change the passcode of the currently authenticated member.
  ///
  /// The target member is implicit (taken from the JWT subject server-side),
  /// so a user can only ever change their own passcode. The server returns
  /// a `bad_credentials` GraphQL error when [currentPasscode] doesn't match,
  /// `invalid_passcode` for malformed new passcodes, and `same_passcode`
  /// when [newPasscode] equals the current one, the caller can use these
  /// codes to display the appropriate inline error.
  ///
  /// We log the call but **never** the passcodes themselves.
  Future<bool> changePasscode(String currentPasscode, String newPasscode) async {
    _log.info("Calling changePasscode mutation");

    final String query = """
      mutation ChangePasscode(\$currentPasscode: String!, \$newPasscode: String!) {
        changePasscode(currentPasscode: \$currentPasscode, newPasscode: \$newPasscode)
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(query),
      variables: {'currentPasscode': currentPasscode, 'newPasscode': newPasscode},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    }
    return result.data!['changePasscode'] == true;
  }

  /// Ask for a password reset for the account related to the specified [email].
  /// Send a POST request to the Restful API.
  /// Throw an exception if response status code is different from 201.
  Future<Member> askPassword(String email) async {
    // convert Member object to JSON string
    final String jsonString = '{email:$email}';

    // call to API
    final response = await http.post(
      Uri.parse(API_OLD_ROOT_URL + API_ASK_PASSWORD_MEMBER_ENDPOINT),
      headers: {'Content-Type': 'application/json'},
      body: jsonString,
    );

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

  /// Upload the specified avatar [file] for the specified [memberId].
  /// Send a POST request to the Restful API.
  /// Throw an exception if response status code is different from 200.
  /// Return the uploaded avatar relative path.
  Future<String> uploadAvatar(File file, int memberId) async {
    final http.ByteStream stream = new http.ByteStream(Stream.castFrom(file.openRead()));
    final int length = await file.length();
    final Uri uri = Uri.parse(API_OLD_ROOT_URL + API_UPLOAD_MEMBER_AVATAR_ENDPOINT);
    final http.MultipartRequest request = new http.MultipartRequest("POST", uri);
    final http.MultipartFile multipartFile = new http.MultipartFile(
      'avatar',
      stream,
      length,
      filename: basename(file.path),
    );
    request.files.add(multipartFile);

    Map<String, String> params = new Map();
    params.putIfAbsent("memberId", () => "$memberId");
    request.fields.addAll(params);

    // call to API
    final response = await request.send();

    // handle server response code
    if (response.statusCode == 200) {
      late String path;
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

  /// Delete avatar for the specified [memberId].
  /// Send a POST request to the Restful API.
  /// Throw an exception if response status code is different from 200.
  Future<void> deleteAvatar(int memberId) async {
    // convert Member object to JSON string
    final String jsonString = '{\"memberId\":$memberId}';

    // call to API
    final response = await http.post(
      Uri.parse(API_OLD_ROOT_URL + API_DELETE_MEMBER_AVATAR_ENDPOINT),
      headers: {'Content-Type': 'application/json'},
      body: jsonString,
    );

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

  Future<MembershipFee> addMembershipFee(int memberId, int year, double amount, bool paid) async {
    final String query = """
      mutation AddMembershipFee(\$memberId: Long!, \$year: Int!, \$amount: Float!, \$paid: Boolean!) {
        addMembershipFee(memberId: \$memberId, year: \$year, amount: \$amount, paid: \$paid) {
          id
          year
          amount
          paid
          createdOn
          modifiedOn
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(query),
      variables: {'memberId': memberId, 'year': year, 'amount': amount, 'paid': paid},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return MembershipFee.fromJson(result.data!['addMembershipFee']);
    }
  }

  Future<MembershipFee> updateMembershipFee(int feeId, int year, double amount, bool paid) async {
    final String query = """
      mutation UpdateMembershipFee(\$feeId: Long!, \$year: Int!, \$amount: Float!, \$paid: Boolean!) {
        updateMembershipFee(feeId: \$feeId, year: \$year, amount: \$amount, paid: \$paid) {
          id
          year
          amount
          paid
          createdOn
          modifiedOn
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(query),
      variables: {'feeId': feeId, 'year': year, 'amount': amount, 'paid': paid},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return MembershipFee.fromJson(result.data!['updateMembershipFee']);
    }
  }

  Future<MembershipFee> deleteMembershipFee(int feeId) async {
    final String query = """
      mutation DeleteMembershipFee(\$feeId: Long!) {
        deleteMembershipFee(feeId: \$feeId) {
          id
          year
          amount
          paid
          createdOn
          modifiedOn
        }
      }
    """;

    final MutationOptions mutationOptions = new MutationOptions(
      document: parseString(query),
      variables: {'feeId': feeId},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await GraphQLConnection().graphQLClient.mutate(mutationOptions);

    if (result.hasException) {
      throw AppUtils.handleGraphQlException(result)!;
    } else {
      return MembershipFee.fromJson(result.data!['deleteMembershipFee']);
    }
  }
}
