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
import 'package:chachatte_team/services/news_service.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LikeButton extends StatefulWidget {
  final News news;
  final Member member;

  const LikeButton({Key key, this.news, this.member}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LikeButtonState();
  }
}

class _LikeButtonState extends State<LikeButton> {
  Future<String> getCurrentUserEmail() async {
    // read shared preference
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // if email is set, we will consider user is already logged in
    return prefs.getString('email');
  }

  /// Method to like a news
  _likeNews(BuildContext context, News news) async {
    final Logger log = new Logger('NewsCard');
    var newsService = new NewsService();
    newsService.likeNews(news.id, widget.member.id).then((value) {
      log.fine("News ${news.title} liked by user ${widget.member.email}");
    }, onError: (error) {
      Navigator.pop(context, AppString.newsLikeFailed);
    });
  }

  String loggedUserEmail;

  @override
  Widget build(BuildContext context) {
    getCurrentUserEmail().then((value) {
      setState(() {
        loggedUserEmail = value;
      });
    });

    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        IconButton(
          icon: widget.news.members.any((member) => member.email == loggedUserEmail)
              ? Icon(
                  Icons.favorite,
                  color: Colors.red[700],
                  size: 20,
                )
              : Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 20,
                ),
          onPressed: () {
            _likeNews(context, widget.news);
          },
        ),
        Text(
          "${widget.news.members.length}",
          textScaleFactor: 0.6,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class NewsCard extends StatelessWidget {
  final News news;
  final Member member;
  final AssetImage image;
  final Color primaryColor;
  final Color shadowColor;

  NewsCard(this.news, this.member, this.image, this.primaryColor, this.shadowColor);

  @override
  Widget build(BuildContext context) {
    final LikeButton likeButton = LikeButton(news: news, member: member,);

    return new Container(
      color: Colors.transparent,
      height: 60.0,
      margin: const EdgeInsets.symmetric(
        vertical: 6.0, // vertical space between cards
        horizontal: 10.0,
      ),
      child: new Stack(
        children: <Widget>[
          new Container(
            height: 60.0,
            margin: new EdgeInsets.only(left: 20.0),
            padding: new EdgeInsets.fromLTRB(0, 8.0, 0.0, 8.0),
            decoration: new BoxDecoration(color: primaryColor, shape: BoxShape.rectangle, borderRadius: new BorderRadius.circular(8.0)),
            child: new Row(
              children: <Widget>[
                new Container(width: 38.0), // fake horizontal space between image and text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Flexible(
                        child: new Row(
                          children: <Widget>[
                            Icon(
                              Icons.date_range,
                              color: Colors.white,
                              size: 12.0,
                            ),
                            new SizedBox(width: 4.0), // fake horizontal space between the 2 lines of text
                            new Text(DateUtils.convertToString(news.newsDate, AppConstants.DATE_FORMAT),
                                softWrap: false, textScaleFactor: 0.9, style: new TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)
                          ],
                        ),
                      ),
                      new SizedBox(height: 4.0), // vertical space between the 2 lines of text
                      new Flexible(
                        child: new Text(news.title, softWrap: false, textScaleFactor: 1.2, style: new TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                      )
                    ],
                  ),
                ),
                likeButton
              ],
            ),
          ),
          new Container(
            margin: new EdgeInsets.only(top: 14.0),
            child: new Image(
              image: image,
              width: 44.0,
            ),
          ),
        ],
      ),
    );
  }
}
