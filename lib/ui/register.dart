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
import 'package:chachatte_team/services/members_service.dart';
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterState();
  }
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // the member to be created
  final Member _newMember = new Member();

  _dismissKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  /// Validate the form then submit data to backend
  void submitForm(Member member) {
    final FormState form = _formKey.currentState;
    final Logger log = new Logger('register');

    if (!form.validate()) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(backgroundColor: Colors.red, content: new Text(AppString.formNotValid)));
    } else {
      // this invokes each onSaved event
      form.save();

      final MembersService membersService = new MembersService();

      // submit data to backend then display a message
      membersService.createMember(member).then(
        (value) {
          log.fine("New user registered : ${member.email}");
          Navigator.pop(context, AppString.memberCreated);
        },
        onError: (error) {
          log.fine("Failed to register new user", error);
          Navigator.pop(context, AppString.memberCreationFailed);
        },
      );
    }
  }

  Widget build(BuildContext context) {
    final logo = Container(
      child: Column(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 24.0,
            child: Image.asset(
              'images/helmet-face.png',
              //color: Colors.red[700],
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

    final firstName = TextFormField(
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        icon: Icon(Icons.person, color: Colors.white),
        hintText: AppString.registrationFirstNameHint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [new LengthLimitingTextInputFormatter(64)],
      validator: (val) => val.isEmpty ? AppString.memberFirstNameMandatory : null,
      onSaved: (val) => _newMember.firstName = val,
      initialValue: _newMember.firstName,
    );

    final lastName = TextFormField(
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        icon: Icon(Icons.person, color: Colors.white),
        hintText: AppString.registrationLastNameHint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [new LengthLimitingTextInputFormatter(64)],
      validator: (val) => val.isEmpty ? AppString.memberLastNameMandatory : null,
      onSaved: (val) => _newMember.lastName = val,
      initialValue: _newMember.lastName,
    );

    final email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      keyboardAppearance: Brightness.dark,
      autofocus: false,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        icon: Icon(Icons.mail, color: Colors.white),
        hintText: AppString.registrationEmailHint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [new LengthLimitingTextInputFormatter(128)],
      validator: (val) => val.isEmpty ? AppString.memberEmailMandatory : (StringUtils.isValidEmail(val) ? null : AppString.memberEmailNotValid),
      onSaved: (val) => _newMember.email = val,
      initialValue: _newMember.email,
    );

    final password = TextFormField(
      autofocus: false,
      style: TextStyle(color: Colors.white),
      obscureText: true,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        icon: Icon(Icons.lock, color: Colors.white),
        hintText: AppString.registrationPasswordHint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [new LengthLimitingTextInputFormatter(32)],
      validator: (val) => val.isEmpty ? AppString.memberPasswordMandatory : null,
      onSaved: (val) => _newMember.password = val,
      initialValue: _newMember.password,
    );

    final passwordBis = TextFormField(
      autofocus: false,
      style: TextStyle(color: Colors.white),
      obscureText: true,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        icon: Icon(Icons.lock, color: Colors.white),
        hintText: AppString.registrationPasswordConfirmHint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      ),
      maxLines: 1,
      inputFormatters: [new LengthLimitingTextInputFormatter(32)],
      validator: (val) => val.isEmpty ? AppString.memberPasswordMandatory : null,
      onSaved: (val) => _newMember.password = val,
      initialValue: _newMember.password,
    );

    final registerButton = Row(
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
            AppString.cancel,
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

    return new GestureDetector(
      onTap: () {
        this._dismissKeyboard(context);
      },
      child: Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("images/motos.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color.fromRGBO(255, 255, 255, 0.4),
              BlendMode.modulate,
            ),
          ),
        ),
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: Colors.transparent,
          body: Container(
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
                      logo,
                      SizedBox(height: 32.0),
                      firstName,
                      SizedBox(height: 8.0),
                      lastName,
                      SizedBox(height: 8.0),
                      email,
                      SizedBox(height: 8.0),
                      password,
                      SizedBox(height: 8.0),
                      passwordBis,
                      SizedBox(height: 24.0),
                      registerButton,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
