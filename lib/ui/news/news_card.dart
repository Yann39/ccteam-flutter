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

import 'package:chachatte_team/models/news.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/custom_decorations.dart';
import 'package:chachatte_team/utils/custom_icons.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:flutter/material.dart';

class NewsCard extends StatelessWidget {
  final News news;
  final int index;

  NewsCard(this.news, this.index);

  @override
  Widget build(BuildContext context) {

    final Color _color = index%3 == 0 ? Colors.red[900] : index%3 == 1 ? Colors.green[600] : Colors.blue[600];

    return Container(
      height: 76.0,
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      decoration: CustomDecorations.cardFull,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          //Image(image: image, height: 30, colorBlendMode: BlendMode.modulate, color: Colors.green),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              //Icon(CustomIcons.helmet, size: 35, color: _color,),
              ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (bounds) => LinearGradient(
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(0.0, 1.0),
                  stops: [0.0, 1.0],
                  colors: [_color, Colors.purple[700]],
                ).createShader(bounds),
                child: Icon(CustomIcons.helmet, size: 35, color: _color,),
              ),
              Row(children: <Widget>[
                Icon(Icons.favorite_border, color: Colors.pink, size: 12.0),
                SizedBox(width: 2.0),
                Text(
                  "3",
                  softWrap: false,
                  textScaleFactor: 0.9,
                  style: TextStyle(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],),
              //Text("News", textScaleFactor: 0.6, style: TextStyle(color: _color, fontFamily: 'Barbatrick', letterSpacing: 1)),
            ],
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(news.title, textScaleFactor: 1.2, style: TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.0),
                Text(news.catchLine, textScaleFactor: 0.9, style: TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.access_time, color: Colors.lime, size: 12.0),
                    SizedBox(width: 2.0),
                    Text(
                      DateUtils.convertToString(news.newsDate, DATE_FORMAT),
                      softWrap: false,
                      textScaleFactor: 0.9,
                      style: TextStyle(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(width: 8.0),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.0),
          Icon(Icons.chevron_right, color: Colors.white, size: 20.0),
        ],
      ),
    );
  }
}
