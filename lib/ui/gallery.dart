import 'package:flutter/material.dart';

enum GalleryTileStyle { imageOnly, oneLine, twoLine }

typedef BannerTapCallback = void Function(Photo photo);

const double _kMinFlingVelocity = 800.0;

class Photo {
  Photo({
    this.assetName,
    this.title,
    this.caption,
    this.isFavorite = false,
  });

  final String assetName;
  final String title;
  final String caption;

  bool isFavorite;

  String get tag => assetName; // Assuming that all asset names are unique.

  bool get isValid => assetName != null && title != null && caption != null && isFavorite != null;
}

class Gallery extends StatefulWidget {
  const Gallery({Key key, this.photo}) : super(key: key);

  final Photo photo;

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryTitleText extends StatelessWidget {
  const _GalleryTitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(text),
    );
  }
}

class _GalleryState extends State<Gallery> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _flingAnimation;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _normalizedOffset;
  double _previousScale;

  @override
  void initState() {
    super.initState();
    print(">>>>>>> INITSTATE");
    _controller = AnimationController(vsync: this)..addListener(_handleFlingAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The maximum offset value is 0,0. If the size of this renderer's box is w,h
  // then the minimum offset value is w - _scale * w, h - _scale * h.
  Offset _clampOffset(Offset offset) {
    final Size size = context.size;
    final Offset minOffset = Offset(size.width, size.height) * (1.0 - _scale);
    return Offset(offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  }

  void _handleFlingAnimation() {
    setState(() {
      _offset = _flingAnimation.value;
    });
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    setState(() {
      _previousScale = _scale;
      _normalizedOffset = (details.focalPoint - _offset) / _scale;
      // The fling animation stops if an input gesture starts.
      _controller.stop();
    });
  }

  void _handleOnScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
      // Ensure that image location under the focal point stays in the same place despite scaling.
      _offset = _clampOffset(details.focalPoint - _normalizedOffset * _scale);
    });
  }

  void _handleOnScaleEnd(ScaleEndDetails details) {
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    if (magnitude < _kMinFlingVelocity) return;
    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    final double distance = (Offset.zero & context.size).shortestSide;
    _flingAnimation = _controller.drive(Tween<Offset>(begin: _offset, end: _clampOffset(_offset + direction * distance)));
    _controller
      ..value = 0.0
      ..fling(velocity: magnitude / 1000.0);
  }

  @override
  Widget build(BuildContext context) {
    print(">>>>>>> BUILD");
    return GestureDetector(
      onScaleStart: _handleOnScaleStart,
      onScaleUpdate: _handleOnScaleUpdate,
      onScaleEnd: _handleOnScaleEnd,
      child: ClipRect(
        child: Transform(
          transform: Matrix4.identity()
            ..translate(_offset.dx, _offset.dy)
            ..scale(_scale),
          child: Image.asset(
            widget.photo.assetName,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class GalleryPhotoItem extends StatelessWidget {
  GalleryPhotoItem({Key key, @required this.photo, @required this.tileStyle, @required this.onBannerTap})
      : assert(photo != null && photo.isValid),
        assert(tileStyle != null),
        assert(onBannerTap != null),
        super(key: key);

  final Photo photo;
  final GalleryTileStyle tileStyle;
  final BannerTapCallback onBannerTap; // User taps on the photo's header or footer.

  void showPhoto(BuildContext context) {
    print(">>>>>>> SHOWPHOTO");
    Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text(photo.title)),
        body: SizedBox.expand(
          child: Hero(
            tag: photo.tag,
            child: Gallery(photo: photo),
          ),
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    print(">>>>>>> BUILD2");
    final Widget image = GestureDetector(
        onTap: () {
          print(">>>>>>> ON TAP");
          showPhoto(context);
        },
        child: Hero(
            key: Key(photo.assetName),
            tag: photo.tag,
            child: Image.asset(
              photo.assetName,
              fit: BoxFit.cover,
            )));

    final IconData icon = photo.isFavorite ? Icons.star : Icons.star_border;

    switch (tileStyle) {
      case GalleryTileStyle.imageOnly:
        return image;

      case GalleryTileStyle.oneLine:
        return GridTile(
          header: GestureDetector(
            onTap: () {
              onBannerTap(photo);
            },
            child: GridTileBar(
              title: _GalleryTitleText(photo.title),
              backgroundColor: Colors.black45,
              leading: Icon(
                icon,
                color: Colors.white,
              ),
            ),
          ),
          child: image,
        );

      case GalleryTileStyle.twoLine:
        return GridTile(
          footer: GestureDetector(
            onTap: () {
              onBannerTap(photo);
            },
            child: GridTileBar(
              backgroundColor: Colors.black45,
              title: _GalleryTitleText(photo.title),
              subtitle: _GalleryTitleText(photo.caption),
              trailing: Icon(
                icon,
                color: Colors.white,
              ),
            ),
          ),
          child: image,
        );
    }
    assert(tileStyle != null);
    return null;
  }
}

class GalleryListDemo extends StatefulWidget {
  const GalleryListDemo({Key key}) : super(key: key);

  static const String routeName = '/material/gallery-list';

  @override
  GalleryListDemoState createState() => GalleryListDemoState();
}

class GalleryListDemoState extends State<GalleryListDemo> {
  GalleryTileStyle _tileStyle = GalleryTileStyle.twoLine;

  List<Photo> photos = <Photo>[
    Photo(
      assetName: 'images/chachatte-team-banner.png',
      title: 'Image1',
      caption: 'Test image 1',
    )
  ];

  void changeTileStyle(GalleryTileStyle value) {
    setState(() {
      _tileStyle = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(">>>>>>> BUILD PHOTOS");
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grid list'),
        actions: <Widget>[
          PopupMenuButton<GalleryTileStyle>(
            onSelected: changeTileStyle,
            itemBuilder: (BuildContext context) => <PopupMenuItem<GalleryTileStyle>>[
                  const PopupMenuItem<GalleryTileStyle>(
                    value: GalleryTileStyle.imageOnly,
                    child: Text('Image only'),
                  ),
                  const PopupMenuItem<GalleryTileStyle>(
                    value: GalleryTileStyle.oneLine,
                    child: Text('One line'),
                  ),
                  const PopupMenuItem<GalleryTileStyle>(
                    value: GalleryTileStyle.twoLine,
                    child: Text('Two line'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: GridView.count(
                crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                padding: const EdgeInsets.all(4.0),
                childAspectRatio: (orientation == Orientation.portrait) ? 1.0 : 1.3,
                children: photos.map<Widget>((Photo photo) {
                  return GalleryPhotoItem(
                      photo: photo,
                      tileStyle: _tileStyle,
                      onBannerTap: (Photo photo) {
                        setState(() {
                          photo.isFavorite = !photo.isFavorite;
                        });
                      });
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
