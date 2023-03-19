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
import 'package:chachatte_team/providers/event_provider.dart';
import 'package:chachatte_team/providers/member_provider.dart';
import 'package:chachatte_team/providers/record_provider.dart';
import 'package:chachatte_team/ui/events/event_card.dart';
import 'package:chachatte_team/utils/custom_decorations.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberEvents extends StatefulWidget {
  final Member member;

  const MemberEvents({Key key, this.member}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MemberEventsState();
  }
}

class _MemberEventsState extends State<MemberEvents> {
  @override
  void initState() {
    super.initState();
    Provider.of<RecordProvider>(context, listen: false)
        .fetchMemberRecords(widget.member.id);
    /*Provider.of<EventProvider>(context, listen: false)
        .fetchMemberEventsByStatus(widget.member.id);*/
  }

  /// Method that launches the Add Event screen and awaits the result from Navigator.pop
  _navigateToAddEventScreen(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final _result = await Navigator.pushNamed(context, '/addEditEvent');

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (_result != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$_result")));
    }
  }

  /// Display a confirmation popup when trying to delete a member
  void _showConfirmation(BuildContext context, String value) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppString.confirmation),
        content: Text(value),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _dialogueResult(context, ConfirmDialogAction.yes);
            },
            child: Text(AppString.confirm),
          ),
          TextButton(
            onPressed: () {
              _dialogueResult(context, ConfirmDialogAction.no);
            },
            child: Text(AppString.cancel),
          ),
        ],
      ),
    );
  }

  /// Handle result of the member deletion confirmation dialog
  void _dialogueResult(BuildContext context, ConfirmDialogAction value) {
    if (value == ConfirmDialogAction.yes) {
      // delete member
      Provider.of<MemberProvider>(context, listen: false)
          .deleteMember(widget.member)
          .then((value) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AppString.memberDeleted)));
      }, onError: (error) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
              SnackBar(content: Text(AppString.memberDeletionFailed)));
      });
    }
    Navigator.pop(context);
  }

  Widget build(BuildContext context) {
    final EventProvider _eventProvider =
        Provider.of<EventProvider>(context, listen: true);

    final _search = SizedBox(
      height: 50,
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(width: 4);
        },
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        itemBuilder: (BuildContext context, int index) => FilterChip(
          label: Text(
            index == 0 ? 'À venir' : 'Terminés',
            style: TextStyle(color: Colors.white),
          ),
          onSelected: (bool value) {
            _eventProvider.updateStatusSelection(index, widget.member.id);
          },
          selected: _eventProvider.selectedStatuses.contains(index),
          selectedColor: Colors.red[700],
          labelStyle: TextStyle(
            color: Colors.black,
          ),
          checkmarkColor: Colors.white,
          backgroundColor: Color(0xffAAAAAA),
          showCheckmark: true,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.myTrackEvents),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: CustomDecorations.mainContent,
        child: Column(
          children: <Widget>[
            _search,
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 8.0),
                scrollDirection: Axis.vertical,
                itemCount: _eventProvider.memberEvents.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0 ||
                      (index > 0 &&
                          _eventProvider.memberEvents[index].startDate.year <
                              _eventProvider
                                  .memberEvents[index - 1].startDate.year)) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            "${_eventProvider.memberEvents[index].startDate.year}"),
                        SizedBox(height: 4.0),
                        EventCard(_eventProvider.memberEvents[index]),
                      ],
                    );
                  } else {
                    return EventCard(_eventProvider.memberEvents[index]);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        child: Icon(Icons.add),
        backgroundColor: Colors.red[700],
        onPressed: () {
          _navigateToAddEventScreen(context);
        },
      ),
    );
  }
}
