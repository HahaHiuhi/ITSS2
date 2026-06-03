import 'package:flutter/material.dart';


class CalendarDaysRow extends StatefulWidget {
  const CalendarDaysRow({super.key, required this.onDateSelected});

  final ValueChanged<DateTime> onDateSelected;

  @override
  State<CalendarDaysRow> createState() => _CalendarDaysRowState();
}

class _CalendarDaysRowState extends State<CalendarDaysRow> {


  // Track the absolute selected date
  DateTime _selectedDate = DateTime.now();


  // Helper to generate a 7-day week based on an offset from the current week
  List<DateTime> _getDaysOfWeek() {
    final now = DateTime.now();
    // Find the most recent Monday
    final mostRecentMonday = now.subtract(Duration(days: now.weekday - 1));
    // Apply the week offset (7 days per week)
    final targetMonday = mostRecentMonday.add(Duration(days: 0));

    return List.generate(7, (index) => targetMonday.add(Duration(days: index)));
  }

  // Get localized or custom weekday names
  String _getWeekdayName(int weekday) {
    const names = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return names[weekday - 1];
  }



  @override
  Widget build(BuildContext context) {
    final weekDays = _getDaysOfWeek();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDays.map((date) {
            final isSelected =
            DateUtils.isSameDay(date, _selectedDate);

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });

                  widget.onDateSelected.call(date);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF5C6BC0)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(_getWeekdayName(date.weekday)),
                      Text("${date.day}/${date.month}"),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(
                      "${_selectedDate.day}, ${_getMonthName(_selectedDate.month)}, ${_selectedDate.year}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      )
          ),

        ],
      );

  }
  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}