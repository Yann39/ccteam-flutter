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

class CalendarSelector extends StatefulWidget {
  final DateTime centerDate; // the date to be rendered on center on start
  final DateTime selectedDate; // the default selected date
  final Function onDateSelected; // a function to execute on date selection
  final Map<String, DateTime> eventsDates; // list of events dates

  CalendarSelector({@required this.centerDate, this.selectedDate, this.onDateSelected, this.eventsDates});

  State<CalendarSelector> createState() => CalendarSelectorState(centerDate, selectedDate);
}

class CalendarSelectorState extends State<CalendarSelector> with TickerProviderStateMixin {
  DateTime _centerDate; // the current center date
  DateTime _selectedDate; // the current selected date

  final PageController pageController = new PageController(initialPage: 5000);

  final List<AnimationController> _animationControllers = new List();
  DateTime _initDate;

  CalendarSelectorState(DateTime centerDate, DateTime selectedDate) {
    _centerDate = centerDate;
    _selectedDate = selectedDate;
    _initDate = centerDate;
  }

  @override
  void initState() {
    super.initState();
    _animationControllers.add(AnimationController(vsync: this, duration: Duration(milliseconds: 100)));
    _animationControllers.add(AnimationController(vsync: this, duration: Duration(milliseconds: 140)));
    _animationControllers.add(AnimationController(vsync: this, duration: Duration(milliseconds: 180)));
    _animationControllers.add(AnimationController(vsync: this, duration: Duration(milliseconds: 220)));
    _animationControllers.add(AnimationController(vsync: this, duration: Duration(milliseconds: 260)));
    _animationControllers.add(AnimationController(vsync: this, duration: Duration(milliseconds: 300)));
    _animationControllers.add(AnimationController(vsync: this, duration: Duration(milliseconds: 340)));
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

    int i = 0;
    for (DateTime dt in dates) {
      int nbEvents = widget.eventsDates != null ? widget.eventsDates.values.where((ed) => ed.compareTo(dt) == 0).length : 0;

      list.add(
        SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(curve: Curves.linear, parent: _animationControllers[i]),
          ),
          child: InkWell(
            onTap: () => onSelectDate(dt),
            child: Container(
              width: 36,
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
              decoration: (_selectedDate != null && _selectedDate.compareTo(dt) == 0) ? BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(18.0)) : null,
              child: Column(
                children: <Widget>[
                  Text(DateFormat('EEEE').format(dt).substring(0, 3), textScaleFactor: 0.9),
                  Text(DateFormat('dd').format(dt), style: TextStyle(fontWeight: FontWeight.bold)),
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
        ),
      );
      _animationControllers[i].forward();
      i++;
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
      ),
      height: 100,
      child: Column(
        children: <Widget>[
          Text(DateFormat('MMMM yyyy').format(_centerDate), textScaleFactor: 1.2),
          SizedBox(height: 5.0),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(onTap: onPrevDate, child: Icon(Icons.chevron_left)),
                Expanded(
                  child: PageView.builder(
                      itemBuilder: (context, position) {
                        final int pos = position - 5000;
                          _centerDate = _initDate.add(Duration(days: pos*7));
                        print("Init date is $_initDate, Center date is $_centerDate, position is $pos");
                        return getDaysWidgets(_centerDate);
                      },
                      controller: pageController,
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
    // setState(() {
    //_centerDate = _centerDate.subtract(Duration(days: 7));
    pageController.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
    /*for (AnimationController ac in _animationControllers) {
        ac.reset();
        ac.forward();
      }*/
    // });
  }

  onNextDate() {
    pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
    //setState(() {
    //_centerDate = _centerDate.add(Duration(days: 7));
    /*for (AnimationController ac in _animationControllers) {
        ac.reset();
        ac.forward();
      }*/
    //});
  }

  onSelectDate(date) {
    setState(() {
      _selectedDate = date;
      widget.onDateSelected(date);
    });
  }
}
