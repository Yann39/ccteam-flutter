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
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/bikes_service.dart';
import 'package:ccteam/services/members_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class BikeListProvider extends ChangeNotifier {
  final Logger _log = new Logger('BikeListProvider');
  final BikesService _bikesService = new BikesService();
  final MembersService _membersService = new MembersService();

  late MessageProvider _messageProvider;
  late LoginProvider _loginProvider;

  List<Bike> _bikes = [];
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  List<Bike> get bikes => _bikes;

  LoadingStatus get loadingStatus => _loadingStatus;

  /// Update message provider.
  void updateMessageProvider(MessageProvider messageProvider) {
    _messageProvider = messageProvider;
  }

  /// Update login provider.
  void updateLoginProvider(LoginProvider loginProvider) {
    _loginProvider = loginProvider;
    if (_loginProvider.authStatus == AuthStatus.Authenticated && _loginProvider.loggedMember != null) {
      _bikes = _loginProvider.loggedMember!.bikes ?? [];
      _loadingStatus = LoadingStatus.loaded;
    }
  }

  /// Pull the latest list of bikes from the backend by re-fetching the
  /// logged member. The bikes collection lives on the Member entity, so
  /// the easiest way to refresh it is to re-query the whole member and
  /// pick up the [bikes] field from the response.
  ///
  /// Note: deliberately does NOT flip [_loadingStatus] to `loading` —
  /// the caller (e.g. a [RefreshIndicator]) provides its own visual
  /// feedback, and we want the existing list to stay visible during
  /// the refresh rather than be replaced by a centred spinner.
  Future<void> refreshBikes() async {
    if (_loginProvider.loggedMember == null || _loginProvider.loggedMember!.email == null) {
      return;
    }
    try {
      final updatedMember = await _membersService.getMemberByEmail(_loginProvider.loggedMember!.email!);
      _bikes = updatedMember.bikes ?? [];
      _loginProvider.loggedMember!.bikes = _bikes;
      notifyListeners();
    } catch (e) {
      _log.severe("Error refreshing bikes: $e");
      AppUtils.handleServiceException(e, _messageProvider, _loginProvider);
    }
  }

  /// Add a new [bike] for the current user.
  Future<void> addBike(Bike bike) async {
    _updateStatus(LoadingStatus.loading);
    try {
      final int memberId = _loginProvider.loggedMember!.id!;
      final Bike newBike = await _bikesService.addBike(memberId, bike);
      _bikes.add(newBike);
      _loginProvider.loggedMember!.bikes = _bikes;
      _messageProvider.setMessage(AppString.bikeAdded, MessageType.SUCCESS);
      _updateStatus(LoadingStatus.loaded);
    } catch (e) {
      _log.severe("Error adding bike: $e");
      _messageProvider.setMessage(AppString.error, MessageType.ERROR);
      AppUtils.handleServiceException(e, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.loaded);
    }
  }

  /// Update the specified [bike].
  Future<void> updateBike(Bike bike) async {
    _updateStatus(LoadingStatus.loading);
    try {
      final Bike updatedBike = await _bikesService.updateBike(bike);
      final int index = _bikes.indexWhere((b) => b.id == updatedBike.id);
      if (index != -1) {
        _bikes[index] = updatedBike;
      }
      _loginProvider.loggedMember!.bikes = _bikes;
      _messageProvider.setMessage(AppString.bikeUpdated, MessageType.SUCCESS);
      _updateStatus(LoadingStatus.loaded);
    } catch (e) {
      _log.severe("Error updating bike: $e");
      _messageProvider.setMessage(AppString.error, MessageType.ERROR);
      AppUtils.handleServiceException(e, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.loaded);
    }
  }

  /// Mark the given [bike] as the member's "current" bike. Any other bike
  /// that was previously marked as current is unmarked first (only one bike
  /// can be current at a time).
  Future<void> setCurrentBike(Bike bike) async {
    _updateStatus(LoadingStatus.loading);
    try {
      // unmark any other bike that is currently flagged as current
      final List<Bike> previousCurrents = _bikes.where((b) => b.id != bike.id && (b.current ?? false)).toList();
      for (final Bike previous in previousCurrents) {
        previous.current = false;
        final Bike updated = await _bikesService.updateBike(previous);
        final int idx = _bikes.indexWhere((b) => b.id == updated.id);
        if (idx != -1) {
          _bikes[idx] = updated;
        }
      }

      // mark the target bike as current
      bike.current = true;
      final Bike updatedCurrent = await _bikesService.updateBike(bike);
      final int targetIdx = _bikes.indexWhere((b) => b.id == updatedCurrent.id);
      if (targetIdx != -1) {
        _bikes[targetIdx] = updatedCurrent;
      }

      _loginProvider.loggedMember!.bikes = _bikes;
      _updateStatus(LoadingStatus.loaded);
    } catch (e) {
      _log.severe("Error setting current bike: $e");
      _messageProvider.setMessage(AppString.error, MessageType.ERROR);
      AppUtils.handleServiceException(e, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.loaded);
    }
  }

  /// Delete the specified [bike].
  Future<void> deleteBike(Bike bike) async {
    _updateStatus(LoadingStatus.loading);
    try {
      await _bikesService.deleteBike(bike.id!);
      _bikes.removeWhere((b) => b.id == bike.id);
      _loginProvider.loggedMember!.bikes = _bikes;
      _messageProvider.setMessage(AppString.bikeDeleted, MessageType.SUCCESS);
      _updateStatus(LoadingStatus.loaded);
    } catch (e) {
      _log.severe("Error deleting bike: $e");
      _messageProvider.setMessage(AppString.error, MessageType.ERROR);
      AppUtils.handleServiceException(e, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.loaded);
    }
  }

  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    notifyListeners();
  }
}
