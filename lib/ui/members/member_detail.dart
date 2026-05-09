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

import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ccteam/models/bike.dart';
import 'package:ccteam/models/member.dart';
import 'package:ccteam/models/membership_fee.dart';
import 'package:ccteam/models/record.dart';
import 'package:ccteam/models/track.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/member_creation_provider.dart';
import 'package:ccteam/providers/member_detail_provider.dart';
import 'package:ccteam/providers/member_list_provider.dart';
import 'package:ccteam/providers/record_list_provider.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:ccteam/widgets/restricted_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/track_detail_provider.dart';
import '../../utils/track_utils.dart';

class MemberDetail extends StatelessWidget {

  final ScrollController _scrollController = new ScrollController();

  // height of the Sliver app bar
  final double _expandedHeight = 202;

  // size (width and height) of an event timeline card
  final double _eventCardSize = 90;

  /// Display or hide the Sliver app bar title depending on the scroll offset
  bool get _showTitle {
    return _scrollController.hasClients &&
        _scrollController.offset > _expandedHeight - kToolbarHeight;
  }

  /// Navigate to the news creation form screen to edit the specified [member].
  void _navigateToEditMemberScreen(BuildContext context, Member member) async {
    // set the member to be edited
    Provider.of<MemberCreationProvider>(
      context,
      listen: false,
    ).setMemberToEdit(member);

    // navigate to the member creation form screen
    Navigator.pushNamed(context, '/addEditMember');
  }

  /// Navigate to the specified [track] detail screen.
  void _navigateToTrackDetailScreen(BuildContext context, Track track) async {
    // todo Maybe better to do it in detail screen init method instead of each time here ?
    Provider.of<TrackDetailProvider>(
      context,
      listen: false,
    ).setCurrentTrack(track);

    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final _result = await Navigator.pushNamed(context, '/trackDetail');

    // after the target screen returns a result, hide any previous snack bars and show the result
    if (_result != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$_result")));
    }
  }

  /// Display a confirmation popup when trying to delete a member
  _showDeleteMemberConfirmation(BuildContext context, String value) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(AppString.confirmation),
            content: Text(value),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  final MemberDetailProvider memberDetailProvider =
                      Provider.of<MemberDetailProvider>(context, listen: false);
                  final MemberListProvider memberListProvider =
                      Provider.of<MemberListProvider>(context, listen: false);
                  final Member memberToDelete =
                      memberDetailProvider.currentMember!;
                  // delete member
                  memberDetailProvider.deleteMember(memberToDelete).then((
                    value,
                  ) {
                    // remove member from the members list
                    memberListProvider.removeMemberFromList(memberToDelete);
                    // close this dialog
                    Navigator.pop(context);
                  });
                },
                child: Text(AppString.confirm),
              ),
              TextButton(
                onPressed: () {
                  // close this dialog
                  Navigator.pop(context);
                },
                child: Text(AppString.cancel),
              ),
            ],
          ),
    );
  }

  /// Race-plate-style badge for the rider number, adapted for the dark
  /// detail-page header: white border + white italic digits with a soft
  /// dark shadow so the number stays readable on top of the photo.
  Widget _buildRiderNumberPlate(int number) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
      child: Text(
        "#$number",
        style: TextStyle(
          color: Colors.white,
          fontSize: 13.0,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.3,
          height: 1.0,
          shadows: [
            Shadow(
              offset: const Offset(1.0, 1.0),
              blurRadius: 3.0,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  /// A small "loading" card that visually replaces the records table
  /// while the data is being fetched.
  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28.0),
      decoration: CustomDecorations.cardLight,
      child: Center(
        child: SizedBox(
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          ),
        ),
      ),
    );
  }

  Widget _recordsTable(RecordListProvider recordListProvider) {
    if (recordListProvider.loadingStatus == LoadingStatus.loading) {
      return _buildLoadingCard();
    }
    if (recordListProvider.memberRecords.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12.0),
        decoration: CustomDecorations.cardLight,
        child: Text(AppString.memberNoChrono),
      );
    }

    // sort by record date desc (most recent first); records without a date go last
    final List<Record> records =
        List<Record>.of(recordListProvider.memberRecords)
          ..sort((a, b) {
            final DateTime? aDate = a.recordDate;
            final DateTime? bDate = b.recordDate;
            if (aDate == null && bDate == null) return 0;
            if (aDate == null) return 1;
            if (bDate == null) return -1;
            return bDate.compareTo(aDate);
          });

    return Container(
      decoration: CustomDecorations.cardLight,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < records.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.black.withValues(alpha: 0.10),
              ),
            _buildMemberRecordRow(records[i]),
          ],
        ],
      ),
    );
  }

  /// Format a [Bike] for display in a chrono row, e.g.
  /// "KAWASAKI ZX-10R". Returns null if neither manufacturer nor model is known.
  String? _recordBikeText(Bike? bike) {
    if (bike == null) return null;
    final String manufacturer = (bike.manufacturer ?? "").trim();
    final String model = (bike.modelName ?? "").trim();
    final String text = [
      if (manufacturer.isNotEmpty) manufacturer.toUpperCase(),
      if (model.isNotEmpty) model,
    ].join(" ");
    return text.isEmpty ? null : text;
  }

  /// Small icon + text pair used for chrono row metadata (bike, date).
  Widget _recordMetaItem(IconData icon, Color iconColor, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 11.0, color: iconColor),
        const SizedBox(width: 3.0),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.7),
              fontSize: 12.0,
              height: 1.1,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  /// Build a single chrono row in the same style as the track-detail
  /// chronos list: blue lap-time pill on the left (digital font), track
  /// name + bike + date in the middle, weather icon on the right.
  Widget _buildMemberRecordRow(Record record) {
    final String lapTime =
        AppDateUtils.toLapTimeString(record.lapTime) ?? "";
    final String trackName = record.track?.name ?? "—";
    final String dateStr = record.recordDate != null
        ? (AppDateUtils.convertToString(record.recordDate!, "dd/MM/yyyy") ?? "")
        : "";
    final String? bikeStr = _recordBikeText(record.bike);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // lap time pill (digital/LCD-style font)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Text(
              lapTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontFamily: "AlarmClock",
                letterSpacing: -1.0,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          // track name (with shape icon) on top, bike + date below
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      TrackUtils.trackIconFromName(trackName),
                      size: 16.0,
                      color: Colors.red[700],
                    ),
                    const SizedBox(width: 6.0),
                    Flexible(
                      child: Text(
                        trackName,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                if (bikeStr != null || dateStr.isNotEmpty) ...[
                  const SizedBox(height: 2.0),
                  Wrap(
                    spacing: 10.0,
                    runSpacing: 2.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      if (bikeStr != null)
                        _recordMetaItem(
                          CustomIcons.motorbike,
                          Colors.deepPurple,
                          bikeStr,
                        ),
                      if (dateStr.isNotEmpty)
                        _recordMetaItem(
                          Icons.calendar_today,
                          Colors.purple[700]!,
                          dateStr,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6.0),
          // weather icon on the right
          Icon(
            record.conditions == "dry" ? Icons.wb_sunny : CustomIcons.rain,
            color: record.conditions == "dry"
                ? Colors.orange[600]
                : Colors.blueGrey[400],
            size: 16.0,
          ),
        ],
      ),
    );
  }

  Widget _feesTable(BuildContext context, MemberDetailProvider memberDetailProvider, bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (memberDetailProvider.currentMember!.membershipFees != null && memberDetailProvider.currentMember!.membershipFees!.length > 0)
          Container(
            decoration: CustomDecorations.cardLight,
            child: Table(
              columnWidths: {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: isAdmin ? FlexColumnWidth(1) : FlexColumnWidth(0),
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
                for (MembershipFee fee in memberDetailProvider.currentMember!.membershipFees!)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                        child: Text(
                          "${fee.year}",
                          style: TextStyle(color: Colors.black.withAlpha(204), fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        "${fee.amount} €",
                        style: TextStyle(color: Colors.black.withAlpha(204)),
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        fee.paid == true ? Icons.check_circle : Icons.cancel,
                        color: fee.paid == true ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      if (isAdmin)
                        IconButton(
                          icon: Icon(Icons.edit, size: 18),
                          onPressed: () {
                            Navigator.pushNamed(context, '/addEditMembershipFee', arguments: {'member': memberDetailProvider.currentMember, 'fee': fee});
                          },
                        ),
                    ],
                  ),
              ],
            ),
          )
        else
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: CustomDecorations.cardLight,
            child: Text(AppString.notDefined),
          ),
        if (isAdmin)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/addEditMembershipFee', arguments: {'member': memberDetailProvider.currentMember});
              },
              icon: Icon(Icons.add),
              label: Text("Ajouter une cotisation"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _eventsTimeline(MemberDetailProvider memberDetailProvider) {
    if (memberDetailProvider.currentMember!.eventMembers != null &&
        memberDetailProvider.currentMember!.eventMembers!.length > 0) {
      return SizedBox(
        height: 142,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: memberDetailProvider.currentMember!.eventMembers!.length,
          itemBuilder: (BuildContext context, int index) {
            // if list view is not large enough, add padding so it fills the whole screen width
            final double pad =
                index >=
                        memberDetailProvider
                                .currentMember!
                                .eventMembers!
                                .length -
                            1
                    ? max(
                      MediaQuery.of(context).size.width -
                          ((_eventCardSize + 16) *
                              memberDetailProvider
                                  .currentMember!
                                  .eventMembers!
                                  .length) -
                          16,
                      0,
                    )
                    : 0.0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 36.0),
                      margin: EdgeInsets.only(right: pad),
                      child: InkWell(
                        onTap:
                            () => _navigateToTrackDetailScreen(
                              context,
                              memberDetailProvider
                                  .currentMember!
                                  .eventMembers![index]
                                  .event!
                                  .track!,
                            ),
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
                                TrackUtils.trackIconFromName(
                                  memberDetailProvider
                                      .currentMember!
                                      .eventMembers![index]
                                      .event!
                                      .track!
                                      .name,
                                ),
                                size: 30,
                                color: Colors.red[700],
                              ),
                              Text(
                                "${memberDetailProvider.currentMember!.eventMembers![index].event!.track!.name}",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withAlpha(204),
                                  height: 1,
                                ),
                                maxLines: 2,
                              ),
                              Text(
                                "${memberDetailProvider.currentMember!.eventMembers![index].event!.organizer}",
                                textScaler: TextScaler.linear(0.7),
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
                      child: Container(height: 2, color: Colors.red[700]),
                    ),
                    if (memberDetailProvider
                                .currentMember!
                                .eventMembers!
                                .length >
                            1 &&
                        index !=
                            memberDetailProvider
                                    .currentMember!
                                    .eventMembers!
                                    .length -
                                1)
                      Positioned(
                        top: 6.0,
                        left: _eventCardSize,
                        child: Icon(Icons.arrow_left, color: Colors.red[700]),
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
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6.0),
                                    topRight: Radius.circular(6.0),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "${AppDateUtils.convertToString(memberDetailProvider.currentMember!.eventMembers![index].event!.startDate!, "MMM yy")}",
                                    textScaler: TextScaler.linear(0.75),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: CustomDecorations.cardBody,
                                  child: Center(
                                    child: Text(
                                      "${AppDateUtils.convertToString(memberDetailProvider.currentMember!.eventMembers![index].event!.startDate!, "dd")}",
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
    final MemberDetailProvider _memberDetailProvider =
        Provider.of<MemberDetailProvider>(context, listen: true);
    final RecordListProvider _recordListProvider =
        Provider.of<RecordListProvider>(context, listen: true);
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final bool _isAdmin = _loginProvider.loggedMember?.role == MemberRole.ROLE_ADMIN;
    final bool _isOwnProfile =
        _memberDetailProvider.currentMember?.id ==
        _loginProvider.loggedMember?.id;
    final bool _canView = _loginProvider.isMember || _isOwnProfile;

    // if currentMember is null (e.g. after session expiration), don't render content
    if (_memberDetailProvider.currentMember == null) {
      return Scaffold(
        body: Container(decoration: CustomDecorations.mainContent),
      );
    }

    // Moto info: shows the "current" bike with a caret next to it; if the
    // member has more than one bike, tapping the caret expands the list of
    // other bikes underneath.
    final _motoInfo = _BikesInfo(
      bikes: _memberDetailProvider.currentMember?.bikes ?? <Bike>[],
    );

    // Board role info: only shown when the member holds an executive
    // board position (Président, Trésorier, …).
    final BoardRole? _boardRole =
        _memberDetailProvider.currentMember?.boardRole;
    final Widget? _boardRoleInfo = _boardRole == null
        ? null
        : MergeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Rôle au bureau",
                          style: TextStyle(color: Colors.red[700]),
                        ),
                        Text(
                          _boardRole.localizedLabel(
                            Localizations.localeOf(context).languageCode,
                          ),
                          style: TextStyle(
                            color: Colors.black.withAlpha(204),
                            fontWeight: FontWeight.w600,
                          ),
                          textScaler: const TextScaler.linear(1.1),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 72.0,
                    child: Icon(
                      Icons.workspace_premium,
                      color: Colors.amber[700],
                    ),
                  ),
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
                  Text(
                    AppString.mobile,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  Container(
                    child: Text(
                      "${_memberDetailProvider.currentMember?.phone}",
                      style: TextStyle(color: Colors.black.withAlpha(204)),
                      textScaler: TextScaler.linear(1.1),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 72.0,
              child: IconButton(
                icon: Icon(Icons.phone),
                color: Colors.green,
                onPressed: () {
                  AppUtils.launchURL(
                    "tel:${_memberDetailProvider.currentMember?.phone}",
                  );
                },
              ),
            ),
            SizedBox(
              width: 72.0,
              child: IconButton(
                icon: Icon(Icons.sms),
                color: Colors.blue,
                onPressed: () {
                  AppUtils.launchURL(
                    "sms:${_memberDetailProvider.currentMember?.phone}",
                  );
                },
              ),
            ),
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
                  Text(
                    AppString.email,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  Container(
                    child: Text(
                      "${_memberDetailProvider.currentMember?.email}",
                      style: TextStyle(color: Colors.black.withAlpha(204)),
                      textScaler: TextScaler.linear(1.1),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 72.0,
              child: IconButton(
                icon: Icon(Icons.mail),
                color: Colors.purple.withAlpha(153),
                onPressed: () {
                  AppUtils.mailTo(_memberDetailProvider.currentMember!.email!);
                },
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body:
          !_canView
              ? Container(
                decoration: CustomDecorations.mainContent,
                child: RestrictedContent(),
              )
              : Container(
                decoration: CustomDecorations.mainContent,
                child: LoadingContent(
          loadingStatus: _memberDetailProvider.loadingStatus,
          defaultText: AppString.contentNotLoaded,
          emptyText: AppString.contentNotLoaded,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                expandedHeight: _expandedHeight,
                title:
                    _showTitle
                        ? Text(
                          _memberDetailProvider.currentMember!.firstName! +
                              ' ' +
                              _memberDetailProvider.currentMember!.lastName!,
                          overflow: TextOverflow.ellipsis,
                        )
                        : null,
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

                    // Vertical lift that peaks at the middle of the
                    // collapse animation: the title arcs UPWARD over the
                    // avatar circle instead of cutting straight through
                    // it. With a lift of 50, the trajectory stays outside
                    // the 50-px avatar radius for the entire transition.
                    final double arcLift = sin(t * pi) * 50;

                    return FlexibleSpaceBar(
                      titlePadding: EdgeInsets.only(
                        left: 144.0 - t * 88,
                        bottom: 16.0 + arcLift,
                      ),
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "${_memberDetailProvider.currentMember!.firstName} ${_memberDetailProvider.currentMember!.lastName}",
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
                          if (_memberDetailProvider
                                  .currentMember!.riderNumber !=
                              null)
                            ClipRect(
                              child: Align(
                                alignment: Alignment.topLeft,
                                heightFactor:
                                    (1.0 - t * 2).clamp(0.0, 1.0),
                                child: Opacity(
                                  opacity: (1.0 - t * 2).clamp(0.0, 1.0),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(top: 4.0),
                                    child: _buildRiderNumberPlate(
                                      _memberDetailProvider
                                          .currentMember!.riderNumber!,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      background: Stack(
                        alignment: Alignment.bottomLeft,
                        fit: StackFit.expand,
                        children: <Widget>[
                          CachedNetworkImage(
                            placeholder:
                                (context, url) => Center(
                                  child: SizedBox(
                                    child: CircularProgressIndicator(),
                                    height: 20.0,
                                    width: 20.0,
                                  ),
                                ),
                            imageUrl:
                                'https://images.freeimages.com/images/small-previews/e71/frog-1371919.jpg',
                            fit: BoxFit.fitWidth,
                          ),
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
                          Positioned(
                            bottom: 15,
                            left: 15,
                            child: Container(
                              decoration: ShapeDecoration(
                                shape: CircleBorder(),
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.all(3.0),
                              child:
                                  _memberDetailProvider.currentMember!.avatar !=
                                          null
                                      ? CircleAvatar(
                                        radius: 50,
                                        backgroundImage: MemoryImage(
                                          base64Decode(
                                            _memberDetailProvider
                                                .currentMember!
                                                .avatar!,
                                          ),
                                        ),
                                      )
                                      : CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.blue[100],
                                        child: ShaderMask(
                                          blendMode: BlendMode.srcATop,
                                          shaderCallback:
                                              (bounds) => LinearGradient(
                                                begin: const FractionalOffset(
                                                  0.0,
                                                  0.0,
                                                ),
                                                end: const FractionalOffset(
                                                  0.0,
                                                  1.0,
                                                ),
                                                stops: [0.0, 1.0],
                                                colors: [
                                                  Colors.red[700]!,
                                                  Colors.blue[700]!,
                                                ],
                                              ).createShader(bounds),
                                          child: Icon(
                                            CustomIcons.pilot,
                                            size: 75,
                                          ),
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed:
                        () => _navigateToEditMemberScreen(
                          context,
                          _memberDetailProvider.currentMember!,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    onPressed:
                        () => _showDeleteMemberConfirmation(
                          context,
                          AppString.memberDeletionAreYouSure,
                        ),
                  ),
                ],
              ),
              SliverPadding(
                padding: EdgeInsets.all(8.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    ConstrainedBox(
                      // set minimum height : screen height - app bar height - status bar height - padding
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.of(context).size.height -
                            kToolbarHeight -
                            MediaQuery.of(context).padding.top -
                            16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.black.withAlpha(204),
                              ),
                              SizedBox(width: 5.0),
                              Text(
                                AppString.personalInformation,
                                textScaler: TextScaler.linear(1.2),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withAlpha(204),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: CustomDecorations.cardLight,
                            child: Column(
                              children: <Widget>[
                                if (_boardRoleInfo != null) ...[
                                  _boardRoleInfo,
                                  Divider(
                                    color: Colors.black.withAlpha(204),
                                    height: 5,
                                  ),
                                ],
                                _motoInfo,
                                Divider(
                                  color: Colors.black.withAlpha(204),
                                  height: 5,
                                ),
                                _mobileInfo,
                                Divider(
                                  color: Colors.black.withAlpha(204),
                                  height: 5,
                                ),
                                _emailInfo,
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.event,
                                size: 16,
                                color: Colors.black.withAlpha(204),
                              ),
                              SizedBox(width: 5.0),
                              Text(
                                AppString.rides,
                                textScaler: TextScaler.linear(1.2),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withAlpha(204),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          _eventsTimeline(_memberDetailProvider),
                          SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.timer,
                                size: 16,
                                color: Colors.black.withAlpha(204),
                              ),
                              SizedBox(width: 5.0),
                              Text(
                                AppString.chronos,
                                textScaler: TextScaler.linear(1.2),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withAlpha(204),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          _recordsTable(_recordListProvider),
                          SizedBox(height: 15),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.payment,
                                size: 16,
                                color: Colors.black.withAlpha(204),
                              ),
                              SizedBox(width: 5.0),
                              Text(
                                "Cotisations",
                                textScaler: TextScaler.linear(1.2),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withAlpha(204),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          _feesTable(context, _memberDetailProvider, _isAdmin),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small block that displays a member's bikes in the detail page:
/// the "current" bike on the first line with a caret if the member has
/// other bikes, and — when the caret is tapped — the list of other bikes
/// expanded just below.
class _BikesInfo extends StatefulWidget {
  final List<Bike> bikes;

  const _BikesInfo({Key? key, required this.bikes}) : super(key: key);

  @override
  State<_BikesInfo> createState() => _BikesInfoState();
}

class _BikesInfoState extends State<_BikesInfo> {
  bool _expanded = false;

  String _bikeLabel(Bike bike) =>
      "${bike.manufacturer?.toUpperCase() ?? ""} ${bike.modelName ?? ""}"
          .trim();

  @override
  Widget build(BuildContext context) {
    final List<Bike> bikes = widget.bikes;
    final Bike? currentBike = bikes.isEmpty
        ? null
        : bikes.firstWhere(
            (b) => b.current ?? false,
            orElse: () => bikes.first,
          );
    final List<Bike> otherBikes =
        bikes.where((b) => b.id != currentBike?.id).toList();

    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppString.moto,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                      // current bike + caret on the same line
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              currentBike != null
                                  ? _bikeLabel(currentBike)
                                  : AppString.notDefined,
                              style: TextStyle(
                                color: Colors.black.withAlpha(204),
                                fontWeight: FontWeight.normal,
                              ),
                              textScaler: const TextScaler.linear(1.1),
                            ),
                          ),
                          if (otherBikes.isNotEmpty)
                            InkWell(
                              onTap: () => setState(
                                () => _expanded = !_expanded,
                              ),
                              borderRadius: BorderRadius.circular(20.0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                  vertical: 2.0,
                                ),
                                child: AnimatedRotation(
                                  turns: _expanded ? 0.5 : 0.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.expand_more,
                                    color: Colors.black.withAlpha(160),
                                    size: 22.0,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 72.0,
                  child: Icon(
                    CustomIcons.motorbike,
                    color: Colors.red[700]!.withAlpha(204),
                  ),
                ),
              ],
            ),
            // animated reveal of the other bikes when expanded
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topLeft,
              child: (_expanded && otherBikes.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: otherBikes
                            .map(
                              (bike) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2.0,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.circle,
                                      size: 5.0,
                                      color: Colors.black.withAlpha(140),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Text(
                                        _bikeLabel(bike),
                                        style: TextStyle(
                                          color: Colors.black.withAlpha(180),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
