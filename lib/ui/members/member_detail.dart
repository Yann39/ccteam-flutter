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
import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/models/record.dart';
import 'package:chachatte_team/providers/member_provider.dart';
import 'package:chachatte_team/providers/record_provider.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/custom_icons_icons.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
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

enum ConfirmDialogAction { yes, no }

const kExpandedHeight = 216.0;

class _MemberDetailState extends State<MemberDetail> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(() => setState(() {}));
    Provider.of<RecordProvider>(context, listen: false).fetchMemberRecords(widget.member.id);
  }

  bool get _showTitle {
    return _scrollController.hasClients && _scrollController.offset > kExpandedHeight - kToolbarHeight;
  }

  /// Method that launches the Edit Member screen and awaits the result from Navigator.pop
  _navigateToEditMemberScreen(BuildContext context, Member member) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final _result = await Navigator.pushNamed(context, '/addEditMember', arguments: member);

    // after the target screen returns a result, hide any previous snack bars and show the result
    if (_result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$_result")));
    }
  }

  /// Display a confirmation popup when trying to delete a member
  _showConfirmation(BuildContext context, String value) {
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
  _dialogueResult(BuildContext context, ConfirmDialogAction value) {
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

  /// get the right icon according to the specified [trackName]
  Icon getTrackIcon(String trackName) {
    if (trackName == 'Alès') {
      return Icon(CustomIcons.track_ales, color: Colors.red[700], size: 40);
    } else if (trackName == 'Bresse') {
      return Icon(CustomIcons.track_bresse, color: Colors.red[700], size: 25);
    } else if (trackName == 'Bourbonnais') {
      return Icon(CustomIcons.track_bourbonnais, color: Colors.red[700], size: 60);
    } else if (trackName == 'Carole') {
      return Icon(CustomIcons.track_carole, color: Colors.red[700], size: 55);
    } else if (trackName == 'Dijon-Prenois') {
      return Icon(CustomIcons.track_dijon_prenois, color: Colors.red[700], size: 25);
    } else if (trackName == 'La Ferté-Gaucher') {
      return Icon(CustomIcons.track_la_ferte_gaucher, color: Colors.red[700], size: 65);
    } else if (trackName == 'Le Mans') {
      return Icon(CustomIcons.track_le_mans, color: Colors.red[700], size: 70);
    } else if (trackName == 'Lédenon') {
      return Icon(CustomIcons.track_ledenon, color: Colors.red[700], size: 60);
    } else if (trackName == 'Magny-Cours') {
      return Icon(CustomIcons.track_magny_cours, color: Colors.red[700], size: 25);
    } else if (trackName == 'Vaison') {
      return Icon(CustomIcons.track_vaison, color: Colors.red[700], size: 45);
    } else {
      return Icon(CustomIcons.track_sample, color: Colors.red[700], size: 40);
    }
  }

  Widget build(BuildContext context) {
    final RecordProvider _recordProvider = Provider.of<RecordProvider>(context, listen: true);

    final motoInfo = MergeSemantics(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Moto", style: TextStyle(color: Colors.black54)),
                  Container(
                    child: Text(
                      widget.member.bike != null ? widget.member.bike : 'test',
                      style: TextStyle(color: Colors.white),
                      textScaleFactor: 1.2,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(width: 72.0, child: IconButton(icon: Icon(CustomIcons.motorbike), color: Colors.white, onPressed: () {}))
          ],
        ),
      ),
    );

    final mobileInfo = MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Mobile", style: TextStyle(color: Colors.black54)),
                  Container(
                    child: Text(
                      widget.member.phone != null ? widget.member.phone : 'test',
                      style: TextStyle(color: Colors.white),
                      textScaleFactor: 1.2,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(width: 72.0, child: IconButton(icon: Icon(Icons.phone), color: Colors.white, onPressed: () {})),
            SizedBox(width: 72.0, child: IconButton(icon: Icon(Icons.sms), color: Colors.white, onPressed: () {}))
          ],
        ),
      ),
    );

    final emailInfo = MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("E-mail", style: TextStyle(color: Colors.black54)),
                  Container(
                    child: Text(
                      widget.member.email != null ? widget.member.email : 'test',
                      style: TextStyle(color: Colors.white),
                      textScaleFactor: 1.2,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(width: 72.0, child: IconButton(icon: Icon(Icons.mail), color: Colors.white, onPressed: () {}))
          ],
        ),
      ),
    );

    return Scaffold(
      body: Container(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: kExpandedHeight,
              title: _showTitle
                  ? Text(
                      widget.member.firstName + ' ' + widget.member.lastName,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              flexibleSpace: _showTitle
                  ? null
                  : FlexibleSpaceBar(
                      title: _Title(
                        text: widget.member.firstName + ' ' + widget.member.lastName,
                        padding: EdgeInsets.only(left: 84, bottom: 40),
                      ),
                      background: Stack(
                        alignment: Alignment.bottomLeft,
                        children: <Widget>[
                          CachedNetworkImage(
                            placeholder: (context, url) => CircularProgressIndicator(),
                            imageUrl: 'https://images.freeimages.com/images/large-previews/e71/frog-1371919.jpg',
                          ),
                          Positioned(
                            bottom: 15,
                            left: 15,
                            child: Container(
                              decoration: ShapeDecoration(shape: CircleBorder(), color: Colors.white),
                              padding: EdgeInsets.all(3.0),
                              child: widget.member.avatar != null && widget.member.avatar.length > 0 ? CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage("${AppConstants.SERVER_ROOT_PATH}${AppConstants.SERVER_AVATAR_FOLDER}${widget.member.avatar}"),
                              ) : CircleAvatar(
                                  radius: 50,
                                backgroundColor: Colors.blue[100],
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    begin: const FractionalOffset(0.0, 0.0),
                                    end: const FractionalOffset(0.0, 1.0),
                                    stops: [0.0, 1.0],
                                    colors: [Colors.red[700], Colors.white],
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
                  tooltip: 'Edit',
                  onPressed: () => _navigateToEditMemberScreen(context, widget.member),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  tooltip: 'Delete',
                  onPressed: () => _showConfirmation(context, AppString.memberDeletionAreYouSure),
                )
              ],
            ),
            /*SliverPersistentHeader(
              pinned: true,
              floating: true,
              delegate: CustomSliverDelegate(
                expandedHeight: 216,
                hideTitleWhenExpanded: true,
                inkWell: InkWell(
                  onTap: () {
                    //_drawerProvider.loadImage(null);
                    Navigator.of(context).pushNamed('/editAvatar', arguments: widget.member);
                  },
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.blue[200],
                    backgroundImage: widget.member.avatar != null && widget.member.avatar.length > 0
                        ? NetworkImage("${AppConstants.SERVER_ROOT_PATH}${AppConstants.SERVER_AVATAR_FOLDER}${widget.member.avatar}")
                        : AssetImage("images/helmet-face.png"),
                  ),
                ),
              ),
            ),*/
            SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  SizedBox(height: 16.0),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[300], Colors.blue[500]],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: [0.0, 1.0],
                          ),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Column(
                          children: <Widget>[
                            motoInfo,
                            Divider(color: Colors.white, height: 5),
                            mobileInfo,
                            Divider(color: Colors.white, height: 5),
                            emailInfo,
                          ],
                        ),
                      ),
                      Positioned(
                        left: 75,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red[700],
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: Text("Informations", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  Stack(children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 16.0),
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[300], Colors.blue[500]],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: [0.0, 1.0],
                          ),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: _recordProvider.memberRecords != null && _recordProvider.memberRecords.length > 0 ? Table(
                          columnWidths: {0: FlexColumnWidth(3), 1: FlexColumnWidth(2), 2: FlexColumnWidth(2), 3: FlexColumnWidth(1)},
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          border: TableBorder(horizontalInside: BorderSide(color: Colors.white, width: 0.5)),
                          children: [
                            for (Record rec in _recordProvider.memberRecords)
                              TableRow(children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                                  child: Text(rec.track.name, style: TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                                  child: Text(DateUtils.toLapTime(rec.lapTime), style: TextStyle(color: Colors.white)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                                  child: Text(DateUtils.convertToString(rec.recordDate, "dd/MM/yyyy"), style: TextStyle(color: Colors.white)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                                  child: SizedBox(
                                      width: 10,
                                      child: rec.conditions == "dry" ? Icon(Icons.wb_sunny, color: Colors.white, size: 15) : Icon(CustomIcons.rain, color: Colors.white, size: 15)),
                                )
                              ])
                          ],
                        ) : Align(child: Text("Aucun chronos enregistrés", style: TextStyle(color: Colors.white),), alignment: Alignment.centerLeft,heightFactor: 2,)
                        /*DataTable(
                        dataRowHeight: 30,
                        columnSpacing: 16.0,
                        columns: <DataColumn>[
                          DataColumn(label: Text("Circuit")),
                          DataColumn(label: Text("Chrono")),
                          DataColumn(label: Text("Date")),
                          DataColumn(label: Text("Conditions")),
                        ],
                        rows: <DataRow>[
                          for (Record rec in _recordProvider.memberRecords)
                            DataRow(cells: <DataCell>[
                              DataCell(Text(rec.track.name, style: TextStyle(color: Colors.white))),
                              DataCell(Text(DateUtils.toLapTime(rec.lapTime), style: TextStyle(color: Colors.white))),
                              DataCell(Text(DateUtils.convertToString(rec.recordDate, "dd MMM yyyy"), style: TextStyle(color: Colors.white))),
                              DataCell(SizedBox(width: 10,child: rec.conditions == "dry" ? Icon(Icons.wb_sunny, color: Colors.white, size: 15) : Icon(Icons.wb_cloudy, color: Colors.white, size: 15)))
                            ])
                        ],
                      ),*/
                        ),
                    Positioned(
                      left: 75,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red[700],
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Chronos",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ]),
                  SizedBox(
                    height: 300,
                  ),
                  Text("TEST")
                ],
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[100], Colors.blue[300]],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
    );
  }
}

class CustomSliverDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final bool hideTitleWhenExpanded;
  final InkWell inkWell;

  CustomSliverDelegate({
    @required this.expandedHeight,
    this.hideTitleWhenExpanded = true,
    this.inkWell,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    print("SHRINKOFFSET : $shrinkOffset");
    final appBarSize = expandedHeight - shrinkOffset;
    final cardTopPosition = expandedHeight / 2 - shrinkOffset;
    final proportion = 2 - (expandedHeight / appBarSize);
    final percent = proportion < 0 || proportion > 1 ? 0.0 : proportion;
    return SizedBox(
      height: expandedHeight + expandedHeight / 2,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          SizedBox(
            height: appBarSize < kToolbarHeight ? kToolbarHeight : appBarSize,
            child: NestedScrollView(
                body: Text("fghjghj"),
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      actions: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit',
                          onPressed: () => {} /*_navigateToEditMemberScreen(context, widget.member)*/,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever),
                          tooltip: 'Delete',
                          onPressed: () => {} /*_showConfirmation(context, AppString.memberDeletionAreYouSure)*/,
                        )
                      ],
                      pinned: true,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      expandedHeight: 216,
                      title: Text("Yann Bailly"),
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          "Yann Bailly",
                          style: TextStyle(backgroundColor: Color(0x60000000)),
                        ),
                        background: CachedNetworkImage(
                          placeholder: (context, url) => CircularProgressIndicator(),
                          imageUrl: 'https://images.freeimages.com/images/small-previews/e71/frog-1371919.jpg',
                        ),
                      ),
                    ),
                  ];
                }),
          ),
          Positioned(
            top: cardTopPosition > 0 ? appBarSize - 80 : 0,
            child: Opacity(
              opacity: percent,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30 * percent),
                child: inkWell,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight + expandedHeight / 2;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class _Title extends StatelessWidget {
  const _Title({
    Key key,
    this.text,
    this.padding,
  }) : super(key: key);

  final String text;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final deltaExtent = settings.maxExtent - settings.minExtent;
    final t = (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent).clamp(0.0, 1.0) as double;
    final double scaleValue = Tween<double>(begin: 1.5, end: 1.0).transform(t);
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: constraints.maxWidth / scaleValue,
        child: Padding(
          padding: EdgeInsets.only(left: (scaleValue - 1) * (padding.left * (8.5 - scaleValue * 5)), bottom: (scaleValue - 1) * (padding.bottom * (8.5 - scaleValue * 5))),
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(backgroundColor: Color.fromARGB(((scaleValue - 1) * 200).toInt(), 0, 0, 0)),
          ),
        ),
      );
    });
  }
}
