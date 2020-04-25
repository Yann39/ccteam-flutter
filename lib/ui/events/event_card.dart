/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of Chachatte Team application.
 *
 * Chachatte Team is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Chachatte Team is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Chachatte Team. If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:chachatte_team/models/event.dart';
import 'package:chachatte_team/ui/events/event_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;

  //final int nbCol;

  EventCard(
    this.event,
    /*this.nbCol*/
  );

  /// Method that launches the Event detail screen and awaits the result from Navigator.pop
  _navigateToEventDetailScreen(BuildContext context, Event event) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetail(event: event)));

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // there can be 2 or 4 events per line in portrait mode, 4 or 6 in landscape, so scale content
    /*final double radius = (nbCol == 1 || nbCol == 2) ? 8 : 6;
    final String dateFormat = (nbCol == 1 || nbCol == 2) ? "MMMM yyyy" : "MMM yyyy";
    final double dateScaleFactor = (nbCol == 1 || nbCol == 2) ? 1.1 : 0.8;
    final double dateIconSize = (nbCol == 1 || nbCol == 2) ? 18 : 12;
    final double dayScaleFactor = (nbCol == 1 || nbCol == 2) ? 3.5 : 2;
    final double placeIconSize = (nbCol == 1 || nbCol == 2) ? 15 : 10;
    final double eventTitleScaleFactor = (nbCol == 1 || nbCol == 2) ? 1.2 : 0.8;
    final double participantsScaleFactor = (nbCol == 1 || nbCol == 2) ? 1 : 0.8;
    final double dayPadding = (nbCol == 1 || nbCol == 2) ? 8 : 4;*/

    return InkWell(
      onTap: () => _navigateToEventDetailScreen(context, event),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            //colors: [Color.fromRGBO(0, 100, 200, 0.3), Color.fromRGBO(0, 100, 200, 0.5)],
            colors: [Colors.blue[300], Colors.blue[500]],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0],
          ),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: ListTile(
          title: Text(event.title, style: TextStyle(color: Colors.white)),
          subtitle: Text(
            event.description,
            style: TextStyle(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: Container(
            padding: EdgeInsets.only(right: 16.0),
            child: Column(
              children: <Widget>[
                Text("${DateFormat('EEEE', 'fr').format(event.eventDate).substring(0, 3)}", textScaleFactor: 0.8, style: TextStyle(color: Colors.white)),
                Text("${DateFormat('dd', 'fr').format(event.eventDate)}", textScaleFactor: 1.7, style: TextStyle(color: Colors.white)),
                Text("${DateFormat('MMM', 'fr').format(event.eventDate)}", textScaleFactor: 0.9, style: TextStyle(color: Colors.white)),
              ],
            ),
            decoration: BoxDecoration(border: Border(right: BorderSide(width: 1.0, color: Colors.grey[300]))),
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(event.members.length > 1 ? Icons.group : Icons.person, color: Colors.white, size: 18),
              Text("${event.members.length}", textScaleFactor: 0.8, style: TextStyle(color: Colors.white))
            ],
          ),
        ),
      ),
    );

    /*return InkWell(
      onTap: () => _navigateToEventDetailScreen(context, event),
      child: new Container(
        margin: EdgeInsets.all(8.0),
        decoration: new BoxDecoration(
          color: new Color.fromRGBO(255, 255, 255, 0.4),
          shape: BoxShape.rectangle,
          borderRadius: new BorderRadius.circular(radius),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                    color: Colors.red[700],
                    shape: BoxShape.rectangle,
                    borderRadius: new BorderRadius.only(
                      topLeft: Radius.circular(radius),
                      topRight: Radius.circular(radius),
                    ),
                  ),
                  child: Text(
                    DateUtils.convertToString(event.eventDate, dateFormat),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    textScaleFactor: dateScaleFactor,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 6.0),
                  child: Icon(
                    Icons.date_range,
                    color: Colors.white,
                    size: dateIconSize,
                  ),
                ),
              ],
            ),
            SizedBox(height: dayPadding),
            Text(
              DateUtils.convertToString(event.eventDate, "dd"),
              softWrap: false,
              textScaleFactor: dayScaleFactor,
              style: new TextStyle(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.place,
                  color: Colors.white,
                  size: placeIconSize,
                ),
                Flexible(
                  child: Text(
                    event.title,
                    softWrap: true,
                    textScaleFactor: eventTitleScaleFactor,
                    style: new TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: dayPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                  child: Text(
                    event.members.length.toString(),
                    textScaleFactor: participantsScaleFactor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  padding: EdgeInsets.all(2.0),
                  decoration: new BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(
                      Radius.circular(3.0),
                    ),
                  ),
                ),
                Text(
                  " " + (event.members.length > 1 ? AppString.participants : AppString.participant),
                  style: TextStyle(color: Colors.white),
                  textScaleFactor: participantsScaleFactor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );*/
  }
}
