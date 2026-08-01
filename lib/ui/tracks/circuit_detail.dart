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

import 'package:ccteam/models/circuit.dart';
import 'package:ccteam/models/track.dart';
import 'package:ccteam/providers/circuit_creation_provider.dart';
import 'package:ccteam/providers/circuit_detail_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/track_creation_provider.dart';
import 'package:ccteam/providers/track_detail_provider.dart';
import 'package:ccteam/utils/app_utils.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/utils/track_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Detail page for a [Circuit] (venue): its identity (cover, country, GPS,
/// website) and the list of its versions (layouts). Tapping a version opens the
/// version detail; admins can edit the circuit and add / edit versions.
class CircuitDetail extends StatelessWidget {
  const CircuitDetail({Key? key}) : super(key: key);

  /// Open the version detail for the tapped [track].
  void _openVersion(BuildContext context, Track track) {
    Provider.of<TrackDetailProvider>(
      context,
      listen: false,
    ).setCurrentTrack(track);
    if (track.id != null)
      Provider.of<TrackDetailProvider>(
        context,
        listen: false,
      ).fetchTrack(track);
    Navigator.pushNamed(context, '/trackDetail');
  }

  /// Open the version form seeded with a fresh version pre-attached to [circuit].
  void _addVersion(BuildContext context, Circuit circuit) {
    Provider.of<TrackCreationProvider>(
      context,
      listen: false,
    ).setTrackToEdit(Track(circuit: circuit));
    Navigator.pushNamed(context, '/addEditTrack');
  }

  /// Open the version form seeded with a clone of [track] (edit flow).
  void _editVersion(BuildContext context, Track track) {
    Provider.of<TrackCreationProvider>(
      context,
      listen: false,
    ).setTrackToEdit(Track.clone(track));
    Navigator.pushNamed(context, '/addEditTrack');
  }

  /// Open the circuit form seeded with a clone of [circuit] (edit flow).
  void _editCircuit(BuildContext context, Circuit circuit) {
    Provider.of<CircuitCreationProvider>(
      context,
      listen: false,
    ).setCircuitToEdit(Circuit.clone(circuit));
    Navigator.pushNamed(context, '/addEditCircuit');
  }

  Widget _infoRow(
    IconData icon,
    Color color,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    final Widget row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: color, size: 20.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black.withAlpha(150),
                    fontSize: 12.0,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.black.withAlpha(220),
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              size: 20.0,
              color: Colors.black.withAlpha(110),
            ),
        ],
      ),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }

  Widget _divider() =>
      Container(height: 1, color: Colors.white.withValues(alpha: 0.6));

  Widget _versionCard(
    BuildContext context,
    Circuit circuit,
    Track track,
    bool isAdmin,
  ) {
    final String title =
        (track.variantName != null && track.variantName!.trim().isNotEmpty)
        ? track.variantName!
        : AppString.circuitSingleVersion;
    final String? lapTime = AppDateUtils.toLapTimeString(track.lapRecord);
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
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
        child: InkWell(
          onTap: () => _openVersion(context, track),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 12.0,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red[700]!.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    TrackUtils.iconForTrack(track),
                    color: Colors.red[700],
                    size: 24.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3.0),
                      Row(
                        children: <Widget>[
                          if (track.distance != null) ...[
                            Icon(
                              Icons.straighten,
                              size: 13.0,
                              color: Colors.black.withAlpha(140),
                            ),
                            const SizedBox(width: 3.0),
                            Text(
                              "${(track.distance! / 1000).toStringAsFixed(2)} km",
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black.withAlpha(160),
                              ),
                            ),
                            const SizedBox(width: 10.0),
                          ],
                          if (lapTime != null) ...[
                            Icon(
                              Icons.timer,
                              size: 13.0,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 3.0),
                            Text(
                              lapTime,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black.withAlpha(160),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (isAdmin)
                  IconButton(
                    tooltip: AppString.trackEdit,
                    icon: Icon(Icons.edit, size: 20.0, color: Colors.blue[700]),
                    onPressed: () => _editVersion(context, track),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CircuitDetailProvider _provider = Provider.of<CircuitDetailProvider>(
      context,
      listen: true,
    );
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(
      context,
      listen: false,
    );
    final Circuit? circuit = _provider.currentCircuit;
    final bool isAdmin = _loginProvider.isAdmin;

    if (circuit == null) {
      return Scaffold(
        body: Container(decoration: CustomDecorations.mainContent),
      );
    }

    final List<Track> versions = circuit.tracks ?? <Track>[];
    final String lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              foregroundColor: Colors.white,
              actions: <Widget>[
                if (circuit.website != null && circuit.website!.isNotEmpty)
                  IconButton(
                    tooltip: AppString.trackWebsite,
                    icon: const Icon(Icons.public, color: Colors.white),
                    onPressed: () => AppUtils.launchURL(circuit.website!),
                  ),
                if (isAdmin)
                  IconButton(
                    tooltip: AppString.circuitEdit,
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => _editCircuit(context, circuit),
                  ),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final FlexibleSpaceBarSettings settings = context
                      .dependOnInheritedWidgetOfExactType<
                        FlexibleSpaceBarSettings
                      >()!;
                  final double deltaExtent =
                      settings.maxExtent - settings.minExtent;
                  // t is 0.0 when fully deployed, 1.0 when fully collapsed
                  final double t =
                      (1.0 -
                              (settings.currentExtent - settings.minExtent) /
                                  deltaExtent)
                          .clamp(0.0, 1.0);
                  return FlexibleSpaceBar(
                    titlePadding: EdgeInsetsDirectional.only(
                      start: 16.0 + t * 40.0,
                      bottom: 16.0,
                    ),
                    title: Text(
                      circuit.name ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0 - t * 6.0,
                        fontWeight: FontWeight.lerp(
                          FontWeight.bold,
                          FontWeight.normal,
                          t,
                        ),
                        shadows: t < 0.5
                            ? const [
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 3.0,
                                  color: Colors.black,
                                ),
                              ]
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Image.asset(
                          TrackUtils.coverImageForCircuit(circuit),
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
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.black.withAlpha(120),
                                Colors.black.withAlpha(40),
                                Colors.black.withAlpha(150),
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
                  // venue info card
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
                        if (circuit.country != null)
                          _infoRow(
                            Icons.public,
                            Colors.indigo[600]!,
                            AppString.trackCountry,
                            "${circuit.country!.flagEmoji}  ${circuit.country!.localizedName(lang)}",
                          ),
                        if (circuit.latitude != null &&
                            circuit.longitude != null) ...[
                          _divider(),
                          _infoRow(
                            Icons.place,
                            Colors.red[700]!,
                            "GPS",
                            "${circuit.latitude!.toStringAsFixed(5)}, ${circuit.longitude!.toStringAsFixed(5)}",
                          ),
                        ],
                      ],
                    ),
                  ),
                  // versions section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2.0, 18.0, 2.0, 4.0),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.alt_route,
                          size: 18.0,
                          color: Colors.black.withAlpha(180),
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(
                            AppString.circuitVersionsSectionTitle,
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black.withAlpha(200),
                            ),
                          ),
                        ),
                        if (isAdmin)
                          TextButton.icon(
                            onPressed: () => _addVersion(context, circuit),
                            icon: const Icon(Icons.add, size: 18.0),
                            label: Text(AppString.circuitAddVersion),
                          ),
                      ],
                    ),
                  ),
                  if (versions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          AppString.circuitNoVersion,
                          style: TextStyle(
                            color: Colors.black.withAlpha(150),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  else
                    ...versions.map(
                      (Track t) => _versionCard(context, circuit, t, isAdmin),
                    ),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 16.0,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
