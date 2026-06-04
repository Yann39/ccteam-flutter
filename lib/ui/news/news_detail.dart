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
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:ccteam/widgets/random_pattern_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
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
    final Member member = Provider.of<LoginProvider>(
      context,
      listen: false,
    ).loggedMember!;
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
    final Member member = Provider.of<LoginProvider>(
      context,
      listen: false,
    ).loggedMember!;
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
      builder: (_) => AlertDialog(
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

  /// Build the hero header for the news. The background is a unique
  /// procedurally generated geometric pattern, with colors picked from
  /// [_gradientPalettes] based on the news id (so the same news always gets
  /// the same look). The header hosts the title, the catch line and the
  /// author/date metadata.
  Widget _buildHeroHeader(News news) {
    final int seed = news.id ?? news.title?.hashCode ?? 0;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          // procedural pattern background
          Positioned.fill(
            child: CustomPaint(painter: RandomPatternPainter(seed: seed)),
          ),
          // soft dark overlay at the bottom for text readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.22),
                  ],
                ),
              ),
            ),
          ),
          // content
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 28.0, 20.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  news.title ?? "",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 4.0,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (news.catchLine != null && news.catchLine!.isNotEmpty) ...[
                  const SizedBox(height: 12.0),
                  Text(
                    news.catchLine!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 15.0,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 18.0),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8.0,
                  runSpacing: 6.0,
                  children: <Widget>[
                    if (news.createdBy != null)
                      _metadataChip(
                        Icons.person,
                        "${news.createdBy!.firstName} ${news.createdBy!.lastName}",
                      ),
                    _metadataChip(
                      Icons.access_time,
                      news.newsDate != null
                          ? (AppDateUtils.convertToString(
                                  news.newsDate!,
                                  DATE_FORMAT_TXT,
                                ) ??
                                "")
                          : "",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Small translucent pill used to display author / date metadata over the
  /// pattern background.
  Widget _metadataChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 13.0),
          const SizedBox(width: 4.0),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the share + like action buttons row.
  Widget _buildActionButtons(BuildContext context, News news, bool isLiked) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.share, size: 18.0),
              label: Text(AppString.share),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue[700],
                side: BorderSide(color: Colors.blue[700]!),
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () => SharePlus.instance.share(
                ShareParams(
                  subject: news.title,
                  text: news.catchLine,
                  title: news.title,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: OutlinedButton.icon(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 18.0,
                color: isLiked ? Colors.pink[400] : Colors.blue[700],
              ),
              label: Text(isLiked ? AppString.unlike : AppString.like),
              style: OutlinedButton.styleFrom(
                foregroundColor: isLiked ? Colors.pink[400] : Colors.blue[700],
                side: BorderSide(
                  color: isLiked ? Colors.pink[400]! : Colors.blue[700]!,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () => isLiked
                  ? _unlikeNews(context, news)
                  : _likeNews(context, news),
            ),
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

    final News news = _newsDetailProvider.currentNews!;

    // get if that news is liked for current logged member
    final bool isLiked =
        news.likedNews?.any(
          (element) => element.member!.id == _loginProvider.loggedMember!.id,
        ) ??
        false;

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          if (_loginProvider.isAdmin)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _navigateToEditNewsScreen(context, news),
              ),
            ),
          if (_loginProvider.isAdmin)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: () => _showDeleteNewsConfirmation(
                  context,
                  AppString.newsDeletionAreYouSure,
                ),
              ),
            ),
        ],
        title: Text(AppString.detail),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: SafeArea(
          top: false,
          child: LoadingContent(
            loadingStatus: _newsDetailProvider.loadingStatus,
            defaultText: AppString.contentNotLoaded,
            emptyText: AppString.contentNotLoaded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // hero header pinned at the top
                _buildHeroHeader(news),
                if (_loginProvider.isMember)
                  _buildActionButtons(context, news, isLiked),
                // news content takes all remaining vertical space and scrolls internally if it overflows
                Expanded(
                  child: Markdown(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
                    data: news.content ?? "",
                    styleSheet: MarkdownStyleSheet.fromTheme(
                      ThemeData(
                        textTheme: const TextTheme(
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
      ),
    );
  }
}
