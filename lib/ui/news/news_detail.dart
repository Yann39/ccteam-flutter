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
import 'package:chachatte_team/providers/login_provider.dart';
import 'package:chachatte_team/providers/news_provider.dart';
import 'package:chachatte_team/services/notifications_service.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/custom_decorations.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class NewsDetail extends StatelessWidget {

  const NewsDetail({Key key}) : super(key: key);

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

  /// Method to like a news
  _likeNews(BuildContext context, News news) async {
    Provider.of<NewsProvider>(context, listen: false).likeNews(news, Provider.of<LoginProvider>(context, listen: false).loggedMember);
  }

  /// Method to unlike a news
  _unlikeNews(BuildContext context, News news) async {
    Provider.of<NewsProvider>(context, listen: false).unlikeNews(news, Provider.of<LoginProvider>(context, listen: false).loggedMember);
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
              Provider.of<NewsProvider>(context, listen: false).deleteNews(Provider.of<NewsProvider>(context, listen: false).currentNews).then((value) {
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
    final isLiked = _newsProvider.currentNews.members.any((element) => element.id == Provider.of<LoginProvider>(context, listen: false).loggedMember.id);
    print(isLiked);
    return Scaffold(
      //extendBodyBehindAppBar: true,
      appBar: AppBar(
        //backgroundColor: Colors.transparent,
        //elevation: 0,
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.notifications_active),
              onPressed: () =>
                  // send a push notification
                  NotificationsService.pushInstantNewsNotification(_newsProvider.currentNews),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _navigateToEditNewsScreen(context, _newsProvider.currentNews),
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
            CustomPaint(
              child: Container(
                color: Colors.transparent,
                height: 132,
                padding: EdgeInsets.symmetric(vertical: 32.0, horizontal: 8.0),
                width: double.infinity,
              ),
              painter: HeaderPainter(),
            ),
            Container(
              color: Colors.transparent,
              padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: Column(
                children: <Widget>[
                  if (_newsProvider.createdBy != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.person, color: Colors.purple[700], size: 13.0),
                        SizedBox(width: 2.0),
                        Text(
                          "${AppString.by} ${_newsProvider.createdBy.firstName} ${_newsProvider.createdBy.lastName}",
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.access_time, color: Colors.red[700], size: 13.0),
                      SizedBox(width: 2.0),
                      Text(
                        "${AppString.on} ${DateUtils.convertToString(_newsProvider.currentNews.newsDate, DATE_FORMAT_TXT)}",
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _newsProvider.currentNews.title,
                textScaleFactor: 2,
                style: TextStyle(color: Colors.black87),
              ),
            ),
            Divider(
              height: 8,
              color: Colors.purple,
              thickness: 2.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onPressed: () => {Share.share(_newsProvider.currentNews.catchLine, subject: _newsProvider.currentNews.title)},
                      padding: EdgeInsets.symmetric(horizontal: 6.0),
                      color: Colors.blue[700],
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.share, color: Colors.white, size: 13),
                          SizedBox(width: 5),
                          Text(
                            AppString.share,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  SizedBox(
                    height: 20,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onPressed: () => isLiked ? _unlikeNews(context, _newsProvider.currentNews) : _likeNews(context, _newsProvider.currentNews),
                      padding: EdgeInsets.symmetric(horizontal: 6.0),
                      color: Colors.blue[700],
                      child: Row(
                        children: <Widget>[
                          Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.pink : Colors.white, size: 13),
                          SizedBox(width: 5),
                          Text(
                            isLiked ? AppString.unlike : AppString.like,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Markdown(
                padding: EdgeInsets.all(8.0),
                data: _newsProvider.currentNews.content,
              ),
            ),
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
    paint.blendMode = BlendMode.srcATop;

    Path path = Path()
      ..lineTo(0, size.height)
      ..lineTo(size.width * 0.30, size.height * 0.25)
      ..lineTo(size.width * 0.55, size.height * 0.55)
      ..lineTo(size.width * 0.62, size.height * 0.30)
      ..lineTo(size.width * 0.80, size.height * 0.88)
      ..lineTo(size.width, size.height * 0.37)
      ..lineTo(size.width, 0)
      ..close();

    paint
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0, 1],
        colors: [Colors.red[700].withOpacity(0.4), Colors.purple[700].withOpacity(0.7)],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

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

    canvas.drawPath(path, paint);

    path = Path()
      ..lineTo(size.width * 0.25, 0)
      ..lineTo(size.width * 0.40, size.height * 0.20)
      ..lineTo(size.width * 0.50, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
