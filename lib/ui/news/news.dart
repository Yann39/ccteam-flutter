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

import 'dart:math';

import 'package:chachatte_team/models/news.dart';
import 'package:chachatte_team/services/news_service.dart';
import 'package:chachatte_team/ui/login.dart';
import 'package:chachatte_team/ui/news/add_news.dart';
import 'package:chachatte_team/ui/news/news_card.dart';
import 'package:chachatte_team/ui/news/news_detail.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewsListState();
  }
}

enum QuickActions { about, contact, logout }

class _NewsListState extends State<NewsList> {
  static final NewsService newsService = new NewsService();

  List helmets = ["images/helmet-blue.png", "images/helmet-green.png", "images/helmet-red.png", "images/helmet-purple.png", "images/helmet-yellow.png"];
  List bgColors = [
    Color.fromRGBO(0, 100, 200, 0.4),
    //Color.fromRGBO(255, 255, 255, 0.3),
    Color.fromRGBO(25, 120, 25, 0.5),
    Color.fromRGBO(180, 0, 25, 0.5),
    Color.fromRGBO(200, 0, 100, 0.5),
    Color.fromRGBO(200, 200, 100, 1)
  ];
  Random random = new Random();

  /// Method that launches the Add News screen and awaits the result from Navigator.pop
  _navigateToAddNewsScreen(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddNews()));

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  /// Method that launches the News detail screen and awaits the result from Navigator.pop
  _navigateToNewsDetailScreen(BuildContext context, News news) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the target screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetail(news: news)));

    // after the target screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  _launchURL() async {
    const url = 'mailto:rockyracer@mailfence.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _select(QuickActions choice) {
    if (choice == QuickActions.contact) {
      _launchURL();
    } else if (choice == QuickActions.logout) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    }
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(AppString.applicationTitle),
        leading: new Icon(Icons.home),
        actions: <Widget>[
          PopupMenuButton<QuickActions>(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<QuickActions>(
                  child: Text(AppString.about),
                  value: QuickActions.about,
                ),
                PopupMenuItem<QuickActions>(
                  child: Text(AppString.contact),
                  value: QuickActions.contact,
                ),
                PopupMenuItem<QuickActions>(
                  child: Text(AppString.logout),
                  value: QuickActions.logout,
                ),
              ];
            },
            onSelected: _select,
          )
        ],
      ),
      body: new NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          final double width = MediaQuery.of(context).size.width;
          return <Widget>[
            SliverAppBar(
              expandedHeight: 150.0,
              floating: true,
              backgroundColor: Colors.transparent,
              pinned: false,
              flexibleSpace: new Container(
                child: FlexibleSpaceBar(
                  centerTitle: true,
                  background: Opacity(
                      child: Image.asset(
                        'images/chachatte-team-banner.png',
                        width: width,
                        fit: BoxFit.fitWidth,
                      ),
                      opacity: 1.0),
                ),
                decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                    colors: [Colors.white, Colors.blue[100]],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(0.0, 1.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp,
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          child: Center(
            child: FutureBuilder<List<News>>(
              future: newsService.fetchNews(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return new Column(
                    children: <Widget>[
                      new Expanded(
                        child: new ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            final int randomIndex = random.nextInt(3);
                            return new InkWell(
                              child: NewsCard(snapshot.data[index], new AssetImage(helmets[0]), bgColors[0], Colors.purple[200]),
                              onTap: () => _navigateToNewsDetailScreen(context, snapshot.data[index]),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                // By default, show a loading spinner
                return CircularProgressIndicator();
              },
            ),
          ),
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors: [Colors.blue[100], Colors.blue[300]],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(0.0, 1.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          elevation: 0.0,
          child: new Icon(Icons.add),
          backgroundColor: Colors.red[700],
          onPressed: () {
            _navigateToAddNewsScreen(context);
          }),
    );
  }
}
