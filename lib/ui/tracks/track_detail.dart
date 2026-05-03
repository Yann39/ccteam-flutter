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

import 'package:ccteam/models/event.dart';
import 'package:ccteam/models/record.dart';
import 'package:ccteam/providers/event_detail_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/record_list_provider.dart';
import 'package:ccteam/providers/track_detail_provider.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/utils/track_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrackDetail extends StatefulWidget {
  const TrackDetail({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TrackDetailState();
  }
}

class _TrackDetailState extends State<TrackDetail> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final TrackDetailProvider trackDetailProvider =
          Provider.of<TrackDetailProvider>(context, listen: false);
      if (trackDetailProvider.currentTrack != null) {
        final int trackId = trackDetailProvider.currentTrack!.id!;
        Provider.of<EventDetailProvider>(
          context,
          listen: false,
        ).fetchEventsByTrack(trackDetailProvider.currentTrack!);
        Provider.of<RecordListProvider>(
          context,
          listen: false,
        ).fetchTrackRecords(trackId);
      }
    });
  }

  Widget _recordsTable(RecordListProvider recordListProvider) {
    if (recordListProvider.trackRecords.length > 0) {
      return Container(
        decoration: CustomDecorations.cardLight,
        child: Table(
          columnWidths: {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            horizontalInside: BorderSide(
              color: Colors.black.withAlpha(76),
              width: 1,
            ),
            verticalInside: BorderSide(
              color: Colors.black.withAlpha(76),
              width: 1,
            ),
          ),
          children: [
            for (Record rec in recordListProvider.trackRecords)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 12.0,
                    ),
                    child: Text(
                      "${rec.member!.firstName} ${rec.member!.lastName}",
                      style: TextStyle(color: Colors.black.withAlpha(192)),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    AppDateUtils.toLapTimeString(rec.lapTime) ?? "",
                    style: TextStyle(color: Colors.black.withAlpha(192)),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    rec.recordDate != null
                        ? (AppDateUtils.convertToString(
                              rec.recordDate!,
                              "dd/MM/yyyy",
                            ) ??
                            "")
                        : "",
                    style: TextStyle(color: Colors.black.withAlpha(192)),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: 10,
                    child:
                        rec.conditions == "dry"
                            ? Icon(
                              Icons.wb_sunny,
                              color: Colors.black.withAlpha(128),
                              size: 15,
                            )
                            : Icon(
                              CustomIcons.rain,
                              color: Colors.black.withAlpha(128),
                              size: 15,
                            ),
                  ),
                ],
              ),
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

  Widget _eventsTable(EventDetailProvider eventDetailProvider) {
    if (eventDetailProvider.allEvents.isNotEmpty) {
      return Container(
        decoration: CustomDecorations.cardLight,
        child: Table(
          columnWidths: {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            horizontalInside: BorderSide(
              color: Colors.black.withValues(alpha: 0.3),
              width: 1,
            ),
            verticalInside: BorderSide(
              color: Colors.black.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          children: [
            for (Event ev in eventDetailProvider.allEvents)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 12.0,
                    ),
                    child: Text(
                      ev.fullDate,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    ev.organizer ?? "",
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "${StringUtils.formatPrice(ev.price ?? 0.0)} €",
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "${ev.participants?.length ?? 0}",
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
  }

  Widget build(BuildContext context) {
    final RecordListProvider _recordListProvider =
        Provider.of<RecordListProvider>(context, listen: true);
    final TrackDetailProvider _trackDetailProvider =
        Provider.of<TrackDetailProvider>(context, listen: true);
    final EventDetailProvider _eventDetailProvider =
        Provider.of<EventDetailProvider>(context, listen: true);
    final LoginProvider _loginProvider =
        Provider.of<LoginProvider>(context, listen: false);

    // if currentTrack is null (e.g. after session expiration), don't render content
    if (_trackDetailProvider.currentTrack == null) {
      return Scaffold(
        body: Container(decoration: CustomDecorations.mainContent),
      );
    }

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
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final FlexibleSpaceBarSettings settings =
                      context
                          .dependOnInheritedWidgetOfExactType<
                            FlexibleSpaceBarSettings
                          >()!;
                  final double deltaExtent =
                      settings.maxExtent - settings.minExtent;
                  final double t = (1.0 -
                          (settings.currentExtent - settings.minExtent) /
                              deltaExtent)
                      .clamp(0.0, 1.0);

                  // t est 0.0 quand complètement déployé, 1.0 quand complètement replié
                  return FlexibleSpaceBar(
                    title: Text(
                      _trackDetailProvider.currentTrack != null
                          ? _trackDetailProvider.currentTrack!.name!
                          : "",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows:
                            t < 0.5
                                ? [
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 3.0,
                                    color: Colors.black,
                                  ),
                                ]
                                : null,
                      ),
                    ),
                    background: Stack(
                      alignment: Alignment.bottomLeft,
                      fit: StackFit.expand,
                      children: <Widget>[
                        _trackDetailProvider.currentTrack != null
                            ? Image.asset(
                              TrackUtils.trackCoverImageUrlFromName(
                                _trackDetailProvider.currentTrack!.name,
                              ),
                              fit: BoxFit.fitWidth,
                            )
                            : Container(),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.0, 0.5),
                              end: Alignment(0.0, -0.5),
                              colors: <Color>[
                                Colors.black.withAlpha(179),
                                Colors.black.withAlpha(76),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                        _trackDetailProvider.currentTrack !=
                                                null
                                            ? Text(
                                              AppDateUtils.toLapTimeString(
                                                    _trackDetailProvider
                                                        .currentTrack!
                                                        .lapRecord,
                                                  ) ??
                                                  "",
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                            : Container(),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                        _trackDetailProvider.currentTrack !=
                                                null
                                            ? Text(
                                              "${_trackDetailProvider.currentTrack!.distance}",
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                                _trackDetailProvider.currentTrack != null
                                    ? Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        onTap:
                                            () => AppUtils.launchURL(
                                              "geo:${_trackDetailProvider.currentTrack!.latitude},${_trackDetailProvider.currentTrack!.longitude}",
                                            ),
                                        child: Container(
                                          height: 100,
                                          margin: EdgeInsets.all(4.0),
                                          padding: EdgeInsets.all(8.0),
                                          decoration:
                                              CustomDecorations.cardLight,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Icon(
                                                Icons.place,
                                                size: 30,
                                                color: Colors.red[700],
                                              ),
                                              Text(
                                                "${_trackDetailProvider.currentTrack!.latitude}",
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                "${_trackDetailProvider.currentTrack!.longitude}",
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    : Container(),
                              ],
                            ),
                            Divider(color: Colors.white),
                            SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.description,
                                  size: 16,
                                  color: Colors.black.withAlpha(204),
                                ),
                                SizedBox(width: 5.0),
                                Text(
                                  AppString.trackEvents,
                                  textScaler: TextScaler.linear(1.2),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black.withAlpha(204),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            _eventsTable(_eventDetailProvider),
                            SizedBox(height: 10),
                            if (_loginProvider.isMember) ...[
                              Divider(color: Colors.white),
                              SizedBox(height: 10),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.group,
                                    size: 18,
                                    color: Colors.black.withAlpha(163),
                                  ),
                                  SizedBox(width: 5.0),
                                  Text(
                                    AppString.chronos,
                                    textScaler: TextScaler.linear(1.2),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black.withAlpha(163),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              _recordsTable(_recordListProvider),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 400),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),

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
                    textScaler: TextScaler.linear(2),
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
                            textScaler: TextScaler.linear(1.2),
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
                            textScaler: TextScaler.linear(1.2),
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.64)),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _recordsTable(_recordListProvider),
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
