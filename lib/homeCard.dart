import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {

  final String label;
  final AssetImage image;
  final Color primaryColor;
  final Color shadowColor;

  HomeCard(this.label, this.image, this.primaryColor, this.shadowColor);

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: Colors.transparent,
        height: 50.0,
        margin: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 24.0,
        ),
        child: new Stack(
          children: <Widget>[
            new Container(
              height: 50.0,
              margin: new EdgeInsets.only(left: 24.0),
              decoration: new BoxDecoration(
                color: primaryColor,
                shape: BoxShape.rectangle,
                borderRadius: new BorderRadius.circular(8.0),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: shadowColor,
                    blurRadius: 10.0,
                    offset: new Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: new Row(children: <Widget>[
                new Container(
                    width: 14.0,
                    margin: new EdgeInsets.fromLTRB(
                        16.0, 16.0, 16.0, 16.0)),
                new Text(label,
                    textScaleFactor: 1.2,
                    style: new TextStyle(color: Colors.white)),
              ]),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(vertical: 8.0),
              child: new Image(
                  image: image
              ),
            ),
          ],
        ));
  }
}
