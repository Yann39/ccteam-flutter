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

/// "Équipements" card of the bike detail page: the parts fitted to the bike (racing exhaust, short levers, crash
/// pads...) in the order set by the member, with their optional price, each one opening the equipment form when
/// tapped. The order is set on the `BikeEquipments` page.
class BikeEquipmentCard extends StatefulWidget {
  final Bike bike;

  const BikeEquipmentCard({Key? key, required this.bike}) : super(key: key);

  @override
  State<BikeEquipmentCard> createState() => _BikeEquipmentCardState();
}

class _BikeEquipmentCardState extends State<BikeEquipmentCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Provider.of<BikeEquipmentProvider>(context, listen: false).load(widget.bike.id!);
    });
  }

  Widget _divider() => Container(height: 1, color: Colors.white.withValues(alpha: 0.6));

  /// Open the equipment form, prefilled with [equipment] when editing.
  void _openForm([BikeEquipment? equipment]) {
    Navigator.pushNamed(
      context,
      '/addEditEquipment',
      arguments: EquipmentFormArguments(bike: widget.bike, equipment: equipment),
    );
  }

  /// The given [lines] stacked next to a single icon on the left, in a soft circular halo like the rows of the other
  /// cards of the bike detail page. The lines run to the right edge of the card, so do their dividers and ripples.
  Widget _buildGroup(List<Widget> lines) {
    final Color iconColor = Colors.deepOrange[700]!;
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, top: 4.0, bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // centered on the first line
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withValues(alpha: 0.15)),
            child: Icon(Icons.handyman, color: iconColor, size: 20.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: lines),
          ),
        ],
      ),
    );
  }

  /// One equipment: designation with the comment below it, the price on the right.
  Widget _buildEquipmentLine(BikeEquipment equipment) {
    return InkWell(
      onTap: () => _openForm(equipment),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 8.0, 14.0, 8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(equipment.designation, style: TextStyle(color: Colors.black.withAlpha(220), fontSize: 14.5)),
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
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Icon(Icons.chevron_right, size: 18.0, color: Colors.black.withAlpha(110)),
            ),
          ],
        ),
      ),
    );
  }

  /// Sum of the prices, only worth a line when there are several equipments and at least one price.
  Widget? _buildTotalLine(List<BikeEquipment> equipments) {
    if (equipments.length < 2) return null;
    final String? total = MaintenanceUtils.formatAmounts(BikeEquipment.sumPrices(equipments));
    if (total == null) return null;
    return Padding(
      // the right padding lines the amount up with the prices above, which sit before the chevron
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 38.0, 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(AppString.equipmentTotal, style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 12.5)),
          ),
          Text(
            total,
            style: TextStyle(color: Colors.black.withAlpha(220), fontSize: 14.0, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BikeEquipmentProvider provider = Provider.of<BikeEquipmentProvider>(context, listen: true);
    final int bikeId = widget.bike.id!;
    final List<BikeEquipment>? equipments = provider.equipmentsOf(bikeId);

    final Widget body;
    if (equipments == null) {
      body = Padding(
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
      );
    } else if (equipments.isEmpty) {
      body = _buildGroup(<Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 8.0, 14.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(AppString.equipmentNone, style: TextStyle(color: Colors.black.withAlpha(200), fontSize: 14.5)),
              const SizedBox(height: 2.0),
              Text(AppString.equipmentNoneHelp, style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 12.5)),
            ],
          ),
        ),
      ]);
    } else {
      final Widget? totalLine = _buildTotalLine(equipments);
      body = _buildGroup(<Widget>[
        for (int i = 0; i < equipments.length; i++) ...[if (i > 0) _divider(), _buildEquipmentLine(equipments[i])],
        if (totalLine != null) ...[_divider(), totalLine],
      ]);
    }

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
            // same header as the maintenance card, with the entry point to the page ordering the equipments
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 4.0, 4.0, 4.0),
              child: Row(
                children: <Widget>[
                  Icon(Icons.handyman, color: Colors.deepOrange[700], size: 18.0),
                  const SizedBox(width: 6.0),
                  Expanded(
                    child: Text(
                      AppString.equipmentTitle,
                      style: TextStyle(
                        color: Colors.black.withAlpha(170),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: equipments == null || equipments.length < 2
                        ? null
                        : () => Navigator.pushNamed(context, '/bikeEquipments', arguments: widget.bike),
                    child: Text(AppString.equipmentReorder),
                  ),
                ],
              ),
            ),
            _divider(),
            body,
            if (equipments != null) ...[
              _divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => _openForm(),
                    icon: const Icon(Icons.add),
                    label: Text(AppString.equipmentCreate),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
