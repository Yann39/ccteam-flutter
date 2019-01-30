import 'package:chachatte_team/models/news.dart';
import 'package:chachatte_team/services/news_service.dart';
import 'package:chachatte_team/ui/news/add_news.dart';
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';

class NewsDetail extends StatefulWidget {
  final News news;

  const NewsDetail({Key key, this.news}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NewsDetailState();
  }
}

enum ConfirmDialogAction { yes, no }

class _NewsDetailState extends State<NewsDetail> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(() => setState(() {}));
  }

  /// Method that launches the Edit New screen and awaits the result from Navigator.pop
  _navigateToEditNewsScreen(BuildContext context, News news) async {
    // Navigator.push returns a Future that will complete after we call Navigator.pop on the Add News Screen
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddNews(news: news)));

    // after the Edit New Screen returns a result, hide any previous snack bars and show the new result
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result")));
    }
  }

  /// Display a confirmation popup when trying to delete a news
  void _showConfirmation(BuildContext context, String value) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
            title: new Text(AppString.confirmation),
            content: new Text(value),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  _dialogueResult(context, ConfirmDialogAction.yes);
                },
                child: new Text(AppString.confirm),
              ),
              new FlatButton(
                onPressed: () {
                  _dialogueResult(context, ConfirmDialogAction.no);
                },
                child: new Text(AppString.cancel),
              ),
            ],
          ),
    );
  }

  /// Handle result of the news deletion confirmation dialog
  void _dialogueResult(BuildContext context, ConfirmDialogAction value) {
    if (value == ConfirmDialogAction.yes) {
      final NewsService newsService = new NewsService();
      // delete news
      newsService.deleteNews(widget.news).then((value) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AppString.newsDeleted)));
      }, onError: (error) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AppString.newsDeletionFailed)));
      });
    }
    Navigator.pop(context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => _navigateToEditNewsScreen(context, widget.news),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Delete',
            onPressed: () => _showConfirmation(context, AppString.newsDeletionAreYouSure),
          )
        ],
        title: Text('News detail'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Text(DateUtils.convertToString(widget.news.newsDate, AppConstants.DATE_FORMAT), textAlign: TextAlign.left),
            Text(widget.news.title, textScaleFactor: 2, textAlign: TextAlign.center),
            SizedBox(height: 10,),
            Text(widget.news.content),
          ],
        ),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [Colors.blue[100], Colors.blue[500]],
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
