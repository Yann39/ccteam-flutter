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
import 'package:ccteam/providers/event_list_provider.dart';
import 'package:ccteam/providers/login_provider.dart';
import 'package:ccteam/providers/member_list_provider.dart';
import 'package:ccteam/providers/news_creation_provider.dart';
import 'package:ccteam/providers/news_detail_provider.dart';
import 'package:ccteam/providers/news_list_provider.dart';
import 'package:ccteam/providers/record_list_provider.dart';
import 'package:ccteam/providers/track_list_provider.dart';
import 'package:ccteam/ui/main/main_action_menu.dart';
import 'package:ccteam/ui/main/main_drawer.dart';
import 'package:ccteam/ui/news/news_card.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/home_stats.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class NewsList extends StatelessWidget {
  final Logger _log = new Logger('NewsList');

  /// Navigate to the news creation form screen to create a new news.
  _navigateToAddNewsScreen(BuildContext context) async {
    // set a new news to be created
    Provider.of<NewsCreationProvider>(context, listen: false).setNewsToEdit(new News());

    // navigate to the news creation form screen
    Navigator.pushNamed(context, '/addEditNews');
  }

  /// Navigate to the detail screen of the specified [news].
  _navigateToNewsDetailScreen(BuildContext context, News news) async {
    // fetch the news from the database to get complete data
    Provider.of<NewsDetailProvider>(context, listen: false)
        .fetchNews(news)
        .then(
          (value) => {
            // once fetched, navigate to the news detail screen
            Navigator.pushNamed(context, '/newsDetail'),
          },
        );
  }

  /// Section title above the news feed: "ACTUALITÉS" left-aligned,
  /// underlined by a thin full-width rule. Subtle anchor that breaks
  /// the visual flow between the stats panel and the news cards
  /// without competing with either of them.
  Widget _buildNewsSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            AppString.news.toUpperCase(),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 4.0),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.18)),
        ],
      ),
    );
  }

  /// Pull-to-refresh handler for the whole home screen. Re-fetches:
  ///  - the news feed (the obvious one — the user is pulling on it)
  ///  - the members / events / tracks lists used by the "Le club" stats
  ///  - the logged member (cascades to "Moi" stats: my events, bikes,
  ///    membership fee, next ride)
  ///  - the member's records (so the estimated-km figure recomputes
  ///    with any newly added chrono)
  ///
  /// Everything runs in parallel — the spinner stays only as long as
  /// the slowest call. Errors on individual fetches are already
  /// surfaced by each provider (snackbar / message-provider), so we
  /// don't need to handle them here.
  Future<void> _refreshAll(BuildContext context, NewsListProvider newsListProvider) async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final memberId = loginProvider.loggedMember?.id;
    await Future.wait<void>(<Future<void>>[
      newsListProvider.fetchNewsList(),
      Provider.of<MemberListProvider>(context, listen: false).fetchMemberList(null),
      Provider.of<EventListProvider>(context, listen: false).fetchEventList(),
      Provider.of<TrackListProvider>(context, listen: false).fetchTracks(),
      loginProvider.refreshLoggedMember(),
      if (memberId != null) Provider.of<RecordListProvider>(context, listen: false).fetchMemberRecords(memberId),
    ]);
  }

  Widget build(BuildContext context) {
    _log.info("Building News list...");
    final NewsListProvider _newsListProvider = Provider.of<NewsListProvider>(context, listen: true);
    final LoginProvider _loginProvider = Provider.of<LoginProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.tabHome),
        actions: <Widget>[
          if (_loginProvider.isAdmin)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _navigateToAddNewsScreen(context);
              },
            ),
          MainActionMenu(),
        ],
      ),
      drawer: MainDrawer(),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          const double logoHeight = 150.0;
          final double bodyHeight = constraints.maxHeight;
          // clamp to keep a valid stop ordering even on tiny screens
          final double logoFraction = bodyHeight > 0 ? (logoHeight / bodyHeight).clamp(0.0, 1.0) : 0.5;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue[100]!, Colors.blue[200]!],
                stops: [0.0, logoFraction, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: logoHeight,
                    floating: true,
                    backgroundColor: Colors.transparent,
                    pinned: false,
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset('images/ccteam6.png', fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: HomeStats()),
                  SliverToBoxAdapter(child: _buildNewsSectionHeader()),
                ];
              },
              body: RefreshIndicator(
                onRefresh: () => _refreshAll(context, _newsListProvider),
                child: LoadingContent(
                  loadingStatus: _newsListProvider.loadingStatus,
                  defaultText: AppString.newsEmpty,
                  emptyText: AppString.newsEmpty,
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8.0),
                    itemCount: _newsListProvider.newsList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        child: NewsCard(index),
                        onTap: () => _navigateToNewsDetailScreen(context, _newsListProvider.newsList[index]),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
