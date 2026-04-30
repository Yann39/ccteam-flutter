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
import 'package:ccteam/models/member.dart';
import 'package:ccteam/models/membership_fee.dart';
import 'package:ccteam/models/record.dart';
import 'package:ccteam/models/track.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/member_creation_provider.dart';
import 'package:ccteam/providers/member_detail_provider.dart';
import 'package:ccteam/providers/member_list_provider.dart';
import 'package:ccteam/providers/record_list_provider.dart';
import 'package:ccteam/providers/record_list_provider.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../../providers/track_detail_provider.dart';
import '../../utils/track_utils.dart';

class MemberDetail extends StatelessWidget {
  final Logger _log = new Logger('MemberDetail');

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

  Widget _recordsTable(RecordListProvider recordListProvider) {
    if (recordListProvider.memberRecords.length > 0) {
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
            for (Record rec in recordListProvider.memberRecords)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 12.0,
                    ),
                    child: Text(
                      rec.track!.name ?? "",
                      style: TextStyle(color: Colors.black.withAlpha(204)),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    rec.recordDate != null
                        ? AppDateUtils.convertToString(
                          rec.recordDate!,
                          "dd/MM/yyyy",
                        )!
                        : "",
                    style: TextStyle(color: Colors.black.withAlpha(204)),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    AppDateUtils.toLapTimeString(rec.lapTime) ?? "",
                    style: TextStyle(
                      color: Colors.black.withAlpha(255),
                      fontFamily: "AlarmClock",
                      letterSpacing: -1,
                    ),
                    textScaler: TextScaler.linear(1),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: 10,
                    child:
                        rec.conditions == "dry"
                            ? Icon(
                              Icons.wb_sunny,
                              color: Colors.black.withAlpha(153),
                              size: 15,
                            )
                            : Icon(
                              CustomIcons.rain,
                              color: Colors.black.withAlpha(153),
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
        child: Text(AppString.memberNoChrono),
      );
    }
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

    // if currentMember is null (e.g. after session expiration), don't render content
    if (_memberDetailProvider.currentMember == null) {
      return Scaffold(
        body: Container(decoration: CustomDecorations.mainContent),
      );
    }

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
                  Text(
                    AppString.moto,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  Container(
                    child: _memberDetailProvider.currentMember?.bikes != null && _memberDetailProvider.currentMember!.bikes!.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _memberDetailProvider.currentMember!.bikes!.map((bike) => Text(
                              "${bike.manufacturer?.toUpperCase()} ${bike.modelName}",
                              style: TextStyle(color: Colors.black.withAlpha(204)),
                              textScaler: TextScaler.linear(1.1),
                            )).toList(),
                          )
                        : Text(
                            AppString.notDefined,
                            style: TextStyle(color: Colors.black.withAlpha(204)),
                            textScaler: TextScaler.linear(1.1),
                          ),
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
      body: Container(
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

                    return FlexibleSpaceBar(
                      titlePadding: EdgeInsets.only(
                        left: 144.0 - t * 88,
                        bottom: 16.0,
                      ),
                      title: Text(
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
