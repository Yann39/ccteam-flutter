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

/// Class representing a team member
class Member {
  int id;
  String firstName;
  String lastName;
  String email;
  String password;
  String avatar;
  String otp;
  bool active;
  bool admin;
  String phone;
  String bike;
  DateTime registrationDate;
  DateTime createdOn;
  DateTime modifiedOn;

  Member({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.avatar,
    this.otp,
    this.active,
    this.admin,
    this.phone,
    this.bike,
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
      avatar: ${this.avatar},
      otp: ${this.otp},
      active: ${this.active},
      admin: ${this.admin},
      phone: ${this.phone},
      bike: ${this.bike},
      registrationDate: ${this.registrationDate?.toIso8601String()},
      createdOn: ${this.createdOn?.toIso8601String()},
      modifiedOn: ${this.modifiedOn?.toIso8601String()},
    }""";
  }

  Member.fromGraphQl(Map<String, dynamic> json)
      : id = json['id'] != null ? int.parse(json['id']) : -1,
        firstName = json['firstName'],
        lastName = json['lastName'],
        email = json['email'],
        password = json['password'],
        avatar = json['avatar'],
        otp = json['otp'],
        active = json['active'] != null && json['active'] == '1',
        admin = json['admin'] != null && json['admin'] == '1',
        phone = json['phone'],
        bike = json['bike'],
        registrationDate = json['registrationDate'] != null
            ? DateFormat("yyyy-MM-dd HH:mm:ss", "fr").parseStrict(json['registrationDate'])
            : null,
        createdOn =
            json['createdOn'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss", "fr").parseStrict(json['createdOn']) : null,
        modifiedOn =
            json['modifiedOn'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss", "fr").parseStrict(json['modifiedOn']) : null;

  /// Convert [json] map to the corresponding object
  Member.fromJson(Map<String, dynamic> json)
      : id = json['id'] != null ? int.parse(json['id']) : -1,
        firstName = json['first_name'],
        lastName = json['last_name'],
        email = json['email'],
        password = json['password'],
        avatar = json['avatar'],
        otp = json['otp'],
        active = json['active'] != null && json['active'] == '1',
        admin = json['admin'] != null && json['admin'] == '1',
        phone = json['phone'],
        bike = json['bike'],
        registrationDate = json['registration_date'] != null
            ? DateFormat("yyyy-MM-dd HH:mm:ss", "fr").parseStrict(json['registration_date'])
            : null,
        createdOn =
            json['created_on'] != null ? DateFormat("yyyy-MM-dd HH:mm:ss", "fr").parseStrict(json['created_on']) : null,
        modifiedOn = json['modified_on'] != null
            ? DateFormat("yyyy-MM-dd HH:mm:ss", "fr").parseStrict(json['modified_on'])
            : null;

  /// Convert [member] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "password": password,
        "avatar": avatar,
        "otp": otp,
        "active": active,
        "admin": admin,
        "phone": phone,
        "bike": bike,
        "registration_date": registrationDate?.toIso8601String(),
        "created_on": createdOn?.toIso8601String(),
        "modified_on": modifiedOn?.toIso8601String(),
      };
}
