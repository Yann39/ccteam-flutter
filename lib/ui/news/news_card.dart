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

import 'package:ccteam/models/news.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/news_list_provider.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/custom_icons.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsCard extends StatelessWidget {
  final int index;

  NewsCard(this.index);

  @override
  Widget build(BuildContext context) {
    final NewsListProvider _newsListProvider = Provider.of<NewsListProvider>(context, listen: true);
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    // the news to display in this card
    final News news = _newsListProvider.newsList[index];

    // the icon color
    final Color _color = index % 3 == 0
        ? Colors.red[900]!
        : index % 3 == 1
            ? Colors.green[600]!
            : Colors.blue[600]!;

    return Container(
      height: 84.0,
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
                  colors: [_color, Colors.purple[700]!],
                ).createShader(bounds),
                child: Icon(
                  CustomIcons.helmet,
                  size: 35,
                  color: _color,
                ),
              ),
              Row(
                children: <Widget>[
                  Icon(
                    news.likedNews != null &&
                            news.likedNews!.any((element) => element.member!.id == _loginProvider.loggedMember!.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.pink,
                    size: 12.0,
                  ),
                  SizedBox(width: 2.0),
                  Text(
                    "${news.likedNews != null ? news.likedNews!.length : 0}",
                    softWrap: false,
                    textScaler: TextScaler.linear(0.9),
                    style: TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(news.title ?? "",
                    textScaler: TextScaler.linear(1.2),
                    style: TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.0),
                Text(news.catchLine ?? "",
                    textScaler: TextScaler.linear(0.9),
                    style: TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.access_time, color: Colors.lime, size: 12.0),
                    SizedBox(width: 2.0),
                    Text(
                      news.newsDate != null ? AppDateUtils.convertToString(news.newsDate!, DATE_FORMAT) ?? "" : "",
                      softWrap: false,
                      textScaler: TextScaler.linear(0.9),
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
