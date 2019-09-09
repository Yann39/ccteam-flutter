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
import 'package:chachatte_team/providers/member_provider.dart';
import 'package:chachatte_team/services/members_service.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddEditMember extends StatefulWidget {
  final Member member;

  const AddEditMember({Key key, this.member}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddEditMemberState();
  }
}

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

class _AddEditMemberState extends State<AddEditMember> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _datePickerController = new TextEditingController();

  // the member to be created with default password 1234
  final Member _newMember = new Member(active: false, admin: false, password: '\$2y\$10\$MuLwPiQkTlcKEbGX6ztzAOxGlqK7ddglgDXcYBRBFDwkM.AQy63EK');

  initState() {
    // set date picker text if set
    if (widget.member != null) {
      _datePickerController.text = DateUtils.convertToString(widget.member.registrationDate, AppConstants.DATE_FORMAT);
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
      controller.text = DateFormat(AppConstants.DATE_FORMAT).format(finalDateTime);
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

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppString.memberCreate),
        bottom: PreferredSize(
          child: Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    child: Text(
                      AppString.cancel.toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    child: Text(
                      AppString.save.toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => submitForm(_currMember),
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(color: Colors.red[700]),
            height: 50.0,
          ),
          preferredSize: Size.fromHeight(50.0),
        ),
      ),
      body: Container(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Form(
            key: _formKey,
            autovalidate: false,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                TextFormField(
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
                ),
                TextFormField(
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
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.mail),
                    hintText: AppString.memberEmailHint,
                    labelText: AppString.memberEmail,
                  ),
                  maxLines: 1,
                  inputFormatters: [LengthLimitingTextInputFormatter(128)],
                  validator: (val) => val.isEmpty ? AppString.memberEmailMandatory : (StringUtils.isValidEmail(val) ? null : AppString.memberEmailNotValid),
                  onSaved: (val) => _currMember.email = val,
                  initialValue: _currMember.email,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.phone),
                    hintText: AppString.memberPhoneHint,
                    labelText: AppString.memberPhone,
                  ),
                  maxLines: 1,
                  inputFormatters: <TextInputFormatter>[LengthLimitingTextInputFormatter(13), WhitelistingTextInputFormatter.digitsOnly, NumberTextInputFormatter()],
                  validator: (val) => val.isEmpty ? AppString.memberPhoneMandatory : (StringUtils.isValidPhoneNumber(val) ? null : AppString.memberPhoneNotValid),
                  onSaved: (val) => _currMember.phone = val,
                  initialValue: _currMember.phone,
                ),
                TextFormField(
                  decoration: const InputDecoration(icon: const Icon(Icons.motorcycle), hintText: AppString.memberBikeHint, labelText: AppString.memberBike),
                  maxLines: 1,
                  inputFormatters: [LengthLimitingTextInputFormatter(64)],
                  validator: (val) => val.isEmpty ? AppString.memberBikeMandatory : null,
                  onSaved: (val) => _currMember.bike = val,
                  initialValue: _currMember.bike,
                ),
                GestureDetector(
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
                      validator: (val) => DateUtils.isBeforeNow(val, AppConstants.DATE_FORMAT)
                          ? (val.isEmpty ? AppString.memberRegistrationDateMandatory : null)
                          : AppString.memberRegistrationDateNotValid,
                      onSaved: (val) => _currMember.registrationDate = DateFormat(AppConstants.DATE_FORMAT).parseStrict(val),
                    ),
                  ),
                ),
                Column(
                    children: <Widget>[
                      new DropdownButtonFormField<bool>(
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
                      )
                    ],
                  ) /*CheckboxListTile(
                    title: Text(AppString.memberActive),
                    value: _currMember.active,
                    selected: _currMember.active,
                    onChanged: (val) => setState(() {
                          _currMember.active = val;
                        }),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),*/
              ],
            ),
          ),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[100], Colors.blue[300]],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
    );
  }
}
