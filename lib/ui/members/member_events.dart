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
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/ui/events/event_card.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/info_banner.dart';
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
      final LoginProvider loginProvider = Provider.of<LoginProvider>(context, listen: false);
      if (loginProvider.isMember && loginProvider.loggedMember != null) {
        Provider.of<MemberDetailProvider>(context, listen: false).fetchMember(loginProvider.loggedMember!);
      }
    });
  }

  /// Open the "S'inscrire à un roulage" screen, which lets the user
  /// register as a participant on an existing upcoming event. The
  /// SelectEventToJoin screen takes care of refreshing the logged
  /// member's data on success, so when we return here the events list
  /// already reflects the newly joined event.
  void _navigateToJoinEventScreen(BuildContext context) async {
    final _result = await Navigator.pushNamed(context, '/selectEventToJoin');
    if (_result != null) {
      Provider.of<MessageProvider>(context, listen: false).setMessage("$_result", MessageType.INFO);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LoginProvider loginProvider = Provider.of<LoginProvider>(context, listen: true);

    if (!loginProvider.isMember) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppString.myTrackEvents),
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        ),
        body: Container(decoration: CustomDecorations.mainContent, child: RestrictedContent()),
      );
    }

    final MemberDetailProvider _memberDetailProvider = Provider.of<MemberDetailProvider>(context, listen: true);

    Widget content;

    if (_memberDetailProvider.loadingStatus == LoadingStatus.loading) {
      content = Center(child: CircularProgressIndicator());
    } else if (_memberDetailProvider.loadingStatus == LoadingStatus.notLoaded) {
      content = Center(child: Text(AppString.contentNotLoaded));
    } else {
      final List<Event> memberEvents =
          _memberDetailProvider.currentMember?.eventMembers?.map((em) => em.event!).toList() ?? [];

      final now = DateTime.now();
      final upcomingEvents = memberEvents
          .where((e) => e.startDate!.isAfter(now) || DateUtils.isSameDay(e.startDate!, now))
          .toList();
      final pastEvents = memberEvents
          .where((e) => e.startDate!.isBefore(now) && !DateUtils.isSameDay(e.startDate!, now))
          .toList();

      // sort upcoming events by date ascending (closest first)
      upcomingEvents.sort((a, b) => a.startDate!.compareTo(b.startDate!));
      // sort past events by date descending (most recent first)
      pastEvents.sort((a, b) => b.startDate!.compareTo(a.startDate!));

      if (upcomingEvents.isEmpty && pastEvents.isEmpty) {
        // member is registered to no event at all
        content = _buildGlobalEmptyState();
      } else {
        content = ListView(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0 + MediaQuery.of(context).padding.bottom + 72.0),
          children: <Widget>[
            const InfoBanner(message: AppString.myEventsHelp),
            const SizedBox(height: 8.0),
            if (upcomingEvents.isNotEmpty)
              _CollapsibleSection(
                title: AppString.upcomingEvents,
                initiallyExpanded: true,
                child: Column(children: upcomingEvents.map((event) => _buildEventItem(context, event)).toList()),
              ),
            if (upcomingEvents.isNotEmpty && pastEvents.isNotEmpty) const SizedBox(height: 8.0),
            if (pastEvents.isNotEmpty)
              _CollapsibleSection(
                title: AppString.pastEvents,
                initiallyExpanded: upcomingEvents.isEmpty,
                past: true,
                child: Column(children: pastEvents.map((event) => _buildEventItem(context, event)).toList()),
              ),
          ],
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.myTrackEvents),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (loginProvider.loggedMember != null) {
            await Provider.of<MemberDetailProvider>(context, listen: false).fetchMember(loginProvider.loggedMember!);
          }
        },
        child: Container(padding: const EdgeInsets.all(8.0), decoration: CustomDecorations.mainContent, child: content),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.red[700],
        tooltip: AppString.joinEvent,
        onPressed: () {
          _navigateToJoinEventScreen(context);
        },
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, Event event) {
    return GestureDetector(
      onTap: () {
        Provider.of<EventDetailProvider>(context, listen: false).setCurrentEvent(event);
        Provider.of<EventDetailProvider>(context, listen: false).fetchEvent(event);
        Navigator.pushNamed(context, '/eventDetail');
      },
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 2.0), child: EventCard(event)),
    );
  }

  /// Full-page empty state shown when the member is registered to no
  /// event at all (neither upcoming nor past). Friendlier than two empty
  /// section headers stacked on top of each other, and points the user
  /// at the FAB to register to one. Wrapped in a scrollable column so
  /// the parent RefreshIndicator stays usable on this state too.
  Widget _buildGlobalEmptyState() {
    return ListView(
      // AlwaysScrollableScrollPhysics + ListView so the surrounding
      // RefreshIndicator still triggers from a pull-down here, even
      // though the content fits in one screen
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        SizedBox(height: 80.0),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.event_note, size: 72.0, color: Colors.black.withValues(alpha: 0.30)),
                const SizedBox(height: 16.0),
                Text(
                  AppString.noRegisteredEvent,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  AppString.tapPlusToJoinEvent,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.black.withValues(alpha: 0.45),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Collapsible section with a styled gradient header (matching the original
/// section header) and a chevron indicator. Tapping the header toggles the
/// visibility of [child].
///
/// When [past] is true, the header switches to a neutral grey gradient and
/// a history icon — a clear "this is archived" cue without hiding the
/// content. The active blue is reserved for the upcoming section so the
/// two are immediately distinguishable at a glance.
class _CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final bool past;

  const _CollapsibleSection({
    Key? key,
    required this.title,
    required this.child,
    this.initiallyExpanded = true,
    this.past = false,
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
    final List<Color> gradientColors = widget.past
        ? [Colors.blueGrey[400]!, Colors.blueGrey[600]!]
        : [Colors.blue[600]!, Colors.blue[800]!];
    final IconData headerIcon = widget.past ? Icons.history : Icons.calendar_today;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // header (clickable to toggle)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _expanded = !_expanded),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            elevation: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                child: Row(
                  children: <Widget>[
                    Icon(headerIcon, size: 20, color: Colors.white),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.expand_more, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // body (animated collapse / expand)
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
