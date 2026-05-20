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

import 'package:ccteam/models/bike.dart';
import 'package:ccteam/models/member.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/member_creation_provider.dart';
import 'package:ccteam/providers/member_detail_provider.dart';
import 'package:ccteam/providers/member_list_provider.dart';
import 'package:ccteam/providers/record_list_provider.dart';
import 'package:ccteam/ui/main/main_action_menu.dart';
import 'package:ccteam/ui/main/main_drawer.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/avatar_image.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:ccteam/widgets/restricted_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// We need stateful widget to keep search field value
class MemberList extends StatelessWidget {
  /// Navigate to the member creation form screen to create a new member.
  _navigateToAddMemberScreen(BuildContext context) async {
    // set a new member to be created
    Provider.of<MemberCreationProvider>(context, listen: false).setMemberToEdit(new Member());

    // navigate to the member creation form screen
    Navigator.pushNamed(context, '/addEditMember');
  }

  /// Navigate to the detail screen of the specified [member].
  void _navigateToMemberDetailScreen(BuildContext context, Member member) async {
    if (member.id != null) {
      Provider.of<RecordListProvider>(context, listen: false).fetchMemberRecords(member.id!);
    }

    // fetch the member to get complete data
    Provider.of<MemberDetailProvider>(context, listen: false)
        .fetchMember(member)
        .then(
          (value) => {
            // navigate to member detail screen
            Navigator.pushNamed(context, '/memberDetail'),
          },
        );
  }

  /// Build the search field (matches the search bar of the tracks page).
  Widget _buildSearchField(MemberListProvider _memberListProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
          hintText: AppString.membersSearchHint,
          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.blue[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.blue[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 1.5),
          ),
        ),
        maxLines: 1,
        onChanged: (String text) {
          _memberListProvider.fetchMemberList(text);
        },
      ),
    );
  }

  /// Build the avatar of a [member] — either the image fetched from
  /// the REST endpoint (with disk cache via cached_network_image) or
  /// a blue fallback circle with the first-name initial.
  Widget _buildAvatar(Member member) {
    if (member.hasAvatar == true && member.id != null) {
      return AvatarImage(memberId: member.id, hasAvatar: true, radius: 28.0);
    }
    final String initial = (member.firstName != null && member.firstName!.isNotEmpty)
        ? member.firstName![0].toUpperCase()
        : "?";
    return CircleAvatar(
      radius: 28.0,
      backgroundColor: Colors.blue[700],
      child: Text(
        initial,
        style: const TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Small race-plate-style badge for the rider number: white rounded
  /// rectangle with a thin colored border and bold italic digits — reads
  /// instantly as a number plate without overpowering the row.
  Widget _buildRiderNumberBadge(int number) {
    final Color plateColor = Colors.blue[700]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(3.0),
        border: Border.all(color: plateColor, width: 1.5),
      ),
      child: Text(
        "#$number",
        style: TextStyle(
          color: plateColor,
          fontSize: 13.0,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.3,
          height: 1.0,
        ),
      ),
    );
  }

  /// Format the current bike of a [member] for display in the subtitle.
  /// Picks the bike the member has explicitly marked as "current"; falls
  /// back to the first bike in the list if none is flagged.
  String _currentBikeText(Member member) {
    if (member.bikes == null || member.bikes!.isEmpty) {
      return AppString.notDefined;
    }
    final Bike bike = member.bikes!.firstWhere((b) => b.current ?? false, orElse: () => member.bikes!.first);
    return "${bike.manufacturer?.toUpperCase() ?? ""} ${bike.modelName ?? ""}".trim();
  }

  /// Pick a semantically meaningful background color for a board role.
  Color _boardRoleColor(BoardRole role) {
    switch (role) {
      case BoardRole.PRESIDENT:
        return Colors.pinkAccent[700]!;
      case BoardRole.VICE_PRESIDENT:
        return Colors.purple[400]!;
      case BoardRole.SECRETARY:
        return Colors.teal[600]!;
      case BoardRole.TREASURER:
        return Colors.deepPurple[500]!;
    }
  }

  /// Small chip showing the member's executive board role (Président,
  /// Trésorier, …). Only displayed when the member holds a board role.
  Widget _buildBoardRoleBadge(BoardRole role, BuildContext context) {
    final String label = role.localizedLabel(Localizations.localeOf(context).languageCode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(color: _boardRoleColor(role), borderRadius: BorderRadius.circular(4.0)),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
          height: 1.2,
        ),
      ),
    );
  }

  /// Build a single member tile (list item).
  Widget _buildMemberTile(BuildContext context, Member member) {
    final bool hasBike = member.bikes != null && member.bikes!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: _buildAvatar(member),
        title: Row(
          children: <Widget>[
            Flexible(
              child: Text(
                "${member.firstName ?? ""} ${member.lastName ?? ""}".trim(),
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (member.riderNumber != null) ...[
              const SizedBox(width: 8.0),
              _buildRiderNumberBadge(member.riderNumber!),
            ],
          ],
        ),
        subtitle: Row(
          children: <Widget>[
            Icon(
              CustomIcons.motorbike_plain,
              size: 13.0,
              color: hasBike ? Colors.deepPurple : Colors.black.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 5.0),
            Expanded(
              child: Text(
                _currentBikeText(member),
                style: TextStyle(fontStyle: hasBike ? FontStyle.normal : FontStyle.italic),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: member.boardRole != null ? _buildBoardRoleBadge(member.boardRole!, context) : null,
        onTap: () => _navigateToMemberDetailScreen(context, member),
      ),
    );
  }

  Widget build(BuildContext context) {
    final MemberListProvider _memberListProvider = Provider.of<MemberListProvider>(context, listen: true);
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.tabTeam),
        actions: <Widget>[
          if (_loginProvider.isAdmin)
            IconButton(icon: Icon(Icons.add), onPressed: () => _navigateToAddMemberScreen(context)),
          MainActionMenu(),
        ],
      ),
      drawer: MainDrawer(),
      body: !_loginProvider.isMember
          ? Container(decoration: CustomDecorations.mainContent, child: RestrictedContent())
          : Container(
              decoration: CustomDecorations.mainContent,
              child: Column(
                children: <Widget>[
                  _buildSearchField(_memberListProvider),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _memberListProvider.fetchMemberList(null),
                      child: LoadingContent(
                        loadingStatus: _memberListProvider.loadingStatus,
                        defaultText: AppString.membersNotFound,
                        emptyText: AppString.membersNotFound,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8.0),
                          separatorBuilder: (context, index) => Divider(color: Colors.white.withAlpha(50), height: 4),
                          itemCount: _memberListProvider.memberList.length,
                          itemBuilder: (context, index) =>
                              _buildMemberTile(context, _memberListProvider.memberList[index]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
