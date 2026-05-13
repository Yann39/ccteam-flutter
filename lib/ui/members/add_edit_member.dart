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
import 'dart:io';

import 'package:ccteam/providers/avatar_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/member_creation_provider.dart';
import 'package:ccteam/providers/member_detail_provider.dart';
import 'package:ccteam/providers/member_list_provider.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/form_scaffold.dart';
import 'package:ccteam/widgets/member_header_palette.dart';
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

  /// Snapshot of the board role the member had when the form was opened,
  /// so we can detect a change on save and call the dedicated server-side
  /// mutation only when needed.
  BoardRole? _initialBoardRole;
  BoardRole? _selectedBoardRole;

  /// Mirror state for the header-palette picker — like board role,
  /// the value is buffered locally and only persisted via
  /// `setHeaderPalette` after the main `updateMember` succeeds.
  int? _initialHeaderPalette;
  int? _selectedHeaderPalette;

  @override
  void initState() {
    super.initState();
    final MemberCreationProvider provider = Provider.of<MemberCreationProvider>(context, listen: false);
    _initialBoardRole = provider.currentMember.boardRole;
    _selectedBoardRole = _initialBoardRole;
    _initialHeaderPalette = provider.currentMember.headerPalette;
    _selectedHeaderPalette = _initialHeaderPalette;
  }

  /// Validate the form then submit data to backend
  void submitForm(MemberCreationProvider memberCreationProvider) {
    final FormState form = _formKey.currentState!;

    if (!form.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(AppString.formNotValid)));
    } else {
      // this invokes each onSaved event
      form.save();

      final MemberListProvider _memberListProvider = Provider.of<MemberListProvider>(context, listen: false);
      final MemberDetailProvider _memberDetailProvider = Provider.of<MemberDetailProvider>(context, listen: false);
      final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

      final bool boardRoleChanged = _selectedBoardRole != _initialBoardRole;
      final bool paletteChanged = _selectedHeaderPalette != _initialHeaderPalette;

      // submit data to backend, if id is set this is an update, else a creation
      if (memberCreationProvider.currentMember.id != null) {
        memberCreationProvider.updateMember().then((value) async {
          // board role is persisted via a dedicated mutation, only call it if the value actually changed
          if (boardRoleChanged) {
            await memberCreationProvider.setBoardRole(_selectedBoardRole);
          }
          // header palette uses its own mutation too
          if (paletteChanged) {
            await memberCreationProvider.setHeaderPalette(_selectedHeaderPalette);
          }
          _memberListProvider.updateMemberInList(memberCreationProvider.currentMember);
          _memberDetailProvider.setCurrentMember(memberCreationProvider.currentMember);
          // keep LoginProvider in sync when the user edits their own profile so the drawer header (and anything else bound to loggedMember) reflects the new avatar / fields immediately
          _loginProvider.updateLoggedMember(memberCreationProvider.currentMember);
        });
      } else {
        memberCreationProvider.createMember().then((value) async {
          // when creating a new member, optionally apply the chosen board role right after creation
          if (_selectedBoardRole != null) {
            await memberCreationProvider.setBoardRole(_selectedBoardRole);
          }
          if (_selectedHeaderPalette != null) {
            await memberCreationProvider.setHeaderPalette(_selectedHeaderPalette);
          }
          _memberListProvider.addMemberInList(memberCreationProvider.currentMember);
        });
      }
      Navigator.pop(context);
    }
  }

  /// Opens the avatar edit page. Pre-fills the [AvatarProvider]'s picked
  /// and cropped images with the current avatar so the editor starts
  /// from "the existing photo" rather than empty.
  void _openAvatarEditor(MemberCreationProvider mcp, AvatarProvider ap) {
    if (mcp.currentMember.avatar != null) {
      ap.setPickedImage(File.fromRawPath(base64Decode(mcp.currentMember.avatar!)));
      ap.setCroppedImage(base64Decode(mcp.currentMember.avatar!));
    }
    Navigator.of(context).pushNamed('/editAvatar');
  }

  @override
  Widget build(BuildContext context) {
    final MemberCreationProvider _memberCreationProvider = Provider.of<MemberCreationProvider>(context, listen: true);
    final AvatarProvider _avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    final _editableAvatar = Stack(
      children: <Widget>[
        InkWell(
          onTap: () => _openAvatarEditor(_memberCreationProvider, _avatarProvider),
          child: _memberCreationProvider.currentMember.avatar != null
              ? CircleAvatar(
                  radius: 60,
                  backgroundImage: MemoryImage(base64Decode(_memberCreationProvider.currentMember.avatar!)),
                )
              : CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue[200],
                  child: ShaderMask(
                    blendMode: BlendMode.srcATop,
                    shaderCallback: (bounds) => LinearGradient(
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(0.0, 1.0),
                      stops: const [0.0, 1.0],
                      colors: [Colors.red[700]!, Colors.blue[700]!],
                    ).createShader(bounds),
                    child: const Icon(CustomIcons.pilot, size: 75, color: Colors.white),
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
            child: const Icon(Icons.edit, size: 12, color: Colors.white),
            onPressed: () => _openAvatarEditor(_memberCreationProvider, _avatarProvider),
          ),
        ),
      ],
    );

    final _avatarHeader = Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red[700],
                boxShadow: const [BoxShadow(color: Colors.black26, spreadRadius: 0.5, blurRadius: 2)],
              ),
            ),
            Container(height: 60, color: Colors.transparent),
          ],
        ),
        Container(
          height: 120,
          width: 120,
          decoration: ShapeDecoration(shape: const CircleBorder(), color: Colors.blue[100]),
          child: Padding(padding: const EdgeInsets.all(6.0), child: _editableAvatar),
        ),
      ],
    );

    final _firstNameField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.person),
        hintText: AppString.memberFirstNameHint,
        labelText: AppString.memberFirstName,
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      validator: (val) => (val == null || val.isEmpty) ? AppString.memberFirstNameMandatory : null,
      onSaved: (val) => _memberCreationProvider.currentMember.firstName = val,
      initialValue: _memberCreationProvider.currentMember.firstName,
    );

    final _lastNameField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.person),
        hintText: AppString.memberLastNameHint,
        labelText: AppString.memberLastName,
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      validator: (val) => (val == null || val.isEmpty) ? AppString.memberLastNameMandatory : null,
      onSaved: (val) => _memberCreationProvider.currentMember.lastName = val,
      initialValue: _memberCreationProvider.currentMember.lastName,
    );

    final _emailField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.mail),
        hintText: AppString.memberEmailHint,
        labelText: AppString.memberEmail,
      ),
      keyboardType: TextInputType.emailAddress,
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(128)],
      validator: (val) {
        if (val == null || val.isEmpty) return AppString.memberEmailMandatory;
        if (!StringUtils.isValidEmail(val)) return AppString.memberEmailNotValid;
        return null;
      },
      onSaved: (val) => _memberCreationProvider.currentMember.email = val,
      initialValue: _memberCreationProvider.currentMember.email,
    );

    final _phoneField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.phone),
        hintText: AppString.memberPhoneHint,
        labelText: AppString.memberPhone,
      ),
      keyboardType: TextInputType.phone,
      maxLines: 1,
      inputFormatters: <TextInputFormatter>[
        LengthLimitingTextInputFormatter(13),
        FilteringTextInputFormatter.digitsOnly,
        NumberTextInputFormatter(),
      ],
      validator: (val) {
        if (val == null || val.isEmpty) return AppString.memberPhoneMandatory;
        if (!StringUtils.isValidPhoneNumber(val)) {
          return AppString.memberPhoneNotValid;
        }
        return null;
      },
      onSaved: (val) => _memberCreationProvider.currentMember.phone = val,
      initialValue: _memberCreationProvider.currentMember.phone,
    );

    final _riderNumberField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.tag),
        hintText: AppString.memberRiderNumberHint,
        labelText: AppString.memberRiderNumber,
      ),
      keyboardType: TextInputType.number,
      maxLines: 1,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      onSaved: (val) =>
          _memberCreationProvider.currentMember.riderNumber = (val != null && val.isNotEmpty) ? int.parse(val) : null,
      initialValue: _memberCreationProvider.currentMember.riderNumber?.toString(),
    );

    // Header palette picker
    final int _paletteSeed = _memberCreationProvider.currentMember.id ??
        _memberCreationProvider.currentMember.email?.hashCode ??
        0;
    final List<Color> _palettePreview = _selectedHeaderPalette != null
        ? kMemberHeaderPalettes[
            _selectedHeaderPalette!.clamp(0, kMemberHeaderPalettes.length - 1)]
        : kMemberHeaderPalettes[_paletteSeed.abs() % kMemberHeaderPalettes.length];
    final _paletteField = InkWell(
      onTap: () {
        showMemberHeaderPalettePicker(
          context: context,
          currentIndex: _selectedHeaderPalette,
          seed: _paletteSeed,
          onSelected: (int? picked) {
            setState(() => _selectedHeaderPalette = picked);
          },
        );
      },
      borderRadius: BorderRadius.circular(4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: <Widget>[
            const Icon(Icons.palette_outlined, color: Colors.black54),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppString.memberHeaderPaletteLabel,
                    style: TextStyle(color: Colors.black.withValues(alpha: 0.6), fontSize: 12),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    _selectedHeaderPalette == null
                        ? AppString.headerPaletteDefault
                        : 'Palette ${_selectedHeaderPalette! + 1}',
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ],
              ),
            ),
            MemberHeaderPaletteChip(palette: _palettePreview),
            const SizedBox(width: 8.0),
            Icon(Icons.chevron_right, color: Colors.black.withValues(alpha: 0.45)),
          ],
        ),
      ),
    );

    final _roleField = DropdownButtonFormField<MemberRole>(
      decoration: const InputDecoration(icon: Icon(Icons.enhanced_encryption), labelText: AppString.memberRole),
      initialValue: _memberCreationProvider.currentMember.role,
      items: MemberRole.values.map((MemberRole role) {
        String label = "";
        switch (role) {
          case MemberRole.ROLE_USER:
            label = AppString.memberRoleUser;
            break;
          case MemberRole.ROLE_MEMBER:
            label = AppString.memberRoleMember;
            break;
          case MemberRole.ROLE_ADMIN:
            label = AppString.memberRoleAdmin;
            break;
        }
        return DropdownMenuItem<MemberRole>(
          value: role,
          child: Text(
            label,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.normal),
          ),
        );
      }).toList(),
      onChanged: (MemberRole? newValue) => setState(() => _memberCreationProvider.currentMember.role = newValue),
    );

    final String _languageCode = Localizations.localeOf(context).languageCode;
    final _boardRoleField = DropdownButtonFormField<BoardRole?>(
      decoration: const InputDecoration(icon: Icon(Icons.workspace_premium), labelText: "Rôle au bureau"),
      initialValue: _selectedBoardRole,
      items: <DropdownMenuItem<BoardRole?>>[
        const DropdownMenuItem<BoardRole?>(
          value: null,
          child: Text(
            "— Aucun —",
            style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
          ),
        ),
        ...BoardRole.values.map(
          (BoardRole role) => DropdownMenuItem<BoardRole?>(
            value: role,
            child: Text(role.localizedLabel(_languageCode), style: const TextStyle(color: Colors.black87)),
          ),
        ),
      ],
      onChanged: (BoardRole? newValue) => setState(() => _selectedBoardRole = newValue),
    );

    final bool isAdmin = _loginProvider.loggedMember?.role == MemberRole.ROLE_ADMIN;

    return FormScaffold(
      title: AppString.profileEdit,
      formKey: _formKey,
      onSave: () => submitForm(_memberCreationProvider),
      header: _avatarHeader,
      fields: <Widget>[
        _firstNameField,
        _lastNameField,
        _emailField,
        _phoneField,
        _riderNumberField,
        _paletteField,
        if (isAdmin) _roleField,
        if (isAdmin) _boardRoleField,
      ],
    );
  }
}
