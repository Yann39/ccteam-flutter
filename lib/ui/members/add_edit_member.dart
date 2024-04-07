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

import 'package:ccteam/models/member.dart';
import 'package:ccteam/providers/avatar_provider.dart';
import 'package:ccteam/providers/member_creation_provider.dart';
import 'package:ccteam/providers/member_detail_provider.dart';
import 'package:ccteam/providers/member_list_provider.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/save_cancel_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  const AddEditMember({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddEditMemberState();
  }
}

class _AddEditMemberState extends State<AddEditMember> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  initState() {
    return super.initState();
  }

  /// Validate the form then submit data to backend
  void submitForm(Member member) {
    final FormState form = _formKey.currentState!;

    if (!form.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(AppString.formNotValid)));
    } else {
      // this invokes each onSaved event
      form.save();

      final MemberCreationProvider _memberCreationProvider =
          Provider.of<MemberCreationProvider>(context, listen: false);
      final MemberListProvider _memberListProvider = Provider.of<MemberListProvider>(context, listen: false);
      final MemberDetailProvider _memberDetailProvider = Provider.of<MemberDetailProvider>(context, listen: false);

      // submit data to backend, if id is set this is an update, else a creation
      if (member.id != null) {
        _memberCreationProvider.updateMember().then((value) {
          _memberListProvider.updateMemberInList(_memberCreationProvider.currentMember);
          _memberDetailProvider.setCurrentMember(_memberCreationProvider.currentMember);
        });
      } else {
        _memberCreationProvider.createMember().then((value) {
          _memberListProvider.addMemberInList(_memberCreationProvider.currentMember);
        });
      }
      Navigator.pop(context);
    }
  }

  Widget build(BuildContext context) {
    final _memberCreationProvider = Provider.of<MemberCreationProvider>(context, listen: true);
    final AvatarProvider _drawerProvider = Provider.of<AvatarProvider>(context, listen: false);

    final firstNameField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.person),
        hintText: AppString.memberFirstNameHint,
        labelText: AppString.memberFirstName,
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      validator: (val) => (val == null || val.isEmpty) ? AppString.memberFirstNameMandatory : null,
      onSaved: (val) => _memberCreationProvider.currentMember.firstName = val,
      initialValue: _memberCreationProvider.currentMember.firstName,
    );

    final lastNameField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.person),
        hintText: AppString.memberLastNameHint,
        labelText: AppString.memberLastName,
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      validator: (val) => (val == null || val.isEmpty) ? AppString.memberLastNameMandatory : null,
      onSaved: (val) => _memberCreationProvider.currentMember.lastName = val,
      initialValue: _memberCreationProvider.currentMember.lastName,
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
      validator: (val) => (val == null || val.isEmpty)
          ? AppString.memberEmailMandatory
          : (StringUtils.isValidEmail(val) ? null : AppString.memberEmailNotValid),
      onSaved: (val) => _memberCreationProvider.currentMember.email = val,
      initialValue: _memberCreationProvider.currentMember.email,
    );

    final phoneField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.phone),
        hintText: AppString.memberPhoneHint,
        labelText: AppString.memberPhone,
      ),
      keyboardType: TextInputType.phone,
      maxLines: 1,
      inputFormatters: <TextInputFormatter>[
        LengthLimitingTextInputFormatter(13),
        FilteringTextInputFormatter.digitsOnly,
        NumberTextInputFormatter()
      ],
      validator: (val) => (val == null || val.isEmpty)
          ? AppString.memberPhoneMandatory
          : (StringUtils.isValidPhoneNumber(val) ? null : AppString.memberPhoneNotValid),
      onSaved: (val) => _memberCreationProvider.currentMember.phone = val,
      initialValue: _memberCreationProvider.currentMember.phone,
    );

    final activeField = Row(
      children: [
        Icon(Icons.timelapse, color: Colors.black45),
        SizedBox(width: 16),
        Text("Actif ?"),
        Switch(
          activeColor: Colors.green[700],
          value: _memberCreationProvider.currentMember.active!,
          onChanged: (val) => setState(() {
            _memberCreationProvider.currentMember.active = val;
          }),
        ),
      ],
    );

    final adminField = Row(
      children: [
        Icon(Icons.enhanced_encryption, color: Colors.black45),
        SizedBox(width: 16),
        Text("Admin ?"),
        Switch(
          activeColor: Colors.green[700],
          value: _memberCreationProvider.currentMember.admin!,
          onChanged: (val) => setState(() {
            _memberCreationProvider.currentMember.admin = val;
          }),
        ),
      ],
    );

    final bikeField = TextFormField(
      decoration: const InputDecoration(
          icon: const Icon(CustomIcons.motorbike), hintText: AppString.memberBikeHint, labelText: AppString.memberBike),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      validator: (val) => (val == null || val.isEmpty) ? AppString.memberBikeMandatory : null,
      onSaved: (val) => _memberCreationProvider.currentMember.bike = val,
      initialValue: _memberCreationProvider.currentMember.bike,
    );

    final editableAvatar = Stack(
      children: <Widget>[
        InkWell(
          onTap: () {
            _drawerProvider.loadImage(null);
            Provider.of<AvatarProvider>(context, listen: false).setMemberToEdit(_memberCreationProvider.currentMember);
            Navigator.of(context).pushNamed('/editAvatar');
          },
          child: _memberCreationProvider.currentMember.avatarUrl != null &&
                  _memberCreationProvider.currentMember.avatarUrl!.length > 0
              ? CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      NetworkImage("$SERVER_AVATAR_FOLDER${_memberCreationProvider.currentMember.avatarUrl}"),
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
                      colors: [Colors.red[700]!, Colors.blue[700]!],
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
            child: Icon(Icons.edit, size: 12, color: Colors.white),
            onPressed: () {
              _drawerProvider.loadImage(null);
              Provider.of<AvatarProvider>(context, listen: false)
                  .setMemberToEdit(_memberCreationProvider.currentMember);
              Navigator.of(context).pushNamed('/editAvatar');
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
                  color: Colors.transparent,
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
            autovalidateMode: AutovalidateMode.disabled,
            key: _formKey,
            child: Column(
              children: <Widget>[
                firstNameField,
                lastNameField,
                emailField,
                phoneField,
                bikeField,
                activeField,
                adminField,
              ],
            ),
          ),
        ),
      ],
    );

    final List<Widget> actionMenu = [
      TextButton(
        child: Text(
          AppString.cancel.toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      TextButton(
        child: Text(
          AppString.save.toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => submitForm(_memberCreationProvider.currentMember),
      ),
    ];

    return Scaffold(
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
                    saveFunction: () => submitForm(_memberCreationProvider.currentMember),
                    cancelFunction: () => Navigator.pop(context),
                  ),
                ],
              )
            : listView,
      ),
    );
  }
}
