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
import 'package:chachatte_team/services/notifications_service.dart';
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
    final _result = await Navigator.pushNamed(context, '/addEditNews', arguments: [news, AppString.newsEdit]);

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
    final NewsProvider _newsProvider = Provider.of<NewsProvider>(context, listen: true);
    return Scaffold(
      /*appBar: AppBar(
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.notifications_active),
              onPressed: () =>
                  // send a push notification
                  NotificationsService.pushInstantNewsNotification(news),
            ),
          ),
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
      ),*/
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CustomPaint(
              child: Container(
                color: Colors.blue.withOpacity(0.4),
                height: 132,
                padding: EdgeInsets.symmetric(vertical: 32.0, horizontal: 8.0),
                width: double.infinity,
                /*child: Text(
                  "${news.title}",
                  textScaleFactor: 2,
                  style: TextStyle(color: Colors.white),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),*/
              ),
              painter: HeaderPainter(),
            ),
            /*Container(
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
                  if (_newsProvider.createdBy != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.person, color: Colors.lime, size: 12.0),
                        SizedBox(width: 2.0),
                        Text(
                          "${AppString.by} ${_newsProvider.createdBy.firstName} ${_newsProvider.createdBy.lastName}",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white),
                        ),
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
            ),*/
            /*Container(
              color: Colors.blue.withOpacity(0.5),
              width: double.infinity,
              padding: EdgeInsets.all(8.0),
              child: Text(
                "${news.title}",
                textScaleFactor: 2,
                style: TextStyle(color: Colors.white),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),*/
            Container(
              color: Colors.blue.withOpacity(0.4),
              padding: EdgeInsets.only(left:8.0, right: 8.0, bottom: 8.0),
              child: Column(
                children: <Widget>[
                  if (_newsProvider.createdBy != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.person, color: Colors.purple[700], size: 12.0),
                        SizedBox(width: 2.0),
                        Text(
                          "${AppString.by} ${_newsProvider.createdBy.firstName} ${_newsProvider.createdBy.lastName}",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white),
                          textScaleFactor: 0.9,
                        ),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.access_time, color: Colors.red[700], size: 12.0),
                      SizedBox(width: 2.0),
                      Text(
                        "${AppString.on} ${DateUtils.convertToString(news.newsDate, DATE_FORMAT_TXT)}",
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white),
                        textScaleFactor: 0.9,
                      ),
                    ],
                  ),
                ],
              ),
            ),
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

class HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    Path path = Path()
      ..lineTo(0, size.height)
      ..lineTo(size.width * 0.30, size.height * 0.25)
      ..lineTo(size.width * 0.55, size.height * 0.55)
      ..lineTo(size.width * 0.62, size.height * 0.30)
      ..lineTo(size.width * 0.80, size.height * 0.88)
      ..lineTo(size.width, size.height * 0.37)
      ..lineTo(size.width, 0)
      ..close();

    paint.color = Colors.blue.withOpacity(0.6);
    canvas.drawPath(path, paint);

    path = Path()
      ..lineTo(0, size.height * 0.35)
      ..lineTo(size.width * 0.20, size.height * 0.75)
      ..lineTo(size.width * 0.58, size.height * 0.15)
      ..lineTo(size.width * 0.70, size.height * 0.35)
      ..lineTo(size.width * 0.90, 0)
      ..lineTo(size.width, size.height * 0.10)
      ..lineTo(size.width, 0)
      ..close();

    paint.color = Colors.teal.withOpacity(0.4);
    canvas.drawPath(path, paint);

    path = Path()
      ..lineTo(size.width * 0.02, 0)
      ..lineTo(size.width * 0.35, size.height * 0.95)
      ..lineTo(size.width * 0.45, size.height * 0.50)
      ..lineTo(size.width * 0.58, size.height * 0.78)
      ..lineTo(size.width * 0.80, size.height * 0.30)
      ..lineTo(size.width, size.height * 0.65)
      ..lineTo(size.width, 0)
      ..close();

    paint.color = Colors.purple.withOpacity(0.3);
    canvas.drawPath(path, paint);

    path = Path()
      ..lineTo(size.width * 0.25, 0)
      ..lineTo(size.width * 0.40, size.height * 0.20)
      ..lineTo(size.width * 0.50, 0)
      ..lineTo(size.width, 0)
      ..close();

    paint.color = Colors.green.withOpacity(0.8);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
