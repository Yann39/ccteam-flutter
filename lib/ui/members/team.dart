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
import 'package:chachatte_team/providers/record_provider.dart';
import 'package:chachatte_team/ui/main/main_action_menu.dart';
import 'package:chachatte_team/ui/main/main_drawer.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/custom_decorations.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:chachatte_team/widgets/loading_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// We need stateful widget to keep search field value
class Team extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TeamState();
  }
}

class _TeamState extends State<Team> {
  /// Method that launches the Add Member screen and awaits the result from Navigator.pop
  void _navigateToAddMemberScreen(BuildContext context) async {
    // Navigator.push returns a Future which will complete after we call Navigator.pop on the target screen
    final _result = await Navigator.pushNamed(context, '/addEditMember');

    // after the target screen returns a result, hide any previous snack bars and show the result
    if (_result != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$_result")));
    }
  }

  /// Method that launches the Member detail screen and awaits the result from Navigator.pop
  void _navigateToMemberDetailScreen(BuildContext context, Member member) async {

    // fetch the current member
    Provider.of<MemberProvider>(context, listen: false).fetchCurrentMember(member);
    Provider.of<RecordProvider>(context, listen: false).fetchMemberRecords(member.id);
    //Provider.of<EventProvider>(context, listen: false).fetchMemberEvents(member.id);

    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final _result = await Navigator.pushNamed(context, '/memberDetail');

    // after the target screen returns a result, hide any previous snack bars and show the result
    if (_result != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$_result")));
    }
  }

  /// Build the search field
  TextField _buildSearchField(MemberProvider _memberProvider) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blue[100],
        prefixIcon: Icon(Icons.search),
        hintText: AppString.membersSearchHint,
      ),
      maxLines: 1,
      onChanged: (String text) {
        _memberProvider.fetchMembers(text);
      },
    );
  }

  Widget build(BuildContext context) {
    final MemberProvider _memberProvider = Provider.of<MemberProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.tabTeam),
        actions: <Widget>[MainActionMenu()],
      ),
      drawer: MainDrawer(),
      body: Column(
        children: <Widget>[
          _buildSearchField(_memberProvider),
          Expanded(
            child: Container(
              decoration: CustomDecorations.mainContent,
              child: LoadingContent(
                loadingStatus: _memberProvider.loadingStatus,
                emptyText: AppString.membersNotFound,
                child: ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.black,
                    height: 4,
                  ),
                  itemCount: _memberProvider.members.length,
                  itemBuilder: (context, index) {
                    return Material(
                      child: InkWell(
                        child: ListTile(
                          title: Text(
                              "${_memberProvider.members[index].firstName} ${_memberProvider.members[index].lastName}"),
                          subtitle: Text(_memberProvider.members[index].bike ?? AppString.notDefined),
                          leading: _memberProvider.members[index].avatarUrl != null &&
                                  _memberProvider.members[index].avatarUrl.length > 0
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      "$SERVER_ROOT_PATH$SERVER_AVATAR_FOLDER${_memberProvider.members[index].avatarUrl}"))
                              : CircleAvatar(child: Text(_memberProvider.members[index].firstName[0])),
                        ),
                        onTap: () => _navigateToMemberDetailScreen(context, _memberProvider.members[index]),
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
        child: Icon(Icons.add),
        backgroundColor: Colors.red[700],
        onPressed: () {
          _navigateToAddMemberScreen(context);
        },
      ),
    );
  }
}
