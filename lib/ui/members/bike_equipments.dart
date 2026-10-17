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
import 'package:ccteam/models/bike_equipment.dart';
import 'package:ccteam/providers/bike_equipment_provider.dart';
import 'package:ccteam/ui/members/add_edit_equipment.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/maintenance_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Equipments of a bike (the bike travels through the route arguments), ordered by drag and drop: this order is the
/// one of the bike detail card and of the bike sheet PDF. An equipment opens its form when tapped, the button adds a
/// new one at the end of the list.
class BikeEquipments extends StatefulWidget {
  const BikeEquipments({Key? key}) : super(key: key);

  @override
  State<BikeEquipments> createState() => _BikeEquipmentsState();
}

class _BikeEquipmentsState extends State<BikeEquipments> {
  late Bike _bike;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _bike = ModalRoute.of(context)!.settings.arguments as Bike;
    // normally already loaded by the card of the bike detail page
    final BikeEquipmentProvider provider = Provider.of<BikeEquipmentProvider>(context, listen: false);
    if (provider.equipmentsOf(_bike.id!) == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) provider.load(_bike.id!);
      });
    }
  }

  /// Open the equipment form, prefilled with [equipment] when editing.
  void _openForm([BikeEquipment? equipment]) {
    Navigator.pushNamed(
      context,
      '/addEditEquipment',
      arguments: EquipmentFormArguments(bike: _bike, equipment: equipment),
    );
  }

  /// One equipment, with the blue gradient of the bike list cards: designation and detail, price, then the drag
  /// handle. A long press anywhere on the item drags it too.
  Widget _buildItem(BikeEquipment equipment, int index) {
    return Padding(
      key: ValueKey<int?>(equipment.id),
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ReorderableDelayedDragStartListener(
        index: index,
        child: Container(
          decoration: CustomDecorations.cardFull,
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openForm(equipment),
              // the default dark ripple would hardly show on the blue card
              splashColor: Colors.white.withValues(alpha: 0.12),
              highlightColor: Colors.white.withValues(alpha: 0.06),
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 10.0, bottom: 10.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(equipment.designation, style: const TextStyle(color: Colors.white, fontSize: 15.0)),
                          if (equipment.comment != null && equipment.comment!.isNotEmpty) ...[
                            const SizedBox(height: 2.0),
                            Text(
                              equipment.comment!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 12.5),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (equipment.price != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          MaintenanceUtils.formatPrice(equipment.price!, equipment.currency),
                          style: const TextStyle(color: Colors.white, fontSize: 13.5),
                        ),
                      ),
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        child: Icon(Icons.drag_handle, color: Colors.white.withAlpha(220)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BikeEquipmentProvider provider = Provider.of<BikeEquipmentProvider>(context, listen: true);
    final int bikeId = _bike.id!;
    final List<BikeEquipment>? equipments = provider.equipmentsOf(bikeId);

    final Widget content;
    if (equipments == null) {
      content = LoadingContent(
        loadingStatus: provider.statusOf(bikeId),
        defaultText: AppString.contentNotLoaded,
        emptyText: AppString.contentNotLoaded,
        child: const SizedBox.shrink(),
      );
    } else if (equipments.isEmpty) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(AppString.equipmentNone, style: TextStyle(color: Colors.black.withAlpha(200), fontSize: 16.0)),
              const SizedBox(height: 4.0),
              Text(AppString.equipmentNoneHelp, style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 13.0)),
            ],
          ),
        ),
      );
    } else {
      content = ReorderableListView.builder(
        padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, MediaQuery.of(context).padding.bottom + 88.0),
        header: Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 12.0, 4.0, 12.0),
          child: Text(
            AppString.equipmentReorderHelp,
            style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 13.0, height: 1.35),
          ),
        ),
        buildDefaultDragHandles: false,
        itemCount: equipments.length,
        itemBuilder: (BuildContext context, int index) => _buildItem(equipments[index], index),
        onReorderItem: (int oldIndex, int newIndex) => provider.reorderEquipments(bikeId, oldIndex, newIndex),
        // no opaque material around the dragged item, just a slight lift
        proxyDecorator: (Widget child, int index, Animation<double> animation) => AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? lifted) =>
              Transform.scale(scale: 1.0 + 0.03 * animation.value, child: lifted),
          child: Material(type: MaterialType.transparency, child: child),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppString.equipmentTitle)),
      // same look as the other list pages ("Mes motos", maintenance history...)
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        backgroundColor: Colors.red[700],
        tooltip: AppString.equipmentCreate,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(decoration: CustomDecorations.mainContent, child: content),
    );
  }
}
