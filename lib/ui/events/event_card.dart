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

    return InkWell(
      onTap: () => _navigateToEventDetailScreen(context, event),
      child: Container(
        decoration: CustomDecorations.cardFull,
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
                Text("${DateFormat('EEEE', 'fr').format(event.startDate).substring(0, 3)}", textScaleFactor: 0.8, style: TextStyle(color: Colors.white)),
                Text("${DateFormat('dd', 'fr').format(event.startDate)}", textScaleFactor: 1.7, style: TextStyle(color: Colors.white)),
                Text("${DateFormat('MMM', 'fr').format(event.startDate)}", textScaleFactor: 0.9, style: TextStyle(color: Colors.white)),
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
  }
}
