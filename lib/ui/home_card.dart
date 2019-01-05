import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  final String title;
  final String date;
  final AssetImage image;
  final Color primaryColor;
  final Color shadowColor;

  HomeCard(this.title, this.date, this.image, this.primaryColor, this.shadowColor);

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: Colors.transparent,
        height: 60.0,
        margin: const EdgeInsets.symmetric(
          vertical: 8.0, // vertical space between cards
          horizontal: 20.0,
        ),
        child: new Stack(
          children: <Widget>[
            new Container(
              height: 60.0,
              margin: new EdgeInsets.only(left: 20.0),
              padding: new EdgeInsets.fromLTRB(0, 8.0, 16.0, 8.0),
              decoration: new BoxDecoration(color: new Color.fromRGBO(255, 255, 255, 0.4), shape: BoxShape.rectangle, borderRadius: new BorderRadius.circular(8.0)),
              child: new Row(children: <Widget>[
                new Container(width: 38.0), // fake horizontal space between image and text
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  new Flexible(
                      child: new Row(children: <Widget>[
                        Icon(
                          Icons.date_range,
                          color: Colors.white,
                          size: 12.0,
                        ),
                        new SizedBox(width: 4.0), // fake horizontal space between the 2 lines of text
                    new Text(date, softWrap: false, textScaleFactor: 0.9, style: new TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)
                  ])),
                  new SizedBox(height: 4.0), // vertical space between the 2 lines of text
                  new Flexible(
                      child: new Text(title, softWrap: false, textScaleFactor: 1.2, style: new TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis))
                ])),
                Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                ),
              ]),
            ),
            new Container(
                margin: new EdgeInsets.only(top: 14.0),
                child: new Image(
                  image: image,
                  width: 44.0,
                )),
          ],
        ));
  }
}
