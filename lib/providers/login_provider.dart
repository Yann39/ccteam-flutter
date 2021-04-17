/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of Chachatte Team application.
 *
 * Chachatte Team is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Chachatte Team is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Chachatte Team. If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';
import 'dart:io';

import 'package:chachatte_team/models/jwt_response.dart';
import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/services/members_service.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:chachatte_team/utils/graphql_connection.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  final Logger _log = new Logger('LoginProvider');
  final MembersService _membersService = new MembersService();

  // current authentication status
  AuthStatus _authStatus = AuthStatus.Unauthenticated;

  // current login process status
  LoginStatus _loginStatus = LoginStatus.EmailStep;

  // current passCode being entered for login
  String _loginPassCode;

  // current passCode being created
  String _firstPassCode;

  // current passCode being confirmed
  String _secondPassCode;

  // current error message
  String _errorMessage;

  // current email being enrolled
  String email;
  String firstName;
  String lastName;

  // current logged member
  Member _loggedMember;

  // current JWT token
  String _jwtToken;

  // constructor
  LoginProvider() {
    // as soon as it is instantiated, we check if the user needs to authenticate
    _checkUser();
  }

  Member get loggedMember => _loggedMember;

  AuthStatus get authStatus => _authStatus;

  LoginStatus get loginStatus => _loginStatus;

  String get loginPassCode => _loginPassCode;

  String get firstPassCode => _firstPassCode;

  String get secondPassCode => _secondPassCode;

  String get jwtToken => _jwtToken;

  String get errorMessage => _errorMessage;

  /// Change the current authentication [status].
  void _setAuthStatus(AuthStatus status) {
    _authStatus = status;
    _log.info("Notifying listeners of LoginProvider");
    notifyListeners();
  }

  /// Change the current login [status].
  void setLoginStatus(LoginStatus status) {
    // if we go to login passcode, always clear it first
    if (status == LoginStatus.PasscodeStep) {
      _loginPassCode = null;
    }
    _loginStatus = status;
    _log.info("Notifying listeners of LoginProvider");
    notifyListeners();
  }

  /// Set the current [passcode] used for logging in.
  void setLoginPassCode(String passcode) {
    _loginPassCode = passcode;
    _log.info("Notifying listeners of LoginProvider");
    notifyListeners();
  }

  /// Set the current [passcode] used in registration process.
  void setFirstPassCode(String passcode) {
    _firstPassCode = passcode;
    _log.info("Notifying listeners of LoginProvider");
    notifyListeners();
  }

  /// Set the current [passcode] used in registration process (confirmation).
  void setSecondPassCode(String passcode) {
    _secondPassCode = passcode;
    _log.info("Notifying listeners of LoginProvider");
    notifyListeners();
  }

  /// Set the current [error] message.
  void _setErrorMessage(String error) {
    _errorMessage = error;
    _log.info("Notifying listeners of LoginProvider");
    notifyListeners();
  }

  /// Change the login status so that it goes back to the previous login step.
  void goToPreviousLoginStep() {
    switch (_loginStatus) {
      case LoginStatus.EmailStep:
        _loginStatus = LoginStatus.EmailStep;
        break;
      case LoginStatus.EmailAndInfoStep:
        _loginStatus = LoginStatus.EmailStep;
        break;
      case LoginStatus.OtpStep:
        _loginStatus = LoginStatus.EmailStep;
        break;
      case LoginStatus.PasscodeStep:
        _loginStatus = LoginStatus.EmailStep;
        break;
      case LoginStatus.CreatePasscodeStep:
        _loginStatus = LoginStatus.EmailStep;
        break;
      case LoginStatus.ConfirmPasscodeStep:
        _loginStatus = LoginStatus.CreatePasscodeStep;
        break;
      default:
        _loginStatus = LoginStatus.EmailStep;
    }
    _log.info("Notifying listeners of LoginProvider");
    notifyListeners();
  }

  /// Check if the user needs to authenticate.
  /// Used to be called on app start.
  /// If email is found in shared preferences and exists in the database, user will be consider as logged in.
  Future<void> _checkUser() async {
    _log.info("Checking user...");
    _setAuthStatus(AuthStatus.Initializing);

    // read shared preference
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    final String _email = _prefs.getString('email');
    final String _jwt = _prefs.getString('jwt');

    // no e-mail found in shared preferences, it means user have to identify
    if (_email == null) {
      _log.info("Email not found in shared preferences");
      setLoginStatus(LoginStatus.EmailStep);
      _setAuthStatus(AuthStatus.Unauthenticated);
      return;
    }

    // no JWT token found in shared preferences, it means user have to authenticate
    if (_jwt == null) {
      _log.info("JWT token not found in shared preferences");
      setLoginStatus(LoginStatus.PasscodeStep);
      _setAuthStatus(AuthStatus.Unauthenticated);
      return;
    }

    _log.fine("Email $_email and token $_jwt found in shared preferences, let's get member from database");

    // set the JWT token to be used for all future GraphQL queries
    GraphQLConnection().jwtToken = _jwt;

    // retrieve full user from database, this will use and check the JWT token
    await _membersService
        .getMemberByEmail(_email)
        .timeout(Duration(seconds: 5))
        .then((value) {
      // null value means member not found
      if (value == null) {
        _log.severe("Email found in shared preferences but member not found in the database !");
        setLoginStatus(LoginStatus.PasscodeStep);
        _setAuthStatus(AuthStatus.Unauthenticated);
        _setErrorMessage(AppString.format(AppString.errorEmailNotFoundInDatabase, [_email]));
      }
      // user found
      else {
        _log.fine("User $_email found in database and JWT token verified, consider as logged in");
        _loggedMember = value;
        _setAuthStatus(AuthStatus.Authenticated);
      }
    }, onError: (error) {
      _log.severe("Email found in shared preferences but an error occurred while retrieving member from the database : $error");
      // JWT token has expired
      if (error.toString().contains("token_expired")) {
        _prefs.remove('jwt');
        setLoginStatus(LoginStatus.PasscodeStep);
        _setAuthStatus(AuthStatus.Unauthenticated);
        _setErrorMessage(AppString.errorTokenExpired);
      }
      // JWT token has not been specified
      else if (error.toString().contains("no_token")) {
        setLoginStatus(LoginStatus.PasscodeStep);
        _setAuthStatus(AuthStatus.Unauthenticated);
        _setErrorMessage(AppString.errorTokenNotFound);
      }
      // Wrong credentials
      else if (error.toString().contains("bad_credentials")) {
        setLoginStatus(LoginStatus.PasscodeStep);
        _setAuthStatus(AuthStatus.Unauthenticated);
        _setErrorMessage(AppString.errorBadCredentials);
      }
      // Other error
      else {
        _prefs.remove('email');
        _prefs.remove('jwt');
        setLoginStatus(LoginStatus.EmailStep);
        _setAuthStatus(AuthStatus.Unauthenticated);
        _setErrorMessage(AppString.format(AppString.errorUnknown, [error]));
      }
    });
  }

  /// Check the specified member account.
  /// It checks the registration status to know if we need to register, identify or login the user.
  Future<void> checkAccount(String email) async {
    _log.info("Checking account for user $email");
    setLoginStatus(LoginStatus.Loading);

    this.email = email;

    await _membersService
        .checkAccount(email)
        .timeout(Duration(seconds: 5))
        .then((response) async {
      if (response.statusCode == 200) {
        // account has been found with password and is verified
        setLoginStatus(LoginStatus.PasscodeStep);
      } else if (response.statusCode == 400) {
        // e-mail address is missing in the request
        setLoginStatus(LoginStatus.EmailStep);
      } else if (response.statusCode == 404) {
        // no account has been found for the specified e-mail address, propose new account
        setLoginStatus(LoginStatus.EmailAndInfoStep);
      } else if (response.statusCode == 302) {
        // account exists, OTP has been sent and is still valid
        setLoginStatus(LoginStatus.OtpStep);
      } else if (response.statusCode == 417) {
        // account exists, OTP has been sent but is not valid anymore
        setLoginStatus(LoginStatus.OtpStep);
      } else if (response.statusCode == 403) {
        // account exist, OTP has been verified, but password has not been created
        setLoginStatus(LoginStatus.CreatePasscodeStep);
      } else {
        _log.severe(
            "Failed to check account for user $email : ${response.body}");
        setLoginStatus(LoginStatus.EmailStep);
        throw Exception(
            "Une erreur s'est produite lors de la vérification de votre compte, si le problème persite, contactez un administrateur");
      }
    }, onError: (error) {
      _log.severe("Error while checking account for user $email : $error");
      setLoginStatus(LoginStatus.EmailStep);
      throw Exception(
          "Une erreur s'est produite lors de la vérification de votre compte, si le problème persite, contactez un administrateur");
    });
  }

  /// pre-register a new member according to the specified [member] information.
  Future<void> preRegisterMember() async {
    _log.info("Pre-registering user ${_loggedMember.email}");

    await _membersService
        .preRegister(_loggedMember)
        .timeout(Duration(seconds: 5))
        .then((response) async {
      if (response.statusCode == 201) {
        // member has been pre-registered successfully
        setLoginStatus(LoginStatus.OtpStep);
      } else if (response.statusCode == 400) {
        // e-mail address, first name, or last name is missing from the request
        setLoginStatus(LoginStatus.EmailAndInfoStep);
      } else if (response.statusCode == 409) {
        // e-mail address already exists
        setLoginStatus(LoginStatus.EmailAndInfoStep);
      } else if (response.statusCode == 207) {
        // member successfully created but the confirmation e-mail failed to be sent
        setLoginStatus(LoginStatus.OtpStep);
      } else {
        _log.severe(
            "Failed to pre-register user ${_loggedMember.email} : ${response.body}");
        setLoginStatus(LoginStatus.EmailAndInfoStep);
        throw Exception(
            "Une erreur s'est produite lors de l'inscription, si le problème persite, contactez un administrateur");
      }
    }, onError: (error) {
      _log.severe(
          "Error while pre-registering user ${_loggedMember.email} : $error");
      setLoginStatus(LoginStatus.EmailAndInfoStep);
      throw Exception(
          "Une erreur s'est produite lors de l'inscription, si le problème persite, contactez un administrateur");
    });
  }

  /// Resend the OTP to the user corresponding to the specified e-mail address.
  Future<void> resendOtp() async {
    _log.info("Resending OTP to user ${_loggedMember.email}");
    setLoginStatus(LoginStatus.Loading);

    await _membersService
        .resendOtp(_loggedMember)
        .timeout(Duration(seconds: 5))
        .then((response) async {
      if (response.statusCode == 200) {
        // store the OTP sent date in the shared preferences for timer
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(
            'otpDate', DateTime.now().millisecondsSinceEpoch.toString());

        // OTP has been resent successfully
        setLoginStatus(LoginStatus.OtpStep);
      } else if (response.statusCode == 400) {
        // e-mail address is missing in the request
        setLoginStatus(LoginStatus.OtpStep);
      } else if (response.statusCode == 404) {
        // no account has been found for the specified e-mail address
        setLoginStatus(LoginStatus.OtpStep);
      } else if (response.statusCode == 207) {
        // the OTP has been successfully updated but the mail failed to be sent
        setLoginStatus(LoginStatus.OtpStep);
      } else {
        _log.severe(
            "Failed to resend OTP to user ${_loggedMember.email} : ${response.body}");
        setLoginStatus(LoginStatus.OtpStep);
        throw Exception(
            "Une erreur s'est produite lors de l'envoi de votre code, si le problème persite, contactez un administrateur");
      }
    }, onError: (error) {
      _log.severe(
          "Error while resending OTP to user ${_loggedMember.email} : $error");
      setLoginStatus(LoginStatus.OtpStep);
      throw Exception(
          "Une erreur s'est produite lors de l'envoi de votre code, si le problème persite, contactez un administrateur");
    });
  }

  /// Confirm the user e-mail address according to specified OTP.
  Future<void> confirmEmail() async {
    _log.info("Confirming e-mail of user ${_loggedMember.email}");

    await _membersService
        .confirmEmail(_loggedMember)
        .timeout(Duration(seconds: 5))
        .then((response) async {
      if (response.statusCode == 202) {
        // e-mail has been verified successfully
        setLoginStatus(LoginStatus.CreatePasscodeStep);
      } else if (response.statusCode == 400) {
        // e-mail address or OTP is missing from the request
        setLoginStatus(LoginStatus.OtpStep);
      } else if (response.statusCode == 404) {
        // e-mail address has not been found in the database
        setLoginStatus(LoginStatus.OtpStep);
      } else if (response.statusCode == 406) {
        // the specified OTP has expired
        setLoginStatus(LoginStatus.OtpStep);
      } else if (response.statusCode == 401) {
        // the specified OTP does not match the one from the database
        setLoginStatus(LoginStatus.OtpStep);
      } else {
        _log.severe(
            "Failed to confirm e-mail for user ${_loggedMember.email} : ${response.body}");
        setLoginStatus(LoginStatus.OtpStep);
        throw Exception(
            "Une erreur s'est produite lors de la vérification de votre code, si le problème persite, contactez un administrateur");
      }
    }, onError: (error) {
      _log.severe(
          "Error while confirming e-mail for user ${_loggedMember.email} : $error");
      setLoginStatus(LoginStatus.OtpStep);
      throw Exception(
          "Une erreur s'est produite lors de la vérification de votre code, si le problème persite, contactez un administrateur");
    });
  }

  /// Complete user registration according to the specified [member] information.
  Future<void> completeRegistration() async {
    _log.info("Completing registration of user ${_loggedMember.email}");
    await _membersService
        .completeRegistration(_loggedMember)
        .timeout(Duration(seconds: 5))
        .then((response) async {
      if (response.statusCode == 200) {
        // account has been created successfully
        setLoginStatus(LoginStatus.PasscodeStep);
      } else if (response.statusCode == 400) {
        // e-mail address or password is missing from the request
        setLoginStatus(LoginStatus.ConfirmPasscodeStep);
      } else if (response.statusCode == 404) {
        // member not found in the database
        setLoginStatus(LoginStatus.ConfirmPasscodeStep);
      } else {
        _log.severe(
            "Failed to complete registration for user ${_loggedMember.email} : ${response.body}");
        setLoginStatus(LoginStatus.CreatePasscodeStep);
        throw Exception(
            "Une erreur s'est produite lors de la création de votre compte, si le problème persite, contactez un administrateur");
      }
    }, onError: (error) {
      _log.severe(
          "Error while completing registration for user ${_loggedMember.email} : $error");
      setLoginStatus(LoginStatus.CreatePasscodeStep);
      throw Exception(
          "Une erreur s'est produite lors de la création de votre compte, si le problème persite, contactez un administrateur");
    });
  }

  /// Log in the specified [member] identified by email and password.
  Future<void> loginMember() async {
    _setAuthStatus(AuthStatus.Authenticating);
    setLoginStatus(LoginStatus.Loading);

    // get email from user preferences
    String email;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('email')) {
      email = prefs.get('email');
    }

    // no email found in shared preferences, get current email from enrollment
    if (email == null) {
      _log.info("No email found in shared preferences");
      email = this.email;
    }

    _log.info("Logging in user $email");

    await _membersService
        .authenticate(email, _loginPassCode)
        .timeout(Duration(seconds: 5))
        .then((response) async {
      // check response and get the JWT token
      if (response.statusCode == 200) {
        _log.info("User $email successfully authenticated and got a JWT token");

        // get and store JWT token
        final JwtResponse jwt =
            JwtResponse.fromJson(json.decode(response.body));
        _jwtToken = jwt.jwtToken;

        // set the JWT token to be used for all future GraphQL queries
        GraphQLConnection().jwtToken = _jwtToken;
        _log.info("JWT token set for member $email : $_jwtToken");

        // get the full member from the database
        await _membersService
            .getMemberByEmail(email)
            .timeout(Duration(seconds: 5))
            .then((m) async {
          _log.info("Member ${m.email} successfully retrieved from database");

          // store the user's e-mail and token in the shared preferences
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('email', m.email);
          prefs.setString('jwt', _jwtToken);

          _loggedMember = m;
          _setAuthStatus(AuthStatus.Authenticated);
          setLoginStatus(LoginStatus.EmailStep);
        }, onError: (error) {
          _log.info(
              "Member with e-mail $email not found in the database from app ($error)");
          _loggedMember = null;
          _jwtToken = null;
          GraphQLConnection().jwtToken = null;
          _setAuthStatus(AuthStatus.Unauthenticated);
          setLoginStatus(LoginStatus.PasscodeStep);
          throw (error);
        });
      } else if (response.statusCode == 401) {
        _log.info(
            "Failed to authenticate member $email, wrong username or password");
        _setAuthStatus(AuthStatus.Unauthenticated);
        setLoginStatus(LoginStatus.PasscodeStep);
        throw Exception("Nom d'utilisateur ou mot de passe incorrect");
      } else {
        _log.info("Failed to authenticate user $email : ${response.body}");
        _setAuthStatus(AuthStatus.Unauthenticated);
        setLoginStatus(LoginStatus.PasscodeStep);
        throw Exception("Erreur serveur : ${response.statusCode}");
      }
    }, onError: (error) {
      _log.info("Member with e-mail $email failed to authenticate ($error)");
      _loggedMember = null;
      _jwtToken = null;
      GraphQLConnection().jwtToken = null;
      _setAuthStatus(AuthStatus.Unauthenticated);
      setLoginStatus(LoginStatus.PasscodeStep);
      throw Exception("Erreur lors de l'authentification : $error");
    });
  }

  /// Log out the current member.
  Future<void> logoutMember() async {
    _log.info("Logging out user ${_loggedMember.email}");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.remove('email');
    _loggedMember = null;
    _jwtToken = null;
    prefs.remove('jwt');
    _setAuthStatus(AuthStatus.Unauthenticated);
  }

  /// Ask for a new password.
  Future<void> askPassword(String email) async {
    await _membersService.askPassword(email).then((value) {
      _log.fine("Forgot password requested for e-mail : $email");
    }, onError: (error) {
      _log.severe("Failed to request forgot password", error);
      throw (error);
    });
  }

  /// Upload the specified [avatar] file for the specified [member].
  /// If the specified [member] is different from the current logged user, it means we are uploading an avatar as admin for a member.
  /// If the specified [member] is the same as the current logged user, it means the current logged user is uploading an avatar.
  Future<void> uploadAvatar(File avatar, Member member) async {
    if (member.id != _loggedMember.id) {
      _log.fine("Uploaded avatar as admin for user ${member.email}");
    }

    final Member tmpMember = member;

    await _membersService.uploadAvatar(avatar, tmpMember.id).then(
        (value) async {
      _log.fine("Avatar uploaded successfully");

      dynamic responseJson = json.decode(value);
      final String uploadedFileName = responseJson['file'];

      _log.fine("Avatar uploaded file name is : $uploadedFileName");

      tmpMember.avatarUrl = uploadedFileName;
      tmpMember.modifiedOn = DateTime.now();

      _log.info("Sending user with new avatar : ${tmpMember.toString()}");

      await _membersService.updateMember(tmpMember).then((value) {
        _log.fine("Avatar updated for member : ${tmpMember.email}");
        if (member.id == _loggedMember.id) {
          _loggedMember.avatarUrl = tmpMember.avatarUrl;
          _loggedMember.modifiedOn = tmpMember.modifiedOn;
          _log.info("Notifying listeners of LoginProvider");
          notifyListeners();
        }
      }, onError: (error) {
        _log.severe(
            "Failed to update avatar for member ${tmpMember.email} ($error)");
        throw (error);
      });
    }, onError: (error) {
      _log.severe("Failed to upload avatar ($error)");
      throw (error);
    });
  }

  /// Delete the avatar of the specified [member].
  /// If the specified [member] is different from the current logged user, it means we are deleting an avatar as admin for a member.
  /// If the specified [member] is the same as the current logged user, it means the current logged user is deleting its avatar.
  Future<void> deleteAvatar(Member member) async {
    if (member.id != _loggedMember.id) {
      _log.fine("Deleting avatar as admin for user ${member.email}");
    }

    final Member tmpMember = member;

    await _membersService.deleteAvatar(member.id).then((value) async {
      _log.fine("Avatar file deleted successfully from server");

      tmpMember.avatarUrl = null;
      tmpMember.modifiedOn = DateTime.now();

      await _membersService.updateMember(tmpMember).then((value) {
        _log.fine("Avatar deleted for member : ${tmpMember.email}");
        if (member.id == _loggedMember.id) {
          _loggedMember.avatarUrl = null;
          _loggedMember.modifiedOn = tmpMember.modifiedOn;
        }
        _log.info("Notifying listeners of LoginProvider");
        notifyListeners();
      }, onError: (error) {
        _log.severe(
            "Failed to delete avatar for member ${tmpMember.email} ($error)");
        throw (error);
      });
    }, onError: (error) {
      _log.severe("Failed to delete avatar ($error)");
      throw (error);
    });
  }

  Future<void> getOtpDate() async {
    // get the OTP sent date from the shared preferences for timer
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime otpDate =
        DateTime.fromMillisecondsSinceEpoch(int.parse(prefs.get('otpDate')));
  }
}
