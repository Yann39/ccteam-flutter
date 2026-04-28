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
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyBikes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppString.myBikes)),
      body: Container(
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

          return ListView.builder(
            itemCount: provider.bikes.length,
            itemBuilder: (context, index) {
              final bike = provider.bikes[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.lightBlueAccent, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    "${bike.manufacturer?.toUpperCase()} ${bike.modelName}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                  ),
                  subtitle: Text(
                    "${bike.engineSize} cc - ${bike.year}",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/addEditBike',
                            arguments: bike,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            () => _showDeleteConfirmation(
                              context,
                              provider,
                              bike,
                            ),
                      ),
                    ],
                  ),
                ),
                  ),
                );
            },
          );
        },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red[700],
        onPressed: () {
          Navigator.pushNamed(context, '/addEditBike');
        },
        child: Icon(Icons.add),
        tooltip: AppString.bikeCreate,
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    BikeListProvider provider,
    Bike bike,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppString.confirmation),
          content: Text(AppString.bikeDeletionAreYouSure),
          actions: <Widget>[
            TextButton(
              child: Text(AppString.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(AppString.confirm),
              onPressed: () {
                provider.deleteBike(bike);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
