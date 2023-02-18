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

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

enum CalendarMode { decade, year, month, week }

class CalendarSelector extends StatefulWidget {
  final CalendarMode mode; // the calendar display mode
  final DateTime centerDate; // the date to be rendered on center
  final DateTime selectedDate; // the default selected date
  final Function onDateSelected; // a function to execute on date selection
  final bool
      onlyMonthDays; // a boolean indicating if we need to display previous and next months days in month view
  final bool
      expandable; // a boolean indicating if calendar is expandable between week to month views
  final Map<String, DateTime> eventsDates; // list of events dates
  final Color
      weekEndDayColor; // color to apply on week end days in month and week views
  final int
      firstWeekDay; // the first week day to display in month and week views
  final String locale; // the locale to use to render dates as strings

  CalendarSelector({
    this.mode = CalendarMode.month,
    this.centerDate,
    this.selectedDate,
    this.onDateSelected,
    this.onlyMonthDays = false,
    this.expandable = true,
    this.eventsDates,
    this.locale = "en",
    this.weekEndDayColor = Colors.black87,
    this.firstWeekDay = DateTime.monday,
  });

  State<CalendarSelector> createState() =>
      CalendarSelectorState(mode, centerDate, selectedDate);
}

class CalendarSelectorState extends State<CalendarSelector>
    with TickerProviderStateMixin {
  CalendarMode _calendarMode; // the current calendar display mode
  DateTime _centerDate; // the current center date
  DateTime _selectedDate; // the current selected date
  DateTime _initDate; // to remember the initial date

  // hack so we can use paging in both directions
  final PageController _pageController = new PageController(initialPage: 5000);

  AnimationController _animationController;
  Animation<double> _animation;

  CalendarSelectorState(
      CalendarMode calendarMode, DateTime centerDate, DateTime selectedDate) {
    _calendarMode = calendarMode;
    _centerDate = centerDate ?? DateTime.now();
    _selectedDate = selectedDate;
    _initDate = _centerDate;
  }

  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(
        duration: Duration(milliseconds: 200), vsync: this);
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.decelerate);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Capitalize the specified [string]
  String capitalize(String string) =>
      string[0].toUpperCase() + string.substring(1);

  /// Build the top bar content widget according to the current display mode
  Widget getTopWidget() {
    switch (_calendarMode) {
      case CalendarMode.decade:
        return Text(
          "${DateFormat('yyyy', widget.locale).format(_centerDate)} - ${DateFormat('yyyy', widget.locale).format(DateTime(_centerDate.year + 10, _centerDate.month, _centerDate.day))}",
          textScaleFactor: 1.2,
        );
      case CalendarMode.year:
        return InkWell(
          onTap: () => setCalendarMode(CalendarMode.decade, _centerDate),
          child: Text(DateFormat('yyyy', widget.locale).format(_centerDate),
              textScaleFactor: 1.2),
        );
      case CalendarMode.month:
        return InkWell(
          onTap: () => setCalendarMode(CalendarMode.year, _centerDate),
          child: Text(
              capitalize(
                  DateFormat('MMMM yyyy', widget.locale).format(_centerDate)),
              textScaleFactor: 1.2),
        );
      case CalendarMode.week:
        return InkWell(
          onTap: () => setCalendarMode(CalendarMode.year, _centerDate),
          child: Text(
              capitalize(
                  DateFormat('MMMM yyyy', widget.locale).format(_centerDate)),
              textScaleFactor: 1.2),
        );
      default:
        return Text("Unsupported mode");
    }
  }

  /// Get calendar bottom content depending on current calendar mode and expandable option
  Widget getBottomWidget() {
    if (widget.expandable) {
      if (_calendarMode == CalendarMode.week) {
        return InkWell(
            onTap: () => setCalendarMode(CalendarMode.month, _centerDate),
            child: Icon(Icons.keyboard_arrow_down));
      } else if (_calendarMode == CalendarMode.month) {
        return InkWell(
            onTap: () => setCalendarMode(CalendarMode.week, _centerDate),
            child: Icon(Icons.keyboard_arrow_up));
      }
    }
    return SizedBox();
  }

  /// Get calendar content depending on current calendar mode
  Widget getContentWidget() {
    switch (_calendarMode) {
      case CalendarMode.decade:
        return getDecadeWidgets(_centerDate.year);
      case CalendarMode.year:
        return SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: getYearWidgets(_centerDate.year));
      case CalendarMode.month:
        return SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: getMonthWidgets(_centerDate.year, _centerDate.month));
      case CalendarMode.week:
        return getWeekWidgets(_centerDate);
      default:
        return Text("Unsupported mode");
    }
  }

  /// Build the widget representing the decade starting from the specified [year]
  Widget getDecadeWidgets(int year) {
    final List<Widget> list = [];
    final DateFormat df = DateFormat('y', widget.locale);

    // for next 10 years
    for (int i = 0; i < 12; i++) {
      final DateTime dt = new DateTime(year + i);

      // number of events in that specific year
      final int nbEvents = widget.eventsDates != null
          ? widget.eventsDates.values
              .where((ed) => df.format(ed) == df.format(dt))
              .length
          : 0;

      list.add(
        InkWell(
          onTap: () => setCalendarMode(CalendarMode.year, dt),
          child: Container(
            height: 45,
            width: 45,
            padding: EdgeInsets.symmetric(vertical: 9.0, horizontal: 2.0),
            decoration: (_selectedDate != null &&
                    df.format(_selectedDate) == df.format(dt))
                ? BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(4.0))
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(df.format(dt),
                    textScaleFactor: 0.9,
                    style: TextStyle(
                        color: i < 10 ? Colors.black87 : Colors.black45)),
                nbEvents > 0
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 1.0),
                        decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(2.0)),
                        child: Text(
                          "$nbEvents",
                          textScaleFactor: 0.6,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list.getRange(0, 3).toList()),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list.getRange(3, 6).toList()),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list.getRange(6, 9).toList()),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list.getRange(9, 12).toList()),
      ],
    );
  }

  /// Build the widget representing the months of the specified [year]
  Widget getYearWidgets(int year) {
    final List<Widget> list = [];
    final DateFormat df = DateFormat('My', widget.locale);

    // for each month of the year
    for (int i = 1; i < 13; i++) {
      final DateTime dt = new DateTime(year, i);

      // number of events in that specific month
      final int nbEvents = widget.eventsDates != null
          ? widget.eventsDates.values
              .where((ed) => df.format(ed) == df.format(dt))
              .length
          : 0;

      list.add(
        InkWell(
          onTap: () => setCalendarMode(
              widget.mode == CalendarMode.month
                  ? CalendarMode.month
                  : CalendarMode.week,
              dt),
          child: Container(
            height: 45,
            width: 45,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
            decoration: (_selectedDate != null &&
                    df.format(_selectedDate) == df.format(dt))
                ? BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(4.0))
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(DateFormat('MMM', widget.locale).format(dt),
                    textScaleFactor: 0.9,
                    style: TextStyle(color: Colors.black87)),
                nbEvents > 0
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 1.0),
                        decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(2.0)),
                        child: Text(
                          "$nbEvents",
                          textScaleFactor: 0.6,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list.getRange(0, 4).toList()),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list.getRange(4, 8).toList()),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list.getRange(8, 12).toList()),
      ],
    );
  }

  /// Build the widget representing the days of the specified [month] in the specified [year]
  Widget getMonthWidgets(int year, int month) {
    final List<DateTime> dates = [];
    final DateFormat df = DateFormat('dMy', widget.locale);

    // add days from previous month
    final DateTime firstDayCurrMonth = new DateTime(year, month, 1);
    // if first day of month weekday is equals to the start weekday, we're good, do not add empty line
    if (firstDayCurrMonth.weekday != widget.firstWeekDay) {
      // get last firstWeekDay
      var lastWeekDay = firstDayCurrMonth;
      while (lastWeekDay.weekday != widget.firstWeekDay) {
        lastWeekDay = lastWeekDay.subtract(new Duration(days: 1));
      }

      // number of days to add to complete the week
      final int nbPrevDaysToAdd =
          firstDayCurrMonth.difference(lastWeekDay).inDays;
      for (int j = 0; j < nbPrevDaysToAdd; j++) {
        dates.add(widget.onlyMonthDays
            ? null
            : firstDayCurrMonth.subtract(Duration(days: nbPrevDaysToAdd - j)));
      }
    }

    // add days of current month
    final DateTime lastDayCurrMonth = new DateTime(year, month + 1, 0);
    for (int i = 1; i < lastDayCurrMonth.day + 1; i++) {
      dates.add(DateTime(year, month, i));
    }

    // add next weeks if necessary to complete the 42 days
    while (dates.length < 42) {
      final DateTime last = dates.last;
      for (int j = 1; j < 8; j++) {
        dates.add(last.add(Duration(days: j)));
      }
    }

    // create widget for each date
    final List<Widget> list = [];
    for (DateTime dt in dates) {
      // number of events in that specific day
      final int nbEvents = dt != null && widget.eventsDates != null
          ? widget.eventsDates.values
              .where((ed) => df.format(ed) == df.format(dt))
              .length
          : 0;

      list.add(
        dt == null
            ? Container(width: 36, height: 36)
            : InkWell(
                onTap: () => onSelectDate(dt),
                child: Container(
                  width: 34,
                  height: 34,
                  padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 2.0),
                  decoration: (_selectedDate != null &&
                          df.format(_selectedDate) == df.format(dt))
                      ? BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(4.0))
                      : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(DateFormat('dd', widget.locale).format(dt),
                          style: TextStyle(color: getDayColor(dt, false))),
                      nbEvents > 0
                          ? Container(
                              padding: EdgeInsets.symmetric(horizontal: 1.0),
                              decoration: BoxDecoration(
                                  color: Colors.white54,
                                  borderRadius: BorderRadius.circular(2.0)),
                              child: Text(
                                "$nbEvents",
                                textScaleFactor: 0.6,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
      );
    }

    // weekday labels row
    final List<Widget> cols = [];
    for (int i = widget.firstWeekDay; i < widget.firstWeekDay + 7; i++) {
      cols.add(
        Container(
          height: 40,
          width: 40,
          alignment: Alignment.center,
          child: Text(
            DateFormat('EEEE', widget.locale)
                .format(DateTime(2000, 1, i + 2))
                .substring(0, 3) /*.toUpperCase()*/,
            textScaleFactor: 0.9,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: getDayColor(DateTime(2000, 1, i + 2), true)),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final List<Widget> rows = [];
    rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cols));

    // days number rows
    for (int i = 0; i < list.length ~/ 7; i++) {
      rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list.getRange(i * 7, i * 7 + 7).toList()));
    }

    return Column(
      children: rows,
    );
  }

  /// Build the widget representing the 7 days around the specified [date]
  Widget getWeekWidgets(DateTime date) {
    final List<Widget> list = [];
    final DateFormat df = DateFormat('dMy', widget.locale);

    // add day and each 3 days around it
    final List<DateTime> dates = [];
    dates.add(date.subtract(Duration(days: 3)));
    dates.add(date.subtract(Duration(days: 2)));
    dates.add(date.subtract(Duration(days: 1)));
    dates.add(date);
    dates.add(date.add(Duration(days: 1)));
    dates.add(date.add(Duration(days: 2)));
    dates.add(date.add(Duration(days: 3)));

    for (DateTime dt in dates) {
      // number of events in that specific day
      final int nbEvents = widget.eventsDates != null
          ? widget.eventsDates.values
              .where((ed) => df.format(ed) == df.format(dt))
              .length
          : 0;

      list.add(
        InkWell(
          onTap: () => onSelectDate(dt),
          child: Container(
            height: 45,
            width: 45,
            //padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 1.0),
            decoration: (_selectedDate != null &&
                    df.format(_selectedDate) == df.format(dt))
                ? BoxDecoration(
                    /*border: Border.all(color: Colors.red[700])*/
                    color: Colors.white54,
                borderRadius: BorderRadius.circular(4.0))
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  DateFormat('EEEE', widget.locale)
                      .format(dt)
                      .substring(0, 3) /*.toUpperCase()*/,
                  textScaleFactor: 0.9,
                  style: TextStyle(color: getDayColor(dt, false)),
                ),
                Text(
                  DateFormat('dd', widget.locale).format(dt),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: getDayColor(dt, false)),
                ),
                nbEvents > 0
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 1.0),
                        decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(2.0)),
                        child: Text(
                          "$nbEvents",
                          textScaleFactor: 0.6,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list);
  }

  /// Update the current center date according to paging [position]
  void updateCenterDate(int position) {
    final int pos = position - 5000;
    switch (_calendarMode) {
      case CalendarMode.decade:
        _centerDate =
            DateTime(_initDate.year + pos * 10, _initDate.month, _initDate.day);
        break;
      case CalendarMode.year:
        _centerDate =
            DateTime(_initDate.year + pos, _initDate.month, _initDate.day);
        break;
      case CalendarMode.month:
        _centerDate =
            DateTime(_initDate.year, _initDate.month + pos, _initDate.day);
        break;
      case CalendarMode.week:
        _centerDate =
            DateTime(_initDate.year, _initDate.month, _initDate.day + pos * 7);
        break;
      default:
        break;
    }
  }

  /// Change the current calendar view mode with the specified [calendarMode] with initial [date]
  setCalendarMode(CalendarMode calendarMode, DateTime date) {
    setState(() {
      _pageController.jumpToPage(5000);
      _initDate = date;
      _centerDate = date;
      _calendarMode = calendarMode;
      _animationController.reset();
      _animationController.forward();
    });
  }

  /// Handle previous icon click
  onPrevDate() {
    _pageController.previousPage(
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  /// Handle next icon click
  onNextDate() {
    _pageController.nextPage(
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  /// Handle [date] selection
  onSelectDate(date) {
    setState(() {
      _centerDate = date;
      _selectedDate =
          _selectedDate != null && _selectedDate.compareTo(date) == 0
              ? null
              : date;
      widget.onDateSelected(_selectedDate, _calendarMode);
    });
  }

  /// Get the color to apply for the specified [date] according to weekday and if it is a header or not (specified by [isHeader])
  Color getDayColor(DateTime date, bool isHeader) {
    if (date.weekday == 6 || date.weekday == 7) {
      return widget.weekEndDayColor;
    } else {
      if (isHeader || date.month == _centerDate.month) {
        return Colors.black87;
      } else {
        return Colors.black45;
      }
    }
  }

  /// Get the calendar height according to current mode
  double getCalendarHeight() {
    switch (_calendarMode) {
      case CalendarMode.decade:
        return 240;
      case CalendarMode.year:
        return 195;
      case CalendarMode.month:
        return widget.expandable ? 330 : 310;
      case CalendarMode.week:
        return widget.expandable ? 130 : 105;
      default:
        return 310;
    }
  }

  build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[200], Colors.blue[300]],
          begin: FractionalOffset(0.0, 0.0),
          end: FractionalOffset(0.0, 1.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      height: getCalendarHeight(),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(onTap: onPrevDate, child: Icon(Icons.chevron_left)),
              Container(
                  height: 30,
                  alignment: Alignment.center,
                  child: getTopWidget()),
              InkWell(onTap: onNextDate, child: Icon(Icons.chevron_right)),
            ],
          ),
          SizedBox(height: 8.0),
          Expanded(
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: FractionalOffset(0.0, 1.0),
                  end: FractionalOffset(1.0, 1.0),
                  colors: <Color>[
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                    Colors.transparent
                  ],
                  tileMode: TileMode.clamp,
                  stops: [0.0, 0.04, 0.96, 1.0],
                ).createShader(Offset.zero & bounds.size);
              },
              child: ScaleTransition(
                scale: _animation,
                child: PageView.builder(
                  itemBuilder: (context, position) {
                    updateCenterDate(position);
                    return SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: getContentWidget(),
                    );
                  },
                  controller: _pageController,
                  onPageChanged: (pageId) {
                    // to update month name
                    setState(() {
                      updateCenterDate(pageId);
                    });
                  },
                ),
              ),
            ),
          ),
          getBottomWidget(),
        ],
      ),
    );
  }
}
