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
import 'package:ccteam/providers/news_creation_provider.dart';
import 'package:ccteam/providers/news_detail_provider.dart';
import 'package:ccteam/providers/news_list_provider.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/loading_content.dart';
import 'package:ccteam/widgets/save_cancel_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddEditNews extends StatefulWidget {
  const AddEditNews({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddEditNewsState();
  }
}

class _AddEditNewsState extends State<AddEditNews> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _datePickerController =
      new TextEditingController();

  initState() {
    final NewsCreationProvider _newsCreationProvider =
        Provider.of<NewsCreationProvider>(context, listen: false);
    // set date picker text if set
    if (_newsCreationProvider.news.newsDate != null) {
      _datePickerController.text =
          AppDateUtils.convertToString(
            _newsCreationProvider.news.newsDate!,
            DATE_FORMAT,
          ) ??
          "";
    }
    return super.initState();
  }

  /// Initialize and display a date picker, related to the specified [controller] in the specified [context].
  /// Default value can be specified through the [defaultValue] parameter, else it will be initialized with current date.
  Future _chooseDate(
    BuildContext context,
    TextEditingController controller,
    DateTime? defaultValue,
  ) async {
    final DateTime _currentDate = DateTime.now();
    final TimeOfDay _currentTime = TimeOfDay.now();

    // define initial date and time from the specified default DateTime value if set
    final DateTime _initialDate = defaultValue ?? _currentDate;
    final TimeOfDay _initialTime =
        defaultValue != null
            ? TimeOfDay.fromDateTime(defaultValue)
            : _currentTime;

    // show the date picker and await for the chosen date
    final DateTime? _dateResult = await showDatePicker(
      context: context,
      initialDate: _initialDate,
      firstDate: DateTime(2010, 1, 1),
      lastDate: DateTime(_currentDate.year + 1),
    );

    if (_dateResult != null) {
      // show the time picker and await for the chosen time
      final TimeOfDay? _timeResult = await showTimePicker(
        context: context,
        initialTime: _initialTime,
      );

      if (_timeResult != null) {
        // build final date with time
        final DateTime finalDateTime = DateTime(
          _dateResult.year,
          _dateResult.month,
          _dateResult.day,
          _timeResult.hour,
          _timeResult.minute,
        );

        // notify the framework that the internal state of this object has changed
        setState(() {
          controller.text = DateFormat(DATE_FORMAT).format(finalDateTime);
        });
      }
    }
  }

  /// Validate the form then submit data to backend.
  void submitForm(News news) {
    final FormState _form = _formKey.currentState!;

    if (!_form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(AppString.formNotValid),
        ),
      );
    } else {
      // this invokes each onSaved event
      _form.save();

      final NewsCreationProvider _newsCreationProvider =
          Provider.of<NewsCreationProvider>(context, listen: false);
      final NewsListProvider _newsListProvider = Provider.of<NewsListProvider>(
        context,
        listen: false,
      );

      // submit data to backend, if id is set this is an update, else a creation
      if (news.id != null) {
        _newsCreationProvider.updateNews().then((value) {
          if (value != null) {
            _newsListProvider.updateNewsInList(_newsCreationProvider.news);
            Provider.of<NewsDetailProvider>(
              context,
              listen: false,
            ).setCurrentNews(value);
          } else {}
        });
      } else {
        _newsCreationProvider.createNews().then((value) {
          _newsListProvider.addNewsInList(_newsCreationProvider.news);
        });
      }
      Navigator.pop(context);
    }
  }

  Widget build(BuildContext context) {
    final _newsCreationProvider = Provider.of<NewsCreationProvider>(
      context,
      listen: true,
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(AppString.newsCreate)),
      body: Container(
        decoration: CustomDecorations.mainContent,
        child: LoadingContent(
          loadingStatus: _newsCreationProvider.loadingStatus,
          defaultText: AppString.contentNotLoaded,
          emptyText: AppString.contentNotLoaded,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Form(
                  autovalidateMode: AutovalidateMode.disabled,
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: <Widget>[
                      TextFormField(
                        style: TextStyle(color: Colors.black87),
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.title, color: Colors.black87),
                          hintText: AppString.newsTitleHint,
                          labelText: AppString.newsTitle,
                          labelStyle: TextStyle(color: Colors.black87),
                          floatingLabelStyle: TextStyle(color: Colors.black87),
                          hintStyle: TextStyle(color: Colors.black54),
                        ),
                        maxLines: 1,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(128),
                        ],
                        validator:
                            (val) =>
                                (val == null || val.isEmpty)
                                    ? AppString.newsTitleMandatory
                                    : null,
                        onSaved:
                            (val) => _newsCreationProvider.news.title = val,
                        initialValue: _newsCreationProvider.news.title,
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.black87),
                        decoration: const InputDecoration(
                          icon: const Icon(
                            Icons.short_text,
                            color: Colors.black87,
                          ),
                          hintText: AppString.newsCatchLineHint,
                          labelText: AppString.newsCatchLine,
                          labelStyle: TextStyle(color: Colors.black87),
                          floatingLabelStyle: TextStyle(color: Colors.black87),
                          hintStyle: TextStyle(color: Colors.black54),
                        ),
                        maxLines: 2,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(512),
                        ],
                        validator:
                            (val) =>
                                (val == null || val.isEmpty)
                                    ? AppString.newsContentMandatory
                                    : null,
                        onSaved:
                            (val) => _newsCreationProvider.news.catchLine = val,
                        initialValue: _newsCreationProvider.news.catchLine,
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.black87),
                        decoration: const InputDecoration(
                          icon: const Icon(
                            Icons.format_align_left,
                            color: Colors.black87,
                          ),
                          hintText: AppString.newsContentHint,
                          labelText: AppString.newsContent,
                          labelStyle: TextStyle(color: Colors.black87),
                          floatingLabelStyle: TextStyle(color: Colors.black87),
                          hintStyle: TextStyle(color: Colors.black54),
                        ),
                        maxLines: 5,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(8128),
                        ],
                        validator:
                            (val) =>
                                (val == null || val.isEmpty)
                                    ? AppString.newsContentMandatory
                                    : null,
                        onSaved:
                            (val) => _newsCreationProvider.news.content = val,
                        initialValue: _newsCreationProvider.news.content,
                      ),
                      GestureDetector(
                        onTap:
                            () => _chooseDate(
                              context,
                              _datePickerController,
                              _newsCreationProvider.news.newsDate,
                            ),
                        child: AbsorbPointer(
                          child: TextFormField(
                            style: TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              icon: const Icon(
                                Icons.calendar_today,
                                color: Colors.black87,
                              ),
                              hintText: AppString.newsDateHint,
                              labelText: AppString.newsDate,
                              labelStyle: TextStyle(color: Colors.black87),
                              floatingLabelStyle: TextStyle(
                                color: Colors.black87,
                              ),
                              hintStyle: TextStyle(color: Colors.black54),
                            ),
                            controller: _datePickerController,
                            keyboardType: TextInputType.datetime,
                            validator:
                                (val) =>
                                    _newsCreationProvider.news.id == null &&
                                            val != null &&
                                            !AppDateUtils.isBeforeNow(
                                              val,
                                              DATE_FORMAT,
                                            )
                                        ? AppString.newsDateMustBeFuture
                                        : ((val == null || val.isEmpty)
                                            ? AppString.newsDateMandatory
                                            : null),
                            onSaved:
                                (val) =>
                                    _newsCreationProvider
                                        .news
                                        .newsDate = DateFormat(
                                      DATE_FORMAT,
                                    ).parseStrict(val!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: SaveCancelBar(
                  saveFunction: () => submitForm(_newsCreationProvider.news),
                  cancelFunction: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
