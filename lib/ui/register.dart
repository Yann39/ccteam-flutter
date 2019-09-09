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

import 'dart:ui';

import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterState();
  }
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Logger _log = new Logger('Register');

  // the member to be created (will hold form data)
  final Member _newMember = new Member();

  /// Validate the form then submit data to backend
  void submitForm(Member member) {
    final FormState _form = _formKey.currentState;

    // validate the form
    if (!_form.validate()) {
      _log.warning("Register form is not valid");
      _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(AppString.formNotValid)));
    } else {
      // this invokes each onSaved event
      _form.save();

      // submit data to backend then display a message
      Provider.of<LoginProvider>(context, listen: false).registerMember(member).then((value) {
        Navigator.pop(context, AppString.memberCreated);
      }, onError: (error) {
        Navigator.pop(context, AppString.memberCreationFailed);
      });
    }
  }

  Widget build(BuildContext context) {
    _log.info("Building Register");

    final _logo = Container(
      padding: EdgeInsets.only(top: 36),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 24.0,
            child: Image.asset(
              'images/helmet-face.png',
            ),
          ),
          SizedBox(height: 6.0),
          Center(
            child: Text(
              AppString.applicationTitle,
              style: TextStyle(color: Colors.white),
              textScaleFactor: 1.3,
            ),
          ),
          SizedBox(height: 6.0),
          Center(
            child: Text(
              AppString.registration,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    final _firstNameField = TextFormField(
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        prefixIcon: Icon(Icons.person, color: Colors.white),
        hintText: AppString.registrationFirstNameHint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      validator: (val) => val.isEmpty ? AppString.memberFirstNameMandatory : null,
      onSaved: (val) => _newMember.firstName = val,
      initialValue: _newMember.firstName,
    );

    final _lastNameField = TextFormField(
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        prefixIcon: Icon(Icons.person, color: Colors.white),
        hintText: AppString.registrationLastNameHint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      validator: (val) => val.isEmpty ? AppString.memberLastNameMandatory : null,
      onSaved: (val) => _newMember.lastName = val,
      initialValue: _newMember.lastName,
    );

    final _emailField = TextFormField(
      keyboardType: TextInputType.emailAddress,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        prefixIcon: Icon(Icons.mail, color: Colors.white),
        hintText: AppString.registrationEmailHint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(128)],
      validator: (val) => val.isEmpty ? AppString.memberEmailMandatory : (StringUtils.isValidEmail(val) ? null : AppString.memberEmailNotValid),
      onSaved: (val) => _newMember.email = val,
      initialValue: _newMember.email,
    );

    final _passwordField = TextFormField(
      autofocus: false,
      style: TextStyle(color: Colors.white),
      obscureText: true,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        prefixIcon: Icon(Icons.lock, color: Colors.white),
        hintText: AppString.registrationPasswordHint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(32)],
      validator: (val) => val.isEmpty ? AppString.memberPasswordMandatory : null,
      onSaved: (val) => _newMember.password = val,
      initialValue: _newMember.password,
    );

    final _passwordBisField = TextFormField(
      autofocus: false,
      style: TextStyle(color: Colors.white),
      obscureText: true,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        prefixIcon: Icon(Icons.lock, color: Colors.white),
        hintText: AppString.registrationPasswordConfirmHint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(32)],
      validator: (val) => val.isEmpty ? AppString.memberPasswordMandatory : null,
      onSaved: (val) => _newMember.password = val,
      initialValue: _newMember.password,
    );

    final _registerButton = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          color: Colors.grey[700],
          child: Text(
            AppString.back,
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(width: 8.0),
        RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: () => submitForm(_newMember),
          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          color: Colors.red[700],
          child: Text(
            AppString.register,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );

    final _haveAccountLabel = FlatButton(
      child: Text(
        AppString.alreadyHaveAccount,
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    return GestureDetector(
      onTap: () {
        // allow to dismiss the keyboard when clicking outside
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/motos.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color.fromRGBO(255, 255, 255, 0.4),
              BlendMode.modulate,
            ),
          ),
        ),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          body: Stack(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Form(
                  key: _formKey,
                  autovalidate: false,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _logo,
                          SizedBox(height: 32.0),
                          _firstNameField,
                          SizedBox(height: 8.0),
                          _lastNameField,
                          SizedBox(height: 8.0),
                          _emailField,
                          SizedBox(height: 8.0),
                          _passwordField,
                          SizedBox(height: 8.0),
                          _passwordBisField,
                          SizedBox(height: 24.0),
                          _registerButton,
                          _haveAccountLabel
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                // Place it at the top, and not use the entire screen
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0, // Shadow gone
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
