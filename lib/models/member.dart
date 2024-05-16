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

import 'package:ccteam/models/event_member.dart';
import 'package:intl/intl.dart';

/// Class representing a member
/// todo add Role attribute ?
class Member {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? phone;
  String? avatar;
  String? avatarName;
  String? bike;
  bool? active;
  bool? verified;
  bool? admin;
  String? otp;
  DateTime? otpDate;
  DateTime? registrationDate;
  List<EventMember>? eventMembers;
  DateTime? createdOn;
  DateTime? modifiedOn;

  Member({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.phone,
    this.avatar,
    this.avatarName,
    this.bike,
    this.active = false,
    this.verified = false,
    this.admin = false,
    this.otp,
    this.otpDate,
    this.registrationDate,
    this.eventMembers,
    this.createdOn,
    this.modifiedOn,
  });

  @override
  String toString() {
    return """{
      id: ${this.id.toString()},
      firstName: ${this.firstName},
      lastName: ${this.lastName},
      email: ${this.email},
      password: ${this.password},
      phone: ${this.phone},
      avatar: ${this.avatar},
      avatarName: ${this.avatarName},
      bike: ${this.bike},
      active: ${this.active},
      verified: ${this.verified},
      admin: ${this.admin},
      otp: ${this.otp},
      otpDate: ${this.otpDate?.toIso8601String()},
      registrationDate: ${this.registrationDate?.toIso8601String()},
      eventMembers: ${this.eventMembers?.map((eventMember) => eventMember.toString())},
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
        avatar = json['avatarFile'],
        avatarName = json['avatarFileName'],
        bike = json['bike'],
        active = json['active'] != null && (json['active'] == '1'),
        verified = json['verified'] != null && (json['verified'] == '1'),
        admin = json['admin'] != null && (json['admin'] == '1'),
        otp = json['otp'],
        otpDate = json['otpDate'] != null ? DateTime.parse(json['otpDate']) : null,
        registrationDate = json['registrationDate'] != null ? DateTime.parse(json['registrationDate']) : null,
        eventMembers = json['eventMembers'] != null
            ? (json['eventMembers'] as List).map((i) => EventMember.fromJson(i)).toList()
            : null,
        createdOn = json['createdOn'] != null ? DateTime.parse(json['createdOn']) : null,
        modifiedOn = json['modifiedOn'] != null ? DateTime.parse(json['modifiedOn']) : null;

  /// Convert [Member] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
        "id": id.toString(),
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
        "phone": phone,
        "avatarFile": avatar,
        "avatarFileName": avatarName,
        "bike": bike,
        "active": active,
        "verified": verified,
        "admin": admin,
        "otp": otp,
        "otpDate": otpDate?.toIso8601String(),
        "registrationDate": registrationDate?.toIso8601String(),
        "eventMembers": eventMembers?.map((i) => i.toJson()),
        "createdOn": createdOn?.toIso8601String(),
        "modifiedOn": modifiedOn?.toIso8601String(),
      };
}
