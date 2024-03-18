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
import 'package:ccteam/models/photo.dart';
import 'package:ccteam/providers/photo_provider.dart';
import 'package:ccteam/services/photos_service.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const double _kMinFlingVelocity = 800.0;

class PhotoDetail extends StatefulWidget {
  final Photo photo;

  const PhotoDetail({Key key, this.photo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PhotoDetailState();
  }
}

class _PhotoDetailState extends State<PhotoDetail>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  PageController _pageController;
  Animation<Offset> _flingAnimation;
  Offset _normalizedOffset;
  double _previousScale;
  int _currentPage = 0;
  Offset _offset = Offset.zero;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _currentPage = Provider.of<PhotoProvider>(context, listen: false)
        .photos
        .indexOf(widget.photo);
    _controller = AnimationController(vsync: this)
      ..addListener(_handleFlingAnimation);
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
    final Size size = context.size;
    final Offset minOffset = Offset(size.width, size.height) * (1.0 - _scale);
    return Offset(
        offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
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
    final double distance = (Offset.zero & context.size).shortestSide;
    _flingAnimation = _controller.drive(Tween<Offset>(
        begin: _offset, end: _clampOffset(_offset + direction * distance)));
    _controller
      ..value = 0.0
      ..fling(velocity: magnitude / 1000.0);
  }

  /// Method that launches the Edit New screen and awaits the result from Navigator.pop
  _navigateToEditPhotoScreen(BuildContext context, Photo photo) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the Add Photo Screen
    final result =
        await Navigator.pushNamed(context, "/addEditPhoto", arguments: photo);

    // after the Edit New Screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  /// Display a confirmation popup when trying to delete a photo
  void _showConfirmation(BuildContext context, String value, Photo photo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppString.confirmation),
        content: Text(value),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _dialogueResult(context, ConfirmDialogAction.yes, photo);
            },
            child: Text(AppString.confirm),
          ),
          TextButton(
            onPressed: () {
              _dialogueResult(context, ConfirmDialogAction.no, photo);
            },
            child: Text(AppString.cancel),
          ),
        ],
      ),
    );
  }

  /// Handle result of the photo deletion confirmation dialog
  void _dialogueResult(
      BuildContext context, ConfirmDialogAction value, Photo photo) {
    if (value == ConfirmDialogAction.yes) {
      final PhotosService photosService = PhotosService();
      // delete photo
      photosService.deletePhoto(photo).then((value) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AppString.photoDeleted)));
      }, onError: (error) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
              SnackBar(content: Text(AppString.photoDeletionFailed)));
      });
    }
    Navigator.pop(context);
  }

  Widget build(BuildContext context) {
    final _photoProvider = Provider.of<PhotoProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditPhotoScreen(
                context, _photoProvider.photos[_currentPage]),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => _showConfirmation(
                context,
                AppString.photoDeletionAreYouSure,
                _photoProvider.photos[_currentPage]),
          )
        ],
        title: Text(AppString.detail),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: PageView.builder(
          itemCount: _photoProvider.photos.length,
          onPageChanged: (value) {
            setState(() {
              _currentPage = value;
              _offset = Offset.zero;
              _scale = 1.0;
            });
          },
          controller: _pageController,
          itemBuilder: (context, index) => AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              /*double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page - index;
                value = (1 - (value.abs() * .5)).clamp(0.0, 1.0);
              }*/
              return SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(8.0),
                  /*height: Curves.easeOut.transform(value) * 400,
                  width: Curves.easeOut.transform(value) * 350,*/
                  child: Column(
                    children: <Widget>[
                      Text("${_photoProvider.photos[index].title}",
                          textScaleFactor: 1.6),
                      SizedBox(height: 12.0),
                      child,
                      SizedBox(height: 12.0),
                      Text("${_photoProvider.photos[index].description}"),
                    ],
                  ),
                ),
              );
            },
            child:
                /*ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child:*/
                GestureDetector(
              onScaleStart: _handleOnScaleStart,
              onScaleUpdate: _handleOnScaleUpdate,
              onScaleEnd: _handleOnScaleEnd,
              child: Transform(
                transform: Matrix4.identity()
                  ..translate(_offset.dx, _offset.dy)
                  ..scale(_scale),
                child: CachedNetworkImage(
                  placeholder: (context, url) => CircularProgressIndicator(),
                  imageUrl: _photoProvider.photos[index].link,
                  fit: BoxFit.cover,
                ),
              ),
              //),
            ),
          ),
        ),
      ),
    );
  }
}
