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
import 'package:ccteam/models/event_member.dart';
import 'package:ccteam/models/record.dart';
import 'package:ccteam/providers/bike_list_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/record_detail_provider.dart';
import 'package:ccteam/providers/record_list_provider.dart';
import 'package:ccteam/utils/bike_utils.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/member_stats.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/utils/track_utils.dart';
import 'package:ccteam/widgets/random_pattern_painter.dart';
import 'package:ccteam/widgets/restricted_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// Read-only detail page for a single bike, reached by tapping a bike in
/// the "My bikes" list (the bike travels through the route arguments).
class BikeDetail extends StatefulWidget {
  const BikeDetail({Key? key}) : super(key: key);

  @override
  State<BikeDetail> createState() => _BikeDetailState();
}

class _BikeDetailState extends State<BikeDetail> {
  // bike passed by the list page, only used as the identity (id), the displayed values are re-derived from
  // BikeListProvider on every build so the page refreshes after an edit
  Bike? _initialBike;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialBike ??= ModalRoute.of(context)!.settings.arguments as Bike?;
  }

  /// Open the bike form seeded with the current bike.
  /// The provider notifies after the update, which rebuilds this page with the fresh values.
  Future<void> _editBike(BuildContext context, Bike bike) async {
    await Navigator.pushNamed(context, '/addEditBike', arguments: bike);
    if (mounted) setState(() {});
  }

  /// Confirm + delete the current bike, then pop back to the "My bikes" list.
  /// Same dialog content as the bike form (including the warning about event participations losing their bike reference).
  void _confirmAndDelete(BuildContext context, Bike bike) {
    final BikeListProvider bikeListProvider = Provider.of<BikeListProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppString.confirmation),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(AppString.bikeDeletionAreYouSure),
              const SizedBox(height: 12.0),
              Text(
                AppString.bikeDeleteWarning,
                style: TextStyle(
                  fontSize: 13.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.black.withAlpha(160),
                  height: 1.35,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(child: Text(AppString.cancel), onPressed: () => Navigator.of(dialogContext).pop()),
            TextButton(
              child: Text(AppString.confirm),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                bikeListProvider.deleteBike(bike).then((value) {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      },
    );
  }

  /// Open the chrono detail page for the specified [record].
  void _navigateToChronoDetail(BuildContext context, Record record) {
    Provider.of<RecordDetailProvider>(context, listen: false).setCurrentRecord(record);
    Navigator.pushNamed(context, '/chronoDetail');
  }

  /// Single info row inside the details card, same idiom as the chrono detail page
  /// (icon in a soft circular halo + label above value).
  Widget _detailRow({required IconData icon, required Color iconColor, required String label, required String value}) {
    return Padding(
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(height: 1, color: Colors.white.withValues(alpha: 0.6));
  }

  /// Build the "Chronos avec cette moto" card from the logged member's own records.
  /// Collapses entirely when no chrono was set with this bike.
  Widget? _buildChronosCard(BuildContext context, Bike bike, List<Record> myRecords) {
    final List<Record> records = myRecords.where((r) => r.bike?.id == bike.id).toList();
    if (records.isEmpty) return null;

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
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 10.0),
              child: Row(
                children: <Widget>[
                  Icon(Icons.timer, color: Colors.blue[700], size: 18.0),
                  const SizedBox(width: 6.0),
                  Text(
                    AppString.bikeChronosTitle,
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
            for (int i = 0; i < records.length; i++) ...[
              if (i > 0) _divider(),
              InkWell(
                onTap: () => _navigateToChronoDetail(context, records[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                  child: Row(
                    children: <Widget>[
                      Icon(TrackUtils.trackIconFromName(records[i].track?.name), size: 18.0, color: Colors.red[700]),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          records[i].track?.name ?? '—',
                          style: TextStyle(color: Colors.black.withAlpha(220), fontSize: 14.0),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (TrackUtils.trackConditionIconData(records[i].conditions) != null) ...[
                        Icon(
                          TrackUtils.trackConditionIconData(records[i].conditions),
                          size: 16.0,
                          color: TrackUtils.trackConditionColor(records[i].conditions),
                        ),
                        const SizedBox(width: 8.0),
                      ],
                      Text(
                        AppDateUtils.toLapTimeString(records[i].lapTime) ?? '—',
                        style: TextStyle(fontFamily: 'AlarmClock', fontSize: 16.0, color: Colors.black.withAlpha(220)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Icon(Icons.chevron_right, size: 18.0, color: Colors.black.withAlpha(110)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build the "Statistiques" card: estimated km, number of track days and
  /// most ridden track with this bike. Reuses the [MemberStatsUtils] heuristics
  /// of the "Mon compte" page, with the participations filtered on this bike
  /// (so only the track days where this bike was pinned count).
  Widget _buildStatsCard(List<EventMember> bikeEventMembers, List<Record> myRecords) {
    final DateTime now = DateTime.now();
    final int events = MemberStatsUtils.pastEventsCount(eventMembers: bikeEventMembers, now: now);
    final int km = MemberStatsUtils.estimateKm(eventMembers: bikeEventMembers, records: myRecords, now: now);
    final MostRiddenTrack? favTrack = MemberStatsUtils.mostRiddenTrack(eventMembers: bikeEventMembers, now: now);

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
                Icon(Icons.query_stats, color: Colors.green[700], size: 18.0),
                const SizedBox(width: 6.0),
                Text(
                  AppString.statistics,
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
          _detailRow(
            icon: Icons.route,
            iconColor: Colors.green[700]!,
            label: AppString.statsKmEstimated,
            value: "≈ $km km",
          ),
          _divider(),
          _detailRow(
            icon: Icons.event,
            iconColor: Colors.purple[600]!,
            label: AppString.statsTrackEventsCount,
            value: events.toString(),
          ),
          if (favTrack != null) ...[
            _divider(),
            _detailRow(
              icon: TrackUtils.trackIconFromName(favTrack.name),
              iconColor: Colors.red[700]!,
              label: AppString.statsFavoriteTrack,
              value: "${favTrack.name} (${AppString.format(AppString.statsFavoriteTrackTimes, [favTrack.count])})",
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // listening so the statistics refresh when the participations change (event registration, bike pinning...)
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: true);

    if (!_loginProvider.isMember || _initialBike == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppString.bikeDetailTitle),
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        ),
        body: Container(decoration: CustomDecorations.mainContent, child: RestrictedContent()),
      );
    }

    // listening so the page rebuilds with fresh values after an edit, and the chronos card reacts to a records refresh
    final BikeListProvider _bikeListProvider = Provider.of<BikeListProvider>(context, listen: true);
    final RecordListProvider _recordListProvider = Provider.of<RecordListProvider>(context, listen: true);

    // re-derive the freshest version of the bike from the provider (the list slot is the source of truth after an update)
    final Bike bike = _bikeListProvider.bikes.firstWhere((b) => b.id == _initialBike!.id, orElse: () => _initialBike!);

    // same "effective current" rule as the list page: the explicitly flagged bike, or the first one when none is flagged
    final bool isCurrent =
        _bikeListProvider.bikes.isNotEmpty &&
        bike.id ==
            _bikeListProvider.bikes
                .firstWhere((b) => b.current ?? false, orElse: () => _bikeListProvider.bikes.first)
                .id;

    final String bikeLabel = "${(bike.manufacturer ?? '').toUpperCase()} ${bike.modelName ?? ''}".trim();
    final String? logoPath = BikeUtils.manufacturerLogoPath(bike.manufacturer);

    // participations where this bike was pinned, the basis of the statistics card
    final List<EventMember> bikeEventMembers = (_loginProvider.loggedMember?.eventMembers ?? const <EventMember>[])
        .where((em) => em.bike?.id == bike.id)
        .toList();

    return Scaffold(
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              actions: <Widget>[
                IconButton(
                  tooltip: AppString.bikeEdit,
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () => _editBike(context, bike),
                ),
                IconButton(
                  tooltip: AppString.bikeDeletionAreYouSure,
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  onPressed: () => _confirmAndDelete(context, bike),
                ),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final FlexibleSpaceBarSettings settings = context
                      .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
                  final double deltaExtent = settings.maxExtent - settings.minExtent;
                  final double t = (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent).clamp(0.0, 1.0);

                  // t is 0.0 when completely deployed, 1.0 when completely collapsed
                  return FlexibleSpaceBar(
                    expandedTitleScale: 1.0,
                    titlePadding: EdgeInsets.only(left: 144.0 - t * 88, bottom: 15.0 - t * 11.0),
                    title: Container(
                      height: 100.0 - t * 52.0,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        bikeLabel.isEmpty ? AppString.notDefined : bikeLabel,
                        // size and weight follow the collapse progress
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0 - t * 8.0,
                          fontWeight: FontWeight.lerp(FontWeight.bold, FontWeight.normal, t),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    background: Stack(
                      alignment: Alignment.bottomLeft,
                      fit: StackFit.expand,
                      children: <Widget>[
                        // procedurally-generated pattern background, seeded by the bike id
                        Positioned.fill(
                          child: CustomPaint(painter: RandomPatternPainter(seed: bike.id ?? 0)),
                        ),
                        // dark bottom gradient so the title and name stay readable over the pattern
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.0, 0.5),
                              end: Alignment(0.0, -0.5),
                              colors: <Color>[
                                Colors.black.withAlpha(179),
                                Colors.black.withAlpha(76),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // white circular badge with the manufacturer logo
                        Positioned(
                          bottom: 15.0,
                          left: 15.0,
                          child: Container(
                            width: 100.0,
                            height: 100.0,
                            padding: const EdgeInsets.all(18.0),
                            decoration: const ShapeDecoration(shape: CircleBorder(), color: Colors.white),
                            child: logoPath != null
                                ? SvgPicture.asset(logoPath, fit: BoxFit.contain)
                                : Icon(CustomIcons.motorbike_plain, color: Colors.deepPurple, size: 48),
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
                    child: Column(
                      children: <Widget>[
                        _detailRow(
                          icon: Icons.factory,
                          iconColor: Colors.indigo[600]!,
                          label: AppString.bikeManufacturer,
                          value: StringUtils.capitalize(bike.manufacturer ?? '') ?? AppString.notDefined,
                        ),
                        _divider(),
                        _detailRow(
                          icon: CustomIcons.motorbike_plain,
                          iconColor: Colors.deepPurple,
                          label: AppString.bikeModel,
                          value: bike.modelName ?? AppString.notDefined,
                        ),
                        _divider(),
                        _detailRow(
                          icon: Icons.speed,
                          iconColor: Colors.red[700]!,
                          label: AppString.bikeEngineSize,
                          value: bike.engineSize != null ? "${bike.engineSize} cc" : AppString.notDefined,
                        ),
                        _divider(),
                        _detailRow(
                          icon: Icons.calendar_today,
                          iconColor: Colors.teal[700]!,
                          label: AppString.bikeYear,
                          value: bike.year?.toString() ?? AppString.notDefined,
                        ),
                        if (isCurrent) ...[
                          _divider(),
                          _detailRow(
                            icon: Icons.star,
                            iconColor: Colors.amber[800]!,
                            label: AppString.bikeStatusLabel,
                            value: AppString.bikeCurrentLabel,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // bike usage statistics
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: _buildStatsCard(bikeEventMembers, _recordListProvider.myRecords.toList()),
                  ),
                  // chronos recorded with this bike
                  () {
                    final Widget? chronosCard = _buildChronosCard(
                      context,
                      bike,
                      _recordListProvider.myRecords.toList(),
                    );
                    if (chronosCard == null) return const SizedBox.shrink();
                    return Padding(padding: const EdgeInsets.only(top: 12.0), child: chronosCard);
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
