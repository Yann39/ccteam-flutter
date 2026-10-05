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
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/maintenance_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Holds the maintenance data (plan, maintenances, odometer, next due) of the logged member's bikes, loaded on
/// demand per bike from the bike detail page.
class BikeMaintenanceProvider extends ChangeNotifier {
  final Logger _log = new Logger('BikeMaintenanceProvider');
  final MaintenanceService _maintenanceService = new MaintenanceService();

  late MessageProvider _messageProvider;
  late LoginProvider _loginProvider;

  final Map<int, BikeMaintenance> _maintenanceByBike = {};
  final Map<int, LoadingStatus> _statusByBike = {};

  // id of the member the cached data belongs to, the cache is dropped when another member logs in
  int? _memberId;

  /// Maintenance data of the bike with the given [bikeId], `null` until loaded.
  BikeMaintenance? maintenanceOf(int bikeId) => _maintenanceByBike[bikeId];

  /// Loading status of the maintenance data of the bike with the given [bikeId].
  LoadingStatus statusOf(int bikeId) => _statusByBike[bikeId] ?? LoadingStatus.notLoaded;

  /// Update message provider.
  void updateMessageProvider(MessageProvider messageProvider) {
    _messageProvider = messageProvider;
  }

  /// Update login provider.
  void updateLoginProvider(LoginProvider loginProvider) {
    _loginProvider = loginProvider;
    final int? memberId = loginProvider.authStatus == AuthStatus.Authenticated ? loginProvider.loggedMember?.id : null;
    if (memberId != _memberId) {
      _memberId = memberId;
      _maintenanceByBike.clear();
      _statusByBike.clear();
    }
  }

  /// Load the maintenance data of the bike with the given [bikeId]. Keeps the data already displayed while
  /// reloading, the spinner is only shown on the first load.
  Future<void> load(int bikeId) async {
    if (_statusByBike[bikeId] == LoadingStatus.loading) return;
    if (_maintenanceByBike[bikeId] == null) {
      _statusByBike[bikeId] = LoadingStatus.loading;
      notifyListeners();
    }
    try {
      _maintenanceByBike[bikeId] = await _maintenanceService.getBikeMaintenance(bikeId);
      _statusByBike[bikeId] = LoadingStatus.loaded;
    } catch (e) {
      _log.severe("Error loading maintenance of bike $bikeId: $e");
      _statusByBike[bikeId] = _maintenanceByBike[bikeId] != null ? LoadingStatus.loaded : LoadingStatus.notLoaded;
      AppUtils.handleServiceException(e, _messageProvider, _loginProvider);
    }
    notifyListeners();
  }

  /// Define or replace the maintenance plan of the bike with the given [bikeId].
  Future<bool> setPlan(int bikeId, int? intervalKm, int? intervalMonths) => _run(
    bikeId,
    () => _maintenanceService.setMaintenancePlan(bikeId, intervalKm, intervalMonths),
    AppString.maintenancePlanSaved,
  );

  /// Delete the maintenance plan of the bike with the given [bikeId].
  Future<bool> deletePlan(int bikeId) =>
      _run(bikeId, () => _maintenanceService.deleteMaintenancePlan(bikeId), AppString.maintenancePlanDeleted);

  /// Create or update (when it has an id) the given [maintenance] of the bike with the given [bikeId].
  Future<bool> saveMaintenance(int bikeId, Maintenance maintenance) => _run(
    bikeId,
    () => maintenance.id == null
        ? _maintenanceService.createMaintenance(bikeId, maintenance)
        : _maintenanceService.updateMaintenance(maintenance),
    maintenance.id == null ? AppString.maintenanceAdded : AppString.maintenanceUpdated,
  );

  /// Delete the given [maintenance] of the bike with the given [bikeId].
  Future<bool> deleteMaintenance(int bikeId, Maintenance maintenance) =>
      _run(bikeId, () => _maintenanceService.deleteMaintenance(maintenance.id!), AppString.maintenanceDeleted);

  /// Set the current [odometerKm] reading of the bike with the given [bikeId].
  Future<bool> updateOdometer(int bikeId, int odometerKm) =>
      _run(bikeId, () => _maintenanceService.updateBikeOdometer(bikeId, odometerKm), AppString.odometerUpdated);

  /// Run the given backend [call], store the fresh data it returns and show the [successMessage].
  /// Returns whether the call succeeded.
  Future<bool> _run(int bikeId, Future<BikeMaintenance> Function() call, String successMessage) async {
    try {
      _maintenanceByBike[bikeId] = await call();
      _statusByBike[bikeId] = LoadingStatus.loaded;
      _messageProvider.setMessage(successMessage, MessageType.SUCCESS);
      notifyListeners();
      return true;
    } catch (e) {
      _log.severe("Error updating maintenance of bike $bikeId: $e");
      _messageProvider.setMessage(AppString.error, MessageType.ERROR);
      AppUtils.handleServiceException(e, _messageProvider, _loginProvider);
      return false;
    }
  }
}
