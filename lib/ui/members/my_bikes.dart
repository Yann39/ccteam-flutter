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
import 'package:ccteam/providers/bike_list_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/info_banner.dart';
import 'package:ccteam/widgets/restricted_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// Set of manufacturers we have an SVG logo for in `images/manufacturers/`.
const Set<String> _knownManufacturers = <String>{
  'aprilia',
  'bmw',
  'ducati',
  'honda',
  'kawasaki',
  'ktm',
  'suzuki',
  'triumph',
  'yamaha',
  'ohvale',
};

/// Return the asset path of the manufacturer logo, or null if we don't have
/// one for that brand.
String? _manufacturerLogoPath(String? manufacturer) {
  if (manufacturer == null || manufacturer.isEmpty) return null;
  final String normalized = manufacturer.toLowerCase().trim();
  if (!_knownManufacturers.contains(normalized)) return null;
  return 'images/manufacturers/logo-$normalized.svg';
}

/// Build the leading manufacturer logo (or a fallback motorbike icon) for a
/// bike card. Sits in a slightly translucent white rounded square so the
/// logo (typically designed for a light background) reads cleanly on top
/// of the blue gradient card without looking like a hard white sticker.
Widget _buildManufacturerLogo(String? manufacturer) {
  final String? logoPath = _manufacturerLogoPath(manufacturer);
  return Container(
    width: 60,
    height: 60,
    padding: const EdgeInsets.all(6.0),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(8.0)),
    child: logoPath != null
        ? SvgPicture.asset(logoPath, fit: BoxFit.contain)
        : Icon(CustomIcons.motorbike, color: Colors.deepPurple, size: 32),
  );
}

class MyBikes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    if (!_loginProvider.isMember) {
      return Scaffold(
        appBar: AppBar(title: Text(AppString.myBikes)),
        body: Container(decoration: CustomDecorations.mainContent, child: RestrictedContent()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppString.myBikes)),
      body: Container(
        padding: EdgeInsets.all(8.0),
        decoration: CustomDecorations.mainContent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const InfoBanner(message: AppString.myBikesHelp),
            const SizedBox(height: 8.0),
            Expanded(
              child: Consumer<BikeListProvider>(
                builder: (context, provider, child) {
                  return RefreshIndicator(
                    onRefresh: () => provider.refreshBikes(),
                    child: _buildBody(context, provider),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        backgroundColor: Colors.red[700],
        onPressed: () {
          Navigator.pushNamed(context, '/addEditBike');
        },
        child: Icon(Icons.add, color: Colors.white),
        tooltip: AppString.bikeCreate,
      ),
    );
  }

  /// Render the body of the bikes list based on the provider state.
  /// Every branch returns a scrollable widget so the surrounding
  /// [RefreshIndicator] can always detect the pull gesture.
  Widget _buildBody(BuildContext context, BikeListProvider provider) {
    if (provider.loadingStatus == LoadingStatus.loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          const SizedBox(height: 100.0),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (provider.bikes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          const SizedBox(height: 100.0),
          Center(child: Text(AppString.noBike, style: TextStyle(fontSize: 18))),
        ],
      );
    }

    // Compute the "effective" current bike: the one explicitly
    // flagged as current, or — if none — the first bike of the list
    final Bike effectiveCurrent = provider.bikes.firstWhere(
      (b) => b.current ?? false,
      orElse: () => provider.bikes.first,
    );

    return ListView.separated(
      // AlwaysScrollableScrollPhysics so pull-to-refresh works even
      // when the list has only 1-2 bikes and doesn't fill the viewport
      physics: const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (context, index) => SizedBox(height: 8.0),
      itemCount: provider.bikes.length,
      itemBuilder: (context, index) {
        final bike = provider.bikes[index];
        final bool isCurrent = bike.id == effectiveCurrent.id;
        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/addEditBike', arguments: bike);
          },
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: CustomDecorations.cardFull,
            height: 91,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildManufacturerLogo(bike.manufacturer),
                SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "${bike.manufacturer?.toUpperCase()} ${bike.modelName}",
                        textScaler: TextScaler.linear(1.3),
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: <Widget>[
                          Icon(CustomIcons.motorbike, size: 16, color: Colors.deepPurple),
                          SizedBox(width: 5.0),
                          Text("${bike.engineSize} cc - ${bike.year}", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Star button to mark this bike as the "current" one.
                // Tap a non-current bike to make it current; tapping
                // an already-current bike is a no-op (use another
                // bike to switch). A tiny "actuel" caption appears
                // under the star of the current bike.
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      tooltip: isCurrent ? "Moto courante" : "Définir comme moto courante",
                      icon: Icon(
                        isCurrent ? Icons.star : Icons.star_border,
                        color: isCurrent ? Colors.amber : Colors.white.withValues(alpha: 0.7),
                        size: 26,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      onPressed: isCurrent ? null : () => provider.setCurrentBike(bike),
                    ),
                    if (isCurrent) ...[
                      Transform.translate(
                        offset: const Offset(0, -9.0),
                        child: const Text(
                          AppString.currentBike,
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 9.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
