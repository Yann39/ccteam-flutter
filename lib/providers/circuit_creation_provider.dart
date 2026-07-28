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
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Holds the edit copy of the [Circuit] being created or modified in the
/// add/edit circuit form. Mirrors [TrackCreationProvider] in shape and contract.
class CircuitCreationProvider extends ChangeNotifier {
  final Logger _log = new Logger('CircuitCreationProvider');
  final CircuitsService _circuitsService = new CircuitsService();

  late MessageProvider _messageProvider;
  late LoginProvider _loginProvider;

  Circuit _circuit = new Circuit();
  LoadingStatus _loadingStatus = LoadingStatus.notLoaded;

  Circuit get circuit => _circuit;

  LoadingStatus get loadingStatus => _loadingStatus;

  void updateMessageProvider(MessageProvider messageProvider) {
    _messageProvider = messageProvider;
    _notifyListeners();
  }

  void updateLoginProvider(LoginProvider loginProvider) {
    _loginProvider = loginProvider;
    _notifyListeners();
  }

  /// Seed the in-progress edit copy with the given [circuit]. Pass a fresh empty
  /// `Circuit()` for the creation flow, an existing circuit for the edit flow.
  void setCircuitToEdit(Circuit circuit) {
    _circuit = circuit;
    _updateStatus(LoadingStatus.loaded);
  }

  /// Persist the in-progress circuit as a new row via the GraphQL mutation.
  Future<void> createCircuit() async {
    _updateStatus(LoadingStatus.loading);
    try {
      _circuit = await _circuitsService.createCircuit(_circuit);
      _log.fine("Circuit created successfully: ${_circuit.name}");
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(
        AppString.circuitCreated,
        MessageType.SUCCESS,
      );
    } catch (error) {
      _log.warning("Error when creating circuit ($error)");
      _messageProvider.setMessage(
        AppString.circuitCreationFailed,
        MessageType.ERROR,
      );
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    }
  }

  /// Persist the in-progress circuit changes via the GraphQL mutation.
  Future<void> updateCircuit() async {
    _updateStatus(LoadingStatus.loading);
    try {
      _circuit = await _circuitsService.updateCircuit(_circuit);
      _log.fine("Circuit successfully updated: ${_circuit.name}");
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(
        AppString.circuitUpdated,
        MessageType.SUCCESS,
      );
    } catch (error) {
      _log.warning("Error when updating circuit ($error)");
      _messageProvider.setMessage(
        AppString.circuitUpdateFailed,
        MessageType.ERROR,
      );
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
    }
  }

  /// Delete the in-progress circuit via the GraphQL mutation. Throws on failure
  /// so the caller can keep the page open and surface the error (e.g. when the
  /// circuit still has versions).
  Future<void> deleteCircuit() async {
    _updateStatus(LoadingStatus.loading);
    try {
      await _circuitsService.deleteCircuit(_circuit.id!);
      _log.fine("Circuit successfully deleted: ${_circuit.name}");
      _updateStatus(LoadingStatus.loaded);
      _messageProvider.setMessage(
        AppString.circuitDeleted,
        MessageType.SUCCESS,
      );
    } catch (error) {
      _log.warning("Error when deleting circuit ($error)");
      _messageProvider.setMessage(
        AppString.circuitDeletionFailed,
        MessageType.ERROR,
      );
      AppUtils.handleServiceException(error, _messageProvider, _loginProvider);
      _updateStatus(LoadingStatus.notLoaded);
      rethrow;
    }
  }

  void _notifyListeners() {
    _log.info("Notifying listeners of CircuitCreationProvider");
    notifyListeners();
  }

  void _updateStatus(LoadingStatus status) {
    _loadingStatus = status;
    _notifyListeners();
  }
}
