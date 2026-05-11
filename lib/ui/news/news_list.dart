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
import 'package:ccteam/providers/news_creation_provider.dart';
import 'package:ccteam/providers/news_detail_provider.dart';
import 'package:ccteam/providers/news_list_provider.dart';
import 'package:ccteam/ui/main/main_action_menu.dart';
import 'package:ccteam/ui/main/main_drawer.dart';
import 'package:ccteam/ui/news/news_card.dart';
import 'package:ccteam/utils/custom_decorations.dart';
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
      body: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 150.0,
                floating: true,
                backgroundColor: Colors.transparent,
                pinned: false,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.blue[100]!],
                      begin: FractionalOffset(0.0, 0.0),
                      end: FractionalOffset(0.0, 1.0),
                      stops: [0.0, 1.0],
                    ),
                  ),
                  child: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset('images/ccteam6.png', fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Container(
            decoration: CustomDecorations.mainContent,
            child: Column(
              children: <Widget>[
                const HomeStats(),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    AppString.news,
                    style: TextStyle(color: Colors.black87, fontSize: 16, fontFamily: 'Barbatrick', letterSpacing: 2),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _newsListProvider.fetchNewsList(),
                    child: LoadingContent(
                      loadingStatus: _newsListProvider.loadingStatus,
                      defaultText: AppString.newsEmpty,
                      emptyText: AppString.newsEmpty,
                      child: ListView.builder(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
