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

import 'package:ccteam/models/member.dart';
import 'package:ccteam/models/record.dart';
import 'package:ccteam/models/track.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/member_detail_provider.dart';
import 'package:ccteam/providers/record_creation_provider.dart';
import 'package:ccteam/providers/record_detail_provider.dart';
import 'package:ccteam/providers/record_list_provider.dart';
import 'package:ccteam/providers/track_detail_provider.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/utils/track_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Read-only detail page for a single chrono.
class ChronoDetail extends StatefulWidget {
  const ChronoDetail({Key? key}) : super(key: key);

  @override
  State<ChronoDetail> createState() => _ChronoDetailState();
}

class _ChronoDetailState extends State<ChronoDetail> {
  @override
  void initState() {
    super.initState();
    // fetch the full list of records on this track right after the first frame,
    // we need it to compute the chrono's ranking in the "Ranking" card below.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final Record? record = Provider.of<RecordDetailProvider>(context, listen: false).currentRecord;
      final int? trackId = record?.track?.id;
      if (trackId != null) {
        Provider.of<RecordListProvider>(context, listen: false).fetchTrackRecords(trackId);
      }
    });
  }

  /// Open the add/edit form seeded with the current record so the user
  /// can update it. After the form pops we touch the detail provider
  /// (the form's `onSaved` callbacks mutate the [Record] in place, so
  /// re-setting the same instance is enough to redraw with the new
  /// values) and re-fetch any parent list that might be holding a
  /// stale copy of the record.
  Future<void> _editRecord(BuildContext context, Record record) async {
    Provider.of<RecordCreationProvider>(context, listen: false).setRecordToEdit(record);
    final dynamic result = await Navigator.pushNamed(context, '/addEditRecord');
    if (!context.mounted) return;
    // poke the detail provider so the page rebuilds with the (possibly mutated) record values
    Provider.of<RecordDetailProvider>(context, listen: false).setCurrentRecord(record);
    if (result != null) {
      _refreshParentLists(context, record);
    }
  }

  /// Confirm + delete the current record. On success we pop back to
  /// the "Mes chronos" list (which is the only entry point) and ask
  /// it to refresh so the deleted row disappears.
  void _confirmAndDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppString.confirmation),
          content: Text(AppString.recordDeletionAreYouSure),
          actions: <Widget>[
            TextButton(child: Text(AppString.cancel), onPressed: () => Navigator.of(dialogContext).pop()),
            TextButton(
              child: Text(AppString.confirm),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final RecordDetailProvider detailProvider = Provider.of<RecordDetailProvider>(context, listen: false);
                // grab the record up-front, deleteRecord() clears the provider,
                // so we'd lose the member/track ids needed for the refresh otherwise
                final Record? deletedRecord = detailProvider.currentRecord;
                try {
                  await detailProvider.deleteRecord();
                  if (!context.mounted) return;
                  if (deletedRecord != null) {
                    _refreshParentLists(context, deletedRecord);
                  }
                  Navigator.pop(context);
                } catch (_) {
                  // snackbar already surfaced by deleteRecord
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Refresh whichever list could plausibly be displaying the record
  /// when we pop back. [RecordListProvider] holds a single slot per
  /// list type so we just overwrite each with the freshest data:
  ///
  ///  - `memberRecords` is whatever the previous screen filled it
  ///    with (the chrono's owner, when coming from member_detail).
  ///    Re-fetching for the chrono's owner keeps that slot
  ///    consistent. It only ever holds public records.
  ///  - `myRecords` backs "My lap times" view (the only list showing
  ///    private records), refresh it when the chrono belongs to the
  ///    logged member.
  ///  - `trackRecords` is the records of whichever track was last
  ///    visited (when coming from track_detail). Refresh for the
  ///    chrono's track for the same reason.
  ///
  /// Either fetch is a no-op when the underlying id is null, that
  /// should never happen for a record that came from the server,
  /// but stays defensive.
  void _refreshParentLists(BuildContext context, Record record) {
    final RecordListProvider listProvider = Provider.of<RecordListProvider>(context, listen: false);
    final int? loggedMemberId = Provider.of<LoginProvider>(context, listen: false).loggedMember?.id;
    final int? ownerId = record.member?.id;
    final int? trackId = record.track?.id;
    if (ownerId != null) {
      listProvider.fetchMemberRecords(ownerId);
    }
    if (ownerId != null && ownerId == loggedMemberId) {
      listProvider.fetchMyRecords();
    }
    if (trackId != null) {
      listProvider.fetchTrackRecords(trackId);
    }
  }

  /// Navigate to the pilot's member detail page. Mirrors the
  /// `_navigateToMemberDetailScreen` pattern used by event_detail:
  /// kick off the records refresh + fetch the full member, then push.
  void _navigateToMemberDetail(BuildContext context, Member member) {
    if (member.id == null) return;
    Provider.of<RecordListProvider>(context, listen: false).fetchMemberRecords(member.id!);
    Provider.of<MemberDetailProvider>(
      context,
      listen: false,
    ).fetchMember(member).then((_) => Navigator.pushNamed(context, '/memberDetail'));
  }

  /// Navigate to the track's detail page. The [track] embedded in a
  /// [Record] only carries `id`, `name` and `lapRecord` (limited
  /// GraphQL projection), so we also fire a full `fetchTrack` so the
  /// stat cards (distance, GPS, country, …) populate as soon as the
  /// network call returns. Push immediately so the user sees the
  /// hero without waiting; the cards fill in once the fetch lands.
  void _navigateToTrackDetail(BuildContext context, Track track) {
    final TrackDetailProvider provider = Provider.of<TrackDetailProvider>(context, listen: false);
    provider.setCurrentTrack(track);
    if (track.id != null) provider.fetchTrack(track); // fire-and-forget
    Navigator.pushNamed(context, '/trackDetail');
  }

  /// Localized label for the raw track-condition code stored on
  /// [Record.conditions]. Returns null for an unknown / null code so
  /// the caller can collapse the row entirely.
  String? _conditionLabel(String? code) {
    switch (code) {
      case 'dry':
        return AppString.recordConditionDry;
      case 'drying':
        return AppString.recordConditionDrying;
      case 'wet':
        return AppString.recordConditionWet;
      default:
        return null;
    }
  }

  /// Single info row inside the details card. When [onTap] is
  /// provided, the row becomes tappable (InkWell ripple) and a
  /// chevron is rendered at the right end to advertise that the
  /// row is interactive, same idiom as the "Mon compte" actions
  /// section. Requires a Material ancestor for the ripple, which
  /// the details card provides.
  ///
  /// [subtitle] is an optional secondary line rendered under the
  /// main value, in lighter / smaller text. Used e.g. on the
  /// ranking card to surface the rank position ("3ème meilleur
  /// chrono") right under the gap figure.
  Widget _detailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    final Widget row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
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
                Text(label, style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 12.0)),
                const SizedBox(height: 2.0),
                Text(
                  value,
                  style: TextStyle(color: Colors.black.withAlpha(220), fontSize: 15.0, fontWeight: FontWeight.w600),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.black.withAlpha(140), fontSize: 12.0, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Icon(Icons.chevron_right, size: 20.0, color: Colors.black.withAlpha(110)),
            ),
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }

  Widget _divider() {
    return Container(height: 1, color: Colors.white.withValues(alpha: 0.6));
  }

  /// Format a signed lap-time gap (in ms) for display:
  ///   1538 ms          → `+1"538`
  ///   −234 ms          → `− 0"234`
  ///   63010 ms         → `+1'03"010`
  ///   0                → `0"000`  (no sign — useful when the chrono
  ///                       happens to match the reference exactly)
  String _formatGap(int gapMs) {
    final int abs = gapMs.abs();
    final int m = abs ~/ 60000;
    final int s = (abs % 60000) ~/ 1000;
    final int ms = abs % 1000;
    final String mmm = ms.toString().padLeft(3, '0');
    final String digits = m > 0 ? '$m\'${s.toString().padLeft(2, '0')}"$mmm' : '$s"$mmm';
    if (gapMs == 0) return digits;
    return gapMs < 0 ? '− $digits' : '+$digits';
  }

  /// Build the "Classement" card, two gap rows: the chrono's delta
  /// to the best member chrono on this track, and to the track's
  /// official lap-record. Each row is rendered iff its reference is
  /// known; the card collapses entirely when neither is available.
  ///
  /// The card sits between the details card and the (optional)
  /// comments card so the visual flow reads: identity → ranking →
  /// notes.
  Widget? _buildRankingCard(Record record, List<Record> trackRecords) {
    final int? recordLap = record.lapTime;
    if (recordLap == null) return null;

    // best chrono among club members
    int? gapFromFirstMember;
    int? rank;
    if (trackRecords.isNotEmpty) {
      final List<Record> sorted = List<Record>.of(trackRecords)
        ..sort((a, b) {
          final int? aLap = a.lapTime;
          final int? bLap = b.lapTime;
          if (aLap == null && bLap == null) return 0;
          if (aLap == null) return 1;
          if (bLap == null) return -1;
          return aLap.compareTo(bLap);
        });
      final int? fastestLap = sorted.first.lapTime;
      if (fastestLap != null) {
        gapFromFirstMember = recordLap - fastestLap;
      }
      final int idx = sorted.indexWhere((r) => r.id == record.id);
      if (idx >= 0) rank = idx + 1;
    }
    final String? rankLabel = rank == null
        ? null
        : (rank == 1 ? '1er meilleur chrono des membres' : '${rank}ème meilleur chrono des membres');

    // gap to the track's official lap record
    final int? trackLapRecord = record.track?.lapRecord;
    final int? gapFromTrackRecord = (trackLapRecord != null && trackLapRecord > 0) ? recordLap - trackLapRecord : null;

    // nothing computable → collapse the card entirely so we don't emit an empty container.
    if (gapFromFirstMember == null && gapFromTrackRecord == null) return null;

    return Container(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 10.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.emoji_events, color: Colors.amber[800], size: 18.0),
                const SizedBox(width: 6.0),
                Text(
                  AppString.recordRankingTitle,
                  style: TextStyle(
                    color: Colors.black.withAlpha(170),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          _divider(),
          if (gapFromFirstMember != null)
            _detailRow(
              icon: Icons.timer_outlined,
              iconColor: Colors.blue[700]!,
              label: AppString.recordGapFromFirstMember,
              value: _formatGap(gapFromFirstMember),
              subtitle: rankLabel,
            ),
          if (gapFromFirstMember != null && gapFromTrackRecord != null) _divider(),
          if (gapFromTrackRecord != null)
            _detailRow(
              icon: Icons.flag,
              iconColor: Colors.red[700]!,
              label: AppString.recordGapFromTrackRecord,
              value: _formatGap(gapFromTrackRecord),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final RecordDetailProvider _recordDetailProvider = Provider.of<RecordDetailProvider>(context, listen: true);
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);
    // listening on the list provider so the ranking card refreshes as soon as trackRecords are loaded (initState triggers the fetch)
    final RecordListProvider _recordListProvider = Provider.of<RecordListProvider>(context, listen: true);
    final Record? record = _recordDetailProvider.currentRecord;

    // defensive fallback in case of session expiration / direct route
    if (record == null) {
      return Scaffold(body: Container(decoration: CustomDecorations.mainContent));
    }

    // edit / delete are only offered to the chrono's owner, and to admins as a moderation lever
    final int? loggedMemberId = _loginProvider.loggedMember?.id;
    final bool isOwner = loggedMemberId != null && record.member?.id == loggedMemberId;
    final bool canMutate = isOwner || _loginProvider.isAdmin;

    final String? conditionLabel = _conditionLabel(record.conditions);
    final String? trackName = record.track?.name;
    final String bikeLabel = record.bike != null
        ? "${StringUtils.capitalize(record.bike!.manufacturer ?? '')} ${record.bike!.modelName ?? ''}".trim()
        : AppString.notDefined;

    return Scaffold(
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 220,
              actions: <Widget>[
                if (canMutate) ...[
                  IconButton(
                    tooltip: AppString.recordEdit,
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => _editRecord(context, record),
                  ),
                  IconButton(
                    tooltip: AppString.recordDeletionAreYouSure,
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    onPressed: () => _confirmAndDelete(context),
                  ),
                ],
              ],
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  // `t` runs from 0.0 (header fully deployed) to 1.0
                  // (fully collapsed). We use it to fade out the hero
                  // content (chrono + track name) as the user scrolls,
                  // so by the time the "Détail du chrono" title settles
                  // on the collapsed bar it never overlaps the lap-time
                  // figure underneath. Same idiom as TrackDetail's
                  // country line.
                  final FlexibleSpaceBarSettings? settings = context
                      .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
                  double t = 0.0;
                  if (settings != null) {
                    final double deltaExtent = settings.maxExtent - settings.minExtent;
                    if (deltaExtent > 0) {
                      t = (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent).clamp(0.0, 1.0);
                    }
                  }
                  // hero fully visible until ~30 % collapsed, then fades linearly so it's gone before the title lands on top of it
                  final double heroOpacity = ((1.0 - (t - 0.3) * 2.5).clamp(0.0, 1.0)).toDouble();

                  return FlexibleSpaceBar(
                    title: Text(
                      AppString.recordDetailTitle,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    background: Stack(
                      alignment: Alignment.center,
                      fit: StackFit.expand,
                      children: <Widget>[
                        // track cover image as backdrop, falls back to a blue gradient if the asset isn't bundled
                        Image.asset(
                          TrackUtils.trackCoverImageUrlFromName(trackName),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.blue[700]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                        // dark gradient overlay so the lap time stays readable on top of the photo
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.0, -0.5),
                              end: Alignment(0.0, 0.8),
                              colors: <Color>[Colors.black.withAlpha(60), Colors.black.withAlpha(160)],
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: heroOpacity,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  AppDateUtils.toLapTimeString(record.lapTime) ?? '—',
                                  style: const TextStyle(
                                    fontFamily: 'AlarmClock',
                                    fontSize: 56.0,
                                    color: Colors.white,
                                    letterSpacing: -2.0,
                                    height: 1.0,
                                    shadows: [Shadow(color: Colors.black, blurRadius: 6.0, offset: Offset(0, 2))],
                                  ),
                                ),
                                if (trackName != null) ...[
                                  const SizedBox(height: 8.0),
                                  Text(
                                    trackName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      shadows: [Shadow(color: Colors.black, blurRadius: 4.0, offset: Offset(0, 1))],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(12.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  // details card
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.blue[100],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          spreadRadius: 0.5,
                          blurRadius: 0.5,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        children: <Widget>[
                          if (record.member != null &&
                              "${record.member!.firstName ?? ''} ${record.member!.lastName ?? ''}"
                                  .trim()
                                  .isNotEmpty) ...<Widget>[
                            _detailRow(
                              icon: Icons.person,
                              iconColor: Colors.indigo[600]!,
                              label: AppString.recordPilot,
                              value: "${record.member!.firstName ?? ''} ${record.member!.lastName ?? ''}".trim(),
                              onTap: () => _navigateToMemberDetail(context, record.member!),
                            ),
                            _divider(),
                          ],
                          _detailRow(
                            icon: Icons.event,
                            iconColor: Colors.teal[700]!,
                            label: AppString.recordDate,
                            value: record.recordDate != null
                                ? (AppDateUtils.convertToString(record.recordDate!, 'dd MMM yyyy') ?? '—')
                                : '—',
                          ),
                          _divider(),
                          _detailRow(
                            icon: TrackUtils.trackIconFromName(trackName),
                            iconColor: Colors.red[700]!,
                            label: AppString.eventTrackId,
                            value: trackName ?? '—',
                            onTap: record.track != null ? () => _navigateToTrackDetail(context, record.track!) : null,
                          ),
                          _divider(),
                          _detailRow(
                            icon: CustomIcons.motorbike_plain,
                            iconColor: Colors.deepPurple,
                            label: AppString.recordBikeLabel,
                            value: bikeLabel.isEmpty ? AppString.notDefined : bikeLabel,
                          ),
                          if (conditionLabel != null) ...[
                            _divider(),
                            _detailRow(
                              icon: TrackUtils.trackConditionIconData(record.conditions) ?? Icons.help_outline,
                              iconColor: TrackUtils.trackConditionColor(record.conditions),
                              label: AppString.recordConditionLabel,
                              value: conditionLabel,
                            ),
                          ],
                          if (record.comments != null) ...[
                            _divider(),
                            _detailRow(
                              icon: TrackUtils.trackConditionIconData(record.comments) ?? Icons.comment,
                              iconColor: Colors.brown,
                              label: AppString.recordCommentsLabel,
                              value: record.comments!,
                            ),
                          ],
                          // only flag private chronos, public is the norm and would be noise on every row
                          if (record.isPublic == false) ...[
                            _divider(),
                            _detailRow(
                              icon: Icons.lock,
                              iconColor: Colors.amber[800]!,
                              label: AppString.recordVisibilityLabel,
                              value: AppString.recordVisibilityPrivate,
                              subtitle: AppString.recordVisibilityPrivateInfo,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // ranking card, chrono's position on the track and its gaps to the leader / official lap record.
                  () {
                    final Widget? rankingCard = _buildRankingCard(record, _recordListProvider.trackRecords.toList());
                    if (rankingCard == null) return const SizedBox.shrink();
                    return Padding(padding: const EdgeInsets.only(top: 12.0), child: rankingCard);
                  }(),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16.0),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
