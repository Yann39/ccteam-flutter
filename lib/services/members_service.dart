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
import 'dart:io';

import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/graphql_connection.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class MembersService {
  /// Check the account associated to the specified member [email].
  /// It returns a specific status code according to the account current status.
  Future<http.Response> checkAccount(String email) {
    return http.post(
      API_ROOT_URL + API_CHECK_ACCOUNT_ENDPOINT,
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{'email': email}),
    );
  }

  /// Pre-register the specified [member] given its e-mail address, first name and last name.
  /// It creates the account with minimal information, but the user will still need to
  /// confirm its e-mail address and create a passcode to complete the registration process.
  Future<http.Response> preRegister(Member member) {
    return http.post(
      API_ROOT_URL + API_PRE_REGISTER_ENDPOINT,
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(
          <String, String>{'firstName': member.firstName, 'lastName': member.lastName, 'email': member.email}),
    );
  }

  /// Send a new one-time password to the specified [member] e-mail address.
  /// It is used in case user has not entered the OTP in the given time, or if he manually ask a new OTP.
  Future<http.Response> resendOtp(Member member) {
    return http.post(
      API_ROOT_URL + API_RESEND_OTP_ENDPOINT,
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{'email': member.email}),
    );
  }

  /// Confirm the specified [member] e-mail address by checking the specified
  /// one-time password which was sent on registration.
  Future<http.Response> confirmEmail(Member member) {
    return http.post(
      API_ROOT_URL + API_CONFIRM_EMAIL_ENDPOINT,
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{'email': member.email, 'otp': member.otp}),
    );
  }

  /// Complete the registration for the specified [member] account, especially by setting the specified password.
  Future<http.Response> completeRegistration(Member member) {
    return http.post(
      API_ROOT_URL + API_COMPLETE_REGISTRATION_ENDPOINT,
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{'email': member.email, 'password': member.password}),
    );
  }

  /// Authenticate the user according to the the specified [email] and [password].
  /// The response will contains the issued JWT token.
  Future<http.Response> authenticate(String email, String password) {
    return http.post(
      API_ROOT_URL + API_AUTHENTICATE_ENDPOINT,
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );
  }

  /// Fetch all members from the database according to the specified text [filter].
  /// Returns all records if [filter] is null or empty.
  Future<List<Member>> fetchMembers(String filter) async {
    final String membersFilteredQuery = """
      query MembersFiltered(\$text: String) {
        membersFiltered(text: \$text) {
          id
          firstName
          lastName
          email
          avatarUrl
          bike
          admin
        }
      }
    """;

    return GraphQLConnection()
        .graphQLClient
        .query(
          QueryOptions(
            documentNode: parseString(membersFilteredQuery),
            variables: {'text': filter},
          ),
        )
        .then(
      (result) {
        final List<Member> members = new List();
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
          for (dynamic m in result.data['membersFiltered']) {
            members.add(Member.fromJson(m));
          }
        }
        return members;
      },
      onError: (error) {
        throw Exception(error);
      },
    );
  }

  /// Get a news from the database given its [id].
  Future<Member> getMemberById(int id) async {
    final String memberByIdQuery = """
      query MemberById(\$id: Int!) {
        memberById(id: \$id) {
          id
          firstName
          lastName
          email
          phone
          avatarUrl
          bike
          admin
          registrationDate
          createdOn
          modifiedOn
        }
      }
    """;

    return GraphQLConnection()
        .graphQLClient
        .query(
          QueryOptions(
            documentNode: parseString(memberByIdQuery),
            variables: {'id': id},
          ),
        )
        .then(
      (result) {
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
          // if no member found, memberById will be null
          if (result.data['memberById'] == null) {
            return null;
          }
          return Member.fromJson(result.data['memberById']);
        }
      },
      onError: (error) {
        throw Exception(error);
      },
    );
  }

  /// Get the member corresponding to the specified [email].
  Future<Member> getMemberByEmail(String email) async {
    final String memberByEmailQuery = """
      query MemberByEmail(\$email: String!) {
        memberByEmail(email: \$email) {
          id
          firstName
          lastName
          email
          phone
          avatarUrl
          bike
          admin
          registrationDate
          createdOn
          modifiedOn
        }
      }
    """;

    return GraphQLConnection()
        .graphQLClient
        .query(
          QueryOptions(
            documentNode: parseString(memberByEmailQuery),
            variables: {'email': email},
          ),
        )
        .then(
      (result) {
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
          // if member not found, memberByEmail will be null
          if (result.data['memberByEmail'] == null) {
            return null;
          }
          return Member.fromJson(result.data['memberByEmail']);
        }
      },
      onError: (error) {
        throw Exception(error);
      },
    );
  }

  /// Create the specified [member] into the database
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 201
  Future<void> createMember(Member member) async {
    // call to API
    final response = await http.post(API_OLD_ROOT_URL + API_CREATE_MEMBER_ENDPOINT,
        headers: {'Content-Type': 'application/json'}, body: member.toJson());

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
    // call to API
    final response = await http.post(API_OLD_ROOT_URL + API_UPDATE_MEMBER_ENDPOINT,
        headers: {'Content-Type': 'application/json'}, body: json.encode(member.toJson()));

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
    // call to API
    final response = await http.post(API_OLD_ROOT_URL + API_DELETE_MEMBER_ENDPOINT,
        headers: {'Content-Type': 'application/json'}, body: json.encode(member.toJson()));

    if (response.statusCode != 204) {
      throw Exception('Unexpected server response');
    }
  }

  /// Ask for a password reset for the account related to the specified [email]
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 201
  Future<void> askPassword(String email) async {
    // convert Member object to JSON string
    final String jsonString = '{email:$email}';

    // call to API
    final response = await http.post(API_OLD_ROOT_URL + API_ASK_PASSWORD_MEMBER_ENDPOINT,
        headers: {'Content-Type': 'application/json'}, body: jsonString);

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

  /// Upload the specified avatar [file] for the specified [memberId]
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  /// Return the uploaded avatar relative path
  Future<String> uploadAvatar(File file, int memberId) async {
    final http.ByteStream stream = new http.ByteStream(Stream.castFrom(file.openRead()));
    final int length = await file.length();
    final Uri uri = Uri.parse(API_OLD_ROOT_URL + API_UPLOAD_MEMBER_AVATAR_ENDPOINT);
    final http.MultipartRequest request = new http.MultipartRequest("POST", uri);
    final http.MultipartFile multipartFile =
        new http.MultipartFile('avatar', stream, length, filename: basename(file.path));
    request.files.add(multipartFile);

    Map<String, String> params = new Map();
    params.putIfAbsent("memberId", () => "$memberId");
    request.fields.addAll(params);

    // call to API
    final response = await request.send();

    // handle server response code
    if (response.statusCode == 200) {
      String path;
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

  /// Delete avatar for the specified [memberId]
  /// Send a POST request to the Restful API
  /// Throw an exception if response status code is different from 200
  Future<void> deleteAvatar(int memberId) async {
    // convert Member object to JSON string
    final String jsonString = '{\"memberId\":$memberId}';

    // call to API
    final response = await http.post(API_OLD_ROOT_URL + API_DELETE_MEMBER_AVATAR_ENDPOINT,
        headers: {'Content-Type': 'application/json'}, body: jsonString);

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
}
