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
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsDetail extends StatefulWidget {
  final News news;

  const NewsDetail({Key key, this.news}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NewsDetailState();
  }
}

class _NewsDetailState extends State<NewsDetail> {
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
  void _showConfirmation(BuildContext context, String value) {
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
              Provider.of<NewsProvider>(context, listen: false).deleteNews(widget.news).then((value) {
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
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () => _navigateToEditNewsScreen(context, widget.news),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Delete',
              onPressed: () => _showConfirmation(context, AppString.newsDeletionAreYouSure),
            ),
          ),
        ],
        title: Text('News detail'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(widget.news.toString()),
            Text(DateUtils.convertToString(widget.news.newsDate, AppConstants.DATE_FORMAT), textAlign: TextAlign.left),
            Text(widget.news.title, textScaleFactor: 2, textAlign: TextAlign.center),
            SizedBox(
              height: 10,
            ),
            Text(widget.news.content),
          ],
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[100], Colors.blue[400]],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
    );
  }
}
