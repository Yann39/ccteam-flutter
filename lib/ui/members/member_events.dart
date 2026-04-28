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
import 'package:ccteam/providers/event_detail_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/member_detail_provider.dart';
import 'package:ccteam/ui/events/event_card.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberEvents extends StatefulWidget {
  const MemberEvents({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MemberEventsState();
  }
}

class _MemberEventsState extends State<MemberEvents> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final LoginProvider loginProvider = Provider.of<LoginProvider>(
        context,
        listen: false,
      );
      if (loginProvider.loggedMember != null) {
        Provider.of<MemberDetailProvider>(
          context,
          listen: false,
        ).fetchMember(loginProvider.loggedMember!);
      }
    });
  }

  /// Method that launches the Add Event screen and awaits the result from Navigator.pop
  _navigateToAddEventScreen(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final _result = await Navigator.pushNamed(context, '/addEditEvent');

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (_result != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$_result")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final MemberDetailProvider _memberDetailProvider =
        Provider.of<MemberDetailProvider>(context, listen: true);
    final LoginProvider loginProvider = Provider.of<LoginProvider>(
      context,
      listen: true,
    );

    Widget content;

    if (_memberDetailProvider.loadingStatus == LoadingStatus.loading) {
      content = Center(child: CircularProgressIndicator());
    } else if (_memberDetailProvider.loadingStatus == LoadingStatus.notLoaded) {
      content = Center(child: Text(AppString.contentNotLoaded));
    } else {
      final List<Event> memberEvents =
          _memberDetailProvider.currentMember?.eventMembers
              ?.map((em) => em.event!)
              .toList() ??
          [];

      final now = DateTime.now();
      final upcomingEvents =
          memberEvents
              .where(
                (e) =>
                    e.startDate!.isAfter(now) ||
                    DateUtils.isSameDay(e.startDate!, now),
              )
              .toList();
      final pastEvents =
          memberEvents
              .where(
                (e) =>
                    e.startDate!.isBefore(now) &&
                    !DateUtils.isSameDay(e.startDate!, now),
              )
              .toList();

      if (upcomingEvents.isEmpty && pastEvents.isEmpty) {
        content = Center(child: Text(AppString.trackNoEvent));
      } else {
        // Sort upcoming events by date ascending (closest first)
        upcomingEvents.sort((a, b) => a.startDate!.compareTo(b.startDate!));
        // Sort past events by date descending (most recent first)
        pastEvents.sort((a, b) => b.startDate!.compareTo(a.startDate!));

        content = ListView(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          children: [
            if (upcomingEvents.isNotEmpty) ...[
              _buildSectionHeader(AppString.upcomingEvents),
              ...upcomingEvents.map((event) => _buildEventItem(context, event)),
            ],
            if (pastEvents.isNotEmpty) ...[
              if (upcomingEvents.isNotEmpty) SizedBox(height: 16),
              _buildSectionHeader(AppString.pastEvents),
              ...pastEvents.map((event) => _buildEventItem(context, event)),
            ],
          ],
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.myTrackEvents),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (loginProvider.loggedMember != null) {
            await Provider.of<MemberDetailProvider>(
              context,
              listen: false,
            ).fetchMember(loginProvider.loggedMember!);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: CustomDecorations.mainContent,
          child: content,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.red[700],
        onPressed: () {
          _navigateToAddEventScreen(context);
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[600]!, Colors.blue[800]!],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 20, color: Colors.white),
              SizedBox(width: 12),
              Text(
                "$title",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, Event event) {
    return GestureDetector(
      onTap: () {
        Provider.of<EventDetailProvider>(
          context,
          listen: false,
        ).setCurrentEvent(event);
        Provider.of<EventDetailProvider>(
          context,
          listen: false,
        ).fetchEvent(event);
        Navigator.pushNamed(context, '/eventDetail');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: EventCard(event),
      ),
    );
  }
}
