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

import 'package:chachatte_team/models/event.dart';
import 'package:chachatte_team/services/events_service.dart';
import 'package:chachatte_team/ui/events/add_edit_event.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';

class EventDetail extends StatefulWidget {
  final Event event;

  const EventDetail({Key key, this.event}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EventDetailState();
  }
}

enum ConfirmDialogAction { yes, no }

class _EventDetailState extends State<EventDetail> {
  /// Method that launches the Edit event screen and awaits the result from Navigator.pop
  _navigateToEditEventScreen(BuildContext context, Event event) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditEvent(event: event)));

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  /// Display a confirmation popup when trying to delete a event
  void _showConfirmation(BuildContext context, String value) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text(AppString.confirmation),
            content: Text(value),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  _dialogueResult(context, ConfirmDialogAction.yes);
                },
                child: Text(AppString.confirm),
              ),
              FlatButton(
                onPressed: () {
                  _dialogueResult(context, ConfirmDialogAction.no);
                },
                child: Text(AppString.cancel),
              ),
            ],
          ),
    );
  }

  /// Handle result of the event deletion confirmation dialog
  void _dialogueResult(BuildContext context, ConfirmDialogAction value) {
    if (value == ConfirmDialogAction.yes) {
      final EventsService eventsService = new EventsService();
      // delete event
      eventsService.deleteEvent(widget.event).then((value) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AppString.eventDeleted)));
      }, onError: (error) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AppString.eventDeletionFailed)));
      });
    }
    Navigator.pop(context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _navigateToEditEventScreen(context, widget.event),
                ),
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () => _showConfirmation(context, AppString.eventDeletionAreYouSure),
          )
        ],
        title: Text(AppString.eventDetailScreenTitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(DateUtils.convertToString(widget.event.eventDate, AppConstants.DATE_FORMAT), textAlign: TextAlign.left),
            Text(widget.event.title, textScaleFactor: 2, textAlign: TextAlign.center),
            SizedBox(
              height: 10,
            ),
            Text(widget.event.description),
          ],
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[100], Colors.blue[300]],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(0.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
    );
  }
}
