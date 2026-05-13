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

import 'package:ccteam/models/bike.dart';
import 'package:ccteam/models/event_member.dart';
import 'package:ccteam/models/membership_fee.dart';
import 'package:ccteam/utils/enums.dart';

/// Class representing a member
class Member {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? phone;
  String? avatar;
  String? avatarName;
  List<Bike>? bikes;
  List<MembershipFee>? membershipFees;
  bool? active;
  bool? verified;
  MemberRole? role;
  BoardRole? boardRole;
  String? otp;
  DateTime? otpDate;
  DateTime? registrationDate;
  List<EventMember>? eventMembers;
  int? riderNumber;
  int? headerPalette;

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
    this.bikes,
    this.membershipFees,
    this.active = false,
    this.verified = false,
    this.role = MemberRole.ROLE_USER,
    this.boardRole,
    this.otp,
    this.otpDate,
    this.registrationDate,
    this.eventMembers,
    this.riderNumber,
    this.headerPalette,
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
      bikes: ${this.bikes?.map((bike) => bike.toString())},
      membershipFees: ${this.membershipFees?.map((fee) => fee.toString())},
      active: ${this.active},
      verified: ${this.verified},
      role: ${this.role},
      boardRole: ${this.boardRole},
      otp: ${this.otp},
      otpDate: ${this.otpDate?.toIso8601String()},
      registrationDate: ${this.registrationDate?.toIso8601String()},
      eventMembers: ${this.eventMembers?.map((eventMember) => eventMember.toString())},
      riderNumber: ${this.riderNumber},
      createdOn: ${this.createdOn?.toIso8601String()},
      modifiedOn: ${this.modifiedOn?.toIso8601String()},
    }""";
  }

  /// Convert [json] map to the corresponding object
  Member.fromJson(Map<String, dynamic> json)
    : id = json['id'] != null ? int.parse(json['id'].toString()) : null,
      firstName = json['firstName'],
      lastName = json['lastName'],
      email = json['email'],
      password = json['password'],
      phone = json['phone'],
      avatar = json['avatarFile'],
      avatarName = json['avatarFileName'],
      bikes = json['bikes'] != null ? (json['bikes'] as Iterable).map((i) => Bike.fromJson(i)).toList() : null,
      membershipFees =
          json['membershipFees'] != null
              ? (json['membershipFees'] as Iterable)
                  .map((i) => MembershipFee.fromJson(i))
                  .toList()
              : null,
      active = json['active'] != null && (json['active'] == '1' || json['active'] == true),
      verified = json['verified'] != null && (json['verified'] == '1' || json['verified'] == true),
      role = json['role'] != null ? MemberRole.values.firstWhere((e) => e.toString().split('.').last == json['role'], orElse: () => MemberRole.ROLE_USER) : MemberRole.ROLE_USER,
      boardRole = json['boardRole'] != null
          ? BoardRole.values.firstWhere(
              (e) => e.toString().split('.').last == json['boardRole'],
              orElse: () => BoardRole.PRESIDENT,
            )
          : null,
      otp = json['otp'],
      otpDate = json['otpDate'] != null ? DateTime.parse(json['otpDate']) : null,
      registrationDate = json['registrationDate'] != null ? DateTime.parse(json['registrationDate']) : null,
      eventMembers = json['eventMembers'] != null ? (json['eventMembers'] as Iterable).map((i) => EventMember.fromJson(i)).toList() : null,
      riderNumber = json['riderNumber'],
      headerPalette = json['headerPalette'],
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
    "bikes": bikes?.map((i) => i.toJson()).toList(),
    "membershipFees": membershipFees?.map((i) => i.toJson()).toList(),
    "active": active,
    "verified": verified,
    "role": role?.toString().split('.').last,
    "boardRole": boardRole?.toString().split('.').last,
    "otp": otp,
    "otpDate": otpDate?.toIso8601String(),
    "registrationDate": registrationDate?.toIso8601String(),
    "eventMembers": eventMembers?.map((i) => i.toJson()).toList(),
    "riderNumber": riderNumber,
    "headerPalette": headerPalette,
    "createdOn": createdOn?.toIso8601String(),
    "modifiedOn": modifiedOn?.toIso8601String(),
  };
}
