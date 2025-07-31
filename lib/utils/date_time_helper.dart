import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeHelper {
  // Format TimeOfDay to a string (e.g., "10:20 PM")
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod; // Handle 12-hour clock
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  // Format DateTime to a string (e.g., "26-12-2024")
  static String formatDate(DateTime date, {String format = 'dd-MM-yyyy'}) {
    return DateFormat(format).format(date);
  }

  // Function to pick a date
  static Future<DateTime?> pickDate(BuildContext context, DateTime initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  // Function to pick a time
  static Future<TimeOfDay?> pickTime(BuildContext context, TimeOfDay initialTime) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }

}
