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

import 'package:ccteam/utils/strings.dart';

/// Currency of the maintenance prices, amounts are never converted.
/// The [code]s must match the backend `CurrencyCode` enum.
enum CurrencyCode {
  chf('CHF'),
  eur('EUR');

  final String code;

  const CurrencyCode(this.code);

  static CurrencyCode fromCode(String? code) =>
      CurrencyCode.values.firstWhere((c) => c.code == code, orElse: () => CurrencyCode.chf);
}

/// Catalog of the maintenance operations, in display order.
/// The [code]s must match the backend `MaintenanceOperationType` enum.
enum MaintenanceOperationType {
  engineOil('ENGINE_OIL', AppString.maintenanceOpEngineOil),
  oilFilter('OIL_FILTER', AppString.maintenanceOpOilFilter),
  airFilter('AIR_FILTER', AppString.maintenanceOpAirFilter),
  sparkPlugs('SPARK_PLUGS', AppString.maintenanceOpSparkPlugs),
  coolant('COOLANT', AppString.maintenanceOpCoolant),
  brakePadsFront('BRAKE_PADS_FRONT', AppString.maintenanceOpBrakePadsFront),
  brakePadsRear('BRAKE_PADS_REAR', AppString.maintenanceOpBrakePadsRear),
  brakeDiscs('BRAKE_DISCS', AppString.maintenanceOpBrakeDiscs),
  brakeFluid('BRAKE_FLUID', AppString.maintenanceOpBrakeFluid),
  tireFront('TIRE_FRONT', AppString.maintenanceOpTireFront),
  tireRear('TIRE_REAR', AppString.maintenanceOpTireRear),
  chainKit('CHAIN_KIT', AppString.maintenanceOpChainKit),
  forkService('FORK_SERVICE', AppString.maintenanceOpForkService),
  shockService('SHOCK_SERVICE', AppString.maintenanceOpShockService),
  valveClearance('VALVE_CLEARANCE', AppString.maintenanceOpValveClearance),
  battery('BATTERY', AppString.maintenanceOpBattery),
  generalInspection('GENERAL_INSPECTION', AppString.maintenanceOpGeneralInspection),
  other('OTHER', AppString.maintenanceOpOther);

  final String code;
  final String label;

  const MaintenanceOperationType(this.code, this.label);

  static MaintenanceOperationType fromCode(String? code) =>
      MaintenanceOperationType.values.firstWhere((t) => t.code == code, orElse: () => MaintenanceOperationType.other);

  /// Operations that make a maintenance a service of the plan by default (see [Maintenance.resetsPlan]),
  /// as opposed to one-off repairs such as a tire or brake pads.
  static const Set<MaintenanceOperationType> planServices = {engineOil, oilFilter, generalInspection};
}

/// Where a bike stands relative to its next maintenance.
/// The [code]s must match the backend `MaintenanceDueStatus` enum.
enum MaintenanceDueStatus {
  unknown('UNKNOWN'),
  ok('OK'),
  dueSoon('DUE_SOON'),
  overdue('OVERDUE');

  final String code;

  const MaintenanceDueStatus(this.code);

  static MaintenanceDueStatus fromCode(String? code) =>
      MaintenanceDueStatus.values.firstWhere((s) => s.code == code, orElse: () => MaintenanceDueStatus.unknown);
}

/// Maintenance plan of a bike: service every [intervalKm] kilometers or every [intervalMonths] months,
/// whichever comes first. At least one of the two is set.
class MaintenancePlan {
  int? id;
  int? intervalKm;
  int? intervalMonths;

  MaintenancePlan({this.id, this.intervalKm, this.intervalMonths});

  MaintenancePlan.fromJson(Map<String, dynamic> json)
    : id = json['id'] != null ? int.parse(json['id'].toString()) : null,
      intervalKm = json['intervalKm'],
      intervalMonths = json['intervalMonths'];
}

/// An operation performed during a [Maintenance]. Each price has its own [currency], the parts of a same
/// maintenance may have been bought in different countries.
class MaintenanceOperation {
  int? id;
  MaintenanceOperationType type;
  String? label;
  double? price;
  CurrencyCode currency;

  MaintenanceOperation({this.id, required this.type, this.label, this.price, this.currency = CurrencyCode.chf});

  MaintenanceOperation.fromJson(Map<String, dynamic> json)
    : id = json['id'] != null ? int.parse(json['id'].toString()) : null,
      type = MaintenanceOperationType.fromCode(json['type']),
      label = json['label'],
      price = (json['price'] as num?)?.toDouble(),
      currency = CurrencyCode.fromCode(json['currency']);

  /// Name to display on a single line: the free label for "other", otherwise the catalog label with the free label
  /// as a precision. The line breaks the precision may hold are flattened.
  String get displayName {
    final String? flatLabel = label?.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).join(', ');
    if (type == MaintenanceOperationType.other) return flatLabel ?? type.label;
    return flatLabel != null && flatLabel.isNotEmpty ? "${type.label} ($flatLabel)" : type.label;
  }

  /// Main name of the operation: the free label for "other", the catalog label otherwise.
  String get title => type == MaintenanceOperationType.other ? (label ?? type.label) : type.label;

  /// Precision shown under [title], possibly on several lines; `null` for "other" whose label already is the title.
  String? get details => type == MaintenanceOperationType.other || label == null || label!.isEmpty ? null : label;

  /// Convert to the GraphQL `MaintenanceOperationInput`.
  Map<String, dynamic> toInput() => {"type": type.code, "label": label, "price": price, "currency": currency.code};
}

/// A maintenance performed on a bike.
class Maintenance {
  int? id;
  DateTime? maintenanceDate;
  int? odometerKm;

  /// Whether this maintenance is a service of the plan, restarting its countdown. A one-off repair (a tire, brake
  /// pads...) does not, the next service stays due from the previous one.
  bool resetsPlan;
  String? comment;
  List<MaintenanceOperation> operations;

  /// Sum of the operation prices per currency (amounts are never converted), empty when nothing has a price.
  Map<CurrencyCode, double> totals;

  Maintenance({
    this.id,
    this.maintenanceDate,
    this.odometerKm,
    this.resetsPlan = true,
    this.comment,
    List<MaintenanceOperation>? operations,
    Map<CurrencyCode, double>? totals,
  }) : operations = operations ?? [],
       totals = totals ?? {};

  Maintenance.fromJson(Map<String, dynamic> json)
    : id = json['id'] != null ? int.parse(json['id'].toString()) : null,
      maintenanceDate = json['maintenanceDate'] != null ? DateTime.parse(json['maintenanceDate']) : null,
      odometerKm = json['odometerKm'],
      resetsPlan = json['resetsPlan'] ?? true,
      comment = json['comment'],
      operations = ((json['operations'] as List?) ?? const [])
          .map((o) => MaintenanceOperation.fromJson(o as Map<String, dynamic>))
          .toList(),
      totals = {
        for (final t in (json['totals'] as List?) ?? const [])
          CurrencyCode.fromCode(t['currency']): (t['amount'] as num).toDouble(),
      };

  /// Deep copy, so a form can be edited and cancelled without touching the displayed data.
  Maintenance copy() => Maintenance(
    id: id,
    maintenanceDate: maintenanceDate,
    odometerKm: odometerKm,
    resetsPlan: resetsPlan,
    comment: comment,
    operations: operations
        .map((o) => MaintenanceOperation(id: o.id, type: o.type, label: o.label, price: o.price, currency: o.currency))
        .toList(),
    totals: Map.of(totals),
  );
}

/// The next maintenance due, counted from the last maintenance.
/// [remainingDays] / [remainingKm] are negative once exceeded.
class MaintenanceDue {
  MaintenanceDueStatus status;
  DateTime? dueDate;
  int? dueKm;
  int? remainingDays;
  int? remainingKm;

  MaintenanceDue({this.status = MaintenanceDueStatus.unknown, this.dueDate, this.dueKm, this.remainingDays, this.remainingKm});

  MaintenanceDue.fromJson(Map<String, dynamic> json)
    : status = MaintenanceDueStatus.fromCode(json['status']),
      dueDate = json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      dueKm = json['dueKm'],
      remainingDays = json['remainingDays'] != null ? int.parse(json['remainingDays'].toString()) : null,
      remainingKm = json['remainingKm'];
}

/// Everything maintenance-related for one bike, only available to the bike owner.
class BikeMaintenance {
  int bikeId;
  int? odometerKm;
  DateTime? odometerUpdatedOn;
  MaintenancePlan? plan;

  /// Most recent first.
  List<Maintenance> maintenances;
  MaintenanceDue nextDue;

  /// The most recent service of the plan, the maintenance [nextDue] counts from.
  Maintenance? get lastService {
    for (final Maintenance m in maintenances) {
      if (m.resetsPlan) return m;
    }
    return null;
  }

  BikeMaintenance({
    required this.bikeId,
    this.odometerKm,
    this.odometerUpdatedOn,
    this.plan,
    required this.maintenances,
    required this.nextDue,
  });

  BikeMaintenance.fromJson(Map<String, dynamic> json)
    : bikeId = int.parse(json['bikeId'].toString()),
      odometerKm = json['odometerKm'],
      odometerUpdatedOn = json['odometerUpdatedOn'] != null ? DateTime.parse(json['odometerUpdatedOn']) : null,
      plan = json['plan'] != null ? MaintenancePlan.fromJson(json['plan']) : null,
      maintenances = ((json['maintenances'] as List?) ?? const [])
          .map((m) => Maintenance.fromJson(m as Map<String, dynamic>))
          .toList(),
      nextDue = json['nextDue'] != null ? MaintenanceDue.fromJson(json['nextDue']) : MaintenanceDue();
}
