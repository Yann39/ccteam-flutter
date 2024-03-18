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
import 'package:ccteam/models/record.dart';
import 'package:ccteam/providers/record_provider.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberChronos extends StatefulWidget {
  final Member member;

  const MemberChronos({Key key, this.member}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MemberChronosState();
  }
}

class _MemberChronosState extends State<MemberChronos> {
  @override
  void initState() {
    super.initState();
    Provider.of<RecordProvider>(context, listen: false)
        .fetchMemberRecords(widget.member.id);
  }

  /// Method that launches the Add Record screen and awaits the result from Navigator.pop
  _navigateToAddRecordScreen(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final _result = await Navigator.pushNamed(context, '/addEditRecord');

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (_result != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$_result")));
    }
  }

  Widget _recordsTable(RecordProvider recordProvider) {
    if (recordProvider.memberRecords != null &&
        recordProvider.memberRecords.length > 0) {
      return Container(
        decoration: CustomDecorations.cardLight,
        child: Table(
          columnWidths: {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1)
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
              horizontalInside:
                  BorderSide(color: Colors.black.withOpacity(0.3), width: 1),
              verticalInside:
                  BorderSide(color: Colors.black.withOpacity(0.3), width: 1)),
          children: [
            for (Record rec in recordProvider.memberRecords)
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 12.0),
                  child: Text(
                    rec.track.name,
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
                        ? Icon(Icons.wb_sunny,
                            color: Colors.black.withOpacity(0.6), size: 15)
                        : Icon(CustomIcons.rain,
                            color: Colors.black.withOpacity(0.6), size: 15))
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

  Widget build(BuildContext context) {
    final RecordProvider _recordProvider =
        Provider.of<RecordProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.myChronos),
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
            //_recordsTable(_recordProvider),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    _recordProvider.fetchMemberRecords(widget.member.id),
                child: LoadingContent(
                  emptyText: AppString.eventsNotFound,
                  loadingStatus: _recordProvider.loadingStatus,
                  child: ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(height: 8.0),
                    itemCount: _recordProvider.memberRecords.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: CustomDecorations.cardFull,
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            //Icon(TrackUtils.trackIconFromName(_recordProvider.memberRecords[index].track.name), size: 38, color: Colors.red[700]),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    //Icon(Icons.location_on, size: 16, color: Colors.deepPurple),
                                    //SizedBox(width: 5.0),
                                    Text(
                                      _recordProvider
                                          .memberRecords[index].track.name,
                                      textScaleFactor: 1.3,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.event,
                                        size: 16, color: Colors.teal[700]),
                                    SizedBox(width: 5.0),
                                    Text(
                                      AppDateUtils.convertToString(
                                          _recordProvider
                                              .memberRecords[index].recordDate,
                                          'dd MMM yyyy'),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(CustomIcons.motorbike,
                                        size: 16, color: Colors.deepPurple),
                                    SizedBox(width: 5.0),
                                    Text(
                                      _recordProvider
                                          .memberRecords[index].member.bike,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.0, vertical: 0.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(4.0),
                                border: Border.all(color: Colors.white),
                              ),
                              child: Text(
                                AppDateUtils.toLapTimeString(_recordProvider
                                    .memberRecords[index].lapTime),
                                style: TextStyle(
                                    fontFamily: "AlarmClock",
                                    color: Colors.white),
                                textScaleFactor: 1.6,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        child: Icon(Icons.add),
        backgroundColor: Colors.red[700],
        onPressed: () {
          _navigateToAddRecordScreen(context);
        },
      ),
    );
  }
}
