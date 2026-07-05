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
import 'package:ccteam/models/record.dart';
import 'package:ccteam/models/track.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/record_creation_provider.dart';
import 'package:ccteam/providers/record_detail_provider.dart';
import 'package:ccteam/providers/record_list_provider.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/string_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/utils/track_utils.dart';
import 'package:ccteam/widgets/info_banner.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:ccteam/widgets/restricted_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberChronos extends StatefulWidget {
  const MemberChronos({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MemberChronosState();
  }
}

class _MemberChronosState extends State<MemberChronos> {
  // active filters. Tracks are multi-select (empty set = "all circuits");
  // bike (by id) and condition (raw code, 'dry' etc.) are single-select (null = "all").
  final Set<int> _filterTrackIds = {};
  int? _filterBikeId;
  String? _filterCondition;

  @override
  void initState() {
    super.initState();
  }

  /// Method that launches the Add Record screen and awaits the result from Navigator.pop
  _navigateToAddRecordScreen(BuildContext context) async {
    // set a new record to be created
    Provider.of<RecordCreationProvider>(context, listen: false).setRecordToEdit(new Record());
    final result = await Navigator.pushNamed(context, '/addEditRecord');
    if (result != null) {
      Provider.of<RecordListProvider>(context, listen: false).fetchMyRecords();
    }
  }

  bool get _filterActive => _filterTrackIds.isNotEmpty || _filterBikeId != null || _filterCondition != null;

  /// Keep only the records matching every active filter (AND across dimensions,
  /// a record matches the circuit filter when its track is any of the selected ones).
  List<Record> _applyFilters(List<Record> records) {
    return records.where((r) {
      if (_filterTrackIds.isNotEmpty && !_filterTrackIds.contains(r.track?.id)) return false;
      if (_filterBikeId != null && r.bike?.id != _filterBikeId) return false;
      if (_filterCondition != null && r.conditions != _filterCondition) return false;
      return true;
    }).toList();
  }

  /// Localized label for a track-condition code, falling back to the raw code.
  String _conditionLabel(String? code) {
    switch (code) {
      case 'dry':
        return AppString.recordConditionDry;
      case 'drying':
        return AppString.recordConditionDrying;
      case 'wet':
        return AppString.recordConditionWet;
      default:
        return code ?? '';
    }
  }

  String _bikeLabel(Bike bike) => "${StringUtils.capitalize(bike.manufacturer ?? '')} ${bike.modelName ?? ''}".trim();

  /// Distinct tracks present in the records, de-duplicated by id and sorted by name.
  List<Track> _distinctTracks(List<Record> records) {
    final Map<int, Track> byId = {};
    for (final r in records) {
      final Track? t = r.track;
      if (t?.id != null) byId.putIfAbsent(t!.id!, () => t);
    }
    final List<Track> tracks = byId.values.toList()
      ..sort((a, b) => (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));
    return tracks;
  }

  /// Distinct bikes present in the records, de-duplicated by id and sorted by label.
  List<Bike> _distinctBikes(List<Record> records) {
    final Map<int, Bike> byId = {};
    for (final r in records) {
      final Bike? b = r.bike;
      if (b?.id != null) byId.putIfAbsent(b!.id!, () => b);
    }
    final List<Bike> bikes = byId.values.toList()
      ..sort((a, b) => _bikeLabel(a).toLowerCase().compareTo(_bikeLabel(b).toLowerCase()));
    return bikes;
  }

  /// Distinct condition codes present in the records, in weather order.
  List<String> _distinctConditions(List<Record> records) {
    const List<String> order = ['dry', 'drying', 'wet'];
    final Set<String> present = records.map((r) => r.conditions).whereType<String>().toSet();
    return order.where(present.contains).toList();
  }

  /// AppBar filter icon, with a small red dot overlaid when a filter is active.
  Widget _buildFilterAction(List<Record> records) {
    return IconButton(
      tooltip: AppString.chronoFilterTooltip,
      onPressed: () => _openFilterSheet(records),
      icon: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          const Icon(Icons.filter_list),
          if (_filterActive)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: Colors.red[700],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Open the filter as a modal bottom sheet with three sections (circuit / bike / weather).
  /// Selecting a chip applies the filter live to the list behind the sheet,
  /// tapping "Tous" (or the active chip again) clears that dimension.
  void _openFilterSheet(List<Record> records) {
    final List<Track> tracks = _distinctTracks(records);
    final List<Bike> bikes = _distinctBikes(records);
    final List<String> conditions = _distinctConditions(records);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            // apply a change both to the page (so the list updates behind the sheet) and to the sheet (so chips refresh)
            void apply(VoidCallback change) {
              setState(change);
              setSheetState(() {});
            }

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[100]!, Colors.blue[200]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
              ),
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 12.0,
                bottom: MediaQuery.of(context).padding.bottom + 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // grab handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12.0),
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2.0)),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Icon(Icons.filter_list, color: Colors.blue[700]),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          AppString.chronoFilterTitle,
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (_filterActive)
                        TextButton.icon(
                          onPressed: () => apply(() {
                            _filterTrackIds.clear();
                            _filterBikeId = null;
                            _filterCondition = null;
                          }),
                          icon: const Icon(Icons.filter_alt_off, size: 18.0),
                          label: Text(AppString.chronoFilterReset),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // circuit (multi-select): "Tous" clears the set, each tile toggles one track
                          _buildFilterSectionLabel(AppString.chronoFilterTrackSection),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: <Widget>[
                              _FilterTile(
                                icon: Icons.done_all,
                                iconColor: Colors.black.withAlpha(140),
                                label: AppString.chronoFilterAll,
                                selected: _filterTrackIds.isEmpty,
                                onTap: () => apply(() => _filterTrackIds.clear()),
                              ),
                              for (final Track t in tracks)
                                _FilterTile(
                                  icon: TrackUtils.trackIconFromName(t.name),
                                  iconColor: Colors.red[600]!,
                                  label: t.name ?? AppString.notDefined,
                                  selected: t.id != null && _filterTrackIds.contains(t.id),
                                  onTap: () => apply(() {
                                    if (t.id == null) return;
                                    if (_filterTrackIds.contains(t.id)) {
                                      _filterTrackIds.remove(t.id);
                                    } else {
                                      _filterTrackIds.add(t.id!);
                                    }
                                  }),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          // bike (single-select)
                          _buildFilterSectionLabel(AppString.chronoFilterBikeSection),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: <Widget>[
                              _FilterTile(
                                icon: Icons.done_all,
                                iconColor: Colors.black.withAlpha(140),
                                label: AppString.chronoFilterAll,
                                selected: _filterBikeId == null,
                                onTap: () => apply(() => _filterBikeId = null),
                              ),
                              for (final Bike b in bikes)
                                _FilterTile(
                                  icon: CustomIcons.motorbike_plain,
                                  iconColor: Colors.deepPurple,
                                  label: _bikeLabel(b),
                                  selected: _filterBikeId == b.id,
                                  onTap: () => apply(() => _filterBikeId = _filterBikeId == b.id ? null : b.id),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          // weather (single-select)
                          _buildFilterSectionLabel(AppString.chronoFilterWeatherSection),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: <Widget>[
                              _FilterTile(
                                icon: Icons.done_all,
                                iconColor: Colors.black.withAlpha(140),
                                label: AppString.chronoFilterAll,
                                selected: _filterCondition == null,
                                onTap: () => apply(() => _filterCondition = null),
                              ),
                              for (final String c in conditions)
                                _FilterTile(
                                  icon: TrackUtils.trackConditionIconData(c) ?? Icons.help_outline,
                                  iconColor: TrackUtils.trackConditionColor(c),
                                  label: _conditionLabel(c),
                                  selected: _filterCondition == c,
                                  onTap: () => apply(() => _filterCondition = _filterCondition == c ? null : c),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600, color: Colors.black.withValues(alpha: 0.6)),
      ),
    );
  }

  /// Placeholder shown when the active filter hides every chrono, with a
  /// one-tap way to clear the filters.
  Widget _buildFilterEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        const SizedBox(height: 60.0),
        Icon(Icons.filter_alt_off, size: 48.0, color: Colors.black.withValues(alpha: 0.30)),
        const SizedBox(height: 12.0),
        Center(
          child: Text(
            AppString.chronoFilterNoMatch,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
          ),
        ),
        const SizedBox(height: 12.0),
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() {
              _filterTrackIds.clear();
              _filterBikeId = null;
              _filterCondition = null;
            }),
            icon: const Icon(Icons.clear),
            label: Text(AppString.chronoFilterClear),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordRow(BuildContext context, Record record, RecordListProvider recordListProvider) {
    return InkWell(
      onTap: () async {
        Provider.of<RecordDetailProvider>(context, listen: false).setCurrentRecord(record);
        await Navigator.pushNamed(context, '/chronoDetail');
        if (!context.mounted) return;
        recordListProvider.fetchMyRecords();
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: CustomDecorations.cardFull,
        height: 90,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(TrackUtils.trackIconFromName(record.track!.name), size: 22, color: Colors.red[600]),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          record.track!.name!,
                          textScaler: TextScaler.linear(1.3),
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: <Widget>[
                      Icon(Icons.event, size: 16, color: Colors.teal[700]),
                      SizedBox(width: 5.0),
                      Text(
                        AppDateUtils.convertToString(record.recordDate!, 'dd MMM yyyy') ?? "",
                        style: TextStyle(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (TrackUtils.trackConditionIconData(record.conditions) != null) ...[
                        SizedBox(width: 8.0),
                        Icon(
                          TrackUtils.trackConditionIconData(record.conditions),
                          size: 18,
                          color: TrackUtils.trackConditionColor(record.conditions),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Icon(CustomIcons.motorbike_plain, size: 16, color: Colors.deepPurple),
                      SizedBox(width: 5.0),
                      Expanded(
                        child: Text(
                          record.bike != null
                              ? "${StringUtils.capitalize(record.bike!.manufacturer ?? '')} ${record.bike!.modelName ?? ''}"
                              : AppString.notDefined,
                          style: TextStyle(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.0),
            // private chronos are only visible here, flag them with a lock
            if (record.isPublic == false) ...[
              Tooltip(
                message: AppString.recordVisibilityPrivate,
                child: Icon(Icons.lock, size: 18, color: Colors.red[700]),
              ),
              SizedBox(width: 8.0),
            ],
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: Colors.white),
              ),
              child: Text(
                AppDateUtils.toLapTimeString(record.lapTime) ?? "",
                style: TextStyle(fontFamily: "AlarmClock", color: Colors.white),
                textScaler: TextScaler.linear(1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    if (!_loginProvider.isMember) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppString.myChronos),
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        ),
        body: Container(decoration: CustomDecorations.mainContent, child: RestrictedContent()),
      );
    }

    final RecordListProvider _recordListProvider = Provider.of<RecordListProvider>(context, listen: true);
    final List<Record> allRecords = _recordListProvider.myRecords.toList();

    // drop any filter whose value no longer exists in the records (e.g. after a refresh)
    _filterTrackIds.removeWhere((id) => !allRecords.any((r) => r.track?.id == id));
    if (_filterBikeId != null && !allRecords.any((r) => r.bike?.id == _filterBikeId)) _filterBikeId = null;
    if (_filterCondition != null && !allRecords.any((r) => r.conditions == _filterCondition)) _filterCondition = null;

    final List<Record> records = _applyFilters(allRecords);
    // the filter hides everything only when there ARE chronos but none match
    final bool filterHidesEverything = allRecords.isNotEmpty && records.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.myChronos),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: <Widget>[
          // filter is only useful once there is something to filter
          if (allRecords.isNotEmpty) _buildFilterAction(allRecords),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: CustomDecorations.mainContent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const InfoBanner(message: AppString.myChronosHelp),
            const SizedBox(height: 8.0),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _recordListProvider.fetchMyRecords(),
                child: LoadingContent(
                  defaultText: AppString.eventsNotFound,
                  emptyText: AppString.eventsNotFound,
                  loadingStatus: _recordListProvider.loadingStatus,
                  child: filterHidesEverything
                      ? _buildFilterEmptyState()
                      : ListView.separated(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 72.0),
                          separatorBuilder: (context, index) => SizedBox(height: 8.0),
                          itemCount: records.length,
                          itemBuilder: (context, index) =>
                              _buildRecordRow(context, records[index], _recordListProvider),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.red[700],
        onPressed: () {
          _navigateToAddRecordScreen(context);
        },
      ),
    );
  }
}

/// Single badge of the chrono filter bottom sheet.
class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: selected ? Colors.green[700]! : Colors.white, width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 18.0, color: iconColor),
              const SizedBox(width: 8.0),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180.0),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.black.withAlpha(204),
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selected) ...[const SizedBox(width: 6.0), Icon(Icons.check, size: 18.0, color: Colors.green[700])],
            ],
          ),
        ),
      ),
    );
  }
}
