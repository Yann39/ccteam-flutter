import 'dart:math';

import 'package:chachatte_team/models/news.dart';
import 'package:chachatte_team/services/news_service.dart';
import 'package:chachatte_team/ui/home_card.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:flutter/material.dart';

class NewsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewsListState();
  }
}

class _NewsListState extends State<NewsList> {
  static final NewsService newsService = new NewsService();

  List helmets = ["images/helmet-blue.png", "images/helmet-green.png", "images/helmet-purple.png", "images/helmet-red.png", "images/helmet-yellow.png"];
  Random random = new Random();

  Widget build(BuildContext context) {
    return new Scaffold(
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
                      colors: [Colors.green[300], Colors.green[400]],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(0.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
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
                                final int index = random.nextInt(5);
                                return new HomeCard(snapshot.data[index].title, DateUtils.convertToString(snapshot.data[index].newsDate, "d/M/y HH:mm"), new AssetImage(helmets[0]), Colors.purple[600], Colors.purple[200]);
                              }))
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
                colors: [Colors.green[400], Colors.blue[300]],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
      ),
    );
  }
}
