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

import 'package:ccteam/models/bike.dart';
import 'package:ccteam/models/event.dart';
import 'package:ccteam/models/event_member.dart';
import 'package:ccteam/providers/event_detail_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/ui/events/event_card.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
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
  Bike? _filterBike;
  bool _filterUnset = false;

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

  /// Whether the given participation passes the current bike filter.
  bool _passesBikeFilter(EventMember em) {
    if (_filterUnset) return em.bike == null;
    if (_filterBike != null) return em.bike?.id == _filterBike!.id;
    return true;
  }

  /// Short human-readable label for a bike.
  String _bikeLabel(Bike b) {
    final String base = "${b.manufacturer?.toUpperCase() ?? ''} ${b.modelName ?? ''}".trim();
    if (b.year == null) return base.isEmpty ? '—' : base;
    if (base.isEmpty) return b.year!.toString();
    return "$base (${b.year})";
  }

  /// Whether any non-default filter is currently applied.
  bool get _filterActive => _filterBike != null || _filterUnset;

  /// Open the bike filter as a modal bottom sheet.
  void _openBikeFilterPicker(BuildContext context, List<Bike> bikes) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (BuildContext sheetCtx) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[100]!, Colors.blue[200]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                    Text(
                      AppString.filterByBikePickerTitle,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                    const SizedBox(height: 12.0),
                    _BikeFilterTile(
                      label: AppString.filterByBikeAll,
                      selected: !_filterUnset && _filterBike == null,
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        setState(() {
                          _filterBike = null;
                          _filterUnset = false;
                        });
                      },
                    ),
                    for (final Bike b in bikes)
                      _BikeFilterTile(
                        label: _bikeLabel(b),
                        selected: _filterBike?.id == b.id && !_filterUnset,
                        onTap: () {
                          Navigator.pop(sheetCtx);
                          setState(() {
                            _filterBike = b;
                            _filterUnset = false;
                          });
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: _BikeFilterTile(
                        label: AppString.filterByBikeUnset,
                        selected: _filterUnset,
                        muted: true,
                        onTap: () {
                          Navigator.pop(sheetCtx);
                          setState(() {
                            _filterBike = null;
                            _filterUnset = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// AppBar filter icon.
  /// When a filter is active, a small red dot is overlaid on the top-right of the icon to signal it.
  /// A tooltip also surfaces what it does.
  Widget _buildFilterAction(List<Bike> bikes) {
    return IconButton(
      tooltip: AppString.filterByBikeTooltip,
      onPressed: () => _openBikeFilterPicker(context, bikes),
      icon: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          const Icon(Icons.filter_list),
          if (_filterActive)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red[400],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.0),
                ),
              ),
            ),
        ],
      ),
    );
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

    Widget content;

    // keep the EventMember (not just the Event) so each card can surface whether the rider has pinned a bike to this specific participation
    final List<EventMember> memberParticipations =
        (loginProvider.loggedMember?.eventMembers
            ?.where((em) => em.event != null && em.event!.startDate != null)
            .toList() ??
        <EventMember>[]);

    final List<Bike> bikes = loginProvider.loggedMember?.bikes ?? const <Bike>[];

    // if the currently-filtered bike was deleted between renders, reset the filter to "all" rather than show a stale chip with no matches
    if (_filterBike != null && !bikes.any((b) => b.id == _filterBike!.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _filterBike = null);
      });
    }

    final now = DateTime.now();
    // apply both the date split and the bike filter
    final upcomingParticipations = memberParticipations
        .where(_passesBikeFilter)
        .where((em) => em.event!.startDate!.isAfter(now) || DateUtils.isSameDay(em.event!.startDate!, now))
        .toList();
    final pastParticipations = memberParticipations
        .where(_passesBikeFilter)
        .where((em) => em.event!.startDate!.isBefore(now) && !DateUtils.isSameDay(em.event!.startDate!, now))
        .toList();

    // sort upcoming events by date ascending (closest first)
    upcomingParticipations.sort((a, b) => a.event!.startDate!.compareTo(b.event!.startDate!));
    // sort past events by date descending (most recent first)
    pastParticipations.sort((a, b) => b.event!.startDate!.compareTo(a.event!.startDate!));

    // no participations at all → show the original "join one!"
    final bool hasAnyParticipation = memberParticipations.isNotEmpty;

    if (!hasAnyParticipation) {
      content = _buildGlobalEmptyState();
    } else {
      // filter is active but no rides match → show a contextual empty placeholder
      final bool filterHidesEverything = upcomingParticipations.isEmpty && pastParticipations.isEmpty;

      content = ListView(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0 + MediaQuery.of(context).padding.bottom + 72.0),
        children: <Widget>[
          const InfoBanner(message: AppString.myEventsHelp),
          const SizedBox(height: 8.0),
          if (filterHidesEverything)
            _buildFilterEmptyState()
          else ...[
            if (upcomingParticipations.isNotEmpty)
              _CollapsibleSection(
                title: AppString.upcomingEvents,
                initiallyExpanded: true,
                child: Column(children: upcomingParticipations.map((em) => _buildEventItem(context, em)).toList()),
              ),
            if (upcomingParticipations.isNotEmpty && pastParticipations.isNotEmpty) const SizedBox(height: 8.0),
            if (pastParticipations.isNotEmpty)
              _CollapsibleSection(
                title: AppString.pastEvents,
                initiallyExpanded: upcomingParticipations.isEmpty,
                past: true,
                child: Column(children: pastParticipations.map((em) => _buildEventItem(context, em)).toList()),
              ),
          ],
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.myTrackEvents),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: <Widget>[
          // filter icon
          if (hasAnyParticipation) _buildFilterAction(bikes),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => loginProvider.refreshLoggedMember(),
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

  Widget _buildEventItem(BuildContext context, EventMember participation) {
    final Event event = participation.event!;

    return GestureDetector(
      onTap: () {
        Provider.of<EventDetailProvider>(context, listen: false).setCurrentEvent(event);
        Provider.of<EventDetailProvider>(context, listen: false).fetchEvent(event);
        Navigator.pushNamed(context, '/eventDetail');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: EventCard(event, bike: participation.bike),
      ),
    );
  }

  /// Inline placeholder shown when the bike filter hides every
  /// participation. The "clear filter" button is the primary recovery
  /// path now that the filter lives behind an icon in the AppBar (no
  /// longer a one-tap chip switch). Tap → resets the filter to
  /// "All", and the list immediately repopulates.
  Widget _buildFilterEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.filter_alt_off, size: 48.0, color: Colors.black.withValues(alpha: 0.30)),
          const SizedBox(height: 12.0),
          Text(
            AppString.filterByBikeNoMatch,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.0, color: Colors.black.withValues(alpha: 0.55), fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16.0),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _filterBike = null;
                _filterUnset = false;
              });
            },
            icon: const Icon(Icons.clear, size: 16.0),
            label: Text(AppString.filterByBikeClear),
            style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
          ),
        ],
      ),
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

/// Single tile of the bike-filter bottom sheet. Mirrors `_BikePickerTile`
/// in `event_detail.dart` so the two pickers feel identical, but kept
/// private to this file rather than shared to avoid coupling the two
/// pages over an internal styling widget.
class _BikeFilterTile extends StatelessWidget {
  const _BikeFilterTile({required this.label, required this.selected, required this.onTap, this.muted = false});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Visual treatment used for the "Not defined" tile.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Material(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.white, width: 1.0),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  muted ? Icons.block : CustomIcons.motorbike,
                  size: 18.0,
                  color: Colors.black.withAlpha(muted ? 110 : 160),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.black.withAlpha(muted ? 140 : 204),
                      fontSize: 13.5,
                      fontStyle: muted ? FontStyle.italic : FontStyle.normal,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (selected) Icon(Icons.check, size: 18.0, color: Colors.green[700]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
