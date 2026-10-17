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

import 'package:ccteam/models/bike_equipment.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/bike_equipment_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Holds the equipments of the logged member's bikes, loaded on demand per bike from the bike detail page.
class BikeEquipmentProvider extends ChangeNotifier {
  final Logger _log = new Logger('BikeEquipmentProvider');
  final BikeEquipmentService _bikeEquipmentService = new BikeEquipmentService();

  late MessageProvider _messageProvider;
  late LoginProvider _loginProvider;

  final Map<int, List<BikeEquipment>> _equipmentsByBike = {};
  final Map<int, LoadingStatus> _statusByBike = {};

  // id of the member the cached data belongs to, the cache is dropped when another member logs in
  int? _memberId;

  /// Equipments of the bike with the given [bikeId], in the order they were entered, `null` until loaded.
  List<BikeEquipment>? equipmentsOf(int bikeId) => _equipmentsByBike[bikeId];

  /// Loading status of the equipments of the bike with the given [bikeId].
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
      _equipmentsByBike.clear();
      _statusByBike.clear();
    }
  }

  /// Load the equipments of the bike with the given [bikeId]. Keeps the list already displayed while reloading, the
  /// spinner is only shown on the first load.
  Future<void> load(int bikeId) async {
    if (_statusByBike[bikeId] == LoadingStatus.loading) return;
    if (_equipmentsByBike[bikeId] == null) {
      _statusByBike[bikeId] = LoadingStatus.loading;
      notifyListeners();
    }
    try {
      _equipmentsByBike[bikeId] = await _bikeEquipmentService.getBikeEquipments(bikeId);
      _statusByBike[bikeId] = LoadingStatus.loaded;
    } catch (e) {
      _log.severe("Error loading equipments of bike $bikeId: $e");
      _statusByBike[bikeId] = _equipmentsByBike[bikeId] != null ? LoadingStatus.loaded : LoadingStatus.notLoaded;
      AppUtils.handleServiceException(e, _messageProvider, _loginProvider);
    }
    notifyListeners();
  }

  /// Create or update (when it has an id) the given [equipment] of the bike with the given [bikeId].
  Future<bool> saveEquipment(int bikeId, BikeEquipment equipment) => _run(
    bikeId,
    () => equipment.id == null
        ? _bikeEquipmentService.createBikeEquipment(bikeId, equipment)
        : _bikeEquipmentService.updateBikeEquipment(equipment),
    equipment.id == null ? AppString.equipmentAdded : AppString.equipmentUpdated,
  );

  /// Delete the given [equipment] of the bike with the given [bikeId].
  Future<bool> deleteEquipment(int bikeId, BikeEquipment equipment) =>
      _run(bikeId, () => _bikeEquipmentService.deleteBikeEquipment(equipment.id!), AppString.equipmentDeleted);

  /// Move the equipment at [oldIndex] to [newIndex] (the index once it is removed from the list) among the
  /// equipments of the bike with the given [bikeId].
  Future<void> reorderEquipments(int bikeId, int oldIndex, int newIndex) async {
    final List<BikeEquipment>? previous = _equipmentsByBike[bikeId];
    if (previous == null || oldIndex == newIndex) return;
    final List<BikeEquipment> reordered = List.of(previous);
    reordered.insert(newIndex, reordered.removeAt(oldIndex));
    _equipmentsByBike[bikeId] = reordered;
    notifyListeners();
    try {
      _equipmentsByBike[bikeId] = await _bikeEquipmentService.reorderBikeEquipments(
        bikeId,
        reordered.map((e) => e.id!).toList(),
      );
    } catch (e) {
      _log.severe("Error reordering equipments of bike $bikeId: $e");
      _equipmentsByBike[bikeId] = previous;
      _messageProvider.setMessage(AppString.error, MessageType.ERROR);
      AppUtils.handleServiceException(e, _messageProvider, _loginProvider);
    }
    notifyListeners();
  }

  /// Run the given backend [call], store the fresh list it returns and show the [successMessage].
  /// Returns whether the call succeeded.
  Future<bool> _run(int bikeId, Future<List<BikeEquipment>> Function() call, String successMessage) async {
    try {
      _equipmentsByBike[bikeId] = await call();
      _statusByBike[bikeId] = LoadingStatus.loaded;
      _messageProvider.setMessage(successMessage, MessageType.SUCCESS);
      notifyListeners();
      return true;
    } catch (e) {
      _log.severe("Error updating equipments of bike $bikeId: $e");
      _messageProvider.setMessage(AppString.error, MessageType.ERROR);
      AppUtils.handleServiceException(e, _messageProvider, _loginProvider);
      return false;
    }
  }
}
