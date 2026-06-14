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

  // Helper to generate a 7-day week based on the current week
  List<DateTime> _getDaysOfWeek() {
    final now = DateTime.now();
    // Find the most recent Monday
    final mostRecentMonday = now.subtract(Duration(days: now.weekday - 1));
    final targetMonday = mostRecentMonday.add(Duration(days: 0));

    return List.generate(7, (index) => targetMonday.add(Duration(days: index)));
  }

  // weekday names
  String _getWeekdayName(int weekday) {
    const names = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return names[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getDaysOfWeek();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((date) {
              final isSelected = DateUtils.isSameDay(date, _selectedDate);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                    widget.onDateSelected.call(date);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xff4B46E5), Color(0xff6C63FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : const Color(0xFFECEBFF),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xff4B46E5).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getWeekdayName(date.weekday),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white70 : const Color(0xFF94A3B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${date.day}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF0B1C30),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 18,
            color: Color(0xFF4B46E5),
          ),
          const SizedBox(width: 8),
          Text(
            "${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B1C30),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}