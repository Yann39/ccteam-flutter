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
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Formatting helpers for the bike maintenance pages.
class MaintenanceUtils {
  static final NumberFormat _kmFormat = NumberFormat('#,##0', 'fr_CH');
  static final NumberFormat _priceFormat = NumberFormat('#,##0.00', 'fr_CH');

  /// "18 400 km".
  static String formatKm(int km) => "${_kmFormat.format(km)} km";

  /// "CHF 380.00" / "380.00 €".
  static String formatPrice(double amount, CurrencyCode currency) {
    final String value = _priceFormat.format(amount);
    return currency == CurrencyCode.eur ? "$value €" : "CHF $value";
  }

  /// Amounts per currency as "CHF 1 200.00 · 80.00 €" (amounts are never converted), each divided by [divisor].
  /// Returns `null` when there is no amount.
  static String? formatAmounts(Map<CurrencyCode, double> totals, {double divisor = 1}) {
    if (totals.isEmpty) return null;
    return CurrencyCode.values
        .where(totals.containsKey)
        .map((c) => formatPrice(totals[c]! / divisor, c))
        .join(" · ");
  }

  /// Sum of the totals of the given [maintenances], per currency.
  static Map<CurrencyCode, double> sumTotals(Iterable<Maintenance> maintenances) {
    final Map<CurrencyCode, double> totals = {};
    for (final Maintenance m in maintenances) {
      m.totals.forEach((currency, amount) => totals[currency] = (totals[currency] ?? 0) + amount);
    }
    return totals;
  }

  /// Sum of the prices of the given [operations], per currency.
  static Map<CurrencyCode, double> sumOperations(Iterable<MaintenanceOperation> operations) {
    final Map<CurrencyCode, double> totals = {};
    for (final MaintenanceOperation o in operations) {
      if (o.price != null) totals[o.currency] = (totals[o.currency] ?? 0) + o.price!;
    }
    return totals;
  }

  /// A number of months as "2 ans", "18 mois" (kept in months when not a whole number of years), "1 an".
  static String formatMonths(int months) {
    if (months >= 12 && months % 12 == 0) {
      final int years = months ~/ 12;
      return AppString.format(years == 1 ? AppString.durationYear : AppString.durationYears, [years]);
    }
    return AppString.format(AppString.durationMonths, [months]);
  }

  /// Human readable time between [from] and [to] (order does not matter): "1 an 3 mois", "5 mois", "12 jours".
  static String formatElapsed(DateTime from, DateTime to) {
    if (to.isBefore(from)) {
      final DateTime tmp = from;
      from = to;
      to = tmp;
    }
    int months = (to.year - from.year) * 12 + to.month - from.month;
    if (to.day < from.day) months--;

    if (months <= 0) {
      final int days = DateUtils.dateOnly(to).difference(DateUtils.dateOnly(from)).inDays;
      return AppString.format(days == 1 ? AppString.durationDay : AppString.durationDays, [days]);
    }

    final int years = months ~/ 12;
    final int rest = months % 12;
    final List<String> parts = [
      if (years > 0) AppString.format(years == 1 ? AppString.durationYear : AppString.durationYears, [years]),
      if (rest > 0) AppString.format(AppString.durationMonths, [rest]),
    ];
    return parts.join(" ");
  }

  /// Plan summary: "Tous les 5 000 km ou 2 ans".
  static String formatPlan(MaintenancePlan plan) {
    final List<String> parts = [
      if (plan.intervalKm != null) formatKm(plan.intervalKm!),
      if (plan.intervalMonths != null) formatMonths(plan.intervalMonths!),
    ];
    return AppString.format(AppString.maintenanceEvery, [parts.join(AppString.maintenanceOr)]);
  }

  /// Remaining distance and time until the next maintenance: "Dans 1 200 km ou 7 mois", "Dépassé de 300 km".
  /// Returns `null` when nothing can be computed.
  static String? formatRemaining(MaintenanceDue due) {
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    if (due.status == MaintenanceDueStatus.overdue) {
      final List<String> parts = [
        if (due.remainingKm != null && due.remainingKm! <= 0) formatKm(-due.remainingKm!),
        if (due.remainingDays != null && due.remainingDays! < 0) formatElapsed(due.dueDate!, today),
      ];
      return parts.isEmpty ? null : AppString.format(AppString.maintenanceOverdueBy, [parts.join(AppString.maintenanceAnd)]);
    }
    final List<String> parts = [
      if (due.remainingKm != null) formatKm(due.remainingKm!),
      if (due.dueDate != null) formatElapsed(today, due.dueDate!),
    ];
    return parts.isEmpty ? null : AppString.format(AppString.maintenanceDueIn, [parts.join(AppString.maintenanceOr)]);
  }

  /// Color associated to the due status.
  static Color statusColor(MaintenanceDueStatus status) {
    switch (status) {
      case MaintenanceDueStatus.ok:
        return Colors.green[700]!;
      case MaintenanceDueStatus.dueSoon:
        return Colors.orange[800]!;
      case MaintenanceDueStatus.overdue:
        return Colors.red[700]!;
      case MaintenanceDueStatus.unknown:
        return Colors.blueGrey;
    }
  }

  /// Share of the maintenance period already consumed, between 0 and 1: the furthest of the distance share and the
  /// time share, since the maintenance is due at whichever comes first. `null` when it can't be computed.
  static double? consumedShare(MaintenancePlan? plan, MaintenanceDue due, Maintenance? last) {
    if (plan == null || last == null) return null;
    double? share;
    if (plan.intervalKm != null && due.remainingKm != null) {
      share = 1 - due.remainingKm! / plan.intervalKm!;
    }
    if (due.dueDate != null && last.maintenanceDate != null) {
      final int total = due.dueDate!.difference(last.maintenanceDate!).inDays;
      if (total > 0) {
        final double timeShare = DateTime.now().difference(last.maintenanceDate!).inDays / total;
        share = share == null || timeShare > share ? timeShare : share;
      }
    }
    return share?.clamp(0.0, 1.0);
  }
}
