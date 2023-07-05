import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../Model/list_item.dart';

class CalendarPage extends StatefulWidget {
  final List<ListItem> courseItems;

  const CalendarPage({Key? key, required this.courseItems}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Page'),
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2023, 1, 1), // Provide the first day of the calendar
        focusedDay: _focusedDay, // Provide the initially focused day
        lastDay: DateTime.utc(2023, 12, 31), // Provide the last day of the calendar
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          // Function to determine if a day should be highlighted as selected
          return isSameDay(_selectedDay, day) ||
              widget.courseItems.any((item) => isSameDay(item.date, day));
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
      ),
    );
  }
}
