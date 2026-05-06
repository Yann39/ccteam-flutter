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

import 'package:ccteam/providers/bike_list_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/utils/custom_decorations.dart';
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
  'ohvale'
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
/// bike card.
Widget _buildManufacturerLogo(String? manufacturer) {
  final String? logoPath = _manufacturerLogoPath(manufacturer);
  return Container(
    width: 60,
    height: 60,
    padding: const EdgeInsets.all(6.0),
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: logoPath != null
        ? SvgPicture.asset(logoPath, fit: BoxFit.contain)
        : Icon(
            CustomIcons.motorbike,
            color: Colors.deepPurple,
            size: 32,
          ),
  );
}

class MyBikes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(
      context,
      listen: false,
    );

    if (!_loginProvider.isMember) {
      return Scaffold(
        appBar: AppBar(title: Text(AppString.myBikes)),
        body: Container(
          decoration: CustomDecorations.mainContent,
          child: RestrictedContent(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppString.myBikes)),
      body: Container(
        padding: EdgeInsets.all(8.0),
        decoration: CustomDecorations.mainContent,
        child: Consumer<BikeListProvider>(
          builder: (context, provider, child) {
          if (provider.loadingStatus == LoadingStatus.loading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.bikes.isEmpty) {
            return Center(
              child: Text(AppString.noBike, style: TextStyle(fontSize: 18)),
            );
          }

            return ListView.separated(
              separatorBuilder: (context, index) => SizedBox(height: 8.0),
            itemCount: provider.bikes.length,
            itemBuilder: (context, index) {
              final bike = provider.bikes[index];
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/addEditBike',
                      arguments: bike,
                    );
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
                                  Icon(
                                    CustomIcons.motorbike,
                                    size: 16,
                                    color: Colors.deepPurple,
                                  ),
                                  SizedBox(width: 5.0),
                                  Text(
                                    "${bike.engineSize} cc - ${bike.year}",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
            },
          );
        },
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
}
