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

import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Device identity used for device binding.
///
/// Holds a high-entropy secret generated once on this device and kept in the
/// OS secure storage (Android Keystore). It is sent to the backend on
/// authentication so a device can be recognized; the server only ever stores
/// its hash. This is deliberately NOT a hardware identifier (those are
/// unreliable across OS updates / resets, privacy-restricted and spoofable).
class DeviceIdentity {
  DeviceIdentity._();

  // v10 uses strong ciphers by default (Keystore-backed); no options needed.
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _keySecret = 'device_secret';
  static const String _keyEnrolled = 'device_enrolled';

  /// A short human-readable label for this device, shown in the (future) trusted-devices
  /// management screen. Kept generic since we don't pull in a device-info plugin.
  static const String label = 'Application mobile Android';

  /// Return the persistent device secret, generating and storing it on first use.
  /// 32 random bytes (256 bits) from a cryptographically secure RNG, URL-safe base64 encoded.
  static Future<String> getOrCreateSecret() async {
    String? secret = await _storage.read(key: _keySecret);
    if (secret == null || secret.isEmpty) {
      final Random rnd = Random.secure();
      final List<int> bytes = List<int>.generate(32, (_) => rnd.nextInt(256));
      secret = base64UrlEncode(bytes);
      await _storage.write(key: _keySecret, value: secret);
    }
    return secret;
  }

  /// Whether this device has already been enrolled as trusted on the backend
  /// (used to avoid re-issuing the grandfather enrollment call every launch).
  static Future<bool> isEnrolled() async {
    return (await _storage.read(key: _keyEnrolled)) == '1';
  }

  /// Mark this device as enrolled (trusted) on the backend.
  static Future<void> setEnrolled() async {
    await _storage.write(key: _keyEnrolled, value: '1');
  }
}
