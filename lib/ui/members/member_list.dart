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
import 'package:ccteam/providers/member_creation_provider.dart';
import 'package:ccteam/providers/member_detail_provider.dart';
import 'package:ccteam/providers/member_list_provider.dart';
import 'package:ccteam/ui/main/main_action_menu.dart';
import 'package:ccteam/ui/main/main_drawer.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/loading_content.dart';
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
    // fetch the member to get complete data
    Provider.of<MemberDetailProvider>(context, listen: false).fetchMember(member).then((value) => {
          // navigate to member detail screen
          Navigator.pushNamed(context, '/memberDetail')
        });
  }

  /// Build the search field
  TextField _buildSearchField(MemberListProvider _memberListProvider) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blue[100],
        prefixIcon: Icon(Icons.search),
        hintText: AppString.membersSearchHint,
      ),
      maxLines: 1,
      onChanged: (String text) {
        _memberListProvider.fetchMemberList(text);
      },
    );
  }

  Widget build(BuildContext context) {
    final MemberListProvider _memberListProvider = Provider.of<MemberListProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.tabTeam),
        actions: <Widget>[MainActionMenu()],
      ),
      drawer: MainDrawer(),
      body: Column(
        children: <Widget>[
          _buildSearchField(_memberListProvider),
          Expanded(
            child: Container(
              decoration: CustomDecorations.mainContent,
              child: LoadingContent(
                loadingStatus: _memberListProvider.loadingStatus,
                emptyText: AppString.membersNotFound,
                child: ListView.separated(
                  separatorBuilder: (context, index) => Divider(color: Colors.black, height: 4),
                  itemCount: _memberListProvider.memberList.length,
                  itemBuilder: (context, index) {
                    return Material(
                      child: InkWell(
                        child: ListTile(
                          title: Text(
                              "${_memberListProvider.memberList[index].firstName} ${_memberListProvider.memberList[index].lastName}"),
                          subtitle: Text(_memberListProvider.memberList[index].bike ?? AppString.notDefined),
                          leading: _memberListProvider.memberList[index].avatarUrl != null &&
                                  _memberListProvider.memberList[index].avatarUrl!.length > 0
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      "$SERVER_AVATAR_FOLDER${_memberListProvider.memberList[index].avatarUrl}"))
                              : CircleAvatar(
                                  child: Text(
                                    _memberListProvider.memberList[index].firstName![0],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red[700],
                                ),
                        ),
                        onTap: () => _navigateToMemberDetailScreen(context, _memberListProvider.memberList[index]),
                      ),
                      color: Colors.transparent,
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.red[700],
        onPressed: () {
          _navigateToAddMemberScreen(context);
        },
      ),
    );
  }
}
