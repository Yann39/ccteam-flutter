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

import 'package:ccteam/models/jwt_response.dart';
import 'package:ccteam/models/member.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/members_service.dart';
import 'package:ccteam/utils/custom_graphql_exception.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/graphql_connection.dart';
import 'package:ccteam/utils/navigator_key.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  final Logger _log = new Logger('LoginProvider');
  final MembersService _membersService = new MembersService();

  // message provider that can be set from the proxy provider
  late MessageProvider _messageProvider;

  // current authentication status
  AuthStatus _authStatus = AuthStatus.Unauthenticated;

  // current login process status
  LoginStatus _loginStatus = LoginStatus.EmailStep;

  // current passcode being entered for login
  String? _loginPassCode;

  // current passcode being created
  String? _firstPassCode;

  // current passcode confirmation
  String? _secondPassCode;

  // current email being enrolled
  String? _email;

  // current first name entered when preregistering
  String? firstName;

  // current last name entered when preregistering
  String? lastName;

  // current OTP being entered when confirming e-mail
  String? otp;

  // current logged member
  Member? _loggedMember;

  // current JWT token
  String? _jwtToken;

  // constructor
  LoginProvider() {
    // as soon as it is instantiated, we check if the user needs to authenticate
    _checkUser();
  }

  Member? get loggedMember => _loggedMember;

  AuthStatus get authStatus => _authStatus;

  LoginStatus get loginStatus => _loginStatus;

  bool get isMember => _loggedMember?.role == MemberRole.ROLE_MEMBER || _loggedMember?.role == MemberRole.ROLE_ADMIN;

  bool get isAdmin => _loggedMember?.role == MemberRole.ROLE_ADMIN;

  String? get loginPassCode => _loginPassCode;

  String? get firstPassCode => _firstPassCode;

  String? get secondPassCode => _secondPassCode;

  String? get jwtToken => _jwtToken;

  String? get email => _email;

  set email(String? email) => this._email = email;

  /// Set the current [passcode] used for login.
  set loginPassCode(String? passcode) {
    _loginPassCode = passcode;
    _notifyListeners();
  }

  /// Set the current [passcode] used in registration process.
  set firstPassCode(String? passcode) {
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

  /// Check if the user needs to authenticate.
  /// Used to be called on app start.
  /// If email is found in shared preferences and exists in the database, user will be consider as logged in.
  Future<void> _checkUser() async {
    _log.info("Checking user...");
    _setAuthStatus(AuthStatus.Initializing);

    // read shared preference to get any e-mail and JWT
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    final String? _email = _prefs.getString('email');
    final String? _jwt = _prefs.getString('jwt');

    // no e-mail found in shared preferences, it means user has to identify
    if (_email == null) {
      _log.info("Email not found in shared preferences");
      _setLoginStatus(LoginStatus.EmailStep);
      _setAuthStatus(AuthStatus.Unauthenticated);
      return;
    }

    // no JWT token found in shared preferences, it means user has to authenticate
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
    await _membersService
        .getMemberByEmail(_email)
        .timeout(Duration(seconds: 10))
        .then(
          (value) {
            _log.fine("User $_email found in database and JWT token verified, consider as logged in");
            _loggedMember = value;
            _setAuthStatus(AuthStatus.Authenticated);
          },
          onError: (error) {
            _log.info("An error occurred while retrieving member from the database : $error");
            if (error is CustomGraphQlException) {
              // JWT token has expired
              if (error.code == "token_expired") {
                _prefs.remove('jwt');
                _messageProvider.setMessage(AppString.errorTokenExpired, MessageType.SESSION_EXPIRED);
                return;
              }

              _setLoginStatus(LoginStatus.PasscodeStep);
              _setAuthStatus(AuthStatus.Unauthenticated);

              // member not found
              if (error.code == "member_not_found") {
                _messageProvider.setMessage(
                  AppString.format(AppString.errorEmailNotFoundInDatabase, [_email]),
                  MessageType.ERROR,
                );
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
              // unknown error code (should never happen)
              else {
                _messageProvider.setMessage(
                  AppString.format(AppString.errorUnknown, [error.code ?? "Unknown error"]),
                  MessageType.ERROR,
                );
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
              _messageProvider.setMessage(
                AppString.format(AppString.errorUnknown, [error.toString()]),
                MessageType.ERROR,
              );
            }
          },
        );
  }

  /// Check the specified member account from the given e-mail address.
  /// It checks the registration status to know if we need to register, identify or login the user.
  Future<void> checkAccountEmail(String email) async {
    _log.info("Checking account for user $email");
    _setLoginStatus(LoginStatus.Loading);

    this._email = email;

    await _membersService
        .checkAccount(email)
        .timeout(Duration(seconds: 10))
        .then(
          (response) async {
            // account has been found with existing password and is verified
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
            // account exist, OTP has been verified, but password has not been created yet
            else if (response.statusCode == 403) {
              _setLoginStatus(LoginStatus.CreatePasscodeStep);
            }
            // unexpected status code
            else {
              _log.severe("Failed to check account for user $email : ${response.body}");
              _setLoginStatus(LoginStatus.EmailStep);
              _messageProvider.setMessage(AppString.checkAccountUnexpectedResponse, MessageType.ERROR);
            }
          },
          onError: (error) {
            _log.severe("Error while checking account for user $email : $error");
            _setLoginStatus(LoginStatus.EmailStep);
            if (error is TimeoutException) {
              _messageProvider.setMessage(AppString.errorServerTimeOut, MessageType.ERROR);
            } else {
              _messageProvider.setMessage(AppString.checkAccountError, MessageType.ERROR);
            }
          },
        );
  }

  /// pre-register a new member according to the specified member information.
  Future<void> preRegisterMember() async {
    _log.info("Pre-registering user ${this.firstName} ${this.lastName} ($_email)");
    _setLoginStatus(LoginStatus.Loading);

    await _membersService
        .preRegister(this.firstName!, this.lastName!, _email!)
        .timeout(Duration(seconds: 10))
        .then(
          (response) async {
            // member has been pre-registered successfully
            if (response.statusCode == 201) {
              await _clearStoredOtpTimer();
              _setLoginStatus(LoginStatus.OtpStep);
            }
            // e-mail address, first name, or last name is missing from the request
            else if (response.statusCode == 400) {
              _setLoginStatus(LoginStatus.EmailAndInfoStep);
              _messageProvider.setMessage(AppString.preRegisterMissingData, MessageType.ERROR);
            }
            // e-mail address already exists
            else if (response.statusCode == 409) {
              _setLoginStatus(LoginStatus.EmailAndInfoStep);
              _messageProvider.setMessage(AppString.loginAccountEmailAlreadyExist, MessageType.ERROR);
            }
            // member successfully created but the confirmation e-mail failed to be sent
            else if (response.statusCode == 207) {
              await _clearStoredOtpTimer();
              _setLoginStatus(LoginStatus.OtpStep);
              _messageProvider.setMessage(
                AppString.format(AppString.preRegisterConfirmationEmailNotSent, [_email!]),
                MessageType.WARNING,
              );
            }
            // unexpected status code
            else {
              _log.severe("Failed to pre-register user $_email : ${response.body}");
              _setLoginStatus(LoginStatus.EmailAndInfoStep);
              _messageProvider.setMessage(AppString.preRegisterUnexpectedResponse, MessageType.ERROR);
            }
          },
          onError: (error) {
            _log.severe("Error while pre-registering user $_email : $error");
            _setLoginStatus(LoginStatus.EmailAndInfoStep);
            if (error is TimeoutException) {
              _messageProvider.setMessage(AppString.errorServerTimeOut, MessageType.ERROR);
            } else {
              _messageProvider.setMessage(AppString.preRegisterError, MessageType.ERROR);
            }
          },
        );
  }

  /// Resend the OTP to the user corresponding to the specified e-mail address.
  Future<void> resendOtp() async {
    _log.info("Resending OTP to user $_email");
    _setLoginStatus(LoginStatus.Loading);

    await _membersService
        .resendOtp(_email!)
        .timeout(Duration(seconds: 10))
        .then(
          (response) async {
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
              _messageProvider.setMessage(AppString.resendOtpMissingData, MessageType.ERROR);
            }
            // no account has been found for the specified e-mail address
            else if (response.statusCode == 404) {
              _setLoginStatus(LoginStatus.OtpStep);
              _messageProvider.setMessage(AppString.resendOtpNoAccountFound, MessageType.ERROR);
            }
            // the OTP has been successfully updated but the mail failed to be sent
            else if (response.statusCode == 207) {
              _setLoginStatus(LoginStatus.OtpStep);
              _messageProvider.setMessage(
                AppString.format(AppString.resendOtpEmailNotSent, [_email!]),
                MessageType.WARNING,
              );
            }
            // unexpected status code
            else {
              _log.severe("Failed to resend OTP to user $_email : ${response.body}");
              _setLoginStatus(LoginStatus.OtpStep);
              _messageProvider.setMessage(AppString.resendOtpUnexpectedResponse, MessageType.ERROR);
            }
          },
          onError: (error) {
            _log.severe("Error while resending OTP to user $_email : $error");
            _setLoginStatus(LoginStatus.OtpStep);
            if (error is TimeoutException) {
              _messageProvider.setMessage(AppString.errorServerTimeOut, MessageType.ERROR);
            } else {
              _messageProvider.setMessage(AppString.resendOtpError, MessageType.ERROR);
            }
          },
        );
  }

  /// Confirm the user e-mail address according to specified OTP.
  Future<void> confirmEmail() async {
    _log.info("Confirming e-mail of user $_email");

    await _membersService
        .confirmEmail(_email!, otp!)
        .timeout(Duration(seconds: 10))
        .then(
          (response) async {
            // e-mail has been verified successfully
            if (response.statusCode == 202) {
              _setLoginStatus(LoginStatus.CreatePasscodeStep);
            }
            // e-mail address or OTP is missing from the request
            else if (response.statusCode == 400) {
              _setLoginStatus(LoginStatus.OtpStep);
              _messageProvider.setMessage(AppString.confirmEmailMissingData, MessageType.ERROR);
            }
            // e-mail address has not been found in the database
            else if (response.statusCode == 404) {
              _setLoginStatus(LoginStatus.OtpStep);
              _messageProvider.setMessage(AppString.confirmEmailNoAccountFound, MessageType.ERROR);
            }
            // the specified OTP has expired
            else if (response.statusCode == 406) {
              _setLoginStatus(LoginStatus.OtpStep);
              _messageProvider.setMessage(AppString.confirmEmailOtpExpired, MessageType.ERROR);
            }
            // the specified OTP does not match the one from the database
            else if (response.statusCode == 401) {
              _setLoginStatus(LoginStatus.OtpStep);
              _messageProvider.setMessage(AppString.confirmEmailWrongOtp, MessageType.ERROR);
            }
            // unexpected status code
            else {
              _log.severe("Failed to confirm e-mail for user $_email : ${response.body}");
              _setLoginStatus(LoginStatus.OtpStep);
              _messageProvider.setMessage(AppString.confirmEmailUnexpectedResponse, MessageType.ERROR);
            }
          },
          onError: (error) {
            _log.severe("Error while confirming e-mail for user $_email : $error");
            _setLoginStatus(LoginStatus.OtpStep);
            if (error is TimeoutException) {
              _messageProvider.setMessage(AppString.errorServerTimeOut, MessageType.ERROR);
            } else {
              _messageProvider.setMessage(AppString.confirmEmailError, MessageType.ERROR);
            }
          },
        );
  }

  /// Complete user registration according to the specified member information.
  Future<void> completeRegistration(String passcode) async {
    _log.info("Completing registration of user $_email");
    await _membersService
        .completeRegistration(_email!, passcode)
        .timeout(Duration(seconds: 10))
        .then(
          (response) async {
            // account has been created successfully
            if (response.statusCode == 200) {
              _setLoginStatus(LoginStatus.PasscodeStep);
            }
            // e-mail address or password is missing from the request
            else if (response.statusCode == 400) {
              _setLoginStatus(LoginStatus.ConfirmPasscodeStep);
              _messageProvider.setMessage(AppString.completeRegistrationMissingData, MessageType.ERROR);
            }
            // member not found in the database
            else if (response.statusCode == 404) {
              _setLoginStatus(LoginStatus.ConfirmPasscodeStep);
              _messageProvider.setMessage(AppString.completeRegistrationNoAccountFound, MessageType.ERROR);
            }
            // unexpected status code
            else {
              _log.severe("Failed to complete registration for user $_email : ${response.body}");
              _setLoginStatus(LoginStatus.CreatePasscodeStep);
              _messageProvider.setMessage(AppString.completeRegistrationUnexpectedResponse, MessageType.ERROR);
            }
          },
          onError: (error) {
            _log.severe("Error while completing registration for user $_email : $error");
            _setLoginStatus(LoginStatus.CreatePasscodeStep);
            if (error is TimeoutException) {
              _messageProvider.setMessage(AppString.errorServerTimeOut, MessageType.ERROR);
            } else {
              _messageProvider.setMessage(AppString.completeRegistrationError, MessageType.ERROR);
            }
          },
        );
  }

  /// Log in the specified [member] identified by email and password.
  Future<void> loginMember(String passcode) async {
    _setAuthStatus(AuthStatus.Authenticating);
    _setLoginStatus(LoginStatus.Loading);

    // get email from shared preferences if present
    String? email;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('email')) {
      email = prefs.get('email') as String?;
    }

    // no email found in shared preferences, get current email from enrollment process
    if (email == null) {
      _log.info("No email found in shared preferences");
      email = _email;
    }

    _log.info("Logging in user $email");

    await _membersService
        .authenticate(email!, passcode)
        .timeout(Duration(seconds: 10))
        .then(
          (response) async {
            // status OK, check response and get the JWT token
            if (response.statusCode == 200) {
              _log.info("User $email successfully authenticated and got a JWT token");

              // get and store JWT token
              final JwtResponse jwt = JwtResponse.fromJson(json.decode(response.body));
              _jwtToken = jwt.jwtToken;

              // set the JWT token to be used for all future GraphQL queries
              GraphQLConnection().jwtToken = _jwtToken;
              _log.info("JWT token set for member $email : $_jwtToken");

              // get the full member from the database
              await _membersService
                  .getMemberByEmail(email!)
                  .timeout(Duration(seconds: 10))
                  .then(
                    (m) async {
                      _log.info("Member ${m.email} successfully retrieved from database with role ${m.role}");

                      // store the user's e-mail and token in the shared preferences
                      final SharedPreferences prefs = await SharedPreferences.getInstance();

                      if (m.email != null) {
                        prefs.setString('email', m.email!);
                      } else {
                        _log.severe("Retrieved member has a null email address!");
                      }

                      if (_jwtToken != null) {
                        prefs.setString('jwt', _jwtToken!);
                      } else {
                        _log.severe("JWT token is null after successful authentication!");
                      }

                      _loggedMember = m;
                      _setAuthStatus(AuthStatus.Authenticated);
                      _setLoginStatus(LoginStatus.EmailStep);
                    },
                    onError: (error) {
                      _log.info("Error while getting member with email $email from database: $error");
                      _loggedMember = null;
                      _jwtToken = null;
                      GraphQLConnection().jwtToken = null;
                      _setAuthStatus(AuthStatus.Unauthenticated);
                      _setLoginStatus(LoginStatus.PasscodeStep);

                      if (error is CustomGraphQlException) {
                        // member not found
                        if (error.code == "member_not_found") {
                          _messageProvider.setMessage(
                            AppString.format(AppString.errorEmailNotFoundInDatabase, [email ?? ""]),
                            MessageType.ERROR,
                          );
                        }
                        // JWT token has expired
                        else if (error.code == "token_expired") {
                          prefs.remove('jwt');
                          _messageProvider.setMessage(AppString.errorTokenExpired, MessageType.SESSION_EXPIRED);
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
                        // unknown error code (should never happen)
                        else {
                          _messageProvider.setMessage(
                            AppString.format(AppString.errorUnknown, [error.code ?? "Unknown error"]),
                            MessageType.ERROR,
                          );
                        }
                      } else if (error is TimeoutException) {
                        _messageProvider.setMessage(AppString.errorServerTimeOut, MessageType.ERROR);
                      } else {
                        _log.info("Error is ${error.toString()}");
                        _messageProvider.setMessage(
                          AppString.format(AppString.errorUnknown, [error.toString()]),
                          MessageType.ERROR,
                        );
                      }
                    },
                  );
            }
            // wrong credentials
            else if (response.statusCode == 401) {
              _log.info("Failed to authenticate member $email, wrong username or password");
              _setAuthStatus(AuthStatus.Unauthenticated);
              _setLoginStatus(LoginStatus.PasscodeStep);
              _messageProvider.setMessage(AppString.errorBadCredentials, MessageType.ERROR);
            }
            // unexpected status code
            else {
              _log.info("Failed to authenticate user $email : ${response.body}");
              _setAuthStatus(AuthStatus.Unauthenticated);
              _setLoginStatus(LoginStatus.PasscodeStep);
              _messageProvider.setMessage(AppString.loginMemberUnexpectedResponse, MessageType.ERROR);
            }
          },
          onError: (error) {
            _log.info("Error while authenticating user with e-mail $email ($error)");
            _loggedMember = null;
            _jwtToken = null;
            GraphQLConnection().jwtToken = null;
            _setAuthStatus(AuthStatus.Unauthenticated);
            _setLoginStatus(LoginStatus.PasscodeStep);
            if (error is TimeoutException) {
              _messageProvider.setMessage(AppString.errorServerTimeOut, MessageType.ERROR);
            } else {
              _messageProvider.setMessage(AppString.loginMemberError, MessageType.ERROR);
            }
          },
        );
  }

  /// Sync the in-memory logged member with the version returned from a
  /// profile edit (called from add_edit_member.submitForm). Only applies
  /// when the edited member matches the logged-in user — i.e. when a
  /// member edits their own profile — so widgets bound to the logged
  /// member (drawer header, etc.) reflect the latest avatar / fields.
  void updateLoggedMember(Member updatedMember) {
    if (_loggedMember?.id != null && _loggedMember!.id == updatedMember.id) {
      _loggedMember = updatedMember;
      _notifyListeners();
    }
  }

  /// Re-fetch the logged member from the backend and rebind it.
  ///
  /// Used as a "refresh everything that hangs off the user" hook
  /// after any mutation that affects the member's associated data —
  /// event registrations, membership fees, bikes, board role, etc.
  /// Widgets bound to [LoginProvider] (notably the home stats panel)
  /// then rebuild with the fresh `loggedMember`, and proxy providers
  /// downstream of `LoginProvider` also re-pull their state via their
  /// `updateLoginProvider` hook.
  ///
  /// Safe to await: silently no-ops when no member is currently
  /// logged in, and swallows fetch failures (we don't want a flaky
  /// refresh to bubble up over a successful mutation).
  Future<void> refreshLoggedMember() async {
    final String? email = _loggedMember?.email;
    if (email == null) return;
    try {
      final Member updated = await _membersService.getMemberByEmail(email);
      _loggedMember = updated;
      _notifyListeners();
    } catch (e, st) {
      _log.warning("Failed to refresh logged member: $e", e, st);
    }
  }

  /// Change the header palette of the currently logged member.
  ///
  /// Used by the "Mon compte" hub which is the canonical place to
  /// customise the user's own header colours. Passing `null` resets
  /// the choice (the client then falls back to the seed-based
  /// default in the picker).
  ///
  /// The mutation's projection is intentionally narrow (id, palette
  /// only), so we follow it up with [refreshLoggedMember] to avoid
  /// wiping the full member object (fees, events, bikes…). On
  /// failure we surface a generic error snackbar via [MessageProvider]
  /// but never throw — the caller is a fire-and-forget tap handler.
  Future<void> updateMyHeaderPalette(int? palette) async {
    final int? id = _loggedMember?.id;
    if (id == null) return;
    try {
      await _membersService.setMemberPalette(id, palette);
      await refreshLoggedMember();
    } catch (error) {
      _log.warning("Failed to update header palette: $error");
      _messageProvider.setMessage(AppString.memberUpdateFailed, MessageType.ERROR);
    }
  }

  /// Log out the current member.
  Future<void> logoutMember() async {
    _log.info("Logging out user ${_loggedMember?.email}");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    _loggedMember = null;
    _jwtToken = null;
    prefs.remove('jwt');
    _setLoginStatus(LoginStatus.EmailStep);
    _setAuthStatus(AuthStatus.Unauthenticated);
  }

  /// Handle a session expiration: clear the JWT and the in-memory state but
  /// keep the e-mail in shared preferences, so the user can re-authenticate
  /// straight from the passcode screen without having to type the e-mail
  /// again.
  Future<void> handleSessionExpired() async {
    _log.info("Session expired for user ${_loggedMember?.email}");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('jwt');
    _loggedMember = null;
    _jwtToken = null;
    GraphQLConnection().jwtToken = null;
    _setLoginStatus(LoginStatus.PasscodeStep);
    _setAuthStatus(AuthStatus.Unauthenticated);
  }

  /// Ask for a new password.
  Future<void> askPassword(String email) async {
    await _membersService
        .askPassword(email)
        .then(
          (value) {
            _log.fine("Forgot password requested for e-mail : $email");
          },
          onError: (error) {
            _log.severe("Failed to request forgot password", error);
            throw (error);
          },
        );
  }

  /// Remove the persisted OTP-countdown timestamp from
  /// SharedPreferences.
  ///
  /// [TimerProvider] persists the start time of an OTP countdown in
  /// the `otp_timer` key so it can resume the remaining time if the
  /// user navigates away and back. The key is, however, never cleaned
  /// up on its own — so a previous (now-defunct) registration attempt
  /// would otherwise make [TimerProvider.resumeOrStartCountDown]
  /// re-load a stale, already-expired timestamp the next time the
  /// user reaches the OTP screen, showing "00:00" instead of a fresh
  /// 10-min countdown.
  ///
  /// Called whenever the server issues a fresh OTP (currently:
  /// [preRegisterMember] success path) so the next mount of the OTP
  /// screen starts from a clean state.
  Future<void> _clearStoredOtpTimer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('otp_timer');
  }

  /// Notify all the registered listeners of this provider.
  void _notifyListeners() {
    _log.info("Notifying listeners of LoginProvider");
    notifyListeners();
  }

  /// Change the current authentication [status].
  void _setAuthStatus(AuthStatus status) {
    final bool becomesAuthenticated = status == AuthStatus.Authenticated && _authStatus != AuthStatus.Authenticated;
    _authStatus = status;
    // dismiss any snackbar that might still be on screen
    if (becomesAuthenticated) {
      scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    }
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
}
