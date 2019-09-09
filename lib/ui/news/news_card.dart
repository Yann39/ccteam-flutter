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

import 'package:chachatte_team/models/member.dart';
import 'package:chachatte_team/models/news.dart';
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/services/news_service.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class LikeButton extends StatefulWidget {
  final News news;

  const LikeButton({Key key, this.news}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LikeButtonState();
  }
}

class _LikeButtonState extends State<LikeButton> {
  /// Method to like a news
  _likeNews(BuildContext context, News news) async {
    final Logger _log = new Logger('NewsCard');
    NewsService _newsService = new NewsService();
    Member _member = Provider.of<LoginProvider>(context, listen: false).loggedMember;
    _newsService.likeNews(news.id, _member.id).then((value) {
      _log.fine("News ${news.title} liked by user ${_member.email}");
    }, onError: (error) {
      _log.severe("Error when liking news ${news.title} by user ${_member.email} : $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        IconButton(
          icon: widget.news.members.any((member) => member.email == Provider.of<LoginProvider>(context, listen: false).loggedMember.email)
              ? Icon(Icons.favorite, color: Colors.red[700], size: 18)
              : Icon(Icons.favorite_border, color: Colors.white, size: 18),
          onPressed: () {
            _likeNews(context, widget.news);
          },
        ),
        Text(
          "${widget.news.members.length}",
          textScaleFactor: 0.7,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class NewsCard extends StatelessWidget {
  final News news;
  final AssetImage image;

  NewsCard(this.news, this.image);

  @override
  Widget build(BuildContext context) {
    final LikeButton _likeButton = LikeButton(news: news);

    return Container(
      color: Colors.transparent,
      height: 60.0,
      margin: const EdgeInsets.symmetric(
        vertical: 6.0, // vertical space between cards
        horizontal: 10.0,
      ),
      child: Stack(
        children: <Widget>[
          Container(
            height: 60.0,
            margin: EdgeInsets.only(left: 20.0),
            padding: EdgeInsets.fromLTRB(0, 8.0, 0.0, 8.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromRGBO(0, 100, 200, 0.3), Color.fromRGBO(0, 100, 200, 0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
              //color: primaryColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: <Widget>[
                Container(width: 38.0), // fake horizontal space between image and text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 12.0,
                            ),
                            SizedBox(width: 4.0), // fake horizontal space between icon and text
                            Text(DateUtils.convertToString(news.newsDate, AppConstants.DATE_FORMAT),
                                softWrap: false, textScaleFactor: 0.8, style: TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.fade)
                          ],
                        ),
                      ),
                      SizedBox(height: 4.0), // vertical space between the 2 lines of text
                      Flexible(
                        child: Text(news.title, softWrap: false, textScaleFactor: 1.1, style: TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.fade),
                      )
                    ],
                  ),
                ),
                /*Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 20,
                  ),
                ),*/
                _likeButton,
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 14.0),
            child: Image(
              image: image,
              width: 44.0,
            ),
          ),
        ],
      ),
    );
  }
}
