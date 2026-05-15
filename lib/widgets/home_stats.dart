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
import 'package:ccteam/models/membership_fee.dart';
import 'package:ccteam/providers/event_detail_provider.dart';
import 'package:ccteam/providers/event_list_provider.dart';
import 'package:ccteam/providers/home_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/member_list_provider.dart';
import 'package:ccteam/providers/record_list_provider.dart';
import 'package:ccteam/providers/track_list_provider.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/member_stats.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Compact "at-a-glance" stats panel rendered between the logo and the
/// news list on the home screen.
///
/// Visual structure (top to bottom):
///  1. **Hero card**, countdown to the next event the user is
///     registered to. Tappable to jump straight to the event detail.
///     Falls back to an "Register" prompt when there is no
///     upcoming registration.
///  2. Two **grouped cards side by side**:
///     - **The club** : community-wide stats (members, upcoming events,
///       tracks). Each row taps through to the matching tab.
///     - **My profile** : personal stats (events registered to, bikes,
///       membership fee status). Each row taps through to its
///       dedicated screen (when applicable).
class HomeStats extends StatelessWidget {
  const HomeStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final memberListProvider = Provider.of<MemberListProvider>(context, listen: true);
    final eventListProvider = Provider.of<EventListProvider>(context, listen: true);
    final trackListProvider = Provider.of<TrackListProvider>(context, listen: true);
    final recordListProvider = Provider.of<RecordListProvider>(context, listen: true);
    final loginProvider = Provider.of<LoginProvider>(context, listen: true);

    final DateTime now = DateTime.now();

    // club-wide values
    final String membersValue = memberListProvider.totalCount?.toString() ?? '—';
    final String eventsValue = eventListProvider.totalCount?.toString() ?? '—';

    final String tracksValue = trackListProvider.loadingStatus == LoadingStatus.loaded
        ? trackListProvider.tracks.length.toString()
        : '—';

    // personal values
    final int myEvents = loginProvider.loggedMember?.eventMembers?.length ?? 0;
    final int myBikes = loginProvider.loggedMember?.bikes?.length ?? 0;

    final fees = loginProvider.loggedMember?.membershipFees;
    final int currentYear = now.year;
    MembershipFee? currentYearFee;
    if (fees != null) {
      for (final fee in fees) {
        if (fee.year == currentYear) {
          currentYearFee = fee;
          break;
        }
      }
    }
    final bool feePaid = currentYearFee?.paid == true;

    // estimated km ridden across all past events the user has been registered to
    final int myKm = MemberStatsUtils.estimateKm(
      eventMembers: loginProvider.loggedMember?.eventMembers,
      records: recordListProvider.memberRecords,
      now: now,
    );

    // next ride (hero card)
    Event? nextEvent;
    final eventMembers = loginProvider.loggedMember?.eventMembers;
    if (eventMembers != null) {
      final upcoming = eventMembers
          .map((em) => em.event)
          .where((e) => e != null && e.startDate != null && !e.startDate!.isBefore(_dayOnly(now)))
          .toList();
      upcoming.sort((a, b) => a!.startDate!.compareTo(b!.startDate!));
      if (upcoming.isNotEmpty) nextEvent = upcoming.first;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // hero: next ride countdown
          _NextRideHero(nextEvent: nextEvent, now: now),
          const SizedBox(height: 8.0),

          // two side-by-side grouped cards
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: _GroupCard(
                    title: AppString.statsClub,
                    rows: <_GroupCardRow>[
                      _GroupCardRow(
                        icon: Icons.people,
                        iconColor: Colors.yellow,
                        value: membersValue,
                        label: AppString.statsMembers,
                        onTap: () => _switchTab(context, 2),
                      ),
                      _GroupCardRow(
                        icon: Icons.event,
                        iconColor: Colors.red,
                        value: eventsValue,
                        label: AppString.events,
                        onTap: () => _switchTab(context, 1),
                      ),
                      _GroupCardRow(
                        icon: CustomIcons.track_sample,
                        iconColor: Colors.blue[800]!,
                        value: tracksValue,
                        label: AppString.statsTracks,
                        onTap: () => _switchTab(context, 3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: _GroupCard(
                    title: AppString.statsProfile,
                    headerTrailing: _FeeStatusPill(paid: feePaid),
                    onHeaderTap: () => _navigateToMyAccount(context),
                    rows: <_GroupCardRow>[
                      _GroupCardRow(
                        icon: Icons.flag,
                        iconColor: Colors.orange[700]!,
                        value: myEvents.toString(),
                        label: AppString.statsMyEvents,
                        onTap: () => Navigator.pushNamed(context, '/memberEvents'),
                      ),
                      _GroupCardRow(
                        icon: CustomIcons.motorbike,
                        iconColor: Colors.purple,
                        value: myBikes.toString(),
                        label: AppString.statsMyBikes,
                        onTap: () => Navigator.pushNamed(context, '/myBikes'),
                      ),
                      _GroupCardRow(
                        icon: Icons.speed,
                        iconColor: Colors.lightGreenAccent,
                        value: StringUtils.formatCompactInt(myKm),
                        label: AppString.statsMyKm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _switchTab(BuildContext context, int index) {
    Provider.of<HomeProvider>(context, listen: false).setCurrentIndex(index);
  }

  /// Open the "My account" hub for the currently logged-in member.
  void _navigateToMyAccount(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    if (loginProvider.loggedMember == null) return;
    Navigator.pushNamed(context, '/myAccount');
  }

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

/// Hero "next ride" card, wide blue gradient tile with a leading disc
/// icon, a countdown headline, an event subtitle, and a chevron. Falls
/// back to a gentle empty-state prompt when the user has no upcoming
/// registration.
class _NextRideHero extends StatelessWidget {
  const _NextRideHero({Key? key, required this.nextEvent, required this.now}) : super(key: key);

  final Event? nextEvent;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    if (nextEvent == null) {
      return _heroShell(
        context: context,
        leadingIcon: Icons.event_busy,
        title: AppString.statsNextRide,
        primary: AppString.statsNoUpcomingRide,
        secondary: null,
        onTap: () => Navigator.pushNamed(context, '/selectEventToJoin'),
      );
    }

    final DateTime startDay = DateTime(
      nextEvent!.startDate!.year,
      nextEvent!.startDate!.month,
      nextEvent!.startDate!.day,
    );
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int days = startDay.difference(today).inDays;
    final String primary = days == 0
        ? AppString.statsNextRideToday
        : days == 1
        ? AppString.statsNextRideTomorrow
        : AppString.format(AppString.statsNextRideInDays, [days]);

    final String trackName = nextEvent!.track?.name ?? '';
    final String dateStr = AppDateUtils.convertToString(nextEvent!.startDate!, 'dd MMM yyyy') ?? '';
    final String secondary = trackName.isNotEmpty ? '$trackName — $dateStr' : dateStr;

    return _heroShell(
      context: context,
      leadingIcon: Icons.flag,
      title: AppString.statsNextRide,
      primary: primary,
      secondary: secondary,
      onTap: () {
        Provider.of<EventDetailProvider>(context, listen: false).setCurrentEvent(nextEvent!);
        Provider.of<EventDetailProvider>(context, listen: false).fetchEvent(nextEvent!);
        Navigator.pushNamed(context, '/eventDetail');
      },
    );
  }

  Widget _heroShell({
    required BuildContext context,
    required IconData leadingIcon,
    required String title,
    required String primary,
    required String? secondary,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(12.0),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[500]!, Colors.blue[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
                  child: Icon(leadingIcon, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        primary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      if (secondary != null && secondary.isNotEmpty) ...[
                        const SizedBox(height: 2.0),
                        Text(
                          secondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A grouped stats card, blue-gradient container with a header row
/// (icon + title) and a vertical list of [_GroupCardRow] entries. Used
/// for the side-by-side "Le club" / "Mon profil" cards on the home
/// stats panel.
class _GroupCard extends StatelessWidget {
  const _GroupCard({Key? key, required this.title, required this.rows, this.headerTrailing, this.onHeaderTap})
    : super(key: key);

  final String title;
  final List<_GroupCardRow> rows;

  /// Optional widget rendered on the right side of the card header.
  /// Used by "Mon profil" to surface the membership-fee status as a
  /// pill, so the critical info stays glanceable while regular rows
  /// remain available for routine stats.
  final Widget? headerTrailing;

  /// Optional tap handler on the card header. When set, the header
  /// becomes interactive (InkWell ripple). Used by "Me" to jump to
  /// the My account hub.
  final VoidCallback? onHeaderTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12.0),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[300]!, Colors.blue[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Container(height: 1, color: Colors.white.withValues(alpha: 0.25)),
              ),
              ...rows,
            ],
          ),
        ),
      ),
    );
  }

  /// Header row builder, extracted so we can either render a plain
  /// Row or wrap it in an [InkWell] when [onHeaderTap] is set. The
  /// tappable variant uses the InkWell ripple alone as the affordance
  /// (no chevron) to stay visually balanced with the non-tappable
  /// card next to it.
  Widget _buildHeader() {
    final bool tappable = onHeaderTap != null;
    final Row content = Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        if (headerTrailing != null) headerTrailing!,
      ],
    );

    if (!tappable) return content;
    return InkWell(onTap: onHeaderTap, borderRadius: BorderRadius.circular(6.0), child: content);
  }
}

/// A single tappable row inside a [_GroupCard]. Shows a leading icon,
/// the value (number or status icon) and a small label. Highlights on
/// tap and triggers [onTap] when provided.
class _GroupCardRow extends StatelessWidget {
  const _GroupCardRow({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.valueIcon,
    this.valueIconColor,
    this.onTap,
  }) : super(key: key);

  final IconData icon;

  /// Tint for the leading icon. Each row gets a different accent so
  /// the stats are scan-friendly even on a uniform blue card.
  final Color iconColor;

  final String value;
  final String label;
  final IconData? valueIcon;
  final Color? valueIconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 10.0),
          if (valueIcon != null)
            Icon(valueIcon, size: 18, color: valueIconColor ?? Colors.white)
          else
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, height: 1.0),
            ),
          const SizedBox(width: 6.0),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(6.0), child: content);
  }
}

/// Tiny "membership fee" status pill displayed in the "My profile" card header.
class _FeeStatusPill extends StatelessWidget {
  const _FeeStatusPill({Key? key, required this.paid}) : super(key: key);

  final bool paid;

  @override
  Widget build(BuildContext context) {
    final Color tint = paid ? Colors.greenAccent : Colors.amberAccent;
    final IconData icon = paid ? Icons.check_circle : Icons.error_outline;
    final String label = paid
        ? AppString.statsMembershipPaid.toUpperCase()
        : AppString.statsMembershipUnpaid.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: tint.withValues(alpha: 0.65), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: tint),
          const SizedBox(width: 3.0),
          Text(
            label,
            style: TextStyle(color: tint, fontSize: 9.0, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}
