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

import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';

/// Curated list of gradient pairs used as the member-detail header
/// background. The same list is shown to the user in the palette
/// picker — index in this list is what gets persisted on the member
/// record as `headerPalette`.
const List<List<Color>> kMemberHeaderPalettes = <List<Color>>[
  [Color(0xFF56CCF2), Color(0xFF2F80ED)], // blue
  [Color(0xFF11998E), Color(0xFF38EF7D)], // teal → green
  [Color(0xFFFE8C00), Color(0xFFF83600)], // sunset orange
  [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // deep purple
  [Color(0xFFFF8C42), Color(0xFFFF3CAC)], // orange → pink
  [Color(0xFF26D0CE), Color(0xFF1A2980)], // teal → midnight
];

/// Show the header-palette picker as a modal bottom sheet.
///
/// [currentIndex] is the index currently selected (null = default).
/// [seed] is the value used to compute the default palette when the
/// user hasn't picked one yet — typically `member.id`.
/// [onSelected] is invoked with the chosen index (null when the user
/// picks "Couleurs par défaut"). It is NOT called if the user
/// dismisses the sheet without picking.
void showMemberHeaderPalettePicker({
  required BuildContext context,
  required int? currentIndex,
  required int seed,
  required void Function(int?) onSelected,
}) {
  showModalBottomSheet<void>(
    context: context,
    // Allow the sheet to grow past the default 50%-of-screen cap, so
    // all 7 rows fit on most phones in portrait.
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
    builder: (BuildContext sheetCtx) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[100]!, Colors.blue[200]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    AppString.headerPaletteTitle,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                  const SizedBox(height: 14.0),
                  _MemberPalettePickerTile(
                    label: AppString.headerPaletteDefault,
                    palette: kMemberHeaderPalettes[seed.abs() % kMemberHeaderPalettes.length],
                    selected: currentIndex == null,
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      onSelected(null);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(height: 1, color: Colors.black.withValues(alpha: 0.12)),
                  ),
                  for (int i = 0; i < kMemberHeaderPalettes.length; i++) ...[
                    _MemberPalettePickerTile(
                      label: 'Palette ${i + 1}',
                      palette: kMemberHeaderPalettes[i],
                      selected: currentIndex == i,
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        onSelected(i);
                      },
                    ),
                    if (i < kMemberHeaderPalettes.length - 1) const SizedBox(height: 8.0),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Small horizontal preview of a [palette] — used as the trailing
/// indicator on the "palette" form row and as the icon on each
/// picker tile.
class MemberHeaderPaletteChip extends StatelessWidget {
  const MemberHeaderPaletteChip({
    Key? key,
    required this.palette,
    this.width = 48,
    this.height = 24,
    this.borderRadius = 6.0,
  }) : super(key: key);

  final List<Color> palette;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: palette, begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
    );
  }
}

/// Row used inside the header-palette picker bottom sheet. Displays a
/// gradient preview + label, and a green check icon when [selected].
class _MemberPalettePickerTile extends StatelessWidget {
  const _MemberPalettePickerTile({
    Key? key,
    required this.label,
    required this.palette,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  final String label;
  final List<Color> palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
        child: Row(
          children: <Widget>[
            MemberHeaderPaletteChip(palette: palette, width: 48, height: 32),
            const SizedBox(width: 14.0),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: Colors.green[700], size: 22),
          ],
        ),
      ),
    );
  }
}
