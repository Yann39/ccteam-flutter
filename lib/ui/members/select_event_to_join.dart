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
import 'package:ccteam/providers/event_list_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/member_detail_provider.dart';
import 'package:ccteam/ui/events/event_card.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/restricted_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Screen reached from the "Mes roulages" page via the "+" button. Lists
/// every event the logged-in user has NOT registered to yet (past and
/// upcoming alike) and lets them join one with a single tap. After
/// confirmation the registration mutation fires and the member is
/// re-fetched so the calling page picks up the new entry in its events
/// list. Past events are kept in the list so members can backfill
/// participations they forgot to record at the time.
class SelectEventToJoin extends StatefulWidget {
  const SelectEventToJoin({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectEventToJoinState();
}

class _SelectEventToJoinState extends State<SelectEventToJoin> {
  /// Set of event ids currently being joined — used to disable double
  /// taps while the registration mutation is in flight.
  final Set<int> _joining = <int>{};

  @override
  void initState() {
    super.initState();
    // refresh the events list as soon as we land on this screen so the
    // user sees the most up-to-date set of upcoming events. Skipped
    // for non-members — they'll see the RestrictedContent placeholder
    // and don't need a (potentially failing) network call.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final LoginProvider loginProvider = Provider.of<LoginProvider>(context, listen: false);
      if (!loginProvider.isMember) return;
      Provider.of<EventListProvider>(context, listen: false).fetchEventList();
    });
  }

  /// Show a small confirmation dialog before registering, then call the
  /// register mutation, refresh the logged member (so the caller's
  /// "Mes roulages" list picks up the new entry on pop), and pop back.
  Future<void> _onTapEvent(Event event, int memberId) async {
    if (event.id == null || _joining.contains(event.id)) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppString.confirmation),
        content: Text(AppString.joinEventConfirmation),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppString.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(AppString.confirm)),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _joining.add(event.id!));

    try {
      await Provider.of<EventDetailProvider>(context, listen: false).registerToEvent(event, memberId);

      // refresh the logged member so its eventMembers list reflects the
      // new registration — that way the "Mes roulages" page rebuilds
      // with the freshly joined event when we pop back
      final LoginProvider loginProvider = Provider.of<LoginProvider>(context, listen: false);
      if (loginProvider.loggedMember != null) {
        await Provider.of<MemberDetailProvider>(context, listen: false).fetchMember(loginProvider.loggedMember!);
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _joining.remove(event.id!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final EventListProvider eventListProvider = Provider.of<EventListProvider>(context, listen: true);
    final LoginProvider loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final int? memberId = loginProvider.loggedMember?.id;

    // build the candidate list: every event the user isn't already
    // registered to, past and upcoming alike. We sort them in two
    // groups so the result reads naturally, actionable / soonest
    // first, then archival:
    //   - upcoming (today or later) ascending → next ride at the top
    //   - past events descending → most recent first
    final DateTime now = DateTime.now();
    final List<Event> notJoined = eventListProvider.allEvents.where((e) {
      if (e.startDate == null) return false;
      final bool alreadyIn = e.participants?.any((p) => p.member?.id == memberId) ?? false;
      return !alreadyIn;
    }).toList();

    final List<Event> upcoming =
        notJoined.where((e) => e.startDate!.isAfter(now) || DateUtils.isSameDay(e.startDate!, now)).toList()
          ..sort((a, b) => a.startDate!.compareTo(b.startDate!));
    final List<Event> past =
        notJoined.where((e) => e.startDate!.isBefore(now) && !DateUtils.isSameDay(e.startDate!, now)).toList()
          ..sort((a, b) => b.startDate!.compareTo(a.startDate!));

    final List<Event> candidateEvents = <Event>[...upcoming, ...past];

    // pick the right body content based on state:
    //   1. provider is loading & nothing to show yet → centered spinner
    //   2. fetch finished but candidate list empty → friendly placeholder
    //   3. otherwise → the events list
    final bool isLoading = eventListProvider.loadingStatus == LoadingStatus.loading;

    Widget body;
    if (isLoading && candidateEvents.isEmpty) {
      body = _buildLoadingState();
    } else if (candidateEvents.isEmpty) {
      body = _buildEmptyState();
    } else {
      body = _buildEventList(candidateEvents, memberId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.joinEvent),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: !loginProvider.isMember
          ? Container(decoration: CustomDecorations.mainContent, child: RestrictedContent())
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: CustomDecorations.mainContent,
              padding: const EdgeInsets.all(8.0),
              child: RefreshIndicator(onRefresh: () => eventListProvider.fetchEventList(), child: body),
            ),
    );
  }

  /// Centered spinner shown while the events are being fetched and we
  /// have nothing to display yet. Wrapped in an always-scrollable
  /// ListView so the surrounding RefreshIndicator stays usable.
  Widget _buildLoadingState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        const SizedBox(height: 120.0),
        Center(
          child: SizedBox(
            width: 28.0,
            height: 28.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
            ),
          ),
        ),
      ],
    );
  }

  /// Centred placeholder shown when there is no event the user can
  /// register to. Mirrors the empty state on "Mes roulages" — same
  /// icon-on-top, bold title and italic hint pattern — so both pages
  /// feel consistent.
  Widget _buildEmptyState() {
    return ListView(
      // AlwaysScrollableScrollPhysics + ListView so the surrounding
      // RefreshIndicator still triggers from a pull-down here
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        const SizedBox(height: 80.0),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.event_busy, size: 72.0, color: Colors.black.withValues(alpha: 0.30)),
                const SizedBox(height: 16.0),
                Text(
                  AppString.noEventToJoin,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  AppString.pullToRefresh,
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

  /// Scrollable list of joinable events. Each card is tappable; while
  /// a registration mutation is in flight, the corresponding card is
  /// dimmed and overlaid with a small spinner so the user sees the
  /// action is being processed.
  Widget _buildEventList(List<Event> candidateEvents, int? memberId) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8.0),
      itemCount: candidateEvents.length,
      itemBuilder: (BuildContext context, int index) {
        final Event event = candidateEvents[index];
        final bool isJoining = _joining.contains(event.id);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Stack(
            children: <Widget>[
              Opacity(
                opacity: isJoining ? 0.6 : 1.0,
                child: IgnorePointer(
                  ignoring: isJoining,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: memberId == null ? null : () => _onTapEvent(event, memberId),
                    child: EventCard(event),
                  ),
                ),
              ),
              if (isJoining)
                Positioned.fill(
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
                ),
            ],
          ),
        );
      },
    );
  }
}
