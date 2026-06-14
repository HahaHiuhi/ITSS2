import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kalender/kalender.dart';
import '../../models/schedule.dart';
import '../../services/task_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late final EventsController eventsController;
  late final CalendarController calendarController;

  @override
  void initState() {
    super.initState();

    eventsController = DefaultEventsController(

    );

    calendarController = CalendarController();
  }

  void _syncEvents(TaskService service) {
    eventsController.clearEvents();

    for (final s in service.schedules) {
      eventsController.addEvent(s.toEvent());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final service = context.watch<TaskService>();
    _syncEvents(service);
  }
  String formatTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {


    return CalendarView(
      eventsController: eventsController,
      calendarController: calendarController,
      viewConfiguration: MultiDayViewConfiguration.week(),
      callbacks: CalendarCallbacks(
        onEventCreated: (event) => eventsController.addEvent(event),
      ),
      header: CalendarHeader(),
      body: CalendarBody(
          multiDayTileComponents: TileComponents(
            tileBuilder: (event, tileRange) {
              final e = event as Event;

              final start = e.dateTimeRange.start.toLocal();
              final end = e.dateTimeRange.end.toLocal();
              print(start);
              final timeText =
                  "${formatTime(start)} - ${formatTime(end)}";

              return Container(
                decoration: BoxDecoration(
                  color: e.color,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          callbacks: CalendarCallbacks(
            // --- Event interactions ---

            // Called when an event tile is tapped.
            onEventTapped: (event, renderBox) {},

            // Called when an event tile is tapped — includes tap position detail.
            // The 'detail' parameter provides the tap location and its exact calculated 'DateTime'
            // position based on the tapped position within the event UI.
            onEventTappedWithDetail: (event, renderBox, detail) {},

            // Called when an event is secondary tapped (right-clicked).
            onEventSecondaryTapped: (event, renderBox) {},
            onEventSecondaryTappedWithDetail: (event, renderBox, detail) {},

            // Called before the calendar creates a new event from a gesture.
            // Return your concrete Event subclass here.
            onEventCreate: (event) {
              return Event(dateTimeRange: event.dateTimeRange, title: 'New Event');
            },

            // Same as onEventCreate but includes gesture detail (position, renderBox).
            onEventCreateWithDetail: (event, detail) {
              return Event(dateTimeRange: event.dateTimeRange, title: 'New Event');
            },

            // Called after a new event has been committed — add it to your controller here.
            onEventCreated: (event) => eventsController.addEvent(event),

            // Called just before a rescheduled / resized event is applied.
            onEventChange: (event) {},

            // Called after a rescheduled / resized event is applied.
            onEventChanged: (original, updated) {
              eventsController.updateEvent(event: original, updatedEvent: updated);
            },

            // --- Calendar interactions ---

            // Called when the visible page changes.
            onPageChanged: (visibleDateTimeRange) {},

            // Called when the user taps an empty area (day / week body).
            onTapped: (date) {},
            onTappedWithDetail: (detail) {
              // detail.dateTime or detail.dateTimeRange, plus renderBox & localOffset.
            },

            // Called when the user secondary taps (right-clicks) an empty area.
            onSecondaryTapped: (date) {},
            onSecondaryTappedWithDetail: (detail) {},

            // Called when the user long-presses an empty area.
            onLongPressed: (date) {},
            onLongPressedWithDetail: (detail) {},

            // Called when the user secondary long-presses an empty area.
            onSecondaryLongPressed: (date) {},
            onSecondaryLongPressedWithDetail: (detail) {},

            // --- Drag-and-drop acceptance ---

            // Day / week vertical drag target. Return false to reject the drop.
            onWillAcceptWithDetailsVertical: (details, controller, configuration) => true,

            // Month / header horizontal drag target.
            onWillAcceptWithDetailsHorizontal: (details, controller, configuration) => true,
          )
      )
    );
            }

}