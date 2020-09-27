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

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/models/record.dart';
import 'package:chachatte_team/models/track.dart';
import 'package:chachatte_team/providers/event_provider.dart';
import 'package:chachatte_team/providers/member_provider.dart';
import 'package:chachatte_team/providers/record_provider.dart';
import 'package:chachatte_team/utils/app_utils.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/custom_decorations.dart';
import 'package:chachatte_team/utils/custom_icons.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/enums.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:chachatte_team/utils/track_utils.dart';
import 'package:chachatte_team/widgets/flexible_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberDetail extends StatefulWidget {
  final Member member;

  const MemberDetail({Key key, this.member}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MemberDetailState();
  }
}

class _MemberDetailState extends State<MemberDetail> {
  ScrollController _scrollController;

  // height of the Sliver app bar
  final double _expandedHeight = 202;

  // size (width and height) of an event timeline card
  final double _eventCardSize = 90;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(() => setState(() {}));
    Provider.of<RecordProvider>(context, listen: false).fetchMemberRecords(widget.member.id);
    Provider.of<EventProvider>(context, listen: false).fetchMemberEvents(widget.member.id);
  }

  /// Display or hide the Sliver app bar title depending on the scroll offset
  bool get _showTitle {
    return _scrollController.hasClients && _scrollController.offset > _expandedHeight - kToolbarHeight;
  }

  /// Method that launches the Edit Member screen and awaits the result from Navigator.pop
  void _navigateToEditMemberScreen(BuildContext context, Member member) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final _result = await Navigator.pushNamed(context, '/addEditMember', arguments: member);

    // after the target screen returns a result, hide any previous snack bars and show the result
    if (_result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$_result")));
    }
  }

  /// Method that launches the Track detail screen and awaits the result from Navigator.pop
  void _navigateToTrackDetailScreen(BuildContext context, Track track) async {
    // todo Maybe better to do it in detail screen init method instead of each time here ?
    Provider.of<RecordProvider>(context, listen: false).fetchTrackRecords(track.id);
    Provider.of<EventProvider>(context, listen: false).fetchTrackEvents(track.id);

    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final _result = await Navigator.pushNamed(context, '/trackDetail', arguments: track);

    // after the target screen returns a result, hide any previous snack bars and show the result
    if (_result != null) {
      Scaffold.of(context)
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

  /// Handle result of the member deletion confirmation dialog
  void _dialogueResult(BuildContext context, ConfirmDialogAction value) {
    if (value == ConfirmDialogAction.yes) {
      // delete member
      Provider.of<MemberProvider>(context, listen: false).deleteMember(widget.member).then((value) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AppString.memberDeleted)));
      }, onError: (error) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AppString.memberDeletionFailed)));
      });
    }
    Navigator.pop(context);
  }

  Widget _recordsTable(RecordProvider recordProvider) {
    if (recordProvider.memberRecords != null && recordProvider.memberRecords.length > 0) {
      return Container(
        decoration: CustomDecorations.cardLight,
        child: Table(
          columnWidths: {0: FlexColumnWidth(3), 1: FlexColumnWidth(2), 2: FlexColumnWidth(2), 3: FlexColumnWidth(1)},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border:
              TableBorder(horizontalInside: BorderSide(color: Colors.black.withOpacity(0.3), width: 1), verticalInside: BorderSide(color: Colors.black.withOpacity(0.3), width: 1)),
          children: [
            for (Record rec in recordProvider.memberRecords)
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Text(
                    rec.track.name,
                    style: TextStyle(color: Colors.black.withOpacity(0.8)),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  DateUtils.convertToString(rec.recordDate, "dd/MM/yyyy"),
                  style: TextStyle(color: Colors.black.withOpacity(0.8)),
                  textAlign: TextAlign.center,
                ),
                Text(
                    DateUtils.toLapTimeString(rec.lapTime),
                    style: TextStyle(color: Colors.black.withOpacity(1), fontFamily: "AlarmClock", letterSpacing: -1),
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                  ),
                SizedBox(
                    width: 10,
                    child: rec.conditions == "dry"
                        ? Icon(Icons.wb_sunny, color: Colors.black.withOpacity(0.6), size: 15)
                        : Icon(CustomIcons.rain, color: Colors.black.withOpacity(0.6), size: 15))
              ])
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(12.0),
        decoration: CustomDecorations.cardLight,
        child: Text(AppString.memberNoChrono),
      );
    }
  }

  Widget _eventsTimeline(EventProvider eventProvider) {
    if (eventProvider.memberEvents != null && eventProvider.memberEvents.length > 0) {
      return SizedBox(
        height: 142,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: eventProvider.memberEvents.length,
          itemBuilder: (BuildContext context, int index) {
            // if list view is not large enough, add padding so it fills the whole screen width
            final double pad =
                index >= eventProvider.memberEvents.length - 1 ? max(MediaQuery.of(context).size.width - ((_eventCardSize + 16) * eventProvider.memberEvents.length) - 16, 0) : 0.0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 36.0),
                      margin: EdgeInsets.only(right: pad),
                      child: InkWell(
                        onTap: () => _navigateToTrackDetailScreen(context, eventProvider.memberEvents[index].track),
                        child: Container(
                          decoration: CustomDecorations.cardLight,
                          width: _eventCardSize,
                          height: _eventCardSize,
                          padding: EdgeInsets.all(2.0),
                          margin: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Icon(
                                TrackUtils.trackIconFromName(eventProvider.memberEvents[index].track.name),
                                size: 30,
                                color: Colors.red[700],
                              ),
                              Text(
                                "${eventProvider.memberEvents[index].track.name}",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                              ),
                              Text(
                                "${eventProvider.memberEvents[index].organizer}",
                                textScaleFactor: 0.8,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 17.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        height: 2,
                        color: Colors.red[700],
                      ),
                    ),
                    if (eventProvider.memberEvents.length > 1 && index != eventProvider.memberEvents.length - 1)
                      Positioned(
                        top: 6.0,
                        left: _eventCardSize,
                        child: Icon(
                          Icons.arrow_left,
                          color: Colors.red[700],
                        ),
                      ),
                    Positioned(
                      top: 0.0,
                      left: 0.0,
                      right: pad,
                      child: Center(
                        child: Container(
                          width: 42,
                          height: 36,
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.red[700],
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0), topRight: Radius.circular(6.0)),
                                ),
                                child: Center(
                                  child: Text(
                                    "${DateUtils.convertToString(eventProvider.memberEvents[index].startDate, "MMM yy")}",
                                    textScaleFactor: 0.75,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: CustomDecorations.cardBody,
                                  child: Center(
                                    child: Text(
                                      "${DateUtils.convertToString(eventProvider.memberEvents[index].startDate, "dd")}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(12.0),
        decoration: CustomDecorations.cardLight,
        child: Text(AppString.memberNoEvent),
      );
    }
  }

  Widget build(BuildContext context) {
    final RecordProvider _recordProvider = Provider.of<RecordProvider>(context, listen: true);
    final EventProvider _eventProvider = Provider.of<EventProvider>(context, listen: true);

    final _motoInfo = MergeSemantics(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(AppString.moto, style: TextStyle(color: Colors.red[700])),
                  Container(
                    child: Text(
                      "${widget.member.bike}",
                      style: TextStyle(color: Colors.black.withOpacity(0.8)),
                      textScaleFactor: 1.1,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 72.0,
              child: Icon(CustomIcons.motorbike, color: Colors.red[700].withOpacity(0.8)),
            )
          ],
        ),
      ),
    );

    final _mobileInfo = MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(AppString.mobile, style: TextStyle(color: Colors.red[700])),
                  Container(
                    child: Text(
                      "${widget.member.phone}",
                      style: TextStyle(color: Colors.black.withOpacity(0.8)),
                      textScaleFactor: 1.1,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
                width: 72.0,
                child: IconButton(
                    icon: Icon(Icons.phone),
                    color: Colors.green,
                    onPressed: () {
                      AppUtils.launchURL("tel:${widget.member.phone}");
                    })),
            SizedBox(
                width: 72.0,
                child: IconButton(
                    icon: Icon(Icons.sms),
                    color: Colors.blue,
                    onPressed: () {
                      AppUtils.launchURL("sms:${widget.member.phone}");
                    }))
          ],
        ),
      ),
    );

    final _emailInfo = MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(AppString.email, style: TextStyle(color: Colors.red[700])),
                  Container(
                    child: Text(
                      "${widget.member.email}",
                      style: TextStyle(color: Colors.black.withOpacity(0.8)),
                      textScaleFactor: 1.1,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
                width: 72.0,
                child: IconButton(
                    icon: Icon(Icons.mail),
                    color: Colors.purple.withOpacity(0.6),
                    onPressed: () {
                      AppUtils.launchURL("mailto:${widget.member.email}");
                    }))
          ],
        ),
      ),
    );

    return Scaffold(
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: _expandedHeight,
              title: _showTitle
                  ? Text(
                      widget.member.firstName + ' ' + widget.member.lastName,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              flexibleSpace: _showTitle
                  ? null
                  : FlexibleSpaceBar(
                      title: FlexibleTitle(
                        text: widget.member.firstName + ' ' + widget.member.lastName,
                        padding: EdgeInsets.only(left: 84, bottom: 44),
                      ),
                      background: Stack(
                        alignment: Alignment.bottomLeft,
                        fit: StackFit.expand,
                        children: <Widget>[
                          CachedNetworkImage(
                            placeholder: (context, url) => Center(
                              child: SizedBox(
                                child: CircularProgressIndicator(),
                                height: 20.0,
                                width: 20.0,
                              ),
                            ),
                            imageUrl: 'https://images.freeimages.com/images/small-previews/e71/frog-1371919.jpg',
                            fit: BoxFit.fitWidth,
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(0.0, 1.0),
                                end: Alignment(0.0, -1.0),
                                colors: <Color>[Colors.black.withOpacity(0.4), Colors.transparent],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 15,
                            left: 15,
                            child: Container(
                              decoration: ShapeDecoration(shape: CircleBorder(), color: Colors.white),
                              padding: EdgeInsets.all(3.0),
                              child: widget.member.avatar != null && widget.member.avatar.length > 0
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage("$SERVER_ROOT_PATH$SERVER_AVATAR_FOLDER${widget.member.avatar}"),
                                    )
                                  : CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.blue[100],
                                      child: ShaderMask(
                                        blendMode: BlendMode.srcATop,
                                        shaderCallback: (bounds) => LinearGradient(
                                          begin: const FractionalOffset(0.0, 0.0),
                                          end: const FractionalOffset(0.0, 1.0),
                                          stops: [0.0, 1.0],
                                          colors: [Colors.red[700], Colors.blue[700]],
                                        ).createShader(bounds),
                                        child: Icon(CustomIcons.pilot, size: 75),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToEditMemberScreen(context, widget.member),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () => _showConfirmation(context, AppString.memberDeletionAreYouSure),
                )
              ],
            ),
            SliverPadding(
              padding: EdgeInsets.all(8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    ConstrainedBox(
                      // set minimum height : screen height - app bar height - status bar height - padding
                      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top - 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(Icons.person, size: 16, color: Colors.black.withOpacity(0.8)),
                              SizedBox(width: 5.0),
                              Text(
                                AppString.personalInformation,
                                textScaleFactor: 1.2,
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: CustomDecorations.cardLight,
                            child: Column(
                              children: <Widget>[
                                _motoInfo,
                                Divider(color: Colors.black.withOpacity(0.8), height: 5),
                                _mobileInfo,
                                Divider(color: Colors.black.withOpacity(0.8), height: 5),
                                _emailInfo,
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: <Widget>[
                              Icon(Icons.event, size: 16, color: Colors.black.withOpacity(0.8)),
                              SizedBox(width: 5.0),
                              Text(
                                AppString.rides,
                                textScaleFactor: 1.2,
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          _eventsTimeline(_eventProvider),
                          SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Icon(Icons.timer, size: 16, color: Colors.black.withOpacity(0.8)),
                              SizedBox(width: 5.0),
                              Text(
                                AppString.chronos,
                                textScaleFactor: 1.2,
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          _recordsTable(_recordProvider),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
