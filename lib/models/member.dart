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

/// class representing a team member
class Member {
  int id;
  String firstName;
  String lastName;
  String email;
  String password;
  String avatar;
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
      active: ${this.active},
      admin: ${this.admin},
      phone: ${this.phone},
      bike: ${this.bike},
      registrationDate: ${this.registrationDate != null ? this.registrationDate.toIso8601String() : ""},
      createdOn: ${this.createdOn != null ? this.createdOn.toIso8601String() : ""},
      modifiedOn: ${this.modifiedOn != null ? this.modifiedOn.toIso8601String() : ""},
    }""";
  }

  /// Convert [json] map to the corresponding object
  Member.fromJson(Map<String, dynamic> json)
      : id = json['id'] != null ? int.parse(json['id']) : -1,
        firstName = json['first_name'],
        lastName = json['last_name'],
        email = json['email'],
        password = json['password'],
        avatar = json['avatar'],
        active = json['active'] != null && json['active'] == '1',
        admin = json['admin'] != null && json['admin'] == '1',
        phone = json['phone'],
        bike = json['bike'],
        registrationDate = json['registration_date'] != null ? new DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['registration_date']) : null,
        createdOn = json['created_on'] != null ? new DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['created_on']) : null,
        modifiedOn = json['modified_on'] != null ? new DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(json['modified_on']) : null;

  /// Convert [member] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "password": password,
        "avatar": avatar,
        "active": active,
        "admin": admin,
        "phone": phone,
        "bike": bike,
        "registration_date": registrationDate != null ? registrationDate.toIso8601String() : null,
        "created_on": createdOn != null ? createdOn.toIso8601String() : null,
        "modified_on": modifiedOn != null ? modifiedOn.toIso8601String() : null,
      };
}
