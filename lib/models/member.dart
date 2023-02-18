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

import 'package:intl/intl.dart';

/// Class representing a member
/// todo add Role attribute ?
class Member {
  int id;
  String firstName;
  String lastName;
  String email;
  String password;
  String phone;
  String avatarUrl;
  String bike;
  bool active;
  bool verified;
  bool admin;
  String otp;
  DateTime otpDate;
  DateTime registrationDate;
  DateTime createdOn;
  DateTime modifiedOn;

  Member({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.phone,
    this.avatarUrl,
    this.bike,
    this.active,
    this.verified,
    this.admin,
    this.otp,
    this.otpDate,
    this.registrationDate,
    this.createdOn,
    this.modifiedOn,
  });

  @override
  String toString() {
    return """{
      id: ${this.id},
      firstName: ${this.firstName},
      lastName: ${this.lastName},
      email: ${this.email},
      password: ${this.password},
      phone: ${this.phone},
      avatarUrl: ${this.avatarUrl},
      bike: ${this.bike},
      active: ${this.active},
      verified: ${this.verified},
      admin: ${this.admin},
      otp: ${this.otp},
      otpDate: ${this.otpDate?.toIso8601String()},
      registrationDate: ${this.registrationDate?.toIso8601String()},
      createdOn: ${this.createdOn?.toIso8601String()},
      modifiedOn: ${this.modifiedOn?.toIso8601String()},
    }""";
  }

  /// Convert [json] map to the corresponding object
  Member.fromJson(Map<String, dynamic> json)
      : id = json['id'] != null ? int.parse(json['id']) : null,
        firstName = json['firstName'],
        lastName = json['lastName'],
        email = json['email'],
        password = json['password'],
        phone = json['phone'],
        avatarUrl = json['avatarUrl'],
        bike = json['bike'],
        active = json['active'] != null && json['active'] == '1',
        verified = json['verified'] != null && json['verified'] == '1',
        admin = json['admin'] != null && json['admin'] == '1',
        otp = json['otp'],
        otpDate = json['otpDate'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss", "fr").parseStrict(json['otpDate']) : null,
        registrationDate = json['registrationDate'] != null
            ? DateFormat("yyyy-MM-dd HH:mm:ss", "fr").parseStrict(json['registrationDate'])
            : null,
        createdOn =
            json['created_on'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss", "fr").parseStrict(json['createdOn']) : null,
        modifiedOn =
            json['modifiedOn'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss", "fr").parseStrict(json['modifiedOn']) : null;

  /// Convert [member] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
        "phone": phone,
        "avatarUrl": avatarUrl,
        "bike": bike,
        "active": active,
        "verified": verified,
        "admin": admin,
        "otp": otp,
        "otpDate": otpDate?.toIso8601String(),
        "registrationDate": registrationDate?.toIso8601String(),
        "createdOn": createdOn?.toIso8601String(),
        "modifiedOn": modifiedOn?.toIso8601String(),
      };
}
