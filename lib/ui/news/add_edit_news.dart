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
import 'package:chachatte_team/utils/constants.dart';
import 'package:chachatte_team/utils/custom_decorations.dart';
import 'package:chachatte_team/utils/date_utils.dart';
import 'package:chachatte_team/utils/strings.dart';
import 'package:chachatte_team/widgets/save_cancel_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddEditNews extends StatefulWidget {
  final News news;

  const AddEditNews({Key key, this.news}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddEditNewsState();
  }
}

class _AddEditNewsState extends State<AddEditNews> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _datePickerController = new TextEditingController();

  // the news to be created
  final News _newNews = new News(members: []);

  initState() {
    // set date picker text if set
    if (widget.news != null) {
      _datePickerController.text = DateUtils.convertToString(widget.news.newsDate, DATE_FORMAT);
    }
    return super.initState();
  }

  /// Initialize and display a Date picker related to the specified [controller] in the specified [context]
  Future _chooseDate(BuildContext context, TextEditingController controller, DateTime defaultValue) async {
    final DateTime _currentDate = DateTime.now();
    final TimeOfDay _currentTime = TimeOfDay.now();

    // define initial date and time from the specified default DateTime value if set
    final DateTime _initialDate = defaultValue ?? _currentDate;
    final TimeOfDay _initialTime = defaultValue != null ? TimeOfDay.fromDateTime(defaultValue) : _currentTime;

    // show the date picker and await for the chosen date
    final DateTime _dateResult =
        await showDatePicker(context: context, initialDate: _initialDate, firstDate: DateTime(_currentDate.year - 5), lastDate: DateTime(_currentDate.year + 5));
    if (_dateResult == null) return;

    // show the time picker and await for the chosen time
    final TimeOfDay _timeResult = await showTimePicker(context: context, initialTime: _initialTime);
    if (_timeResult == null) return;

    // build final date with time
    final DateTime finalDateTime = DateTime(_dateResult.year, _dateResult.month, _dateResult.day, _timeResult.hour, _timeResult.minute);

    // notify the framework that the internal state of this object has changed
    setState(() {
      controller.text = DateFormat(DATE_FORMAT).format(finalDateTime);
    });
  }

  /// Validate the form then submit data to backend
  void submitForm(News news) {
    final FormState _form = _formKey.currentState;

    if (!_form.validate()) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(AppString.formNotValid)));
    } else {
      // this invokes each onSaved event
      _form.save();

      // submit data to backend, if id is set this is an update, else a creation
      if (news.id != null) {
        // update the news then go back with a message, the result is awaited in caller
        Provider.of<NewsProvider>(context, listen: false).updateNews(news).then((value) {
          Navigator.pop(context, AppString.newsUpdated);
        }, onError: (error) {
          Navigator.pop(context, AppString.newsUpdateFailed);
        });
      } else {
        // create the news then go back with a message, the result is awaited in caller
        Provider.of<NewsProvider>(context, listen: false).createNews(news).then((value) {
          Navigator.pop(context, AppString.newsCreated);
        }, onError: (error) {
          Navigator.pop(context, AppString.newsUpdateFailed);
        });
      }
    }
  }

  Widget build(BuildContext context) {
    // the current News to be edited
    final News _currNews = widget.news != null ? widget.news : _newNews;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppString.newsCreate),
      ),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: Stack(
          children: <Widget>[
            Form(
              key: _formKey,
              autovalidate: false,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.title),
                      hintText: AppString.newsTitleHint,
                      labelText: AppString.newsTitle,
                    ),
                    maxLines: 1,
                    inputFormatters: [LengthLimitingTextInputFormatter(128)],
                    validator: (val) => val.isEmpty ? AppString.newsTitleMandatory : null,
                    onSaved: (val) => _currNews.title = val,
                    initialValue: _currNews.title,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.short_text),
                      hintText: AppString.newsContentHint,
                      labelText: AppString.newsContent,
                    ),
                    maxLines: 5,
                    inputFormatters: [LengthLimitingTextInputFormatter(2048)],
                    validator: (val) => val.isEmpty ? AppString.newsContentMandatory : null,
                    onSaved: (val) => _currNews.content = val,
                    initialValue: _currNews.content,
                  ),
                  GestureDetector(
                    onTap: () => _chooseDate(context, _datePickerController, _currNews.newsDate),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.calendar_today),
                          hintText: AppString.newsDateHint,
                          labelText: AppString.newsDate,
                        ),
                        controller: _datePickerController,
                        keyboardType: TextInputType.datetime,
                        validator: (val) => !DateUtils.isBeforeNow(val, DATE_FORMAT) ? (val.isEmpty ? AppString.newsDateMandatory : null) : AppString.newsDateNotValid,
                        onSaved: (val) => _currNews.newsDate = DateFormat(DATE_FORMAT).parseStrict(val),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SaveCancelBar(
              saveFunction: () => submitForm(_currNews),
              cancelFunction: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
