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
import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/services/events_service.dart';
import 'package:chachatte_team/ui/events/add_edit_event.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/custom_decorations.dart';
import 'package:chachatte_team/utils/custom_icons.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:chachatte_team/utils/track_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

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

  /// Method that launches the Member detail screen and awaits the result from Navigator.pop
  void _navigateToMemberDetailScreen(BuildContext context, Member member) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final _result = await Navigator.pushNamed(context, '/memberDetail', arguments: member);

    // after the target screen returns a result, hide any previous snack bars and show the result
    if (_result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$_result")));
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
        decoration: CustomDecorations.mainContent,
        child: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  height: 120,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage("images/finish_flag.png"),
                      colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.04), BlendMode.dstATop),
                    ),
                    gradient: LinearGradient(
                      colors: [Colors.blue[400], Colors.blue[600]],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    widget.event.title,
                    textScaleFactor: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 100,
                              margin: EdgeInsets.all(4.0),
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 2.0),
                                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                color: Colors.blue[100],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Icon(
                                    Icons.event,
                                    size: 38,
                                    color: Colors.red[700],
                                  ),
                                  Text(
                                    DateUtils.convertToString(widget.event.eventDate, "dd MMM yyyy"),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 100,
                              margin: EdgeInsets.all(4.0),
                              padding: EdgeInsets.all(8.0),
                              decoration:
                                  BoxDecoration(border: Border.all(color: Colors.white, width: 2.0), borderRadius: BorderRadius.all(Radius.circular(4.0)), color: Colors.blue[100]),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Icon(
                                    Icons.euro_symbol,
                                    size: 38,
                                    color: Colors.red[700],
                                  ),
                                  Text(
                                    "${StringUtils.formatPrice(widget.event.price)}",
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 100,
                              margin: EdgeInsets.all(4.0),
                              padding: EdgeInsets.all(8.0),
                              decoration:
                                  BoxDecoration(border: Border.all(color: Colors.white, width: 2.0), borderRadius: BorderRadius.all(Radius.circular(4.0)), color: Colors.blue[100]),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Icon(TrackUtils.trackIconFromName(widget.event.track.name), size: 38, color: Colors.red[700]),
                                  Text(
                                    widget.event.track.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 100,
                              margin: EdgeInsets.all(4.0),
                              padding: EdgeInsets.all(8.0),
                              decoration:
                                  BoxDecoration(border: Border.all(color: Colors.white, width: 2.0), borderRadius: BorderRadius.all(Radius.circular(4.0)), color: Colors.blue[100]),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Icon(CustomIcons.helmet, size: 38, color: Colors.red[700]),
                                  Text(
                                    widget.event.organizer,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.white),
                      Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.description, size: 18),
                            SizedBox(width: 5.0),
                            Text(
                              "Description",
                              textScaleFactor: 1.2,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Text(widget.event.description),
                      SizedBox(height: 10),
                      Divider(color: Colors.white),
                      Row(
                        children: <Widget>[
                          Icon(Icons.group, size: 18),
                          SizedBox(width: 5.0),
                          Text(
                            "Participants",
                            textScaleFactor: 1.2,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.event.members.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: <Widget>[
                                InkWell(
                                  onTap: () => _navigateToMemberDetailScreen(context, widget.event.members[index]),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    padding: EdgeInsets.all(2.0),
                                    margin: EdgeInsets.all(12.0),
                                    decoration: ShapeDecoration(shape: CircleBorder(), color: Colors.white),
                                    child: widget.event.members[index].avatar != null && widget.event.members[index].avatar.length > 0
                                        ? CircleAvatar(
                                            backgroundColor: Colors.blue[100],
                                            backgroundImage: NetworkImage("$SERVER_ROOT_PATH$SERVER_AVATAR_FOLDER${widget.event.members[index].avatar}"),
                                          )
                                        : CircleAvatar(
                                            backgroundColor: Colors.blue[100],
                                            child: ShaderMask(
                                              shaderCallback: (bounds) => LinearGradient(
                                                begin: const FractionalOffset(0.0, 0.0),
                                                end: const FractionalOffset(0.0, 1.0),
                                                stops: [0.0, 1.0],
                                                colors: [Colors.red[700], Colors.white],
                                              ).createShader(bounds),
                                              child: Icon(CustomIcons.pilot, size: 50),
                                            ),
                                          ),
                                  ),
                                ),
                                Container(
                                  width: 80,
                                  child: Text(
                                    "${widget.event.members[index].firstName} ${widget.event.members[index].lastName}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Divider(color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
