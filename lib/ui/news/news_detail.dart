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
import 'package:chachatte_team/providers/news_provider.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/custom_decorations.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

class NewsDetail extends StatelessWidget {
  final News news;

  const NewsDetail({Key key, this.news}) : super(key: key);

  /// Method that launches the Edit New screen and awaits the result from Navigator.pop
  _navigateToEditNewsScreen(BuildContext context, News news) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the Add News screen
    final _result = await Navigator.pushNamed(context, '/addEditNews', arguments: news);

    // after the Edit New Screen returns a result, hide any previous snack bars and show the new result
    if (_result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$_result")));
    }
  }

  /// Display a confirmation popup when trying to delete a news
  _showConfirmation(BuildContext context, String value) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppString.confirmation),
        content: Text(value),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              // close this dialog
              Navigator.pop(context);
              // delete news
              Provider.of<NewsProvider>(context, listen: false).deleteNews(news).then((value) {
                Navigator.pop(context, AppString.newsDeleted);
              }, onError: (error) {
                Navigator.pop(context, AppString.newsDeletionFailed);
              });
            },
            child: Text(AppString.confirm),
          ),
          FlatButton(
            onPressed: () {
              // close this dialog
              Navigator.pop(context);
            },
            child: Text(AppString.cancel),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _navigateToEditNewsScreen(context, news),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: () => _showConfirmation(context, AppString.newsDeletionAreYouSure),
            ),
          ),
        ],
        title: Text(AppString.detail),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              height: 132,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue[300],
                    spreadRadius: 1,
                    blurRadius: 2,
                  ),
                ],
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage("images/finish_flag.png"),
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.05), BlendMode.dstATop),
                ),
                gradient: LinearGradient(
                  colors: [Colors.blue[300], Colors.blue[500]],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "${news.title}",
                    textScaleFactor: 2,
                    style: TextStyle(color: Colors.white),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.person, color: Colors.lime, size: 12.0),
                      SizedBox(width: 2.0),
                      Text("${AppString.by} ${news.createdBy.firstName} ${news.createdBy.lastName}", textAlign: TextAlign.left, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.access_time, color: Colors.lime, size: 12.0),
                      SizedBox(width: 2.0),
                      Text("${AppString.on} ${DateUtils.convertToString(news.newsDate, DATE_FORMAT_TXT)}", textAlign: TextAlign.left, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 36, color: Colors.white),
            Flexible(
              child: Markdown(
                data: news.content,
              ),
            ),
            //Text(news.content, textScaleFactor: 1.3, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
