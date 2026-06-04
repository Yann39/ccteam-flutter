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
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/providers/news_creation_provider.dart';
import 'package:ccteam/providers/news_detail_provider.dart';
import 'package:ccteam/providers/news_list_provider.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/date_utils.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:ccteam/utils/strings.dart';
import 'package:ccteam/widgets/form_scaffold.dart';
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
  final TextEditingController _datePickerController = new TextEditingController();

  initState() {
    final NewsCreationProvider _newsCreationProvider = Provider.of<NewsCreationProvider>(context, listen: false);
    // set date picker text if set
    if (_newsCreationProvider.news.newsDate != null) {
      _datePickerController.text =
          AppDateUtils.convertToString(_newsCreationProvider.news.newsDate!, DATE_FORMAT) ?? "";
    }
    return super.initState();
  }

  /// Initialize and display a date picker, related to the specified [controller] in the specified [context].
  /// Default value can be specified through the [defaultValue] parameter, else it will be initialized with current date.
  Future _chooseDate(BuildContext context, TextEditingController controller, DateTime? defaultValue) async {
    final DateTime _currentDate = DateTime.now();
    final TimeOfDay _currentTime = TimeOfDay.now();

    // define initial date and time from the specified default DateTime value if set
    final DateTime _initialDate = defaultValue ?? _currentDate;
    final TimeOfDay _initialTime = defaultValue != null ? TimeOfDay.fromDateTime(defaultValue) : _currentTime;

    // show the date picker and await for the chosen date
    final DateTime? _dateResult = await showDatePicker(
      context: context,
      initialDate: _initialDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(_currentDate.year + 1),
    );

    if (_dateResult != null) {
      // show the time picker and await for the chosen time
      final TimeOfDay? _timeResult = await showTimePicker(context: context, initialTime: _initialTime);

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
  Future<void> submitForm(News news) async {
    final FormState _form = _formKey.currentState!;

    if (!_form.validate()) {
      Provider.of<MessageProvider>(context, listen: false).setMessage(AppString.formNotValid, MessageType.ERROR);
      return;
    }
    // this invokes each onSaved event
    _form.save();

    final NewsCreationProvider _newsCreationProvider = Provider.of<NewsCreationProvider>(context, listen: false);
    final NewsListProvider _newsListProvider = Provider.of<NewsListProvider>(context, listen: false);
    final NewsDetailProvider _newsDetailProvider = Provider.of<NewsDetailProvider>(context, listen: false);

    // submit data to backend, if id is set this is an update, else a creation
    if (news.id != null) {
      final News? updated = await _newsCreationProvider.updateNews();
      if (updated != null) {
        _newsListProvider.updateNewsInList(_newsCreationProvider.news);
        _newsDetailProvider.setCurrentNews(updated);
      }
    } else {
      await _newsCreationProvider.createNews();
      _newsListProvider.addNewsInList(_newsCreationProvider.news);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget build(BuildContext context) {
    final _newsCreationProvider = Provider.of<NewsCreationProvider>(context, listen: true);

    final _titleField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.title),
        hintText: AppString.newsTitleHint,
        labelText: AppString.newsTitle,
      ),
      maxLines: 1,
      inputFormatters: [LengthLimitingTextInputFormatter(128)],
      validator: (val) => (val == null || val.isEmpty) ? AppString.newsTitleMandatory : null,
      onSaved: (val) => _newsCreationProvider.news.title = val,
      initialValue: _newsCreationProvider.news.title,
    );

    final _catchLineField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.short_text),
        hintText: AppString.newsCatchLineHint,
        labelText: AppString.newsCatchLine,
      ),
      maxLines: 2,
      inputFormatters: [LengthLimitingTextInputFormatter(512)],
      validator: (val) => (val == null || val.isEmpty) ? AppString.newsContentMandatory : null,
      onSaved: (val) => _newsCreationProvider.news.catchLine = val,
      initialValue: _newsCreationProvider.news.catchLine,
    );

    final _contentField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.format_align_left),
        hintText: AppString.newsContentHint,
        labelText: AppString.newsContent,
      ),
      maxLines: 5,
      inputFormatters: [LengthLimitingTextInputFormatter(8128)],
      validator: (val) => (val == null || val.isEmpty) ? AppString.newsContentMandatory : null,
      onSaved: (val) => _newsCreationProvider.news.content = val,
      initialValue: _newsCreationProvider.news.content,
    );

    final _dateField = GestureDetector(
      onTap: () => _chooseDate(context, _datePickerController, _newsCreationProvider.news.newsDate),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: const InputDecoration(
            icon: Icon(Icons.calendar_today),
            hintText: AppString.newsDateHint,
            labelText: AppString.newsDate,
          ),
          controller: _datePickerController,
          keyboardType: TextInputType.datetime,
          validator: (val) {
            if (val == null || val.isEmpty) return AppString.newsDateMandatory;
            // only enforce "must be in the future" rule on creation —
            // existing news may legitimately have a past date.
            if (_newsCreationProvider.news.id == null && AppDateUtils.isBeforeNow(val, DATE_FORMAT)) {
              return AppString.newsDateMustBeFuture;
            }
            return null;
          },
          onSaved: (val) => _newsCreationProvider.news.newsDate = DateFormat(DATE_FORMAT).parseStrict(val!),
        ),
      ),
    );

    return FormScaffold(
      title: AppString.newsCreate,
      formKey: _formKey,
      loadingStatus: _newsCreationProvider.loadingStatus,
      onSave: () => submitForm(_newsCreationProvider.news),
      fields: <Widget>[_titleField, _catchLineField, _contentField, _dateField],
    );
  }
}
