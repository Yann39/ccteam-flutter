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

import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/providers/avatar_provider.dart';
import 'package:chachatte_team/providers/member_provider.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/custom_decorations.dart';
import 'package:chachatte_team/utils/custom_icons.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:chachatte_team/widgets/save_cancel_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Input formatter class for E.164 phone number
class NumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final int _newTextLength = newValue.text.length;
    int _selectionIndex = newValue.selection.end;
    int _usedSubstringIndex = 0;
    final StringBuffer _newText = new StringBuffer();
    // add a "+" in front of the text
    if (_newTextLength >= 1) {
      _newText.write('+');
      if (newValue.selection.end >= 1) _selectionIndex++;
    }
    // add a space after the 3rd character
    if (_newTextLength >= 3) {
      _newText.write(newValue.text.substring(0, _usedSubstringIndex = 2) + ' ');
      if (newValue.selection.end >= 2) _selectionIndex += 1;
    }
    // then write following characters
    if (_newTextLength >= _usedSubstringIndex) _newText.write(newValue.text.substring(_usedSubstringIndex));
    return TextEditingValue(
      text: _newText.toString(),
      selection: TextSelection.collapsed(offset: _selectionIndex),
    );
  }
}

class AddEditMember extends StatefulWidget {
  final Member member;

  const AddEditMember({Key key, this.member}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddEditMemberState();
  }
}

class _AddEditMemberState extends State<AddEditMember> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _datePickerController = new TextEditingController();

  // the member to be created with default password 1234
  final Member _newMember = new Member(active: false, admin: false, password: '\$2y\$10\$MuLwPiQkTlcKEbGX6ztzAOxGlqK7ddglgDXcYBRBFDwkM.AQy63EK');

  initState() {
    // set date picker text if set
    if (widget.member != null) {
      _datePickerController.text = DateUtils.convertToString(widget.member.registrationDate, DATE_FORMAT);
    }
    return super.initState();
  }

  /// Initialize and display a Date picker related to the specified [controller] in the specified [context]
  Future _chooseDate(BuildContext context, TextEditingController controller, DateTime defaultValue) async {
    final DateTime currentDate = DateTime.now();
    final TimeOfDay currentTime = TimeOfDay.now();

    // define initial date and time from the specified default DateTime value if set
    final DateTime initialDate = defaultValue ?? currentDate;
    final TimeOfDay initialTime = defaultValue != null ? TimeOfDay.fromDateTime(defaultValue) : currentTime;

    // show the date picker and await for the chosen date
    final DateTime dateResult =
        await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(currentDate.year - 5), lastDate: DateTime(currentDate.year + 5));
    if (dateResult == null) return;

    // show the time picker and await for the chosen time
    final TimeOfDay timeResult = await showTimePicker(context: context, initialTime: initialTime);
    if (timeResult == null) return;

    // build final date with time
    final DateTime finalDateTime = DateTime(dateResult.year, dateResult.month, dateResult.day, timeResult.hour, timeResult.minute);

    // notify the framework that the internal state of this object has changed
    setState(() {
      controller.text = DateFormat(DATE_FORMAT).format(finalDateTime);
    });
  }

  /// Validate the form then submit data to backend
  void submitForm(Member member) {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(AppString.formNotValid)));
    } else {
      // this invokes each onSaved event
      form.save();

      // submit data to backend, if id is set this is an update, else a creation
      if (member.id != null) {
        // update the news go back with a message, the result is awaited in caller
        Provider.of<MemberProvider>(context, listen: false).updateMember(member).then((value) {
          Navigator.pop(context, AppString.memberUpdated);
        }, onError: (error) {
          Navigator.pop(context, AppString.memberUpdateFailed);
        });
      } else {
        // create the news go back with a message, the result is awaited in caller
        Provider.of<MemberProvider>(context, listen: false).createMember(member).then((value) {
          Navigator.pop(context, AppString.memberCreated);
        }, onError: (error) {
          Navigator.pop(context, AppString.memberCreationFailed);
        });
      }
    }
  }

  Widget build(BuildContext context) {
    // the current Member to be edited
    final Member _currMember = widget.member != null ? widget.member : _newMember;
    final AvatarProvider _drawerProvider = Provider.of<AvatarProvider>(context, listen: false);

    final firstNameField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.person),
        hintText: AppString.memberFirstNameHint,
        labelText: AppString.memberFirstName,
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      validator: (val) => val.isEmpty ? AppString.memberFirstNameMandatory : null,
      onSaved: (val) => _currMember.firstName = val,
      initialValue: _currMember.firstName,
    );

    final lastNameField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.person),
        hintText: AppString.memberLastNameHint,
        labelText: AppString.memberLastName,
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      validator: (val) => val.isEmpty ? AppString.memberLastNameMandatory : null,
      onSaved: (val) => _currMember.lastName = val,
      initialValue: _currMember.lastName,
    );

    final emailField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.mail),
        hintText: AppString.memberEmailHint,
        labelText: AppString.memberEmail,
      ),
      keyboardType: TextInputType.emailAddress,
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(128)],
      validator: (val) => val.isEmpty ? AppString.memberEmailMandatory : (StringUtils.isValidEmail(val) ? null : AppString.memberEmailNotValid),
      onSaved: (val) => _currMember.email = val,
      initialValue: _currMember.email,
    );

    final phoneField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.phone),
        hintText: AppString.memberPhoneHint,
        labelText: AppString.memberPhone,
      ),
      keyboardType: TextInputType.phone,
      maxLines: 1,
      inputFormatters: <TextInputFormatter>[LengthLimitingTextInputFormatter(13), WhitelistingTextInputFormatter.digitsOnly, NumberTextInputFormatter()],
      validator: (val) => val.isEmpty ? AppString.memberPhoneMandatory : (StringUtils.isValidPhoneNumber(val) ? null : AppString.memberPhoneNotValid),
      onSaved: (val) => _currMember.phone = val,
      initialValue: _currMember.phone,
    );

    final registrationDateField = GestureDetector(
      onTap: () => _chooseDate(context, _datePickerController, _currMember.registrationDate),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            icon: const Icon(Icons.calendar_today),
            hintText: AppString.memberRegistrationDateHint,
            labelText: AppString.memberRegistrationDate,
          ),
          controller: _datePickerController,
          keyboardType: TextInputType.datetime,
          validator: (val) => DateUtils.isBeforeNow(val, DATE_FORMAT) ? (val.isEmpty ? AppString.memberRegistrationDateMandatory : null) : AppString.memberRegistrationDateNotValid,
          onSaved: (val) => _currMember.registrationDate = DateFormat(DATE_FORMAT).parseStrict(val),
        ),
      ),
    );

    final activeField = new DropdownButtonFormField<bool>(
      value: _currMember.active,
      decoration: const InputDecoration(
        icon: const Icon(Icons.enhanced_encryption),
        hintText: AppString.memberActive,
        labelText: AppString.memberActive,
      ),
      items: <bool>[true, false].map((bool val) {
        return DropdownMenuItem<bool>(value: val, child: Text(val.toString()));
      }).toList(),
      onChanged: (bool val) {
        setState(() {
          _currMember.active = val;
        });
      },
      onSaved: (val) => _currMember.active = val,
      validator: (val) => val == null ? AppString.memberActiveMandatory : null,
    );

    /*final activeField = CheckboxListTile(
      title: Text(AppString.memberActive),
      value: _currMember.active,
      selected: _currMember.active,
      onChanged: (val) => setState(() {
        _currMember.active = val;
      }),
      controlAffinity: ListTileControlAffinity.leading,
    );*/

    final bikeField = TextFormField(
      decoration: const InputDecoration(icon: const Icon(CustomIcons.motorbike), hintText: AppString.memberBikeHint, labelText: AppString.memberBike),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      validator: (val) => val.isEmpty ? AppString.memberBikeMandatory : null,
      onSaved: (val) => _currMember.bike = val,
      initialValue: _currMember.bike,
    );

    final editableAvatar = Stack(
      children: <Widget>[
        InkWell(
          onTap: () {
            _drawerProvider.loadImage(null);
            Navigator.of(context).pushNamed('/editAvatar', arguments: _currMember);
          },
          child: _currMember.avatar != null && _currMember.avatar.length > 0
              ? CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage("$SERVER_ROOT_PATH$SERVER_AVATAR_FOLDER${_currMember.avatar}"),
                )
              : CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue[200],
                  child: ShaderMask(
                    blendMode: BlendMode.srcATop,
                    shaderCallback: (bounds) => LinearGradient(
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(0.0, 1.0),
                      stops: [0.0, 1.0],
                      colors: [Colors.red[700], Colors.blue[700]],
                    ).createShader(bounds),
                    child: Icon(CustomIcons.pilot, size: 75, color: Colors.white),
                  ),
                ),
        ),
        Positioned(
          height: 30,
          width: 30,
          top: 75,
          left: 75,
          child: FloatingActionButton(
            backgroundColor: Colors.red[700],
            child: Icon(Icons.edit, size: 12),
            onPressed: () {
              _drawerProvider.loadImage(null);
              Navigator.of(context).pushNamed('/editAvatar', arguments: _currMember);
            },
          ),
        ),
      ],
    );

    final listView = ListView(
      children: <Widget>[
        Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 60,
                  decoration: BoxDecoration(color: Colors.red[700], boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      spreadRadius: 0.5,
                      blurRadius: 2,
                    )
                  ]),
                ),
                Container(
                  height: 60,
                  color: Colors.blue[100],
                ),
              ],
            ),
            Container(
              height: 120,
              width: 120,
              decoration: ShapeDecoration(shape: CircleBorder(), color: Colors.blue[100]),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: editableAvatar,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.only(top: 0, left: 16.0, right: 16.0, bottom: 56.0),
          child: Form(
            key: _formKey,
            autovalidate: false,
            child: Column(
              children: <Widget>[
                firstNameField,
                lastNameField,
                emailField,
                phoneField,
                bikeField,
                registrationDateField,
                activeField,
              ],
            ),
          ),
        ),
      ],
    );

    final List<Widget> actionMenu = [
      FlatButton(
        child: Text(
          AppString.cancel.toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      FlatButton(
        child: Text(
          AppString.save.toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => submitForm(_currMember),
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        title: Text(AppString.profileEdit),
        actions: MediaQuery.of(context).orientation == Orientation.portrait ? null : actionMenu,
      ),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: MediaQuery.of(context).orientation == Orientation.portrait
            ? Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  listView,
                  SaveCancelBar(
                    saveFunction: () => submitForm(_currMember),
                    cancelFunction: () => Navigator.pop(context),
                  ),
                ],
              )
            : listView,
      ),
    );
  }
}
