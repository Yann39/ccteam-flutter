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
import 'package:chachatte_team/services/members_service.dart';
import 'package:chachatte_team/ui/members/add_member.dart';
import 'package:chachatte_team/ui/members/member_detail.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';

class Team extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TeamState();
  }
}

/// Class representing a list item
class _MemberListItem extends ListTile {
  _MemberListItem(Member member)
      : super(title: new Text(member.firstName + " " + member.lastName), subtitle: new Text(member.bike), leading: new CircleAvatar(child: new Text(member.firstName[0])));
}

class _TeamState extends State<Team> {
  static final MembersService membersService = new MembersService();

  /// Method that launches the Add Member screen and awaits the result from Navigator.pop
  _navigateToAddMemberScreen(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddMember()));

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  /// Method that launches the Member detail screen and awaits the result from Navigator.pop
  _navigateToMemberDetailScreen(BuildContext context, Member member) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => MemberDetail(member: member)));

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.memberScreenTitle),
        leading: new Icon(Icons.group),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [PopupMenuItem(child: Text(AppString.about)), PopupMenuItem(child: Text(AppString.contact))];
            },
          )
        ],
      ),
      body: FutureBuilder<List<Member>>(
        future: membersService.fetchMembers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new Column(
              children: <Widget>[
                new Expanded(
                  child: new Container(
                    child: new ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return new Material(
                            child: InkWell(
                              child: new _MemberListItem(snapshot.data[index]),
                              onTap: () => _navigateToMemberDetailScreen(context, snapshot.data[index]),
                            ),
                            color: Colors.transparent,
                          );
                        }),
                    decoration: new BoxDecoration(
                      gradient: new LinearGradient(
                          colors: [Colors.blue[100], Colors.blue[300]],
                          begin: const FractionalOffset(0.0, 0.0),
                          end: const FractionalOffset(0.0, 1.0),
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp),
                    ),
                  ),
                )
              ],
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner
          return CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
          elevation: 0.0,
          child: new Icon(Icons.add),
          backgroundColor: Colors.red[700],
          onPressed: () {
            _navigateToAddMemberScreen(context);
          }),
    );
  }
}
