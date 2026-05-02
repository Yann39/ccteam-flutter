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

import 'package:ccteam/models/member.dart';
import 'package:ccteam/models/news.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/news_creation_provider.dart';
import 'package:ccteam/providers/news_detail_provider.dart';
import 'package:ccteam/providers/news_list_provider.dart';
import 'package:ccteam/services/notifications_service.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class NewsDetail extends StatelessWidget {
  final Logger _log = new Logger('NewsDetail');

  /// Navigate to the news creation form screen to edit the specified [news].
  _navigateToEditNewsScreen(BuildContext context, News news) async {
    // need deep copy here else the reference will be updated even on error
    Provider.of<NewsCreationProvider>(
      context,
      listen: false,
    ).setNewsToEdit(News.clone(news));

    // navigate to the news creation form screen
    Navigator.pushNamed(context, '/addEditNews');
  }

  /// Set the specified [news] as liked by the current logged member.
  _likeNews(BuildContext context, News news) async {
    final Member member =
        Provider.of<LoginProvider>(context, listen: false).loggedMember!;
    Provider.of<NewsDetailProvider>(context, listen: false)
        .likeNews(news, member)
        .then(
          (value) => {
            // update the news in the news list
            Provider.of<NewsListProvider>(
              context,
              listen: false,
            ).updateNewsInList(
              Provider.of<NewsDetailProvider>(
                context,
                listen: false,
              ).currentNews!,
            ),
          },
        );
  }

  /// Set the specified [news] as not liked by the current logged member.
  _unlikeNews(BuildContext context, News news) async {
    final Member member =
        Provider.of<LoginProvider>(context, listen: false).loggedMember!;
    Provider.of<NewsDetailProvider>(context, listen: false)
        .unlikeNews(news, member)
        .then(
          (value) => {
            // update the news in the news list
            Provider.of<NewsListProvider>(
              context,
              listen: false,
            ).updateNewsInList(
              Provider.of<NewsDetailProvider>(
                context,
                listen: false,
              ).currentNews!,
            ),
          },
        );
  }

  /// Display a confirmation popup when trying to delete a news.
  _showDeleteNewsConfirmation(BuildContext context, String value) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(AppString.confirmation),
            content: Text(value),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  final NewsDetailProvider newsDetailProvider =
                      Provider.of<NewsDetailProvider>(context, listen: false);
                  final NewsListProvider newsListProvider =
                      Provider.of<NewsListProvider>(context, listen: false);
                  final News newsToDelete = newsDetailProvider.currentNews!;
                  // delete news
                  newsDetailProvider.deleteNews(newsToDelete).then((value) {
                    // remove news from the news list
                    newsListProvider.removeNewsFromList(newsToDelete);
                    // back to news list (need to pop 2 times)
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                },
                child: Text(AppString.confirm),
              ),
              TextButton(
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
    _log.info("Building News detail...");

    final NewsDetailProvider _newsDetailProvider =
        Provider.of<NewsDetailProvider>(context, listen: true);
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(
      context,
      listen: false,
    );

    // if currentNews is null (e.g. after session expiration), don't render content
    if (_newsDetailProvider.currentNews == null) {
      return Scaffold(
        body: Container(decoration: CustomDecorations.mainContent),
      );
    }

    // get if that news is liked for current logged member
    final bool isLiked =
        _newsDetailProvider.currentNews!.likedNews?.any(
          (element) => element.member!.id == _loginProvider.loggedMember!.id,
        ) ??
        false;

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          if (_loginProvider.isMember) ...[
            Builder(
              builder:
                  (context) => IconButton(
                    icon: Icon(Icons.notifications_active),
                    onPressed:
                        () =>
                        // send a push notification
                        NotificationsService.pushInstantNewsNotification(
                          _newsDetailProvider.currentNews!,
                        ),
                  ),
            ),
            Builder(
              builder:
                  (context) => IconButton(
                    icon: Icon(Icons.edit),
                    onPressed:
                        () => _navigateToEditNewsScreen(
                          context,
                          _newsDetailProvider.currentNews!,
                        ),
                  ),
            ),
            Builder(
              builder:
                  (context) => IconButton(
                    icon: Icon(Icons.delete_forever),
                    onPressed:
                        () => _showDeleteNewsConfirmation(
                          context,
                          AppString.newsDeletionAreYouSure,
                        ),
                  ),
            ),
          ],
        ],
        title: Text(AppString.detail),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: LoadingContent(
          loadingStatus: _newsDetailProvider.loadingStatus,
          defaultText: AppString.contentNotLoaded,
          emptyText: AppString.contentNotLoaded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CustomPaint(
                child: Container(
                  color: Colors.transparent,
                  height: 132,
                  padding: EdgeInsets.symmetric(
                    vertical: 32.0,
                    horizontal: 8.0,
                  ),
                  width: double.infinity,
                ),
                painter: HeaderPainter(),
              ),
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Column(
                  children: <Widget>[
                    if (_newsDetailProvider.currentNews!.createdBy != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.person,
                            color: Colors.purple[700],
                            size: 13.0,
                          ),
                          SizedBox(width: 2.0),
                          Text(
                            "${AppString.by} ${_newsDetailProvider.currentNews!.createdBy!.firstName} ${_newsDetailProvider.currentNews!.createdBy!.lastName}",
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.access_time,
                          color: Colors.red[700],
                          size: 13.0,
                        ),
                        SizedBox(width: 2.0),
                        Text(
                          "${AppString.on} ${AppDateUtils.convertToString(_newsDetailProvider.currentNews!.newsDate!, DATE_FORMAT_TXT)}",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 8, color: Colors.purple, thickness: 2.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _newsDetailProvider.currentNews!.title!,
                  textScaler: TextScaler.linear(2),
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              if (_loginProvider.isMember)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            backgroundColor: Colors.blue[700],
                          ),
                          onPressed:
                              () => {
                                Share.share(
                                  _newsDetailProvider.currentNews!.catchLine!,
                                subject: _newsDetailProvider.currentNews!.title,
                                ),
                              },
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
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            backgroundColor: Colors.blue[700],
                          ),
                          onPressed:
                              () =>
                                  isLiked
                                      ? _unlikeNews(
                                        context,
                                        _newsDetailProvider.currentNews!,
                                      )
                                      : _likeNews(
                                        context,
                                        _newsDetailProvider.currentNews!,
                                      ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.pink : Colors.white,
                                size: 13,
                              ),
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
                  data: _newsDetailProvider.currentNews!.content!,
                  styleSheet: MarkdownStyleSheet.fromTheme(
                    ThemeData(
                      textTheme: TextTheme(
                        bodyMedium: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the header graphics.
class HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.blendMode = BlendMode.srcATop;

    Path path =
        Path()
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
        colors: [
          Colors.red[700]!.withAlpha(102),
          Colors.purple[700]!.withAlpha(179),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    path =
        Path()
          ..lineTo(size.width * 0.02, 0)
          ..lineTo(size.width * 0.35, size.height * 0.95)
          ..lineTo(size.width * 0.45, size.height * 0.50)
          ..lineTo(size.width * 0.58, size.height * 0.78)
          ..lineTo(size.width * 0.80, size.height * 0.30)
          ..lineTo(size.width, size.height * 0.65)
          ..lineTo(size.width, 0)
          ..close();

    canvas.drawPath(path, paint);

    path =
        Path()
          ..lineTo(0, size.height * 0.35)
          ..lineTo(size.width * 0.20, size.height * 0.75)
          ..lineTo(size.width * 0.58, size.height * 0.15)
          ..lineTo(size.width * 0.70, size.height * 0.35)
          ..lineTo(size.width * 0.90, 0)
          ..lineTo(size.width, size.height * 0.10)
          ..lineTo(size.width, 0)
          ..close();

    canvas.drawPath(path, paint);

    path =
        Path()
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
