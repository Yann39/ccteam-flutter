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
import 'package:ccteam/widgets/restricted_content.dart';
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
      if (loginProvider.isMember && loginProvider.loggedMember != null) {
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
    final LoginProvider loginProvider = Provider.of<LoginProvider>(
      context,
      listen: true,
    );

    if (!loginProvider.isMember) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppString.myTrackEvents),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: CustomDecorations.mainContent,
          child: RestrictedContent(),
        ),
      );
    }

    final MemberDetailProvider _memberDetailProvider =
        Provider.of<MemberDetailProvider>(context, listen: true);

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

      // Sort upcoming events by date ascending (closest first)
      upcomingEvents.sort((a, b) => a.startDate!.compareTo(b.startDate!));
      // Sort past events by date descending (most recent first)
      pastEvents.sort((a, b) => b.startDate!.compareTo(a.startDate!));

      content = ListView(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        children: [
          // upcoming: always show the section, even when empty
          _CollapsibleSection(
            title: AppString.upcomingEvents,
            initiallyExpanded: true,
            child: upcomingEvents.isEmpty
                ? _buildEmptyMessage(AppString.noUpcomingEvent)
                : Column(
                    children: upcomingEvents
                        .map((event) => _buildEventItem(context, event))
                        .toList(),
                  ),
          ),
          // past: only show the section if there is at least one past event;
          // collapsed by default
          if (pastEvents.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            _CollapsibleSection(
              title: AppString.pastEvents,
              initiallyExpanded: false,
              child: Column(
                children: pastEvents
                    .map((event) => _buildEventItem(context, event))
                    .toList(),
              ),
            ),
          ],
        ],
      );
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

  /// Italic placeholder shown inside an empty section (e.g. "Aucun
  /// événement à venir").
  Widget _buildEmptyMessage(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      child: Text(
        message,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.black.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

/// Collapsible section with a styled gradient header (matching the original
/// section header) and a chevron indicator. Tapping the header toggles the
/// visibility of [child].
class _CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const _CollapsibleSection({
    Key? key,
    required this.title,
    required this.child,
    this.initiallyExpanded = true,
  }) : super(key: key);

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Header (clickable to toggle)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _expanded = !_expanded),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
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
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.expand_more,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Body (animated collapse / expand)
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: _expanded ? widget.child : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
