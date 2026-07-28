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

import 'dart:collection';

import 'package:ccteam/models/circuit.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/circuits_service.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class CircuitListProvider extends ChangeNotifier {
  final Logger _log = new Logger('CircuitListProvider');
  final CircuitsService _circuitsService = new CircuitsService();

  late MessageProvider _messageProvider;
  late LoginProvider _loginProvider;

  // current list of circuits
  List<Circuit> _circuits = [];

  // current loading status
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  CircuitListProvider() {
    fetchCircuits();
  }

  UnmodifiableListView<Circuit> get circuits => UnmodifiableListView(_circuits);

  LoadingStatus get loadingStatus => _loadingStatus;

  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _log.info("Notifying listeners of CircuitListProvider");
    notifyListeners();
  }

  void updateMessageProvider(MessageProvider messageProvider) {
    _messageProvider = messageProvider;
    notifyListeners();
  }

  void updateLoginProvider(LoginProvider loginProvider) {
    _loginProvider = loginProvider;
    notifyListeners();
  }

  /// Get the list of all circuits.
  Future<void> fetchCircuits() async {
    _updateStatus(LoadingStatus.loading);
    await _circuitsService.fetchCircuits().then(
      (value) async {
        _log.fine(
          "Circuits list of ${value.length} circuits retrieved successfully",
        );
        _circuits = value;
        _updateStatus(
          _circuits.isEmpty ? LoadingStatus.empty : LoadingStatus.loaded,
        );
      },
      onError: (error) {
        _log.warning("Error when retrieving circuits list ($error)");
        _circuits = [];
        AppUtils.handleServiceException(
          error,
          _messageProvider,
          _loginProvider,
        );
        _updateStatus(LoadingStatus.notLoaded);
      },
    );
  }

  /// Search for circuits according to the specified [text].
  void searchCircuits(String text) async {
    _updateStatus(LoadingStatus.loading);
    await _circuitsService
        .searchCircuits(text)
        .then(
          (value) async {
            _log.fine("Circuits search list retrieved successfully");
            _circuits = value;
            _updateStatus(
              _circuits.isEmpty ? LoadingStatus.empty : LoadingStatus.loaded,
            );
          },
          onError: (error) {
            _log.warning("Error when searching circuits ($error)");
            _circuits = [];
            _updateStatus(LoadingStatus.notLoaded);
            throw (error);
          },
        );
  }

  /// Insert the server-persisted [circuit] into the in-memory list and re-sort.
  void addCircuitInList(Circuit circuit) {
    _circuits.add(circuit);
    _circuits.sort(
      (a, b) =>
          (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()),
    );
    _loadingStatus = LoadingStatus.loaded;
    _log.info("Notifying listeners of CircuitListProvider");
    notifyListeners();
  }

  /// Replace the in-memory copy of the [circuit] with the freshly updated one.
  void updateCircuitInList(Circuit circuit) {
    final int idx = _circuits.indexWhere((c) => c.id == circuit.id);
    if (idx != -1) {
      _circuits[idx] = circuit;
    }
    _circuits.sort(
      (a, b) =>
          (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()),
    );
    _log.info("Notifying listeners of CircuitListProvider");
    notifyListeners();
  }

  /// Drop the circuit with the specified [circuitId] from the in-memory list.
  void removeCircuitFromList(int circuitId) {
    _circuits.removeWhere((c) => c.id == circuitId);
    _loadingStatus = _circuits.isEmpty
        ? LoadingStatus.empty
        : LoadingStatus.loaded;
    _log.info("Notifying listeners of CircuitListProvider");
    notifyListeners();
  }
}
