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
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/maintenance_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Equipments of a bike, for the equipment tab of the bike detail page: a card like the other tabs ones, starting
/// with a summary row (number of equipments and total of their prices), then the parts fitted to the bike over the
/// whole width, in the order set by the member by drag and drop (also the order of the bike sheet PDF), each one
/// opening its form when tapped, and the add button.
///
/// Built as a sliver, so the list scrolls with the tab while an item is dragged. The data is loaded by the bike
/// detail page.
class BikeEquipmentList extends StatelessWidget {
  final Bike bike;

  const BikeEquipmentList({Key? key, required this.bike}) : super(key: key);

  static final Color _iconColor = Colors.deepOrange[700]!;

  /// Same look as the other cards of the bike detail page.
  static final BoxDecoration _cardDecoration = BoxDecoration(
    border: Border.all(color: Colors.white, width: 1.0),
    borderRadius: BorderRadius.circular(8.0),
    color: Colors.blue[100],
    boxShadow: [
      BoxShadow(color: Colors.black.withAlpha(25), spreadRadius: 0.5, blurRadius: 0.5, offset: const Offset(2, 2)),
    ],
  );

  static Widget _divider() => Container(height: 1, color: Colors.white.withValues(alpha: 0.6));

  /// Open the equipment form, prefilled with [equipment] when editing.
  static void openForm(BuildContext context, Bike bike, [BikeEquipment? equipment]) {
    Navigator.pushNamed(
      context,
      '/addEditEquipment',
      arguments: EquipmentFormArguments(bike: bike, equipment: equipment),
    );
  }

  /// Summary row, same idiom as the rows of the other cards: the icon in a soft circular halo, then the optional
  /// [label] above the [value], and the optional [below] text under it.
  Widget _buildSummary({String? label, required String value, String? below}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _iconColor.withValues(alpha: 0.15)),
            child: Icon(Icons.handyman, color: _iconColor, size: 20.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (label != null) ...[
                  Text(label, style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 12.0)),
                  const SizedBox(height: 2.0),
                ],
                Text(
                  value,
                  style: TextStyle(color: Colors.black.withAlpha(220), fontSize: 15.0, fontWeight: FontWeight.w600),
                ),
                if (below != null) ...[
                  const SizedBox(height: 2.0),
                  Text(below, style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 12.5)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// One equipment over the whole width: designation with its detail below, the price, then the drag handle. A long
  /// press anywhere on the line drags it too. The divider above belongs to the line, so it moves with it.
  Widget _buildItem(BuildContext context, BikeEquipment equipment, int index) {
    return Column(
      key: ValueKey<int?>(equipment.id),
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (index > 0) _divider(),
        ReorderableDelayedDragStartListener(
          index: index,
          // the ripple would otherwise be painted under the card
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => openForm(context, bike, equipment),
              child: Padding(
                padding: const EdgeInsets.only(left: 14.0, top: 10.0, bottom: 10.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            equipment.designation,
                            style: TextStyle(color: Colors.black.withAlpha(220), fontSize: 14.5),
                          ),
                          if (equipment.comment != null && equipment.comment!.isNotEmpty) ...[
                            const SizedBox(height: 2.0),
                            Text(
                              equipment.comment!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 12.5),
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
                          style: TextStyle(color: Colors.black.withAlpha(200), fontSize: 13.5),
                        ),
                      ),
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        child: Icon(Icons.drag_handle, size: 22.0, color: Colors.black.withAlpha(110)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final BikeEquipmentProvider provider = Provider.of<BikeEquipmentProvider>(context, listen: true);
    final int bikeId = bike.id!;
    final List<BikeEquipment>? equipments = provider.equipmentsOf(bikeId);

    final List<Widget> content;
    if (equipments == null) {
      content = <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: provider.statusOf(bikeId) == LoadingStatus.loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                  : TextButton.icon(
                      onPressed: () => provider.load(bikeId),
                      icon: const Icon(Icons.refresh),
                      label: Text(AppString.contentNotLoaded),
                    ),
            ),
          ),
        ),
      ];
    } else if (equipments.isEmpty) {
      content = <Widget>[
        SliverToBoxAdapter(
          child: _buildSummary(value: AppString.equipmentNone, below: AppString.equipmentNoneHelp),
        ),
      ];
    } else {
      final String? total = MaintenanceUtils.formatAmounts(BikeEquipment.sumPrices(equipments));
      content = <Widget>[
        SliverToBoxAdapter(
          child: _buildSummary(
            label: equipments.length == 1
                ? AppString.equipmentCountOne
                : AppString.format(AppString.equipmentCountMany, [equipments.length]),
            value: total == null ? AppString.equipmentNoPrice : AppString.format(AppString.equipmentTotalOf, [total]),
          ),
        ),
        SliverToBoxAdapter(child: _divider()),
        SliverReorderableList(
          itemCount: equipments.length,
          itemBuilder: (BuildContext context, int index) => _buildItem(context, equipments[index], index),
          onReorderItem: (int oldIndex, int newIndex) => provider.reorderEquipments(bikeId, oldIndex, newIndex),
          // the dragged line takes the card background with a slight shadow, the card shows through otherwise
          proxyDecorator: (Widget child, int index, Animation<double> animation) => AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? lifted) => Material(
              color: Colors.blue[100],
              elevation: 4.0 * animation.value,
              borderRadius: BorderRadius.circular(4.0),
              child: lifted,
            ),
            child: child,
          ),
        ),
      ];
    }

    return DecoratedSliver(
      decoration: _cardDecoration,
      sliver: SliverMainAxisGroup(
        // no title, the tab already names it
        slivers: <Widget>[
          ...content,
          if (equipments != null) ...<Widget>[
            SliverToBoxAdapter(child: _divider()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => openForm(context, bike),
                    icon: const Icon(Icons.add),
                    label: Text(AppString.equipmentCreate),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
