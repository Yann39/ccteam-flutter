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

import 'package:ccteam/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum CalendarMode { decade, year, month, week }

class CalendarSelector extends StatefulWidget {
  final CalendarMode mode; // the calendar display mode
  final DateTime? centerDate; // the date to be rendered on center (default current date)
  final DateTime? selectedDate; // the default selected date (default current date)
  final Function onDateSelected; // a function to execute on date selection
  final bool onlyMonthDays; // a boolean indicating if we need to display previous and next months days in month view
  final bool expandable; // a boolean indicating if calendar is expandable between week to month views
  final List<DateTime>? eventsDates; // list of events dates
  final Color weekEndDayColor; // color to apply on week end days in month and week views
  final int firstWeekDay; // the first week day to display in month and week views
  final String locale; // the locale to use to render dates as strings

  CalendarSelector({
    required this.mode,
    this.centerDate,
    this.selectedDate,
    required this.onDateSelected,
    this.onlyMonthDays = false,
    this.expandable = true,
    this.eventsDates,
    this.locale = "en",
    this.weekEndDayColor = Colors.black87,
    this.firstWeekDay = DateTime.monday,
  });

  State<CalendarSelector> createState() => CalendarSelectorState(mode, centerDate, selectedDate);
}

class CalendarSelectorState extends State<CalendarSelector> with TickerProviderStateMixin {
  CalendarMode _calendarMode = CalendarMode.month; // the current calendar display mode
  DateTime? _centerDate; // the current center date (default current date)
  DateTime? _selectedDate; // the current selected date (default current date)
  DateTime? _initDate; // to remember the initial date

  /// When set to `month` or `year`, the user activated the matching
  /// "Voir tout..." chip and the filter applies to the whole period
  /// (rather than to a single day / month). In that state:
  ///  - no individual cell is rendered as "selected" (which would be
  ///    misleading since the events list shows everything for the
  ///    period, not a specific cell),
  ///  - the chip itself is rendered in an "active" filled style.
  /// Cleared as soon as the user taps a regular cell or navigates
  /// (page, chevrons, drill-up / drill-down).
  CalendarMode? _periodFilterMode;

  // hack so we can use paging in both directions
  final PageController _pageController = new PageController(initialPage: 5000);

  late AnimationController _animationController;
  late Animation<double> _animation;

  CalendarSelectorState(CalendarMode calendarMode, DateTime? centerDate, DateTime? selectedDate) {
    _calendarMode = calendarMode;
    _centerDate = centerDate ?? DateTime.now();
    _selectedDate = selectedDate ?? DateTime.now();
    _initDate = _centerDate;
  }

  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.decelerate);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Capitalize the specified [string]
  String capitalize(String string) => string[0].toUpperCase() + string.substring(1);

  /// Returns true if [a] and [b] fall on the same calendar day.
  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// Returns true if [a] and [b] fall in the same calendar month.
  bool _isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

  /// Build the top bar content widget according to the current display mode.
  /// In modes that allow drilling up (month/week → year → decade), the
  /// title is tappable and gets a small caret + tooltip to advertise it.
  Widget getTopWidget() {
    switch (_calendarMode) {
      case CalendarMode.decade:
        return Text(
          "${DateFormat('yyyy', widget.locale).format(_centerDate!)} - ${DateFormat('yyyy', widget.locale).format(DateTime(_centerDate!.year + 10, _centerDate!.month, _centerDate!.day))}",
          textScaler: TextScaler.linear(1.2),
          style: TextStyle(color: Colors.black87),
        );
      case CalendarMode.year:
        return _buildDrillUpTitle(
          label: DateFormat('yyyy', widget.locale).format(_centerDate!),
          onTap: () => setCalendarMode(CalendarMode.decade, _centerDate!),
        );
      case CalendarMode.month:
        return _buildDrillUpTitle(
          label: capitalize(DateFormat('MMMM yyyy', widget.locale).format(_centerDate!)),
          onTap: () => setCalendarMode(CalendarMode.year, _centerDate!),
        );
      case CalendarMode.week:
        return _buildDrillUpTitle(
          label: capitalize(DateFormat('MMMM yyyy', widget.locale).format(_centerDate!)),
          onTap: () => setCalendarMode(CalendarMode.year, _centerDate!),
        );
    }
  }

  /// Tappable title with a caret to make the "tap to zoom out" affordance
  /// discoverable (was previously a hidden gesture).
  Widget _buildDrillUpTitle({required String label, required VoidCallback onTap}) {
    return Tooltip(
      message: AppString.changePeriod,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                textScaler: TextScaler.linear(1.2),
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.arrow_drop_down, size: 22, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  /// Get calendar bottom content depending on current calendar mode and expandable option
  Widget getBottomWidget() {
    if (widget.expandable) {
      if (_calendarMode == CalendarMode.week) {
        return InkWell(
          onTap: () => setCalendarMode(CalendarMode.month, _centerDate!),
          child: Icon(Icons.keyboard_arrow_down),
        );
      } else if (_calendarMode == CalendarMode.month) {
        return InkWell(
          onTap: () => setCalendarMode(CalendarMode.week, _centerDate!),
          child: Icon(Icons.keyboard_arrow_up),
        );
      }
    }
    return SizedBox();
  }

  /// "Show all events of the current period" action chip — only shown in
  /// modes where filtering by the whole period makes sense (month/year).
  /// Fires [widget.onDateSelected] with the matching [CalendarMode] so
  /// the host page can call the correct backend method.
  ///
  /// When tapped we also clear the single-cell selection and switch the
  /// chip to its "active" state, so the user gets immediate confirmation
  /// that the filter is on the whole period — without a stray cell
  /// highlight giving the false impression that only that cell is
  /// filtered.
  Widget _buildShowAllChip() {
    if (_calendarMode == CalendarMode.month) {
      return _ShowAllChip(
        label: AppString.showAllForMonth,
        icon: Icons.calendar_view_month,
        active: _periodFilterMode == CalendarMode.month,
        onTap: () {
          setState(() {
            _periodFilterMode = CalendarMode.month;
            _selectedDate = null;
          });
          widget.onDateSelected(_centerDate, CalendarMode.month);
        },
      );
    }
    if (_calendarMode == CalendarMode.year) {
      return _ShowAllChip(
        label: AppString.showAllForYear,
        icon: Icons.calendar_today,
        active: _periodFilterMode == CalendarMode.year,
        onTap: () {
          setState(() {
            _periodFilterMode = CalendarMode.year;
            _selectedDate = null;
          });
          widget.onDateSelected(_centerDate, CalendarMode.year);
        },
      );
    }
    return const SizedBox.shrink();
  }

  /// "Aujourd'hui" chip — a one-tap shortcut that both recenters the
  /// calendar on today AND filters events to today. Hidden only when
  /// today is already the currently-selected day on the currently-
  /// visible month, so the chip would otherwise be a no-op.
  Widget _buildTodayChip() {
    final DateTime now = DateTime.now();
    final bool alreadyOnToday =
        _selectedDate != null && _isSameDay(_selectedDate!, now) && _isSameMonth(_centerDate!, now);
    if (alreadyOnToday) return const SizedBox.shrink();
    return _ShowAllChip(
      label: AppString.today,
      icon: Icons.today,
      onTap: () {
        // recenter, select today, drop any active period filter, and
        // fire the day-level filter so the events list narrows down to today's events
        setState(() {
          _pageController.jumpToPage(5000);
          _initDate = now;
          _centerDate = now;
          _selectedDate = now;
          _periodFilterMode = null;
          _animationController.reset();
          _animationController.forward();
        });
        widget.onDateSelected(now, CalendarMode.week);
      },
    );
  }

  /// Get calendar content depending on current calendar mode
  Widget getContentWidget() {
    switch (_calendarMode) {
      case CalendarMode.decade:
        return getDecadeWidgets(_centerDate!.year);
      case CalendarMode.year:
        return SingleChildScrollView(physics: NeverScrollableScrollPhysics(), child: getYearWidgets(_centerDate!.year));
      case CalendarMode.month:
        return SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: getMonthWidgets(_centerDate!.year, _centerDate!.month),
        );
      case CalendarMode.week:
        return getWeekWidgets(_centerDate!);
    }
  }

  /// Build the widget representing the decade starting from the specified [year]
  Widget getDecadeWidgets(int year) {
    final List<Widget> list = [];
    final DateFormat df = DateFormat('y', widget.locale);
    final DateTime now = DateTime.now();

    // for next 10 years
    for (int i = 0; i < 12; i++) {
      final DateTime dt = new DateTime(year + i);

      // number of events in that specific year
      final int nbEvents = widget.eventsDates != null
          ? widget.eventsDates!.where((ed) => df.format(ed) == df.format(dt)).length
          : 0;
      final bool isSelected = _selectedDate != null && df.format(_selectedDate!) == df.format(dt);
      final bool isCurrent = dt.year == now.year;

      list.add(
        InkWell(
          onTap: () => setCalendarMode(CalendarMode.year, dt),
          child: Container(
            height: 49,
            width: 49,
            padding: EdgeInsets.symmetric(vertical: 9.0, horizontal: 2.0),
            decoration: _cellDecoration(isSelected: isSelected, isCurrent: isCurrent),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  df.format(dt),
                  textScaler: TextScaler.linear(0.9),
                  style: TextStyle(color: i < 10 ? Colors.black87 : Colors.black45),
                ),
                if (nbEvents > 0) _eventCountBadge(nbEvents),
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
          children: list.getRange(0, 3).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list.getRange(3, 6).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list.getRange(6, 9).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list.getRange(9, 12).toList(),
        ),
      ],
    );
  }

  /// Build the widget representing the months of the specified [year]
  Widget getYearWidgets(int year) {
    final List<Widget> list = [];
    final DateFormat df = DateFormat('My', widget.locale);
    final DateTime now = DateTime.now();

    // for each month of the year
    for (int i = 1; i < 13; i++) {
      final DateTime dt = new DateTime(year, i);

      // number of events in that specific month
      final int nbEvents = widget.eventsDates != null
          ? widget.eventsDates!.where((ed) => df.format(ed) == df.format(dt)).length
          : 0;
      final bool isSelected = _selectedDate != null && df.format(_selectedDate!) == df.format(dt);
      final bool isCurrent = _isSameMonth(dt, now);

      list.add(
        InkWell(
          onTap: () => setCalendarMode(widget.mode == CalendarMode.month ? CalendarMode.month : CalendarMode.week, dt),
          child: Container(
            height: 48,
            width: 45,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
            decoration: _cellDecoration(isSelected: isSelected, isCurrent: isCurrent),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  DateFormat('MMM', widget.locale).format(dt),
                  textScaler: TextScaler.linear(0.9),
                  style: TextStyle(color: Colors.black87),
                ),
                if (nbEvents > 0) _eventCountBadge(nbEvents),
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
          children: list.getRange(0, 4).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list.getRange(4, 8).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list.getRange(8, 12).toList(),
        ),
      ],
    );
  }

  /// Build the widget representing the days of the specified [month] in the specified [year]
  Widget getMonthWidgets(int year, int month) {
    final List<DateTime?> dates = [];
    final DateFormat df = DateFormat('dMy', widget.locale);
    final DateTime now = DateTime.now();

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
      final int nbPrevDaysToAdd = firstDayCurrMonth.difference(lastWeekDay).inDays;
      for (int j = 0; j < nbPrevDaysToAdd; j++) {
        dates.add(widget.onlyMonthDays ? null : firstDayCurrMonth.subtract(Duration(days: nbPrevDaysToAdd - j)));
      }
    }

    // add days of current month
    final DateTime lastDayCurrMonth = new DateTime(year, month + 1, 0);
    for (int i = 1; i < lastDayCurrMonth.day + 1; i++) {
      dates.add(DateTime(year, month, i));
    }

    // add next weeks if necessary to complete the 42 days
    while (dates.length < 42) {
      final DateTime? last = dates.last;
      if (last != null) {
        for (int j = 1; j < 8; j++) {
          dates.add(last.add(Duration(days: j)));
        }
      }
    }

    // create widget for each date
    final List<Widget> list = [];
    for (DateTime? dt in dates) {
      // number of events in that specific day
      final int nbEvents = widget.eventsDates != null
          ? widget.eventsDates!.where((ed) => dt != null && df.format(ed) == df.format(dt)).length
          : 0;
      final bool isSelected = dt != null && _selectedDate != null && df.format(_selectedDate!) == df.format(dt);
      final bool isCurrent = dt != null && _isSameDay(dt, now);

      list.add(
        dt == null
            ? Container(width: 36, height: 36)
            : InkWell(
                onTap: () => onSelectDate(dt),
                child: Container(
                  width: 34,
                  height: 38,
                  padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 2.0),
                  decoration: _cellDecoration(isSelected: isSelected, isCurrent: isCurrent),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(DateFormat('dd', widget.locale).format(dt), style: TextStyle(color: getDayColor(dt, false))),
                      if (nbEvents > 0) _eventCountBadge(nbEvents),
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
            DateFormat('EEEE', widget.locale).format(DateTime(2000, 1, i + 2)).substring(0, 3) /*.toUpperCase()*/,
            textScaler: TextScaler.linear(0.9),
            style: TextStyle(fontWeight: FontWeight.bold, color: getDayColor(DateTime(2000, 1, i + 2), true)),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final List<Widget> rows = [];
    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cols,
      ),
    );

    // days number rows
    for (int i = 0; i < list.length ~/ 7; i++) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list.getRange(i * 7, i * 7 + 7).toList(),
        ),
      );
    }

    return Column(children: rows);
  }

  /// Build the widget representing the 7 days around the specified [date]
  Widget getWeekWidgets(DateTime date) {
    final List<Widget> list = [];
    final DateFormat df = DateFormat('dMy', widget.locale);
    final DateTime now = DateTime.now();

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
          ? widget.eventsDates!.where((ed) => df.format(ed) == df.format(dt)).length
          : 0;
      final bool isSelected = _selectedDate != null && df.format(_selectedDate!) == df.format(dt);
      final bool isCurrent = _isSameDay(dt, now);

      list.add(
        InkWell(
          onTap: () => onSelectDate(dt),
          child: Container(
            height: 45,
            width: 45,
            decoration: _cellDecoration(isSelected: isSelected, isCurrent: isCurrent),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  DateFormat('EEEE', widget.locale).format(dt).substring(0, 3) /*.toUpperCase()*/,
                  textScaler: TextScaler.linear(0.9),
                  style: TextStyle(color: getDayColor(dt, false)),
                ),
                Text(
                  DateFormat('dd', widget.locale).format(dt),
                  style: TextStyle(fontWeight: FontWeight.bold, color: getDayColor(dt, false)),
                ),
                if (nbEvents > 0) _eventCountBadge(nbEvents),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }

  /// Update the current center date according to paging [position]
  void updateCenterDate(int position) {
    final int pos = position - 5000;
    switch (_calendarMode) {
      case CalendarMode.decade:
        _centerDate = DateTime(_initDate!.year + pos * 10, _initDate!.month, _initDate!.day);
        break;
      case CalendarMode.year:
        _centerDate = DateTime(_initDate!.year + pos, _initDate!.month, _initDate!.day);
        break;
      case CalendarMode.month:
        _centerDate = DateTime(_initDate!.year, _initDate!.month + pos, _initDate!.day);
        break;
      case CalendarMode.week:
        _centerDate = DateTime(_initDate!.year, _initDate!.month, _initDate!.day + pos * 7);
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
      _periodFilterMode = null;
      _animationController.reset();
      _animationController.forward();
    });
  }

  /// Handle previous icon click
  onPrevDate() {
    _pageController.previousPage(duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  /// Handle next icon click
  onNextDate() {
    _pageController.nextPage(duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  /// Handle [date] selection
  onSelectDate(date) {
    setState(() {
      _centerDate = date;
      final bool sameAsBefore = _selectedDate != null && _selectedDate!.compareTo(date) == 0;
      _selectedDate = sameAsBefore ? null : date;
      _periodFilterMode = null;
      widget.onDateSelected(_selectedDate, CalendarMode.week);
    });
  }

  /// Get the color to apply for the specified [date] according to weekday and if it is a header or not (specified by [isHeader])
  Color getDayColor(DateTime date, bool isHeader) {
    if (date.weekday == 6 || date.weekday == 7) {
      return widget.weekEndDayColor;
    } else {
      if (isHeader || date.month == _centerDate!.month) {
        return Colors.black87;
      } else {
        return Colors.black45;
      }
    }
  }

  /// Cell decoration that combines "selected" and "today" visual cues.
  /// Selected wins on background; "today" adds a coloured border so the
  /// current day stays distinguishable even when another cell is selected.
  BoxDecoration? _cellDecoration({required bool isSelected, required bool isCurrent}) {
    if (!isSelected && !isCurrent) return null;
    return BoxDecoration(
      color: isSelected ? Colors.white.withAlpha(200) : null,
      borderRadius: BorderRadius.circular(6.0),
      border: Border.all(color: isCurrent ? Colors.red[700]! : Colors.transparent, width: isCurrent ? 1.5 : 0),
      boxShadow: isSelected
          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 3.0, offset: const Offset(0, 1))]
          : null,
    );
  }

  /// Compact "this cell has events" indicator: a small red dot, with
  /// the count written next to it when there is more than one event.
  Widget _eventCountBadge(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: Colors.red[700], shape: BoxShape.circle),
        ),
        if (count > 1) ...[
          const SizedBox(width: 2.5),
          Text(
            "$count",
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
              height: 1.0,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );
  }

  /// Get the calendar height according to current mode
  double getCalendarHeight() {
    // extra room reserved for the action chip row (Today + Show-all)
    const double chipRow = 36.0;
    switch (_calendarMode) {
      case CalendarMode.decade:
        return 240 + chipRow;
      case CalendarMode.year:
        return 195 + chipRow;
      case CalendarMode.month:
        return (widget.expandable ? 345 : 310) + chipRow;
      case CalendarMode.week:
        return (widget.expandable ? 130 : 105) + chipRow;
    }
  }

  /// Velocity threshold (px/s) below which a vertical drag is ignored.
  /// Filters out accidental nudges while still triggering on a casual
  /// swipe gesture.
  static const double _swipeVelocityThreshold = 200.0;

  /// Handle a vertical fling on the calendar surface — swipe down to
  /// expand from week → month view, swipe up to collapse the other way.
  /// Mirrors what the chevron at the bottom already does, just with
  /// a more direct interaction. No-op outside week / month views or
  /// when [CalendarSelector.expandable] is false.
  void _onVerticalDragEnd(DragEndDetails details) {
    if (!widget.expandable) return;
    final double? v = details.primaryVelocity;
    if (v == null) return;
    if (v > _swipeVelocityThreshold && _calendarMode == CalendarMode.week) {
      setCalendarMode(CalendarMode.month, _centerDate!);
    } else if (v < -_swipeVelocityThreshold && _calendarMode == CalendarMode.month) {
      setCalendarMode(CalendarMode.week, _centerDate!);
    }
  }

  build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[200]!, Colors.blue[300]!],
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
            // top header: prev / title (drill-up) / next
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(onTap: onPrevDate, child: Icon(Icons.chevron_left)),
                Container(height: 30, alignment: Alignment.center, child: getTopWidget()),
                InkWell(onTap: onNextDate, child: Icon(Icons.chevron_right)),
              ],
            ),
            // action chips row: "Today" shortcut + period-wide filter
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildTodayChip(),
                  if (_calendarMode == CalendarMode.month || _calendarMode == CalendarMode.year) ...[
                    const SizedBox(width: 6.0),
                    _buildShowAllChip(),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: FractionalOffset(0.0, 1.0),
                    end: FractionalOffset(1.0, 1.0),
                    colors: <Color>[Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                    tileMode: TileMode.clamp,
                    stops: [0.0, 0.04, 0.96, 1.0],
                  ).createShader(Offset.zero & bounds.size);
                },
                child: ScaleTransition(
                  scale: _animation,
                  child: PageView.builder(
                    itemBuilder: (context, position) {
                      updateCenterDate(position);
                      return SingleChildScrollView(physics: NeverScrollableScrollPhysics(), child: getContentWidget());
                    },
                    controller: _pageController,
                    onPageChanged: (pageId) {
                      setState(() {
                        updateCenterDate(pageId);
                        _periodFilterMode = null;
                      });
                    },
                  ),
                ),
              ),
            ),
            getBottomWidget(),
          ],
        ),
      ),
    );
  }
}

/// Pill-style action chip used by the calendar selector for "Aujourd'hui"
/// and "Voir tout le mois/année". Sits in the header chip row and
/// triggers an immediate filter without any drill-down ambiguity.
class _ShowAllChip extends StatelessWidget {
  const _ShowAllChip({Key? key, required this.label, required this.icon, required this.onTap, this.active = false})
    : super(key: key);

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  /// When true, the chip switches to a filled style (red background,
  /// white text/icon) to make it obvious that the matching filter is
  /// currently in effect.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color background = active ? Colors.red[700]! : Colors.white.withValues(alpha: 0.75);
    final Color foreground = active ? Colors.white : Colors.red[700]!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: Colors.red[700]!, width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 4.0),
            Text(
              label,
              style: TextStyle(color: foreground, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
