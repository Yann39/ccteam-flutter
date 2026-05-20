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

import 'package:flutter/material.dart';

/// Decorates a horizontally-scrolling child (typically a ListView)
/// with a small chevron pill on each edge that fades in / out based
/// on whether there's more content in that direction.
///
/// Usage:
/// ```dart
/// HorizontalScrollHints(
///   controller: _myController,
///   child: ListView(
///     controller: _myController,
///     scrollDirection: Axis.horizontal,
///     children: [...],
///   ),
/// )
/// ```
///
/// The [controller] is shared: it must be the same instance used by
/// the underlying scrollable so this widget can read the current
/// scroll position. The parent is responsible for the controller's
/// lifecycle (creating it in `initState`, disposing in `dispose`),
/// this widget only attaches/detaches a listener.
///
/// The pill is intentionally subtle: a 26 px white circle with a
/// soft shadow + a 18 px grey chevron, wrapped in `IgnorePointer`
/// so it never steals taps from items underneath.
class HorizontalScrollHints extends StatefulWidget {
  const HorizontalScrollHints({Key? key, required this.controller, required this.child}) : super(key: key);

  final ScrollController controller;
  final Widget child;

  @override
  State<HorizontalScrollHints> createState() => _HorizontalScrollHintsState();
}

class _HorizontalScrollHintsState extends State<HorizontalScrollHints> {
  /// Whether there is content to scroll to past the right edge.
  /// Starts at `true` so the hint shows on first paint for lists
  /// that overflow; the post-frame check below flips it to `false`
  /// for lists that fit entirely on screen.
  bool _hasMoreOnRight = true;

  /// Whether there is content to the left of the current viewport.
  /// Starts at `false` since [ScrollController]s always begin at
  /// `pixels == 0`.
  bool _hasMoreOnLeft = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_recompute);
    // first hint state isn't known until layout has happened, defer
    // by one frame so `maxScrollExtent` is populated
    WidgetsBinding.instance.addPostFrameCallback((_) => _recompute());
  }

  @override
  void didUpdateWidget(covariant HorizontalScrollHints oldWidget) {
    super.didUpdateWidget(oldWidget);
    // re-wire the listener if the parent swapped controllers, rare
    // in practice but keeps the widget correct under hot reload
    // and parent-driven controller changes
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_recompute);
      widget.controller.addListener(_recompute);
      WidgetsBinding.instance.addPostFrameCallback((_) => _recompute());
    }
  }

  void _recompute() {
    if (!widget.controller.hasClients) return;
    final ScrollPosition pos = widget.controller.position;
    // small tolerance so floating-point near-equality at either
    // extreme doesn't leave a 0.1 px residue keeping a hint visible
    final bool canScrollRight = pos.maxScrollExtent > 0 && pos.pixels < pos.maxScrollExtent - 4.0;
    final bool canScrollLeft = pos.pixels > 4.0;
    if (canScrollRight != _hasMoreOnRight || canScrollLeft != _hasMoreOnLeft) {
      setState(() {
        _hasMoreOnRight = canScrollRight;
        _hasMoreOnLeft = canScrollLeft;
      });
    }
  }

  @override
  void dispose() {
    // controller is owned by the parent, only detach the listener
    widget.controller.removeListener(_recompute);
    super.dispose();
  }

  /// Smoothly scroll to one of the two extremes (depending on
  /// [leading]). Wrapped in `hasClients` + `mounted` guards so a
  /// rapid tap during teardown can't crash.
  void _scrollToExtreme({required bool leading}) {
    if (!mounted || !widget.controller.hasClients) return;
    final ScrollPosition pos = widget.controller.position;
    final double target = leading ? pos.minScrollExtent : pos.maxScrollExtent;
    widget.controller.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.child,
        Positioned(left: 4.0, top: 0.0, bottom: 0.0, child: _hint(visible: _hasMoreOnLeft, leading: true)),
        Positioned(right: 4.0, top: 0.0, bottom: 0.0, child: _hint(visible: _hasMoreOnRight, leading: false)),
      ],
    );
  }

  /// Single chevron pill. [leading] picks the chevron direction
  /// (`chevron_left` when true, `chevron_right` when false) so the
  /// same helper renders both edges without duplicating the chrome.
  /// When visible, the pill is tappable and triggers a smooth
  /// `animateTo` to the matching scroll extreme — quick way for the
  /// user to jump to the start / end without dragging.
  Widget _hint({required bool visible, required bool leading}) {
    final Widget pill = Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // disabled when invisible — prevents an accidental tap on a
        // fully-faded pill (the AnimatedOpacity widget keeps it in
        // the tree, just transparent)
        onTap: visible ? () => _scrollToExtreme(leading: leading) : null,
        customBorder: const CircleBorder(),
        child: Container(
          width: 26.0,
          height: 26.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.85),
            boxShadow: <BoxShadow>[
              BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 3.0, offset: const Offset(0, 1)),
            ],
          ),
          child: Icon(
            leading ? Icons.chevron_left : Icons.chevron_right,
            size: 18.0,
            color: Colors.black.withAlpha(170),
          ),
        ),
      ),
    );
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      // when invisible we also block hit-testing so a phantom tap
      // can't fire on a 0-opacity pill
      child: IgnorePointer(ignoring: !visible, child: Center(child: pill)),
    );
  }
}
