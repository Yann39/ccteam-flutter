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

import 'package:ccteam/models/bike_maintenance.dart';

/// A part fitted to a bike (racing exhaust, short brake lever, crash pads...), only available to the bike owner.
class BikeEquipment {
  int? id;
  String designation;
  double? price;
  CurrencyCode currency;
  String? comment;

  BikeEquipment({this.id, required this.designation, this.price, this.currency = CurrencyCode.chf, this.comment});

  BikeEquipment.fromJson(Map<String, dynamic> json)
    : id = json['id'] != null ? int.parse(json['id'].toString()) : null,
      designation = json['designation'] ?? '',
      price = (json['price'] as num?)?.toDouble(),
      currency = CurrencyCode.fromCode(json['currency']),
      comment = json['comment'];

  /// Copy, so a form can be edited and cancelled without touching the displayed data.
  BikeEquipment copy() =>
      BikeEquipment(id: id, designation: designation, price: price, currency: currency, comment: comment);

  /// Sum of the prices of the given [equipments], per currency (amounts are never converted).
  static Map<CurrencyCode, double> sumPrices(Iterable<BikeEquipment> equipments) {
    final Map<CurrencyCode, double> totals = {};
    for (final BikeEquipment e in equipments) {
      if (e.price != null) totals[e.currency] = (totals[e.currency] ?? 0) + e.price!;
    }
    return totals;
  }
}
