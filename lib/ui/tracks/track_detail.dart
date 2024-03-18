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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chachatte_team/models/record.dart';
import 'package:chachatte_team/models/track.dart';
import 'package:chachatte_team/providers/record_provider.dart';
import 'package:chachatte_team/utils/app_utils.dart';
import 'package:chachatte_team/utils/custom_decorations.dart';
import 'package:chachatte_team/utils/custom_icons.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:chachatte_team/utils/track_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrackDetail extends StatefulWidget {
  final Track track;

  const TrackDetail({Key key, this.track}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TrackDetailState();
  }
}

class _TrackDetailState extends State<TrackDetail> {
  /// Method that launches the Edit track screen and awaits the result from Navigator.pop
  _navigateToEditTrackScreen(BuildContext context, Track track) async {
    /*// Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditTrack(event: event)));

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }*/
  }

  Widget _recordsTable(RecordProvider recordProvider) {
    if (recordProvider.trackRecords != null && recordProvider.trackRecords.length > 0) {
      return Container(
        decoration: CustomDecorations.cardLight,
        child: Table(
          columnWidths: {0: FlexColumnWidth(3), 1: FlexColumnWidth(2), 2: FlexColumnWidth(2), 3: FlexColumnWidth(1)},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
              horizontalInside: BorderSide(color: Colors.black.withOpacity(0.3), width: 1),
              verticalInside: BorderSide(color: Colors.black.withOpacity(0.3), width: 1)),
          children: [
            for (Record rec in recordProvider.trackRecords)
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Text(
                    "${rec.member.firstName} ${rec.member.lastName}",
                    style: TextStyle(color: Colors.black.withOpacity(0.8)),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  AppDateUtils.toLapTimeString(rec.lapTime),
                  style: TextStyle(color: Colors.black.withOpacity(0.8)),
                  textAlign: TextAlign.center,
                ),
                Text(
                  AppDateUtils.convertToString(rec.recordDate, "dd/MM/yyyy"),
                  style: TextStyle(color: Colors.black.withOpacity(0.8)),
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
        child: Text(AppString.trackNoChrono),
      );
    }
  }

  /*Widget _eventsTable(EventProvider eventProvider) {
    if (eventProvider.trackEvents != null &&
        eventProvider.trackEvents.length > 0) {
      return Container(
        decoration: CustomDecorations.cardLight,
        child: Table(
          columnWidths: {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1)
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
              horizontalInside:
                  BorderSide(color: Colors.black.withOpacity(0.3), width: 1),
              verticalInside:
                  BorderSide(color: Colors.black.withOpacity(0.3), width: 1)),
          children: [
            for (Event ev in eventProvider.trackEvents)
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 12.0),
                  child: Text(
                    ev.fullDate,
                    style: TextStyle(color: Colors.black.withOpacity(0.8)),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  ev.organizer,
                  style: TextStyle(color: Colors.black.withOpacity(0.8)),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "${StringUtils.formatPrice(ev.price)} €",
                  style: TextStyle(color: Colors.black.withOpacity(0.8)),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "${ev.members.length}",
                  style: TextStyle(color: Colors.black.withOpacity(0.8)),
                  textAlign: TextAlign.center,
                ),
              ])
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(12.0),
        decoration: CustomDecorations.cardLight,
        child: Text(AppString.trackNoEvent),
      );
    }
  }*/

  Widget build(BuildContext context) {
    final RecordProvider _recordProvider = Provider.of<RecordProvider>(context, listen: true);
    //final EventProvider _eventProvider = Provider.of<EventProvider>(context, listen: true);

    return Scaffold(
      /*appBar: AppBar(
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _navigateToEditTrackScreen(context, widget.track),
            ),
          ),
        ],
        title: Text(widget.track.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),*/
      body: Container(
          decoration: CustomDecorations.mainContent,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(widget.track.name),
                  background: Stack(
                    alignment: Alignment.bottomLeft,
                    fit: StackFit.expand,
                    children: <Widget>[
                      Image.asset(
                        TrackUtils.trackCoverImageUrlFromName(widget.track.name),
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
                    ],
                  ),
                ),
              ),
              SliverPadding(
                  padding: EdgeInsets.all(8.0),
                  sliver: SliverList(
                      delegate: SliverChildListDelegate(<Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
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
                                      decoration: CustomDecorations.cardLight,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Icon(
                                            Icons.timer,
                                            size: 30,
                                            color: Colors.red[700],
                                          ),
                                          Text(
                                            AppString.lapRecord,
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            AppDateUtils.toLapTimeString(widget.track.lapRecord),
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
                                      decoration: CustomDecorations.cardLight,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Icon(
                                            Icons.straighten,
                                            size: 30,
                                            color: Colors.red[700],
                                          ),
                                          Text(
                                            AppString.length,
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            "${widget.track.distance}",
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
                                    child: InkWell(
                                      onTap: () =>
                                          AppUtils.launchURL("geo:${widget.track.latitude},${widget.track.longitude}"),
                                      child: Container(
                                        height: 100,
                                        margin: EdgeInsets.all(4.0),
                                        padding: EdgeInsets.all(8.0),
                                        decoration: CustomDecorations.cardLight,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Icon(
                                              Icons.place,
                                              size: 30,
                                              color: Colors.red[700],
                                            ),
                                            Text(
                                              "${widget.track.latitude}",
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              "${widget.track.longitude}",
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(color: Colors.white),
                              SizedBox(height: 10),
                              Row(
                                children: <Widget>[
                                  Icon(Icons.description, size: 16, color: Colors.black.withOpacity(0.8)),
                                  SizedBox(width: 5.0),
                                  Text(
                                    AppString.trackEvents,
                                    textScaleFactor: 1.2,
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              //_eventsTable(_eventProvider),
                              SizedBox(height: 10),
                              Divider(color: Colors.white),
                              SizedBox(height: 10),
                              Row(
                                children: <Widget>[
                                  Icon(Icons.group, size: 18, color: Colors.black.withOpacity(0.64)),
                                  SizedBox(width: 5.0),
                                  Text(
                                    AppString.chronos,
                                    textScaleFactor: 1.2,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.64)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              _recordsTable(_recordProvider),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 400,
                        )
                      ],
                    ),
                  ]))),
            ],
          )

          /*ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  //alignment: Alignment.center,
                  height: 180,
                  //padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue[300],
                        spreadRadius: 1,
                        blurRadius: 2,
                      ),
                    ],
                    /*image: DecorationImage(
                      fit: BoxFit.fill,
                      image: /*AssetImage("images/finish_flag.png")*/,
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(1), BlendMode.dstATop),
                    ),*/
                    gradient: LinearGradient(
                      colors: [Colors.blue[300], Colors.blue[500]],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  /*child: Text(
                    "${widget.track.name}",
                    textScaleFactor: 2,
                    style: TextStyle(color: Colors.white),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),*/
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Center(
                      child: SizedBox(
                        child: CircularProgressIndicator(),
                        height: 20.0,
                        width: 20.0,
                      ),
                    ),
                    imageUrl: TrackUtils.trackCoverImageUrlFromName(widget.track.name),
                    fit: BoxFit.fill,
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
                              decoration: CustomDecorations.cardLight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Icon(
                                    Icons.timer,
                                    size: 30,
                                    color: Colors.red[700],
                                  ),
                                  Text(
                                    AppString.lapRecord,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    DateUtils.toLapTime(widget.track.lapRecord),
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
                              decoration: CustomDecorations.cardLight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Icon(
                                    Icons.straighten,
                                    size: 30,
                                    color: Colors.red[700],
                                  ),
                                  Text(
                                    AppString.length,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "${widget.track.distance}",
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
                              decoration: CustomDecorations.cardLight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Icon(
                                    Icons.place,
                                    size: 30,
                                    color: Colors.red[700],
                                  ),
                                  Text(
                                    "${widget.track.latitude}",
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "${widget.track.longitude}",
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.white),
                      SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Icon(Icons.description, size: 16, color: Colors.black.withOpacity(0.8)),
                          SizedBox(width: 5.0),
                          Text(
                            AppString.trackEvents,
                            textScaleFactor: 1.2,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _eventsTable(_eventProvider),
                      SizedBox(height: 10),
                      Divider(color: Colors.white),
                      SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Icon(Icons.group, size: 18, color: Colors.black.withOpacity(0.64)),
                          SizedBox(width: 5.0),
                          Text(
                            AppString.chronos,
                            textScaleFactor: 1.2,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.64)),
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
          ],
        ),*/
          ),
    );
  }
}
