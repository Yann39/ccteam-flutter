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
import 'dart:convert';
import 'dart:io';

import 'package:ccteam/models/jwt_response.dart';
import 'package:ccteam/models/member.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/members_service.dart';
import 'package:ccteam/utils/custom_graphql_exception.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  final Logger _log = new Logger('LoginProvider');
  final MembersService _membersService = new MembersService();

  // message provider that can be set from the proxy provider
  MessageProvider _messageProvider;

  // current authentication status
  AuthStatus _authStatus = AuthStatus.Unauthenticated;

  // current login process status
  LoginStatus _loginStatus = LoginStatus.EmailStep;

  // current passcode being entered for login
  String _loginPassCode;

  // current passcode being created
  String _firstPassCode;

  // current passcode confirmation
  String _secondPassCode;

  // current email being enrolled
  String _email;

  // current first name entered when preregistering
  String firstName;

  // current last name entered when preregistering
  String lastName;

  // current OTP being entered when confirming e-mail
  String otp;

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

  String get email => _email;

  set email(String email) => this._email = email;

  /// Set the current [passcode] used for login.
  set loginPassCode(String passcode) {
    _loginPassCode = passcode;
    _notifyListeners();
  }

  /// Set the current [passcode] used in registration process.
  set firstPassCode(String passcode) {
    _firstPassCode = passcode;
    _notifyListeners();
  }

  /// Update message provider with the specified [messageProvider].
  void updateMessageProvider(MessageProvider messageProvider) {
    _messageProvider = messageProvider;
    _notifyListeners();
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
    _notifyListeners();
  }

  /// Go to the confirm password screen.
  void goToConfirmPassword() {
    _log.info("Confirming e-mail of user $_email");
    _setLoginStatus(LoginStatus.ConfirmPasscodeStep);
  }

  /// Go to the confirm password screen.
  void goToRegister() {
    _log.info("User clicked link to go to register page");
    _setLoginStatus(LoginStatus.EmailAndInfoStep);
  }

  /// Check the specified member account from the given e-mail address.
  /// It checks the registration status to know if we need to register, identify or login the user.
  Future<void> checkAccountEmail(String email) async {
    _log.info("Checking account for user $email");
    _setLoginStatus(LoginStatus.Loading);

    this._email = email;

    await _membersService.checkAccount(email).timeout(Duration(seconds: 5)).then((response) async {
      // account has been found with password and is verified
      if (response.statusCode == 200) {
        _setLoginStatus(LoginStatus.PasscodeStep);
      }
      // e-mail address is missing in the request
      else if (response.statusCode == 400) {
        _setLoginStatus(LoginStatus.EmailStep);
        _messageProvider.setMessage(AppString.loginEmailMissing, MessageType.ERROR);
      }
      // no account has been found for the specified e-mail address, propose new account
      else if (response.statusCode == 404) {
        _setLoginStatus(LoginStatus.EmailStep);
        _messageProvider.setMessage(AppString.loginNoAccountFound, MessageType.ERROR);
      }
      // account exists, OTP has been sent and is still valid
      else if (response.statusCode == 302) {
        _setLoginStatus(LoginStatus.OtpStep);
      }
      // account exists, OTP has been sent but is not valid anymore
      else if (response.statusCode == 417) {
        _setLoginStatus(LoginStatus.OtpStep);
      }
      // account exist, OTP has been verified, but password has not been created
      else if (response.statusCode == 403) {
        _setLoginStatus(LoginStatus.CreatePasscodeStep);
      }
      // unexpected status code
      else {
        _log.severe("Failed to check account for user $email : ${response.body}");
        _setLoginStatus(LoginStatus.EmailStep);
        _messageProvider.setMessage(AppString.checkAccountUnexpectedResponse, MessageType.ERROR);
      }
    }, onError: (error) {
      _log.severe("Error while checking account for user $email : $error");
      _setLoginStatus(LoginStatus.EmailStep);
      if (error is TimeoutException) {
        _messageProvider.setMessage(AppString.errorServerTimeOut, MessageType.ERROR);
      } else {
        _messageProvider.setMessage(AppString.checkAccountError, MessageType.ERROR);
      }
    });
  }

  /// pre-register a new member according to the specified member information.
  Future<void> preRegisterMember() async {
    _log.info("Pre-registering user ${this.firstName} ${this.lastName} ($_email)");
    _setLoginStatus(LoginStatus.Loading);

    await _membersService.preRegister(this.firstName, this.lastName, _email).timeout(Duration(seconds: 5)).then(
        (response) async {
      // member has been pre-registered successfully
      if (response.statusCode == 201) {
        _setLoginStatus(LoginStatus.OtpStep);
      }
      // e-mail address, first name, or last name is missing from the request
      else if (response.statusCode == 400) {
        _setLoginStatus(LoginStatus.EmailAndInfoStep);
      }
      // e-mail address already exists
      else if (response.statusCode == 409) {
        _messageProvider.setMessage(AppString.loginAccountEmailAlreadyExist, MessageType.ERROR);
        _setLoginStatus(LoginStatus.EmailAndInfoStep);
      }
      // member successfully created but the confirmation e-mail failed to be sent
      else if (response.statusCode == 207) {
        _setLoginStatus(LoginStatus.OtpStep);
        _messageProvider.setMessage(AppString.preRegisterConfirmationEmailNotSent, MessageType.WARNING);
      }
      // unexpected status code
      else {
        _log.severe("Failed to pre-register user $_email : ${response.body}");
        _setLoginStatus(LoginStatus.EmailAndInfoStep);
        _messageProvider.setMessage(AppString.preRegisterUnexpectedResponse, MessageType.ERROR);
      }
    }, onError: (error) {
      _log.severe("Error while pre-registering user $_email : $error");
      _setLoginStatus(LoginStatus.EmailAndInfoStep);
      if (error is TimeoutException) {
        _messageProvider.setMessage(AppString.errorServerTimeOut, MessageType.ERROR);
      } else {
        _messageProvider.setMessage(AppString.preRegisterError, MessageType.ERROR);
      }
    });
  }

  /// Resend the OTP to the user corresponding to the specified e-mail address.
  Future<void> resendOtp() async {
    _log.info("Resending OTP to user $_email");
    _setLoginStatus(LoginStatus.Loading);

    await _membersService.resendOtp(_email).timeout(Duration(seconds: 5)).then((response) async {
      // OTP has been resent successfully
      if (response.statusCode == 200) {
        // store the OTP sent date in the shared preferences for timer
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('otpDate', DateTime.now().millisecondsSinceEpoch.toString());
        _setLoginStatus(LoginStatus.OtpStep);
      }
      // e-mail address is missing in the request
      else if (response.statusCode == 400) {
        _setLoginStatus(LoginStatus.OtpStep);
      }
      // no account has been found for the specified e-mail address
      else if (response.statusCode == 404) {
        _setLoginStatus(LoginStatus.OtpStep);
      }
      // the OTP has been successfully updated but the mail failed to be sent
      else if (response.statusCode == 207) {
        _setLoginStatus(LoginStatus.OtpStep);
      }
      // unexpected status code
      else {
        _log.severe("Failed to resend OTP to user $_email : ${response.body}");
        _setLoginStatus(LoginStatus.OtpStep);
        throw Exception(
            "Une erreur s'est produite lors de l'envoi de votre code, si le problème persite, contactez un administrateur");
      }
    }, onError: (error) {
      _log.severe("Error while resending OTP to user $_email : $error");
      _setLoginStatus(LoginStatus.OtpStep);
      throw Exception(
          "Une erreur s'est produite lors de l'envoi de votre code, si le problème persite, contactez un administrateur");
    });
  }

  /// Confirm the user e-mail address according to specified OTP.
  Future<void> confirmEmail() async {
    _log.info("Confirming e-mail of user $_email");

    await _membersService.confirmEmail(_email, otp).timeout(Duration(seconds: 5)).then((response) async {
      // e-mail has been verified successfully
      if (response.statusCode == 202) {
        _setLoginStatus(LoginStatus.CreatePasscodeStep);
      }
      // e-mail address or OTP is missing from the request
      else if (response.statusCode == 400) {
        _setLoginStatus(LoginStatus.OtpStep);
      }
      // e-mail address has not been found in the database
      else if (response.statusCode == 404) {
        _setLoginStatus(LoginStatus.OtpStep);
      }
      // the specified OTP has expired
      else if (response.statusCode == 406) {
        _setLoginStatus(LoginStatus.OtpStep);
      }
      // the specified OTP does not match the one from the database
      else if (response.statusCode == 401) {
        _setLoginStatus(LoginStatus.OtpStep);
      }
      // unexpected status code
      else {
        _log.severe("Failed to confirm e-mail for user $_email : ${response.body}");
        _setLoginStatus(LoginStatus.OtpStep);
        throw Exception(
            "Une erreur s'est produite lors de la vérification de votre code, si le problème persite, contactez un administrateur");
      }
    }, onError: (error) {
      _log.severe("Error while confirming e-mail for user $_email : $error");
      _setLoginStatus(LoginStatus.OtpStep);
      throw Exception(
          "Une erreur s'est produite lors de la vérification de votre code, si le problème persite, contactez un administrateur");
    });
  }

  /// Complete user registration according to the specified member information.
  Future<void> completeRegistration() async {
    _log.info("Completing registration of user $_email");
    await _membersService.completeRegistration(_email, _firstPassCode).timeout(Duration(seconds: 5)).then(
        (response) async {
      // account has been created successfully
      if (response.statusCode == 200) {
        _setLoginStatus(LoginStatus.PasscodeStep);
      }
      // e-mail address or password is missing from the request
      else if (response.statusCode == 400) {
        _setLoginStatus(LoginStatus.ConfirmPasscodeStep);
      }
      // member not found in the database
      else if (response.statusCode == 404) {
        _setLoginStatus(LoginStatus.ConfirmPasscodeStep);
      }
      // unexpected status code
      else {
        _log.severe("Failed to complete registration for user $_email : ${response.body}");
        _setLoginStatus(LoginStatus.CreatePasscodeStep);
        throw Exception(
            "Une erreur s'est produite lors de la création de votre compte, si le problème persite, contactez un administrateur");
      }
    }, onError: (error) {
      _log.severe("Error while completing registration for user $_email : $error");
      _setLoginStatus(LoginStatus.CreatePasscodeStep);
      throw Exception(
          "Une erreur s'est produite lors de la création de votre compte, si le problème persite, contactez un administrateur");
    });
  }

  /// Log in the specified [member] identified by email and password.
  Future<void> loginMember(String passcode) async {
    _setAuthStatus(AuthStatus.Authenticating);
    _setLoginStatus(LoginStatus.Loading);

    // get email from user preferences
    String email;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('email')) {
      email = prefs.get('email');
    }

    // no email found in shared preferences, get current email from enrollment
    if (email == null) {
      _log.info("No email found in shared preferences");
      email = _email;
    }

    _log.info("Logging in user $email");

    await _membersService.authenticate(email, passcode).timeout(Duration(seconds: 5)).then((response) async {
      // check response and get the JWT token
      if (response.statusCode == 200) {
        _log.info("User $email successfully authenticated and got a JWT token");

        // get and store JWT token
        final JwtResponse jwt = JwtResponse.fromJson(json.decode(response.body));
        _jwtToken = jwt.jwtToken;

        // set the JWT token to be used for all future GraphQL queries
        GraphQLConnection().jwtToken = _jwtToken;
        _log.info("JWT token set for member $email : $_jwtToken");

        // get the full member from the database
        await _membersService.getMemberByEmail(email).timeout(Duration(seconds: 5)).then((m) async {
          _log.info("Member ${m.email} successfully retrieved from database");

          // store the user's e-mail and token in the shared preferences
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('email', m.email);
          prefs.setString('jwt', _jwtToken);

          _loggedMember = m;
          _setAuthStatus(AuthStatus.Authenticated);
          _setLoginStatus(LoginStatus.EmailStep);
        }, onError: (error) {
          _log.info("Member with e-mail $email not found in the database from app ($error)");
          _loggedMember = null;
          _jwtToken = null;
          GraphQLConnection().jwtToken = null;
          _setAuthStatus(AuthStatus.Unauthenticated);
          _setLoginStatus(LoginStatus.PasscodeStep);
          throw (error);
        });
      } else if (response.statusCode == 401) {
        _log.info("Failed to authenticate member $email, wrong username or password");
        _setAuthStatus(AuthStatus.Unauthenticated);
        _setLoginStatus(LoginStatus.PasscodeStep);
        throw Exception("Passcode incorrect");
      } else {
        _log.info("Failed to authenticate user $email : ${response.body}");
        _setAuthStatus(AuthStatus.Unauthenticated);
        _setLoginStatus(LoginStatus.PasscodeStep);
        throw Exception("Erreur serveur : ${response.statusCode}");
      }
    }, onError: (error) {
      _log.info("Member with e-mail $email failed to authenticate ($error)");
      _loggedMember = null;
      _jwtToken = null;
      GraphQLConnection().jwtToken = null;
      _setAuthStatus(AuthStatus.Unauthenticated);
      _setLoginStatus(LoginStatus.PasscodeStep);
      throw Exception("Erreur lors de l'authentification : $error");
    });
  }

  /// Log out the current member.
  Future<void> logoutMember() async {
    _log.info("Logging out user ${_loggedMember?.email}");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.remove('email');
    _loggedMember = null;
    _jwtToken = null;
    prefs.remove('jwt');
    _setLoginStatus(LoginStatus.PasscodeStep);
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

    await _membersService.uploadAvatar(avatar, tmpMember.id).then((value) async {
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
          _notifyListeners();
        }
      }, onError: (error) {
        _log.severe("Failed to update avatar for member ${tmpMember.email} ($error)");
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
        _notifyListeners();
      }, onError: (error) {
        _log.severe("Failed to delete avatar for member ${tmpMember.email} ($error)");
        throw (error);
      });
    }, onError: (error) {
      _log.severe("Failed to delete avatar ($error)");
      throw (error);
    });
  }

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of LoginProvider");
    notifyListeners();
  }

  /// Change the current authentication [status].
  void _setAuthStatus(AuthStatus status) {
    _authStatus = status;
    _notifyListeners();
  }

  /// Change the current login [status].
  void _setLoginStatus(LoginStatus status) {
    // if we go to login passcode, always clear it first
    if (status == LoginStatus.PasscodeStep) {
      _loginPassCode = null;
    }
    _loginStatus = status;
    _notifyListeners();
  }

  /// Check if the user needs to authenticate.
  /// Used to be called on app start.
  /// If email is found in shared preferences and exists in the database, user will be consider as logged in.
  Future<void> _checkUser() async {
    _log.info("Checking user...");
    _setAuthStatus(AuthStatus.Initializing);

    // read shared preference to get any e-mail and JWT
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    final String _email = _prefs.getString('email');
    final String _jwt = _prefs.getString('jwt');

    // no e-mail found in shared preferences, it means user have to identify
    if (_email == null) {
      _log.info("Email not found in shared preferences");
      _setLoginStatus(LoginStatus.EmailStep);
      _setAuthStatus(AuthStatus.Unauthenticated);
      return;
    }

    // no JWT token found in shared preferences, it means user have to authenticate
    if (_jwt == null) {
      _log.info("JWT token not found in shared preferences");
      _setLoginStatus(LoginStatus.PasscodeStep);
      _setAuthStatus(AuthStatus.Unauthenticated);
      return;
    }

    _log.fine("Email $_email and token $_jwt found in shared preferences, let's get member from database");

    // set the JWT token to be used for all future GraphQL queries
    GraphQLConnection().jwtToken = _jwt;

    // retrieve full user from database, this will use and check the JWT token
    await _membersService.getMemberByEmail(_email).timeout(Duration(seconds: 5)).then((value) {
      _log.fine("User $_email found in database and JWT token verified, consider as logged in");
      _loggedMember = value;
      _setAuthStatus(AuthStatus.Authenticated);
    }, onError: (error) {
      _log.info("An error occurred while retrieving member from the database : $error");
      if (error is CustomGraphQlException) {
        _setLoginStatus(LoginStatus.PasscodeStep);
        _setAuthStatus(AuthStatus.Unauthenticated);
        // Member not found
        if (error.code == "member_not_found") {
          _messageProvider.setMessage(
              AppString.format(AppString.errorEmailNotFoundInDatabase, [_email]), MessageType.ERROR);
        }
        // JWT token has expired
        else if (error.code == "token_expired") {
          _prefs.remove('jwt');
          _messageProvider.setMessage(AppString.errorTokenExpired, MessageType.INFO);
        }
        // JWT token has wrong format and cannot be decoded
        else if (error.code == "wrong_token_format") {
          _messageProvider.setMessage(AppString.errorTokenWrongFormat, MessageType.ERROR);
        }
        // JWT token has not been specified
        else if (error.code == "no_token") {
          _messageProvider.setMessage(AppString.errorTokenNotFound, MessageType.ERROR);
        }
        // wrong credentials
        else if (error.code == "bad_credentials") {
          _messageProvider.setMessage(AppString.errorBadCredentials, MessageType.ERROR);
        }
      } else if (error is TimeoutException) {
        _setAuthStatus(AuthStatus.Unauthenticated);
        _messageProvider.setMessage(AppString.errorServerTimeOut, MessageType.ERROR);
      }
      // other error
      else {
        _setLoginStatus(LoginStatus.EmailStep);
        _setAuthStatus(AuthStatus.Unauthenticated);
        _log.info("Error is ${error.toString()}");
        _messageProvider.setMessage(AppString.format(AppString.errorUnknown, [error.toString()]), MessageType.ERROR);
      }
    });
  }
}
