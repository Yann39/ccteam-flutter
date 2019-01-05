import 'package:chachatte_team/models/news.dart';
import 'package:chachatte_team/services/news_service.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddNews extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddNewsState();
  }
}

class _AddNewsState extends State<AddNews> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _controller = new TextEditingController();

  // the current News to be created
  final News newNews = new News();

  /// Initialize and display a Date picker related to the specified [controller] in the specified [context]
  Future _chooseDate(BuildContext context, TextEditingController controller) async {
    final DateTime now = new DateTime.now();
    final TimeOfDay initialTime = TimeOfDay.now();
    DateTime initialDate = DateUtils.convertToDate(controller.text, "d/M/y H:m") ?? now;
    initialDate = (initialDate.year >= now.year - 5 && initialDate.year <= now.year + 5 ? initialDate : now);

    // show the date picker and await for the chosen date
    final DateTime dateResult = await showDatePicker(context: context, initialDate: initialDate, firstDate: new DateTime(now.year - 5), lastDate: new DateTime(now.year + 5));
    if (dateResult == null) return;

    // show the time picker and await for the chosen time
    final TimeOfDay timeResult = await showTimePicker(context: context, initialTime: initialTime);
    if (timeResult == null) return;

    // build final date with time
    DateTime finalDateTime = new DateTime(dateResult.year, dateResult.month, dateResult.day, timeResult.hour, timeResult.minute);

    // notify the framework that the internal state of this object has changed
    setState(() {
      controller.text = new DateFormat("d/M/y H:m").format(finalDateTime);
    });
  }

  /// Validate the form then submit data to backend
  void submitForm() {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(backgroundColor: Colors.red, content: new Text(AppString.formNotValid)));
    } else {
      // this invokes each onSaved event
      form.save();

      // submit data to backend
      var newsService = new NewsService();
      newsService.createNews(newNews); //.then((value) => showMessage('News successfully created', Colors.green));

      // go back with a message, the result is awaited in caller
      Navigator.pop(context, AppString.newsCreated);
    }
  }

  /// Go back to previous page
  void goBack() {
    Navigator.pop(context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(AppString.createNews),
          bottom: PreferredSize(
            child: Container(
              child: Row(
                children: <Widget>[
                  new Expanded(
                      child: new FlatButton(
                    child: Text(AppString.cancel.toUpperCase()),
                    onPressed: goBack,
                  )),
                  new Expanded(
                      child: new FlatButton(
                    child: Text(AppString.save.toUpperCase()),
                    onPressed: submitForm,
                  )),
                ],
              ),
              decoration: new BoxDecoration(color: Colors.green[400]),
              height: 50.0,
            ),
            preferredSize: Size.fromHeight(50.0),
          ),
        ),
        body: Container(
          child: new SafeArea(
              top: false,
              bottom: false,
              child: new Form(
                  key: _formKey,
                  autovalidate: true,
                  child: new ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: <Widget>[
                      new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.title),
                          hintText: AppString.newsTitleHint,
                          labelText: AppString.newsTitle,
                        ),
                        maxLines: 1,
                        inputFormatters: [new LengthLimitingTextInputFormatter(128)],
                        validator: (val) => val.isEmpty ? AppString.newsTitleMandatory : null,
                        onSaved: (val) => newNews.title = val,
                      ),
                      new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.short_text),
                          hintText: AppString.newsContentHint,
                          labelText: AppString.newsContent,
                        ),
                        maxLines: 5,
                        inputFormatters: [new LengthLimitingTextInputFormatter(128)],
                        validator: (val) => val.isEmpty ? AppString.newsContentMandatory : null,
                        onSaved: (val) => newNews.content = val,
                      ),
                      new GestureDetector(
                          onTap: () => _chooseDate(context, _controller),
                          child: AbsorbPointer(
                              child: new TextFormField(
                            decoration: new InputDecoration(
                              icon: const Icon(Icons.calendar_today),
                              hintText: AppString.newsDateHint,
                              labelText: AppString.newsDate,
                            ),
                            controller: _controller,
                            keyboardType: TextInputType.datetime,
                                validator: (val) => DateUtils.isBeforeNow(val, "d/M/y H:m") ? (val.isEmpty ? AppString.newsDateMandatory : null) : AppString.newsDateNotValid,
                            onSaved: (val) => newNews.newsDate = new DateFormat("d/M/y H:m").parseStrict(val),
                          ))),
                    ],
                  ))),
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [Colors.green[300], Colors.blue[300]],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ));
  }
}
