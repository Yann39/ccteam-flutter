/*
 * Copyright (c) 2024 by Yann39.
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

/// Class representing a membership fee
class MembershipFee {
  int? id;
  int? year;
  double? amount;
  bool? paid;
  DateTime? createdOn;
  DateTime? modifiedOn;

  MembershipFee({
    this.id,
    this.year,
    this.amount,
    this.paid,
    this.createdOn,
    this.modifiedOn,
  });

  @override
  String toString() {
    return """{
      id: ${this.id.toString()},
      year: ${this.year},
      amount: ${this.amount},
      paid: ${this.paid},
      createdOn: ${this.createdOn?.toIso8601String()},
      modifiedOn: ${this.modifiedOn?.toIso8601String()},
    }""";
  }

  /// Convert [json] map to the corresponding object
  MembershipFee.fromJson(Map<String, dynamic> json)
    : id = json['id'] != null ? int.parse(json['id'].toString()) : null,
      year = json['year'],
      amount = json['amount'] != null ? double.parse(json['amount'].toString()) : null,
      paid = json['paid'] != null && (json['paid'] == '1' || json['paid'] == true),
      createdOn = json['createdOn'] != null ? DateTime.parse(json['createdOn']) : null,
      modifiedOn = json['modifiedOn'] != null ? DateTime.parse(json['modifiedOn']) : null;

  /// Convert [MembershipFee] object to the corresponding JSON map
  Map<String, dynamic> toJson() => {
    "id": id?.toString(),
    "year": year,
    "amount": amount,
    "paid": paid,
    "createdOn": createdOn?.toIso8601String(),
    "modifiedOn": modifiedOn?.toIso8601String(),
  };

  /// Override == operator to compare fees by id
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MembershipFee && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
