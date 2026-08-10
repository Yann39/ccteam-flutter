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

import 'dart:async';

import 'package:ccteam/models/circuit.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/circuits_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Holds the circuit currently shown on the circuit detail page. Mirrors
/// [TrackDetailProvider] in shape and contract.
class CircuitDetailProvider extends ChangeNotifier {
  final Logger _log = new Logger('CircuitDetailProvider');
  final CircuitsService _circuitsService = new CircuitsService();

  late MessageProvider _messageProvider;
  late LoginProvider _loginProvider;

  Circuit? _currentCircuit;
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  Circuit? get currentCircuit => _currentCircuit;

  LoadingStatus get loadingStatus => _loadingStatus;

  void updateMessageProvider(MessageProvider messageProvider) {
    _messageProvider = messageProvider;
    _notifyListeners();
  }

  void updateLoginProvider(LoginProvider loginProvider) {
    _loginProvider = loginProvider;
    _notifyListeners();
  }

  /// Set the current circuit to be the specified [circuit].
  void setCurrentCircuit(Circuit circuit) {
    _currentCircuit = circuit;
    _notifyListeners();
  }

  /// Fetch the specified [circuit] (with its versions) from the database.
  Future<void> fetchCircuit(Circuit circuit) async {
    _log.fine("Fetching circuit ${circuit.name}...");
    _updateStatus(LoadingStatus.loading);
    await _circuitsService
        .getCircuitById(circuit.id!)
        .then(
          (value) async {
            _log.fine("Circuit ID ${circuit.id} retrieved successfully");
            if (value != null) _currentCircuit = value;
            _updateStatus(LoadingStatus.loaded);
          },
          onError: (error) {
            _log.warning("Error when retrieving circuit ($error)");
            AppUtils.handleServiceException(
              error,
              _messageProvider,
              _loginProvider,
            );
            _updateStatus(LoadingStatus.notLoaded);
          },
        );
  }

  /// Clear the currently-shown circuit. Used right after a delete so a stale
  /// reference can't be reused.
  void clearCurrentCircuit() {
    _currentCircuit = null;
    _notifyListeners();
  }

  void _notifyListeners() {
    _log.info("Notifying listeners of CircuitDetailProvider");
    notifyListeners();
  }

  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _notifyListeners();
  }
}
