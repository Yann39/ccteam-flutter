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
import 'package:intl/intl.dart';

enum CalendarMode { year, month }

class CalendarSelector extends StatefulWidget {
  final CalendarMode mode; // the calendar display mode (month or year)
  final DateTime centerDate; // the date to be rendered on center
  final DateTime selectedDate; // the default selected date
  final Function onDateSelected; // a function to execute on date selection
  final Map<String, DateTime> eventsDates; // list of events dates

  CalendarSelector({this.centerDate, this.selectedDate, this.onDateSelected, this.eventsDates, this.mode});

  State<CalendarSelector> createState() => CalendarSelectorState(mode, centerDate, selectedDate);
}

class CalendarSelectorState extends State<CalendarSelector> with TickerProviderStateMixin {
  CalendarMode _calendarMode; // the current calendar display mode (month or year)
  DateTime _centerDate; // the current center date
  DateTime _selectedDate; // the current selected date
  DateTime _initDate; // to remember the initial date

  final PageController pageController = new PageController(initialPage: 5000);

  CalendarSelectorState(CalendarMode calendarMode, DateTime centerDate, DateTime selectedDate) {
    _calendarMode = calendarMode ?? CalendarMode.month;
    _centerDate = centerDate ?? DateTime.now();
    _selectedDate = selectedDate;
    _initDate = _centerDate;
  }

  /// get the widget representing the months of the specified [year]
  Widget getMonthsWidgets(int year) {
    final List<Widget> list = new List<Widget>();

    for (int i = 1; i < 13; i++) {
      final DateTime dt = new DateTime(year, i);
      final int nbEvents = widget.eventsDates != null ? widget.eventsDates.values.where((ed) => DateFormat('My').format(ed) == DateFormat('My').format(dt)).length : 0;

      list.add(InkWell(
        onTap: () => setCalendarMode(CalendarMode.month, dt),
        child: Container(
          width: 36,
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
          decoration: (_selectedDate != null && DateFormat('My').format(_selectedDate) == DateFormat('My').format(dt))
              ? BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(18.0))
              : null,
          child: Column(
            children: <Widget>[
              Text(DateFormat('MMM').format(dt), textScaleFactor: 0.9, style: TextStyle(color: Colors.black87)),
              nbEvents > 0
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 1.0),
                      decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(2.0)),
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
      ));
    }

    return Column(
      children: <Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.start, children: list.getRange(0, 6).toList()),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.start, children: list.getRange(6, 12).toList()),
      ],
    );
  }

  Widget getDaysWidgets(DateTime centerDate) {
    List<Widget> list = new List<Widget>();

    List<DateTime> dates = new List();
    dates.add(centerDate.subtract(Duration(days: 3)));
    dates.add(centerDate.subtract(Duration(days: 2)));
    dates.add(centerDate.subtract(Duration(days: 1)));
    dates.add(centerDate);
    dates.add(centerDate.add(Duration(days: 1)));
    dates.add(centerDate.add(Duration(days: 2)));
    dates.add(centerDate.add(Duration(days: 3)));

    /*List<DateTime> prevDates = widget.eventsDates.values.where((d) => d.isBefore(centerDate)).toList();
    prevDates.sort((a,b) => b.compareTo(a));

    List<DateTime> nextDates = widget.eventsDates.values.where((d) => d.isAfter(centerDate)).toList();
    nextDates.sort((a,b) => a.compareTo(b));

    print(prevDates);
    print(nextDates);

    dates.add(prevDates.length > 2 ? prevDates[2] : centerDate.subtract(Duration(days: 3)));
    dates.add(prevDates.length > 1 ? prevDates[1] : centerDate.subtract(Duration(days: 2)));
    dates.add(prevDates.length > 0 ? prevDates[0] : centerDate.subtract(Duration(days: 1)));
    dates.add(centerDate);
    dates.add(nextDates.length > 2 ? nextDates[2] : centerDate.add(Duration(days: 1)));
    dates.add(nextDates.length > 1 ? nextDates[1] : centerDate.add(Duration(days: 2)));
    dates.add(nextDates.length > 0 ? nextDates[0] : centerDate.add(Duration(days: 3)));*/

    for (DateTime dt in dates) {
      int nbEvents = widget.eventsDates != null ? widget.eventsDates.values.where((ed) => DateFormat('dMy').format(ed) == DateFormat('dMy').format(dt)).length : 0;

      list.add(
        InkWell(
          onTap: () => onSelectDate(dt),
          child: Container(
            width: 36,
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
            decoration: (_selectedDate != null && DateFormat('dMy').format(_selectedDate) == DateFormat('dMy').format(dt))
                ? BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(18.0))
                : null,
            child: Column(
              children: <Widget>[
                Text(DateFormat('EEEE').format(dt).substring(0, 3), textScaleFactor: 0.9, style: TextStyle(color: dt.month == _centerDate.month ? Colors.black87 : Colors.black45)),
                Text(DateFormat('dd').format(dt), style: TextStyle(fontWeight: FontWeight.bold, color: dt.month == _centerDate.month ? Colors.black87 : Colors.black45)),
                nbEvents > 0
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 1.0),
                        decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(2.0)),
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

    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.start, children: list);
  }

  build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[200], Colors.blue[300]],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(0.0, 1.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      height: 100,
      child: Column(
        children: <Widget>[
          _calendarMode == CalendarMode.month
              ? InkWell(
                  onTap: () => setCalendarMode(CalendarMode.year, _centerDate),
                  child: Text(DateFormat('MMMM yyyy').format(_centerDate), textScaleFactor: 1.2),
                )
              : Text(DateFormat('yyyy').format(_centerDate), textScaleFactor: 1.2),
          SizedBox(height: 4.0),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(onTap: onPrevDate, child: Icon(Icons.chevron_left)),
                Expanded(
                  child: PageView.builder(
                    itemBuilder: (context, position) {
                      final int pos = position - 5000;
                      _centerDate = _calendarMode == CalendarMode.month ? _initDate.add(Duration(days: pos * 7)) : DateTime(_initDate.year + pos, _initDate.month, _initDate.day);
                      return _calendarMode == CalendarMode.month ? getDaysWidgets(_centerDate) : getMonthsWidgets(_centerDate.year);
                    },
                    controller: pageController,
                    onPageChanged: (pageId) {
                      // to update month name
                      setState(() {
                        _centerDate = _calendarMode == CalendarMode.month
                            ? _initDate.add(Duration(days: (pageId - 5000) * 7))
                            : DateTime(_initDate.year + (pageId - 5000), _initDate.month, _initDate.day);
                      });
                    },
                  ),
                ),
                InkWell(onTap: onNextDate, child: Icon(Icons.chevron_right)),
              ],
            ),
          )
        ],
      ),
    );
  }

  onPrevDate() {
    pageController.previousPage(duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  onNextDate() {
    pageController.nextPage(duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  setCalendarMode(CalendarMode calendarMode, DateTime date) {
    setState(() {
      pageController.jumpToPage(5000);
      _initDate = date;
      _centerDate = date;
      _calendarMode = calendarMode;
    });
  }

  onSelectDate(date) {
    setState(() {
      _selectedDate = _selectedDate != null && _selectedDate.compareTo(date) == 0 ? null : date;
      widget.onDateSelected(_selectedDate, _calendarMode);
    });
  }
}
