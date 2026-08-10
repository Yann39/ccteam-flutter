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
import 'package:ccteam/providers/circuit_list_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/track_detail_provider.dart';
import 'package:ccteam/ui/main/main_action_menu.dart';
import 'package:ccteam/ui/main/main_drawer.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/utils/track_utils.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// "Circuits" tab: lists the circuits (venues). Each circuit groups one or more
/// versions (layouts). We keep the stateful widget to preserve the search field.
class Tracks extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TracksState();
  }
}

class _TracksState extends State<Tracks> {
  /// Build the search field
  Widget buildSearchField(CircuitListProvider _circuitListProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
          hintText: AppString.tracksSearchHint,
          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.blue[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.blue[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 1.5),
          ),
        ),
        maxLines: 1,
        onChanged: (String text) {
          _circuitListProvider.searchCircuits(text);
        },
      ),
    );
  }

  /// Open a circuit from the list. A circuit with a single version has no useful
  /// intermediate page (it would list just that one version), so we jump straight
  /// to the version detail; circuits with several versions (or none) open the
  /// circuit detail so the user can pick a version / an admin can manage them.
  void _openCircuit(BuildContext context, Circuit circuit) {
    final List<Track> versions = circuit.tracks ?? <Track>[];
    if (versions.length == 1) {
      final Track version = versions.first;
      Provider.of<TrackDetailProvider>(context, listen: false).setCurrentTrack(version);
      if (version.id != null) {
        Provider.of<TrackDetailProvider>(context, listen: false).fetchTrack(version); // fire-and-forget
      }
      Navigator.pushNamed(context, '/trackDetail');
      return;
    }
    Provider.of<CircuitDetailProvider>(context, listen: false).setCurrentCircuit(circuit);
    Provider.of<CircuitDetailProvider>(context, listen: false).fetchCircuit(circuit); // fire-and-forget
    Navigator.pushNamed(context, '/circuitDetail');
  }

  /// Seed the creation provider with a fresh, empty [Circuit] and open the form.
  void _navigateToAddCircuitScreen(BuildContext context) {
    Provider.of<CircuitCreationProvider>(context, listen: false).setCircuitToEdit(Circuit());
    Navigator.pushNamed(context, '/addEditCircuit');
  }

  /// Build a single circuit card: cover photo on top half + info (name, country,
  /// number of versions) on a blue gradient bottom half. A circular icon badge
  /// sits in the top-right corner of the photo.
  Widget _buildCircuitCard(BuildContext context, Circuit circuit) {
    final int versionCount = circuit.tracks?.length ?? 0;
    // with a single version, show its length under the name, with several, show the version count instead
    final int? soleDistance = versionCount == 1 ? circuit.tracks!.first.distance : null;
    final bool showDistance = soleDistance != null;
    final IconData subtitleIcon = showDistance ? Icons.straighten : Icons.alt_route;
    final String subtitleLabel = showDistance
        ? "${(soleDistance / 1000).toStringAsFixed(2)} km"
        : versionCount == 0
        ? AppString.circuitNoVersion
        : versionCount == 1
        ? AppString.circuitSingleVersion
        : "$versionCount ${AppString.circuitVersionsSectionTitle.toLowerCase()}";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: () => _openCircuit(context, circuit),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    TrackUtils.coverImageForCircuit(circuit),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[200]!, Colors.blue[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6.0,
                    right: 6.0,
                    child: Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 4.0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 32.0,
                        height: 32.0,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Icon(
                            TrackUtils.iconForTrack(
                              (circuit.tracks != null && circuit.tracks!.isNotEmpty) ? circuit.tracks!.first : null,
                            ),
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[300]!, Colors.blue[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      circuit.name ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3.0),
                    Row(
                      children: <Widget>[
                        Icon(subtitleIcon, color: Colors.white, size: 12.0),
                        const SizedBox(width: 4.0),
                        Flexible(
                          child: Text(
                            subtitleLabel,
                            style: const TextStyle(color: Colors.white, fontSize: 11.0, height: 1.1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (circuit.country != null) ...[
                      const SizedBox(height: 1.0),
                      Row(
                        children: <Widget>[
                          Text(circuit.country!.flagEmoji, style: const TextStyle(fontSize: 12.0, height: 1.0)),
                          const SizedBox(width: 4.0),
                          Flexible(
                            child: Text(
                              circuit.country!.localizedName(Localizations.localeOf(context).languageCode),
                              style: const TextStyle(color: Colors.white, fontSize: 11.0, height: 1.1),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    final _circuitListProvider = Provider.of<CircuitListProvider>(context, listen: true);
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.tabTracks),
        actions: <Widget>[
          if (_loginProvider.isAdmin)
            IconButton(icon: const Icon(Icons.add), onPressed: () => _navigateToAddCircuitScreen(context)),
          MainActionMenu(),
        ],
      ),
      drawer: MainDrawer(),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: Column(
          children: <Widget>[
            buildSearchField(_circuitListProvider),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _circuitListProvider.fetchCircuits(),
                child: LoadingContent(
                  loadingStatus: _circuitListProvider.loadingStatus,
                  defaultText: AppString.tracksNotFound,
                  emptyText: AppString.tracksNotFound,
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: _circuitListProvider.circuits.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _buildCircuitCard(context, _circuitListProvider.circuits[index]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
