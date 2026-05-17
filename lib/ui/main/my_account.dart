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
import 'package:ccteam/models/member.dart';
import 'package:ccteam/models/membership_fee.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/member_creation_provider.dart';
import 'package:ccteam/providers/record_list_provider.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/member_stats.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/avatar_image.dart';
import 'package:ccteam/widgets/member_header_palette.dart';
import 'package:ccteam/widgets/random_pattern_painter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Hub page replacing the old direct-to-edit "Profil" drawer entry.
///
/// Shows a sober header (avatar + name + e-mail), a quick read-out of
/// the membership-fee status for the current year, and a short list
/// of account actions: edit profile, change passcode. Easy to extend
/// with notification preferences, account deletion, etc.
class MyAccount extends StatelessWidget {
  const MyAccount({Key? key}) : super(key: key);

  /// Navigate to the profile edit screen, seeding the
  /// [MemberCreationProvider] with a deep copy of the logged member.
  void _editProfile(BuildContext context, Member member) {
    final Member copy = Member.fromJson(member.toJson());
    Provider.of<MemberCreationProvider>(context, listen: false).setMemberToEdit(copy);
    Navigator.pushNamed(context, '/addEditMember');
  }

  /// Pick the [MembershipFee] for the current calendar year, or null
  /// when nothing was recorded for that year yet.
  MembershipFee? _currentYearFee(Member member) {
    final int currentYear = DateTime.now().year;
    final List<MembershipFee> fees = member.membershipFees ?? const <MembershipFee>[];
    for (final MembershipFee fee in fees) {
      if (fee.year == currentYear) return fee;
    }
    return null;
  }

  /// Resolve the palette + seed pair used to drive the procedural
  /// header background. Falls back to a deterministic seed-based
  /// default when the member hasn't picked a palette yet.
  ({int seed, List<Color> palette}) _resolvePalette(Member member) {
    final int seed = member.id ?? member.email?.hashCode ?? 0;
    final int paletteIdx = member.headerPalette ?? (seed.abs() % kMemberHeaderPalettes.length);
    final List<Color> palette = kMemberHeaderPalettes[paletteIdx.clamp(0, kMemberHeaderPalettes.length - 1)];
    return (seed: seed, palette: palette);
  }

  /// Header: same procedural pattern as the member-detail hero (a
  /// [RandomPatternPainter] driven by the user's seed + palette),
  /// with a soft dark overlay so the white text stays readable.
  /// Includes a small palette-edit chip in the top-right corner so
  /// the customisation affordance lives right where its result shows.
  Widget _buildHeader(BuildContext context, Member member) {
    final resolved = _resolvePalette(member);
    return SizedBox(
      width: double.infinity,
      height: 232,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: RandomPatternPainter(
                seed: resolved.seed,
                color1: resolved.palette[0],
                color2: resolved.palette[1],
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withAlpha(90)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.white.withValues(alpha: 0.18),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _openPalettePicker(context, member),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.palette_outlined, size: 18, color: Colors.white),
                ),
              ),
            ),
          ),
          // avatar + name + e-mail stack
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 88,
                  height: 88,
                  decoration: const ShapeDecoration(shape: CircleBorder(), color: Colors.white),
                  padding: const EdgeInsets.all(3.0),
                  child: AvatarImage(memberId: member.id, hasAvatar: member.hasAvatar == true, radius: 41.0),
                ),
                const SizedBox(height: 10.0),
                Text(
                  "${member.firstName ?? ''} ${member.lastName ?? ''}".trim(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Colors.black.withAlpha(120), blurRadius: 4.0, offset: const Offset(0, 1))],
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  member.email ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13.0,
                    shadows: [Shadow(color: Colors.black.withAlpha(120), blurRadius: 3.0, offset: const Offset(0, 1))],
                  ),
                ),
                _buildRoleBadges(member),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Render a row of identity badges just under the email line. The
  /// row is intentionally only shown when the member has something
  /// worth flagging:
  ///   - `ROLE_ADMIN` → red "Administrateur" pill. Plain members get
  ///     no badge — being a member is the implicit default and a
  ///     "Membre" pill would just be noise.
  ///   - `boardRole` set → amber pill with the localised label
  ///     ("Président", "Trésorier"…) sourced from [BoardRoleLabel].
  /// When both apply (e.g. an admin who's also Treasurer), the two
  /// badges sit side by side. When neither applies, the entire row
  /// is collapsed to a zero-height SizedBox so we don't push down
  /// the layout for nothing.
  Widget _buildRoleBadges(Member member) {
    final bool isAdmin = member.role == MemberRole.ROLE_ADMIN;
    final BoardRole? boardRole = member.boardRole;
    if (!isAdmin && boardRole == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 6.0,
        runSpacing: 4.0,
        children: <Widget>[
          if (isAdmin) _buildBadge(icon: Icons.security, label: AppString.memberRoleAdmin, color: Colors.red[400]!),
          if (boardRole != null)
            _buildBadge(icon: Icons.workspace_premium, label: boardRole.labelFr, color: Colors.amber[700]!),
        ],
      ),
    );
  }

  /// A single pill. Reused by [_buildRoleBadges] so admin / board-role
  /// badges share the same shape and only the colour + icon differ.
  /// Slightly translucent fill so the gradient header still breathes
  /// through, white text + white border for legibility on top of the
  /// procedural pattern background.
  Widget _buildBadge({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12.0, color: Colors.white),
          const SizedBox(width: 4.0),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Open the shared header-palette picker and persist the choice
  /// through [LoginProvider.updateMyHeaderPalette] so the change is
  /// applied immediately on the header (and propagated to anything
  /// else bound to `loggedMember`, like the member-detail page).
  void _openPalettePicker(BuildContext context, Member member) {
    final LoginProvider loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final int seed = member.id ?? member.email?.hashCode ?? 0;
    showMemberHeaderPalettePicker(
      context: context,
      currentIndex: member.headerPalette,
      seed: seed,
      onSelected: (int? picked) => loginProvider.updateMyHeaderPalette(picked),
    );
  }

  /// Soft amber banner shown on top of the page for accounts that
  /// are still `ROLE_USER`, i.e. registered but not yet promoted to
  /// `ROLE_MEMBER` by an admin. Explains that most club features
  /// (event registration, bikes, chronos, …) will stay out of reach
  /// until the admin validates the membership.
  ///
  /// Visual is intentionally distinct from the other cards (amber
  /// instead of blue) so it reads as a notice rather than as another
  /// data tile.
  Widget _buildPendingValidationBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange[300]!, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.orange[50],
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(25), spreadRadius: 0.5, blurRadius: 0.5, offset: const Offset(2, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.orange[700]!.withValues(alpha: 0.15)),
            child: Icon(Icons.hourglass_top, color: Colors.orange[700], size: 22.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  AppString.accountPendingTitle,
                  style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold, fontSize: 14.0, height: 1.2),
                ),
                const SizedBox(height: 4.0),
                Text(
                  AppString.accountPendingMessage,
                  style: TextStyle(color: Colors.black.withAlpha(180), fontSize: 12.5, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card that summarises the current year's membership fee.
  /// Three visual variants: paid (green), unpaid (orange), missing (grey).
  Widget _buildMembershipCard(Member member) {
    final MembershipFee? fee = _currentYearFee(member);
    final int currentYear = DateTime.now().year;

    final IconData icon;
    final Color color;
    final String label;
    final String? amount;
    if (fee == null) {
      icon = Icons.help_outline_rounded;
      color = Colors.blueGrey[500]!;
      label = AppString.format(AppString.membershipNoneYear, [currentYear]);
      amount = null;
    } else if (fee.paid == true) {
      icon = Icons.check_circle_rounded;
      color = Colors.green[700]!;
      label = AppString.format(AppString.membershipPaidYear, [currentYear]);
      amount = fee.amount != null
          ? AppString.format(AppString.membershipAmountEur, [fee.amount!.toStringAsFixed(0)])
          : null;
    } else {
      icon = Icons.warning_amber_rounded;
      color = Colors.orange[700]!;
      label = AppString.format(AppString.membershipUnpaidYear, [currentYear]);
      amount = fee.amount != null
          ? AppString.format(AppString.membershipAmountEur, [fee.amount!.toStringAsFixed(0)])
          : null;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)),
            child: Icon(icon, color: color, size: 24.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  AppString.membershipStatus,
                  style: TextStyle(color: Colors.black.withAlpha(140), fontSize: 11.0, height: 1.2),
                ),
                const SizedBox(height: 2.0),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black.withAlpha(204),
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          if (amount != null) ...[
            const SizedBox(width: 8.0),
            Text(
              amount,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15.0),
            ),
          ],
        ],
      ),
    );
  }

  /// A single tappable row used inside the actions card.
  ///
  /// Visually mirrors `_GroupCardRow` from the home stats panel:
  /// soft circular halo for the icon, dark label, faint chevron at
  /// the right end. The InkWell ripple stays clipped inside the
  /// parent's rounded border so the press feedback feels native.
  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final BorderRadius radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(7.0) : Radius.zero,
      bottom: isLast ? const Radius.circular(7.0) : Radius.zero,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withValues(alpha: 0.15)),
              child: Icon(icon, color: iconColor, size: 20.0),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: Colors.black.withAlpha(204), fontSize: 14.0, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black.withValues(alpha: 0.35), size: 22.0),
          ],
        ),
      ),
    );
  }

  /// Section wrapping the action tiles in a single rounded card.
  ///
  /// Same visual language as the membership-fee card: `Colors.blue[100]`
  /// fill, white border, subtle drop shadow. Rows are separated by a
  /// thin white divider so the grouping reads as "one block".
  Widget _buildActionsSection(BuildContext context, Member member) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.blue[100],
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(25), spreadRadius: 0.5, blurRadius: 0.5, offset: const Offset(2, 2)),
        ],
      ),
      // clip the ripple to the rounded border
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: <Widget>[
            _buildActionTile(
              icon: Icons.person,
              iconColor: Colors.green[700]!,
              label: AppString.editMyProfile,
              onTap: () => _editProfile(context, member),
              isFirst: true,
            ),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.6)),
            _buildActionTile(
              icon: Icons.lock_reset,
              iconColor: Colors.blue[700]!,
              label: AppString.changeMyPasscode,
              onTap: () => Navigator.pushNamed(context, '/changePasscode'),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Small section header: a tinted icon + an uppercase-y label.
  /// Used to separate the membership / stats / actions zones so the
  /// page reads as a stack of grouped concerns rather than one long
  /// list.
  Widget _buildSectionLabel(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: Colors.black.withAlpha(150)),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: TextStyle(
              color: Colors.black.withAlpha(150),
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Compact bike label used in the stats rows. Same format as the
  /// event-detail picker and the participation row on `EventCard` so
  /// a given bike reads identically across the app: manufacturer
  /// upper-cased, model as stored, year when known.
  String _bikeStatLabel(Bike b) {
    final String base = "${b.manufacturer?.toUpperCase() ?? ''} ${b.modelName ?? ''}".trim();
    if (b.year == null) return base.isEmpty ? '—' : base;
    if (base.isEmpty) return b.year!.toString();
    return "$base ${b.year}";
  }

  /// Stats card: seven rows summarising the user's track-day activity
  /// (events, bikes, km, favourite track, favourite bike, favourite
  /// organizer, total spent). Uses the same `blue[100]` +
  /// white-border visual language
  /// as the other cards on this page so the three zones (statut /
  /// stats / actions) read as siblings.
  ///
  /// All metrics are **past-only** so the numbers stay meaningful: a
  /// future commitment isn't yet a "ride completed" or "money spent".
  /// The heuristic for km estimation is shared with the home stats
  /// panel (lives in [MemberStatsUtils]) so the user sees the same
  /// number in both places.
  Widget _buildStatsCard(Member member, RecordListProvider recordListProvider) {
    final DateTime now = DateTime.now();
    final int events = MemberStatsUtils.pastEventsCount(eventMembers: member.eventMembers, now: now);
    final int bikes = member.bikes?.length ?? 0;
    final int km = MemberStatsUtils.estimateKm(
      eventMembers: member.eventMembers,
      records: recordListProvider.memberRecords,
      now: now,
    );
    final MostRiddenTrack? favTrack = MemberStatsUtils.mostRiddenTrack(eventMembers: member.eventMembers, now: now);
    final MostUsedBike? favBike = MemberStatsUtils.mostUsedBike(eventMembers: member.eventMembers, now: now);
    final MostFavoriteOrganizer? favOrganizer = MemberStatsUtils.mostFavoriteOrganizer(
      eventMembers: member.eventMembers,
      now: now,
    );
    final double spent = MemberStatsUtils.totalSpent(eventMembers: member.eventMembers, now: now);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.blue[100],
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(25), spreadRadius: 0.5, blurRadius: 0.5, offset: const Offset(2, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          _buildStatRow(
            icon: Icons.flag,
            iconColor: Colors.orange[700]!,
            label: AppString.statsTrackEventsCount,
            value: events.toString(),
          ),
          _buildStatDivider(),
          _buildStatRow(
            icon: CustomIcons.motorbike_plain,
            iconColor: Colors.purple,
            label: AppString.statsBikesCount,
            value: bikes.toString(),
          ),
          _buildStatDivider(),
          _buildStatRow(
            icon: Icons.speed,
            iconColor: Colors.lightGreen[700]!,
            label: AppString.statsKmEstimated,
            value: km.toString(),
          ),
          _buildStatDivider(),
          _buildStatRow(
            icon: Icons.emoji_events,
            iconColor: Colors.amber[700]!,
            label: AppString.statsFavoriteTrack,
            // track name + visit count
            value: favTrack?.name ?? AppString.statsNoData,
            subtitle: favTrack != null ? AppString.format(AppString.statsFavoriteTrackTimes, [favTrack.count]) : null,
          ),
          _buildStatDivider(),
          _buildStatRow(
            icon: CustomIcons.motorbike_plain,
            iconColor: Colors.indigo[600]!,
            label: AppString.statsFavoriteBike,
            value: favBike != null ? _bikeStatLabel(favBike.bike) : AppString.statsNoData,
            subtitle: favBike != null ? AppString.format(AppString.statsFavoriteTrackTimes, [favBike.count]) : null,
          ),
          _buildStatDivider(),
          _buildStatRow(
            icon: Icons.perm_contact_calendar,
            iconColor: Colors.teal[700]!,
            label: AppString.statsFavoriteOrganizer,
            value: favOrganizer?.organizer.name ?? AppString.statsNoData,
            subtitle: favOrganizer != null
                ? AppString.format(AppString.statsFavoriteTrackTimes, [favOrganizer.count])
                : null,
          ),
          _buildStatDivider(),
          _buildStatRow(
            icon: Icons.payments_outlined,
            iconColor: Colors.red[700]!,
            label: AppString.statsTotalSpent,
            value: AppString.format(AppString.statsAmountEur, [spent.toStringAsFixed(0)]),
          ),
        ],
      ),
    );
  }

  /// A single stat row: a colour-tinted halo icon on the left, a small
  /// label, and the value (with optional subtitle) right-aligned.
  /// Same visual rhythm as the membership-fee card above so the two
  /// zones feel like siblings.
  Widget _buildStatRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withValues(alpha: 0.15)),
            child: Icon(icon, color: iconColor, size: 20.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(label, style: TextStyle(color: Colors.black.withAlpha(180), fontSize: 13.0)),
                const SizedBox(height: 2.0),
                Text(
                  value,
                  style: TextStyle(color: Colors.black.withAlpha(220), fontSize: 15.0, fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2.0),
                  Text(subtitle, style: TextStyle(color: Colors.black.withAlpha(120), fontSize: 11.0)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Soft white divider between two stat rows — visible against the
  /// `blue[100]` background without being heavy.
  Widget _buildStatDivider() {
    return Container(height: 1, color: Colors.white.withValues(alpha: 0.6));
  }

  @override
  Widget build(BuildContext context) {
    final LoginProvider loginProvider = Provider.of<LoginProvider>(context, listen: true);
    // records are fetched eagerly from the home page (news_list) right
    // after login, so by the time the user reaches this hub the list
    // is usually populated. We listen so the km estimate refreshes if
    // a new chrono is logged elsewhere while the page is open
    final RecordListProvider recordListProvider = Provider.of<RecordListProvider>(context, listen: true);
    final Member? member = loginProvider.loggedMember;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppString.myAccountTitle),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
      ),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: member == null
            // defensive fallback, should never happen since this screen is only reachable from an authenticated session, but it saves us from a null-pointer crash on session expiration
            ? Center(child: Text(AppString.contentNotLoaded))
            : ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _buildHeader(context, member),
                  const SizedBox(height: 16.0),
                  // pending-validation notice for ROLE_USER accounts
                  if (!loginProvider.isMember) ...[_buildPendingValidationBanner(), const SizedBox(height: 16.0)],
                  _buildMembershipCard(member),
                  const SizedBox(height: 20.0),
                  _buildSectionLabel(Icons.tune, AppString.accountActions),
                  _buildActionsSection(context, member),
                  // stats are hidden for non-members
                  if (loginProvider.isMember) ...[
                    const SizedBox(height: 20.0),
                    _buildSectionLabel(Icons.bar_chart, AppString.statistics),
                    _buildStatsCard(member, recordListProvider),
                  ],
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16.0),
                ],
        ),
      ),
    );
  }
}
