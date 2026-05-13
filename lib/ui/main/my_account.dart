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

import 'package:ccteam/models/member.dart';
import 'package:ccteam/models/membership_fee.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/member_creation_provider.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Hub page replacing the old direct-to-edit "Profil" drawer entry.
///
/// Shows a sober header (avatar + name + e-mail), a quick read-out of
/// the membership-fee status for the current year, and a short list
/// of account actions: edit profile, change passcode. Easy to extend
/// with notification preferences, account deletion, etc.
class MyAccount extends StatelessWidget {
  const MyAccount({Key? key}) : super(key: key);

  /// Navigate to the profile edit screen, seeding the
  /// [MemberCreationProvider] with a deep copy of the logged member.
  void _editProfile(BuildContext context, Member member) {
    final Member copy = Member.fromJson(member.toJson());
    Provider.of<MemberCreationProvider>(context, listen: false).setMemberToEdit(copy);
    Navigator.pushNamed(context, '/addEditMember');
  }

  /// Pick the [MembershipFee] for the current calendar year, or null
  /// when nothing was recorded for that year yet.
  MembershipFee? _currentYearFee(Member member) {
    final int currentYear = DateTime.now().year;
    final List<MembershipFee> fees = member.membershipFees ?? const <MembershipFee>[];
    for (final MembershipFee fee in fees) {
      if (fee.year == currentYear) return fee;
    }
    return null;
  }

  /// Header: sober blue rectangle with the user's avatar, name and
  /// e-mail. No gradient pattern, it's a utility page, not a hero.
  Widget _buildHeader(Member member) {
    return Container(
      width: double.infinity,
      color: Colors.red[700],
      padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 88,
            height: 88,
            decoration: const ShapeDecoration(shape: CircleBorder(), color: Colors.white),
            padding: const EdgeInsets.all(3.0),
            child: member.avatar != null
                ? CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.blue[100],
                    backgroundImage: MemoryImage(base64Decode(member.avatar!)),
                  )
                : CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.blue[100],
                    child: ShaderMask(
                      blendMode: BlendMode.srcATop,
                      shaderCallback: (bounds) => LinearGradient(
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(0.0, 1.0),
                        stops: const [0.0, 1.0],
                        colors: [Colors.red[700]!, Colors.blue[700]!],
                      ).createShader(bounds),
                      child: const Icon(CustomIcons.pilot, size: 52, color: Colors.white),
                    ),
                  ),
          ),
          const SizedBox(height: 12.0),
          Text(
            "${member.firstName ?? ''} ${member.lastName ?? ''}".trim(),
            style: const TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2.0),
          Text(member.email ?? '', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13.0)),
        ],
      ),
    );
  }

  /// Card that summarises the current year's membership fee.
  /// Three visual variants: paid (green), unpaid (orange), missing (grey).
  Widget _buildMembershipCard(Member member) {
    final MembershipFee? fee = _currentYearFee(member);
    final int currentYear = DateTime.now().year;

    final IconData icon;
    final Color color;
    final String label;
    final String? amount;
    if (fee == null) {
      icon = Icons.help_outline_rounded;
      color = Colors.blueGrey[500]!;
      label = AppString.format(AppString.membershipNoneYear, [currentYear]);
      amount = null;
    } else if (fee.paid == true) {
      icon = Icons.check_circle_rounded;
      color = Colors.green[700]!;
      label = AppString.format(AppString.membershipPaidYear, [currentYear]);
      amount = fee.amount != null
          ? AppString.format(AppString.membershipAmount, [fee.amount!.toStringAsFixed(0)])
          : null;
    } else {
      icon = Icons.warning_amber_rounded;
      color = Colors.orange[700]!;
      label = AppString.format(AppString.membershipUnpaidYear, [currentYear]);
      amount = fee.amount != null
          ? AppString.format(AppString.membershipAmount, [fee.amount!.toStringAsFixed(0)])
          : null;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.blue[100],
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(25), spreadRadius: 0.5, blurRadius: 0.5, offset: const Offset(2, 2)),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)),
            child: Icon(icon, color: color, size: 24.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  AppString.membershipStatus,
                  style: TextStyle(color: Colors.black.withAlpha(140), fontSize: 11.0, height: 1.2),
                ),
                const SizedBox(height: 2.0),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black.withAlpha(204),
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          if (amount != null) ...[
            const SizedBox(width: 8.0),
            Text(
              amount,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15.0),
            ),
          ],
        ],
      ),
    );
  }

  /// A single tappable row used inside the actions card.
  ///
  /// Visually mirrors `_GroupCardRow` from the home stats panel:
  /// soft circular halo for the icon, dark label, faint chevron at
  /// the right end. The InkWell ripple stays clipped inside the
  /// parent's rounded border so the press feedback feels native.
  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final BorderRadius radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(7.0) : Radius.zero,
      bottom: isLast ? const Radius.circular(7.0) : Radius.zero,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withValues(alpha: 0.15)),
              child: Icon(icon, color: iconColor, size: 20.0),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: Colors.black.withAlpha(204), fontSize: 14.0, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black.withValues(alpha: 0.35), size: 22.0),
          ],
        ),
      ),
    );
  }

  /// Section wrapping the action tiles in a single rounded card.
  ///
  /// Same visual language as the membership-fee card: `Colors.blue[100]`
  /// fill, white border, subtle drop shadow. Rows are separated by a
  /// thin white divider so the grouping reads as "one block".
  Widget _buildActionsSection(BuildContext context, Member member) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.blue[100],
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(25), spreadRadius: 0.5, blurRadius: 0.5, offset: const Offset(2, 2)),
        ],
      ),
      // clip the ripple to the rounded border
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: <Widget>[
            _buildActionTile(
              icon: Icons.person,
              iconColor: Colors.green[700]!,
              label: AppString.editMyProfile,
              onTap: () => _editProfile(context, member),
              isFirst: true,
            ),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.6)),
            _buildActionTile(
              icon: Icons.lock_reset,
              iconColor: Colors.blue[700]!,
              label: AppString.changeMyPasscode,
              onTap: () => Navigator.pushNamed(context, '/changePasscode'),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LoginProvider loginProvider = Provider.of<LoginProvider>(context, listen: true);
    final Member? member = loginProvider.loggedMember;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppString.myAccountTitle),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
      ),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: member == null
            // defensive fallback, should never happen since this screen is only reachable from an authenticated session, but it saves us from a null-pointer crash on session expiration
            ? Center(child: Text(AppString.contentNotLoaded))
            : ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _buildHeader(member),
                  const SizedBox(height: 16.0),
                  _buildMembershipCard(member),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.tune, size: 16, color: Colors.black.withAlpha(150)),
                        const SizedBox(width: 6.0),
                        Text(
                          AppString.accountActions,
                          style: TextStyle(
                            color: Colors.black.withAlpha(150),
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildActionsSection(context, member),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16.0),
                ],
        ),
      ),
    );
  }
}
