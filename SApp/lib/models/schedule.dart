
import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:sapp/models/task.dart';


class Event extends CalendarEvent {
  final String title;
  final Color color;

  Event({
    required super.dateTimeRange,
    required this.title,
    this.color = Colors.blue,
  });

}


class Schedule {
  final Task? task;
  String title;
  DateTime startTime;
  Duration duration;

  Schedule({
    this.task,
    required this.title,
    required this.startTime,
    required this.duration,
  });


  Event toEvent() {
    return Event(
        dateTimeRange: DateTimeRange(
          start: startTime,
          end: startTime.add(duration),
        ),
      title: title.toString(),
      color: (task?.isUrgent ?? false)
          ? Colors.red
          : Colors.blue,

    );
  }

  @override
  String toString() {


    return '''
Schedule(
  title: $title,
  startTime: $startTime,
  endTime: ${startTime.add(duration)},
  duration: ${duration.inMinutes} min,
  task: ${task?.name ?? "null"}
)
''';
  }
}


class TimeSlot {
  DateTime start;
  DateTime end;

  TimeSlot({
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);
}


class Scheduler {
  static double slack(Task task, DateTime now) {
    final availableHours =
        task.deadline.difference(now).inMinutes / 60;

    final workHours = task.t2c.inMinutes / 60;

    return availableHours - workHours;
  }

  static List<TimeSlot> generateFreeSlots({
    required DateTime start,
    required DateTime end,
    required List<Event> fixedEvents,
  }) {
    fixedEvents.sort(
          (a, b) => a.start.compareTo(b.start),
    );

    final slots = <TimeSlot>[];

    DateTime cursor = start;

    for (final event in fixedEvents) {
      if (event.start.isAfter(cursor)) {
        slots.add(
          TimeSlot(
            start: cursor,
            end: event.start,
          ),
        );
      }

      if ( event.end.isAfter(cursor)) {
        cursor = event.end;
      }
    }

    if (cursor.isBefore(end)) {
      slots.add(
        TimeSlot(
          start: cursor,
          end: end,
        ),
      );
    }

    return slots;
  }

  static List<Schedule> scheduleTasks({
    required List<Task> tasks,
    required List<TimeSlot> slots,
    required DateTime now,
  }) {
    tasks.sort(
          (a, b) =>
          slack(a, now).compareTo(slack(b, now)),
    );

    final schedules = <Schedule>[];

    for (final task in tasks) {
      Duration remaining = task.t2c - task.timeCompleted;

      for (final slot in slots) {
        if (remaining <= Duration.zero) {
          break;
        }

        if (slot.start.isAfter(task.deadline)) {
          continue;
        }

        final available = slot.duration;

        if (available <= Duration.zero) {
          continue;
        }

        final used =
        available < remaining
            ? available
            : remaining;

        schedules.add(
          Schedule(
            task: task,
            title: task.name,
            startTime: slot.start,
            duration: used,
          ),
        );

        slot.start = slot.start.add(used);

        remaining -= used;
      }

      if (remaining > Duration.zero) {
        print(
          'WARNING: Could not fully schedule ${task.name}',
        );
      }
    }

    return schedules;
  }
}

List<Schedule> generateSleepSchedules(
    DateTime startDay,
    int days,
    DateTime bedTime,
    Duration sleepHours
    ) {
  return List.generate(days, (i) {
    final day = startDay.add(Duration(days: i));
    final start = DateTime(
      day.year,
      day.month,
      day.day,
      bedTime.hour,
      bedTime.minute,
    );



    return Schedule(
      title: "Sleep",
      startTime: start,
      duration: sleepHours,
    );
  });
}

