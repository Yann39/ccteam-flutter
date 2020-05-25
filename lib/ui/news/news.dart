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
import 'package:chachatte_team/ui/main/main_action_menu.dart';
import 'package:chachatte_team/ui/main/main_drawer.dart';
import 'package:chachatte_team/ui/news/news_card.dart';
import 'package:chachatte_team/utils/custom_decorations.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:chachatte_team/widgets/loading_content.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class NewsList extends StatelessWidget {
  final Logger _log = new Logger('NewsList');

  /// Navigates to the Add News screen and awaits the result from Navigator.pop
  _navigateToAddNewsScreen(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final _result = await Navigator.pushNamed(context, '/addEditNews');

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (_result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$_result")));
    }
  }

  /// Navigates to the News detail screen and awaits the result from Navigator.pop
  _navigateToNewsDetailScreen(BuildContext context, News news) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final _result = await Navigator.pushNamed(context, '/newsDetail', arguments: news);

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (_result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$_result")));
    }
  }

  Widget build(BuildContext context) {
    _log.info("Building News list...");
    final _newsProvider = Provider.of<NewsProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.tabHome),
        actions: <Widget>[
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
                  child: FlexibleSpaceBar(
                    centerTitle: true,
                    background: Opacity(
                      child: Image.asset(
                        'images/chachatte-team-banner.png',
                        fit: BoxFit.fitWidth,
                      ),
                      opacity: 1.0,
                    ),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.blue[100]],
                      begin: FractionalOffset(0.0, 0.0),
                      end: FractionalOffset(0.0, 1.0),
                      stops: [0.0, 1.0],
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
                Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.event_note, color: Colors.red[700], size: 18),
                      SizedBox(width: 3),
                      Text(AppString.news.toUpperCase(), style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
                      //Text(AppString.news, style: TextStyle(color: Colors.black87, fontSize: 16, fontFamily: 'Barbatrick', letterSpacing: 2)),
                    ],
                  ),
                ),
                Expanded(
                  child: LoadingContent(
                    loadingStatus: _newsProvider.loadingStatus,
                    emptyText: AppString.newsEmpty,
                    child: ListView.builder(
                      itemCount: _newsProvider.news.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          child: NewsCard(_newsProvider.news[index], index),
                          onTap: () => _navigateToNewsDetailScreen(context, _newsProvider.news[index]),
                        );
                      },
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
