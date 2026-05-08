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

enum AuthStatus { Initializing, Unauthenticated, Authenticating, Authenticated }

enum MemberRole { ROLE_USER, ROLE_MEMBER, ROLE_ADMIN }

/// Position held by a member in the club's executive board (orthogonal to
/// the security [MemberRole]). At most one member holds each role at a
/// time; uniqueness is enforced server-side.
enum BoardRole { PRESIDENT, VICE_PRESIDENT, SECRETARY, TREASURER }

/// Human-readable French label for a [BoardRole].
extension BoardRoleLabel on BoardRole {
  String get labelFr {
    switch (this) {
      case BoardRole.PRESIDENT:
        return "Président";
      case BoardRole.VICE_PRESIDENT:
        return "Vice-président";
      case BoardRole.SECRETARY:
        return "Secrétaire";
      case BoardRole.TREASURER:
        return "Trésorier";
    }
  }

  String get labelEn {
    switch (this) {
      case BoardRole.PRESIDENT:
        return "President";
      case BoardRole.VICE_PRESIDENT:
        return "Vice-president";
      case BoardRole.SECRETARY:
        return "Secretary";
      case BoardRole.TREASURER:
        return "Treasurer";
    }
  }

  /// Pick the label for the given [languageCode] (`'fr'` / `'en'`),
  /// defaulting to French.
  String localizedLabel(String languageCode) {
    return languageCode == 'en' ? labelEn : labelFr;
  }
}

enum LoginStatus {
  Loading,
  EmailStep,
  EmailAndInfoStep,
  OtpStep,
  CreatePasscodeStep,
  ConfirmPasscodeStep,
  PasscodeStep,
}

enum OtpStatus { NotSent, Sent, Verified }

enum LoadingStatus { notLoaded, loading, loaded, empty }

enum ConfirmDialogAction { yes, no }

enum QuickActions { about, contact, logout }

enum DialogType { info, success, warning, error }

enum MessageType { INFO, SUCCESS, WARNING, ERROR, SESSION_EXPIRED }

enum TrackCondition { dry, drying, wet }

enum BikeManufacturer {
  honda,
  yamaha,
  aprilia,
  ducati,
  kawasaki,
  suzuki,
  bmw,
  ktm,
  triumph,
  ohvale,
  other
}
