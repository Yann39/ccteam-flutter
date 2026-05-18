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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ccteam/providers/photo_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/photo_detail_provider.dart';

const double _kMinFlingVelocity = 800.0;

class PhotoDetail extends StatefulWidget {
  const PhotoDetail({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PhotoDetailState();
  }
}

class _PhotoDetailState extends State<PhotoDetail> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late PageController _pageController;
  late Animation<Offset> _flingAnimation;
  late Offset _normalizedOffset;
  late double _previousScale;
  int _currentPage = 0;
  Offset _offset = Offset.zero;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _currentPage = Provider.of<PhotoProvider>(context, listen: false)
        .photos
        .indexOf(Provider.of<PhotoDetailProvider>(context, listen: false).currentPhoto);
    _controller = AnimationController(vsync: this)..addListener(_handleFlingAnimation);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleFlingAnimation() {
    setState(() {
      _offset = _flingAnimation.value;
    });
  }

  /// Get the clamp offset for the given [offset]
  /// The maximum offset value is 0,0. If the size of this renderer's box is w,h
  /// then the minimum offset value is w - _scale * w, h - _scale * h
  Offset _clampOffset(Offset offset) {
    final Size size = context.size!;
    final Offset minOffset = Offset(size.width, size.height) * (1.0 - _scale);
    return Offset(offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  }

  /// Handle scale start given the gesture [details]
  /// The fling animation stops if an input gesture starts
  void _handleOnScaleStart(ScaleStartDetails details) {
    setState(() {
      _previousScale = _scale;
      _normalizedOffset = (details.focalPoint - _offset) / _scale;
      _controller.stop();
    });
  }

  /// Handle scale updates (while scaling) given the gesture [details]
  /// It also sets offset to ensure that image location under the focal point stays in the same place despite scaling
  void _handleOnScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
      _offset = _clampOffset(details.focalPoint - _normalizedOffset * _scale);
    });
  }

  /// Handle scale stop given the gesture [details]
  void _handleOnScaleEnd(ScaleEndDetails details) {
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    if (magnitude < _kMinFlingVelocity) return;
    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    final double distance = (Offset.zero & context.size!).shortestSide;
    _flingAnimation =
        _controller.drive(Tween<Offset>(begin: _offset, end: _clampOffset(_offset + direction * distance)));
    _controller
      ..value = 0.0
      ..fling(velocity: magnitude / 1000.0);
  }

  Widget build(BuildContext context) {
    final _photoProvider = Provider.of<PhotoProvider>(context, listen: true);

    // if photos list is empty (e.g. after session expiration), don't render content
    if (_photoProvider.photos.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Container(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(150),
        elevation: 0,
        title: Text(_photoProvider.photos[_currentPage].title ?? ""),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: PageView.builder(
        itemCount: _photoProvider.photos.length,
        onPageChanged: (value) {
          setState(() {
            _currentPage = value;
            _offset = Offset.zero;
            _scale = 1.0;
          });
        },
        controller: _pageController,
        itemBuilder: (context, index) => Center(
          child: GestureDetector(
            onScaleStart: _handleOnScaleStart,
            onScaleUpdate: _handleOnScaleUpdate,
            onScaleEnd: _handleOnScaleEnd,
            child: Transform(
              transform: Matrix4.identity()
                ..translateByDouble(_offset.dx, _offset.dy, 0.0, 1.0)
                ..scaleByDouble(_scale, _scale, _scale, 1.0),
              child: CachedNetworkImage(
                placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Colors.white)),
                imageUrl: _photoProvider.photos[index].link!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
