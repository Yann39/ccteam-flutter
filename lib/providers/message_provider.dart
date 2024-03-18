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

import 'package:ccteam/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class MessageProvider extends ChangeNotifier {
  final Logger _log = new Logger('MessageProvider');

  // current message
  String _message;

  // current message type
  MessageType _messageType;

  String get message => _message;

  MessageType get messageType => _messageType;

  /// Set the current message.
  void setMessage(String message, MessageType messageType) {
    _message = message;
    _messageType = messageType;
    _log.info("Notifying listeners of MessageProvider");
    notifyListeners();
  }

  /// Clear the current message
  void clearMessage() {
    _message = null;
    _log.info("Notifying listeners of MessageProvider");
    notifyListeners();
  }
}
