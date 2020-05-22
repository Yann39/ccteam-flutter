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
import 'package:chachatte_team/utils/custom_decorations.dart';
import 'package:chachatte_team/utils/custom_icons.dart';
import 'package:chachatte_team/utils/string_utils.dart';
import 'package:chachatte_team/utils/track_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;

  EventCard(this.event);

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
    return InkWell(
      onTap: () => _navigateToEventDetailScreen(context, event),
      child: Container(
        height: 90,
        decoration: CustomDecorations.cardFull,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: event.endDate.isAfter(DateTime.now()) ? Colors.green[700] : Colors.grey[700],
                borderRadius: BorderRadius.only(topLeft: Radius.circular(4.0), bottomLeft: Radius.circular(4.0)),
              ),
              width: 5,
            ),
            Expanded(
              child: Padding(
                child: Row(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          child: Image.network(
                            TrackUtils.trackCoverImageUrlFromName(event.track.name),
                            width: 50,
                            //fit: BoxFit.fill,
                          ),
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              RotatedBox(
                                quarterTurns: -1,
                                child: Text(
                                  "${DateFormat('EEEE', 'fr').format(event.startDate).substring(0, 3)}",
                                  style: TextStyle(color: Colors.white, height: 1),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text("${DateFormat('dd', 'fr').format(event.startDate)}", textScaleFactor: 1.5, style: TextStyle(color: Colors.white, height: 1)),
                                  Text("${DateFormat('MMM', 'fr').format(event.startDate)}", textScaleFactor: 0.9, style: TextStyle(color: Colors.white, height: 0.8)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    VerticalDivider(color: Colors.white),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(event.title, textScaleFactor: 1.2, style: TextStyle(color: Colors.white)),
                          Divider(height: 12.0, color: Colors.white),
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.location_on, size: 15, color: Colors.red[700]),
                                        Text("${event.track.name}", textScaleFactor: 0.9, style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    VerticalDivider(color: Colors.white),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.euro_symbol, size: 15, color: Colors.purple[700]),
                                        Text("${StringUtils.formatPrice(event.price)}€", textScaleFactor: 0.9, style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    VerticalDivider(color: Colors.white),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(CustomIcons.helmet, size: 15, color: Colors.teal[700]),
                                        Text(event.organizer, textScaleFactor: 0.9, style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 26,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(event.members.length > 1 ? Icons.group : Icons.person, color: Colors.white, size: 18),
                          Text("${event.members.length}", textScaleFactor: 0.8, style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(8.0),
              ),
            )
          ],
        ),
      ),
    );
  }
}
