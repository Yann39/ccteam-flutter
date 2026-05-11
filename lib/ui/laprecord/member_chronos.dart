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

import 'package:ccteam/models/record.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/record_creation_provider.dart';
import 'package:ccteam/providers/record_list_provider.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/utils/track_utils.dart';
import 'package:ccteam/widgets/info_banner.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:ccteam/widgets/restricted_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberChronos extends StatefulWidget {
  const MemberChronos({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MemberChronosState();
  }
}

class _MemberChronosState extends State<MemberChronos> {
  @override
  void initState() {
    super.initState();
  }

  /// Method that launches the Add Record screen and awaits the result from Navigator.pop
  _navigateToAddRecordScreen(BuildContext context) async {
    // set a new record to be created
    Provider.of<RecordCreationProvider>(context, listen: false).setRecordToEdit(new Record());
    final result = await Navigator.pushNamed(context, '/addEditRecord');
    if (result != null) {
      final _recordListProvider = Provider.of<RecordListProvider>(context, listen: false);
      final _loginProvider = Provider.of<LoginProvider>(context, listen: false);
      _recordListProvider.fetchMemberRecords(_loginProvider.loggedMember!.id!);
    }
  }

  Widget build(BuildContext context) {
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    if (!_loginProvider.isMember) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppString.myChronos),
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        ),
        body: Container(decoration: CustomDecorations.mainContent, child: RestrictedContent()),
      );
    }

    final RecordListProvider _recordListProvider = Provider.of<RecordListProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.myChronos),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: CustomDecorations.mainContent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const InfoBanner(message: AppString.myChronosHelp),
            const SizedBox(height: 8.0),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _recordListProvider.fetchMemberRecords(_loginProvider.loggedMember!.id!),
                child: LoadingContent(
                  defaultText: AppString.eventsNotFound,
                  emptyText: AppString.eventsNotFound,
                  loadingStatus: _recordListProvider.loadingStatus,
                  child: ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(height: 8.0),
                    itemCount: _recordListProvider.memberRecords.length,
                    itemBuilder: (context, index) {
                      final record = _recordListProvider.memberRecords[index];
                      return InkWell(
                        onTap: () async {
                          Provider.of<RecordCreationProvider>(context, listen: false).setRecordToEdit(record);
                          final result = await Navigator.pushNamed(context, '/addEditRecord');
                          if (result != null) {
                            _recordListProvider.fetchMemberRecords(_loginProvider.loggedMember!.id!);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: CustomDecorations.cardFull,
                          height: 91,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          TrackUtils.trackIconFromName(record.track!.name),
                                          size: 20,
                                          color: Colors.red[600],
                                        ),
                                        SizedBox(width: 8.0),
                                        Expanded(
                                          child: Text(
                                            record.track!.name!,
                                            textScaler: TextScaler.linear(1.3),
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.event, size: 16, color: Colors.teal[700]),
                                        SizedBox(width: 5.0),
                                        Text(
                                          AppDateUtils.convertToString(record.recordDate!, 'dd MMM yyyy') ?? "",
                                          style: TextStyle(color: Colors.white),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (TrackUtils.trackConditionIconData(record.conditions) != null) ...[
                                          SizedBox(width: 8.0),
                                          Icon(
                                            TrackUtils.trackConditionIconData(record.conditions),
                                            size: 18,
                                            color: TrackUtils.trackConditionColor(record.conditions),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Icon(CustomIcons.motorbike, size: 16, color: Colors.deepPurple),
                                        SizedBox(width: 5.0),
                                        Expanded(
                                          child: Text(
                                            record.bike != null
                                                ? "${StringUtils.capitalize(record.bike!.manufacturer ?? '')} ${record.bike!.modelName ?? ''}"
                                                : AppString.notDefined,
                                            style: TextStyle(color: Colors.white),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(color: Colors.white),
                                ),
                                child: Text(
                                  AppDateUtils.toLapTimeString(record.lapTime) ?? "",
                                  style: TextStyle(fontFamily: "AlarmClock", color: Colors.white),
                                  textScaler: TextScaler.linear(1.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.red[700],
        onPressed: () {
          _navigateToAddRecordScreen(context);
        },
      ),
    );
  }
}
