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

import 'package:ccteam/models/event.dart';
import 'package:ccteam/models/member.dart';
import 'package:ccteam/providers/event_creation_provider.dart';
import 'package:ccteam/providers/event_detail_provider.dart';
import 'package:ccteam/providers/event_list_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/member_detail_provider.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/utils/track_utils.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:ccteam/widgets/random_pattern_painter.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../../providers/record_list_provider.dart';

class EventDetail extends StatelessWidget {
  final Logger _log = new Logger('EventDetail');

  /// Navigate to the event creation form screen to edit the specified [event].
  _navigateToEditEventScreen(BuildContext context, Event event) async {
    // set the event to be edited
    // todo : need deep copy here else the reference will be updated even on error ?
    Provider.of<EventCreationProvider>(context, listen: false).setEventToEdit(event);

    // navigate to the event creation form screen
    Navigator.pushNamed(context, '/addEditEvent');
  }

  /// Navigate to the detail screen of the specified [member].
  void _navigateToMemberDetailScreen(BuildContext context, Member member) async {
    // fetch member records
    Provider.of<RecordListProvider>(context, listen: false).fetchMemberRecords(member.id!);
    // fetch the member to get complete data
    Provider.of<MemberDetailProvider>(context, listen: false)
        .fetchMember(member)
        .then(
          (value) => {
            // navigate to member detail screen
            Navigator.pushNamed(context, '/memberDetail'),
          },
        );
  }

  /// Display a confirmation popup when trying to delete an event.
  void _showDeleteEventConfirmation(BuildContext context, String value) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppString.confirmation),
        content: Text(value),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              final EventDetailProvider eventDetailProvider = Provider.of<EventDetailProvider>(context, listen: false);
              final EventListProvider eventListProvider = Provider.of<EventListProvider>(context, listen: false);
              // delete event
              final Event eventToDelete = eventDetailProvider.currentEvent;
              eventDetailProvider.deleteEvent(eventToDelete).then((value) {
                // remove event from the event list
                eventListProvider.removeEventFromList(eventToDelete);
                // back to event list (need to pop 2 times)
                Navigator.pop(context);
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

  /// Build the registration "card": a horizontal panel that shows the
  /// current participation state (icon + label) on the left and the
  /// appropriate toggle action on the right. Visually integrated with
  /// the stat cards (date / price / track / organiser) of the page.
  ///
  /// Asymmetric on purpose:
  ///  - not registered → filled green CTA "Je participe" (encourages action)
  ///  - registered     → outlined red "Se désister" (remains available but
  ///    doesn't shout; reduces the chance of an accidental cancellation)
  Widget _registrationCard(Event event, int memberId, EventDetailProvider provider) {
    final bool isRegistered = event.participants?.any((p) => p.member?.id == memberId) ?? false;

    final Color statusColor = isRegistered ? Colors.green[700]! : Colors.blueGrey[500]!;
    final IconData statusIcon = isRegistered ? Icons.check_circle_rounded : Icons.help_outline_rounded;
    final String statusTitle = isRegistered ? "Vous participez" : "Vous ne participez pas encore";
    final String statusSubtitle = isRegistered
        ? "Inscrit à cet événement"
        : "Inscrivez-vous pour rejoindre l'événement";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.blue[100],
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(25), spreadRadius: 0.5, blurRadius: 0.5, offset: const Offset(2, 2)),
        ],
      ),
      child: Row(
        children: <Widget>[
          // status indicator (icon in a soft circular halo)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor.withValues(alpha: 0.15)),
            child: Icon(statusIcon, color: statusColor, size: 24.0),
          ),
          const SizedBox(width: 10.0),
          // status text (title + small explanatory subtitle)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  statusTitle,
                  style: TextStyle(
                    color: Colors.black.withAlpha(204),
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Text(
                  statusSubtitle,
                  style: TextStyle(color: Colors.black.withAlpha(140), fontSize: 11.0, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          // action button — filled CTA when not registered, outlined
          // (less aggressive) when already registered
          isRegistered
              ? OutlinedButton.icon(
                  onPressed: () => provider.unregisterFromEvent(event, memberId),
                  icon: const Icon(Icons.event_busy, size: 16.0),
                  label: Text(AppString.eventUnregister),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[700],
                    side: BorderSide(color: Colors.red[700]!, width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: () => provider.registerToEvent(event, memberId),
                  icon: const Icon(Icons.event_available, size: 16.0),
                  label: Text(AppString.eventParticipated),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                    elevation: 1,
                  ),
                ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    _log.info("Building Event detail...");

    final EventDetailProvider _eventDetailProvider = Provider.of<EventDetailProvider>(context, listen: true);
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: true);

    // if currentEvent is null or empty (e.g. after session expiration), don't render content
    if (_eventDetailProvider.currentEvent.id == null) {
      return Scaffold(body: Container(decoration: CustomDecorations.mainContent));
    }

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          if (_loginProvider.isAdmin)
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _navigateToEditEventScreen(context, _eventDetailProvider.currentEvent),
              ),
            ),
          if (_loginProvider.isAdmin)
            IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: () => _showDeleteEventConfirmation(context, AppString.eventDeletionAreYouSure),
            ),
        ],
        title: Text(AppString.eventDetailScreenTitle),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: LoadingContent(
          loadingStatus: _eventDetailProvider.loadingStatus,
          defaultText: AppString.contentNotLoaded,
          emptyText: AppString.contentNotLoaded,
          child: ListView(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 12.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: <Widget>[
                        // procedural pattern background
                        Positioned.fill(
                          child: CustomPaint(
                            painter: RandomPatternPainter(
                              seed:
                                  _eventDetailProvider.currentEvent.id ??
                                  _eventDetailProvider.currentEvent.title?.hashCode ??
                                  0,
                            ),
                          ),
                        ),
                        // soft dark overlay at the bottom for text readability
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.22)],
                              ),
                            ),
                          ),
                        ),
                        // centered title
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              _eventDetailProvider.currentEvent.title ?? "",
                              textScaler: const TextScaler.linear(2),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    blurRadius: 4.0,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
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
                                  border: Border.all(color: Colors.white, width: 1.0),
                                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                  color: Colors.blue[100],
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(25),
                                      spreadRadius: 0.5,
                                      blurRadius: 0.5,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Icon(Icons.event, size: 38, color: Colors.blue[700]),
                                    Text(
                                      _eventDetailProvider.currentEvent.fullDate,
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
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 1.0),
                                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                  color: Colors.blue[100],
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(25),
                                      spreadRadius: 0.5,
                                      blurRadius: 0.5,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Icon(Icons.euro_symbol, size: 38, color: Colors.purple[700]),
                                    Text(
                                      _eventDetailProvider.currentEvent.price != null
                                          ? StringUtils.formatPrice(_eventDetailProvider.currentEvent.price!)
                                          : "",
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
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 1.0),
                                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                  color: Colors.blue[100],
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(25),
                                      spreadRadius: 0.5,
                                      blurRadius: 0.5,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Icon(
                                      TrackUtils.trackIconFromName(_eventDetailProvider.currentEvent.track?.name),
                                      size: 38,
                                      color: Colors.red[700],
                                    ),
                                    Text(
                                      _eventDetailProvider.currentEvent.track != null
                                          ? _eventDetailProvider.currentEvent.track!.name ?? ""
                                          : "",
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
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 1.0),
                                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                  color: Colors.blue[100],
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(25),
                                      spreadRadius: 0.5,
                                      blurRadius: 0.5,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Icon(Icons.perm_contact_calendar, size: 38, color: Colors.teal[700]),
                                    Text(
                                      _eventDetailProvider.currentEvent.organizer ?? "",
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
                        SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Icon(Icons.description, size: 16, color: Colors.black.withAlpha(163)),
                            SizedBox(width: 5.0),
                            Text(
                              AppString.description,
                              textScaler: TextScaler.linear(1.2),
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withAlpha(163)),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(_eventDetailProvider.currentEvent.description ?? ""),
                        SizedBox(height: 10),
                        if (_loginProvider.isMember) ...[
                          Divider(color: Colors.white),
                          SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Icon(Icons.group, size: 18, color: Colors.black.withAlpha(163)),
                              SizedBox(width: 5.0),
                              Text(
                                AppString.participants,
                                textScaler: TextScaler.linear(1.2),
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withAlpha(163)),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          (_eventDetailProvider.currentEvent.participants?.length ?? 0) > 0
                              ? SizedBox(
                                  height: 140,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _eventDetailProvider.currentEvent.participants!.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Column(
                                        children: <Widget>[
                                          InkWell(
                                            onTap: () => _navigateToMemberDetailScreen(
                                              context,
                                              _eventDetailProvider.currentEvent.participants![index].member!,
                                            ),
                                            child: Container(
                                              width: 80,
                                              height: 80,
                                              padding: EdgeInsets.all(2.0),
                                              margin: EdgeInsets.symmetric(horizontal: 12.0),
                                              decoration: ShapeDecoration(shape: CircleBorder(), color: Colors.white70),
                                              child:
                                                  _eventDetailProvider
                                                          .currentEvent
                                                          .participants![index]
                                                          .member!
                                                          .avatar !=
                                                      null
                                                  ? CircleAvatar(
                                                      backgroundColor: Colors.blue[100],
                                                      backgroundImage: MemoryImage(
                                                        base64Decode(
                                                          _eventDetailProvider
                                                              .currentEvent
                                                              .participants![index]
                                                              .member!
                                                              .avatar!,
                                                        ),
                                                      ),
                                                    )
                                                  : CircleAvatar(
                                                      backgroundColor: Colors.blue[100],
                                                      child: ShaderMask(
                                                        shaderCallback: (bounds) => LinearGradient(
                                                          begin: const FractionalOffset(0.0, 0.0),
                                                          end: const FractionalOffset(0.0, 1.0),
                                                          stops: [0.0, 1.0],
                                                          colors: [Colors.red[300]!, Colors.white],
                                                        ).createShader(bounds),
                                                        child: Icon(CustomIcons.pilot, size: 50),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          SizedBox(height: 5.0),
                                          Container(
                                            width: 80,
                                            child: Text(
                                              "${_eventDetailProvider.currentEvent.participants![index].member!.firstName} ${_eventDetailProvider.currentEvent.participants![index].member!.lastName}",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                )
                              : Text(AppString.noParticipant),
                          SizedBox(height: 16),
                          if (_loginProvider.loggedMember != null)
                            _registrationCard(
                              _eventDetailProvider.currentEvent,
                              _loginProvider.loggedMember!.id!,
                              _eventDetailProvider,
                            ),
                          SizedBox(height: 10),
                          Divider(color: Colors.white),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
