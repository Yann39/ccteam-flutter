/*
 * Copyright (c) 2024 by Yann39.
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
import 'package:ccteam/models/membership_fee.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/member_detail_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/members_service.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/form_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEditMembershipFee extends StatefulWidget {
  @override
  _AddEditMembershipFeeState createState() => _AddEditMembershipFeeState();
}

class _AddEditMembershipFeeState extends State<AddEditMembershipFee> {
  final _formKey = GlobalKey<FormState>();
  final MembersService _membersService = MembersService();

  LoadingStatus _loadingStatus = LoadingStatus.loaded;
  Member? _member;
  MembershipFee? _fee;

  int? _year;
  double? _amount;
  bool _paid = false;

  bool get _isEditing => _fee != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _member = args['member'] as Member?;
      _fee = args['fee'] as MembershipFee?;

      if (_fee != null && _year == null) {
        _year = _fee!.year;
        _amount = _fee!.amount;
        _paid = _fee!.paid ?? false;
      } else if (_year == null) {
        _year = DateTime.now().year;
        _amount = 0.0;
        _paid = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _yearField = TextFormField(
      initialValue: _year?.toString() ?? '',
      decoration: const InputDecoration(icon: Icon(Icons.calendar_today), labelText: AppString.membershipFeeYear),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppString.membershipFeeYearMandatory;
        }
        if (int.tryParse(value) == null) {
          return AppString.membershipFeeYearNotValid;
        }
        return null;
      },
      onSaved: (value) => _year = int.parse(value!),
    );

    final _amountField = TextFormField(
      initialValue: _amount?.toString() ?? '',
      decoration: const InputDecoration(icon: Icon(Icons.euro), labelText: AppString.membershipFeeAmount),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppString.membershipFeeAmountMandatory;
        }
        if (double.tryParse(value.replaceAll(',', '.')) == null) {
          return AppString.membershipFeeAmountNotValid;
        }
        return null;
      },
      onSaved: (value) => _amount = double.parse(value!.replaceAll(',', '.')),
    );

    final _paidField = SwitchListTile(
      title: const Text(AppString.membershipFeePaid),
      value: _paid,
      onChanged: (bool value) => setState(() => _paid = value),
      secondary: const Icon(Icons.payment),
      contentPadding: EdgeInsets.zero,
    );

    return FormScaffold(
      title: _isEditing ? AppString.membershipFeeEdit : AppString.membershipFeeCreate,
      formKey: _formKey,
      loadingStatus: _loadingStatus,
      onSave: _saveFee,
      onDelete: _isEditing ? _deleteFee : null,
      fields: <Widget>[_yearField, _amountField, _paidField],
    );
  }

  void _saveFee() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loadingStatus = LoadingStatus.loading);

    try {
      if (_fee == null) {
        await _membersService.addMembershipFee(_member!.id!, _year!, _amount!, _paid);
      } else {
        await _membersService.updateMembershipFee(_fee!.id!, _year!, _amount!, _paid);
      }
      await Provider.of<MemberDetailProvider>(context, listen: false).refreshCurrentMember();
      // also refresh the logged member if the fee belongs to them,
      // so the home stats "Cotisation" pill updates without a manual reload
      await _syncLoggedMemberIfSelf();
      Navigator.of(context).pop(AppString.membershipFeeSaved);
    } catch (e) {
      Provider.of<MessageProvider>(
        context,
        listen: false,
      ).setMessage("${AppString.membershipFeeSaveFailed}: $e", MessageType.ERROR);
      setState(() => _loadingStatus = LoadingStatus.loaded);
    }
  }

  /// If the membership fee being edited belongs to the logged-in user,
  /// re-fetch their member record so providers depending on
  /// `loggedMember.membershipFees` (home stats…) refresh.
  Future<void> _syncLoggedMemberIfSelf() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    if (_member?.id != null && _member!.id == loginProvider.loggedMember?.id) {
      await loginProvider.refreshLoggedMember();
    }
  }

  void _deleteFee() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text(AppString.confirmation),
          content: const Text(AppString.membershipFeeDeletionAreYouSure),
          actions: <Widget>[
            TextButton(child: const Text(AppString.cancel), onPressed: () => Navigator.of(ctx).pop()),
            TextButton(
              child: const Text(AppString.confirm),
              onPressed: () async {
                Navigator.of(ctx).pop();
                setState(() => _loadingStatus = LoadingStatus.loading);
                try {
                  await _membersService.deleteMembershipFee(_fee!.id!);
                  await Provider.of<MemberDetailProvider>(context, listen: false).refreshCurrentMember();
                  await _syncLoggedMemberIfSelf();
                  Navigator.of(context).pop(AppString.membershipFeeDeleted);
                } catch (e) {
                  Provider.of<MessageProvider>(
                    context,
                    listen: false,
                  ).setMessage("${AppString.membershipFeeDeleteFailed}: $e", MessageType.ERROR);
                  setState(() => _loadingStatus = LoadingStatus.loaded);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
