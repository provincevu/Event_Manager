import 'package:event_manager/event/event_service.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../l10n/app_localizations.dart';
import 'package:event_manager/event/event_detail_view.dart';
import 'package:event_manager/event/event_model.dart';
import 'package:event_manager/event/event_data_source.dart';

class EventView extends StatefulWidget {
  const EventView({super.key});

  @override
  State<EventView> createState() => _EventViewState();
}

class EventSearchDelegate extends SearchDelegate<EventModel?> {
  final List<EventModel> items;

  EventSearchDelegate(this.items);

  List<EventModel> _filter(String query) {
    final q = query.toLowerCase();
    return items.where((e) {
      final subject = e.subject.toLowerCase();
      final notes = (e.notes ?? '').toLowerCase();
      return subject.contains(q) || notes.contains(q);
    }).toList();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _filter(query);
    if (results.isEmpty) {
      return const Center(child: Text('Không tìm thấy sự kiện'));
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final e = results[index];
        return ListTile(
          title: Text(e.subject.isEmpty ? '(Không tiêu đề)' : e.subject),
          subtitle: Text('${e.startTime} - ${e.endTime}'),
          onTap: () => close(context, e),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty ? items : _filter(query);
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final e = suggestions[index];
        return ListTile(
          title: Text(e.subject.isEmpty ? '(Không tiêu đề)' : e.subject),
          subtitle: Text('${e.startTime}'),
          onTap: () => close(context, e),
        );
      },
    );
  }
}

class _EventViewState extends State<EventView> {
  final eventService = EventService();
  List<EventModel> items = [];
  final calendarController = CalendarController();

  @override
  void initState() {
    super.initState();
    calendarController.view = CalendarView.day;
    loadEvents();
  }

  Future<void> loadEvents() async {
    final events = await eventService.getAllEvents();
    setState(() {
      items = events;
    });
  }
  final ValueNotifier<Locale?> appLocale = ValueNotifier<Locale?>(Locale('vi'));
  void setAppLocale(Locale? locale) => appLocale.value = locale;

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(al.apptitle),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'vi', child: Text('Tiếng Việt')),
              const PopupMenuItem(value: 'en', child: Text('English')),
            ],
            onSelected: (code) {
              setAppLocale(Locale(code));
            },
          ),
          PopupMenuButton<CalendarView>(
            itemBuilder: (context) => CalendarView.values.map((view) {
              return PopupMenuItem<CalendarView>(
                value: view,
                child: ListTile(title: Text(view.name)),
              );
            }).toList(),
            icon: getCalendarviewIcon(calendarController.view!),
            onSelected: (CalendarView selectedView) {
              setState(() {
                calendarController.view = selectedView;
              });
            },
          ),
          IconButton(
            onPressed: () {
              calendarController.displayDate = DateTime.now();
            },
            icon: const Icon(Icons.today_outlined),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final EventModel? selected = await showSearch<EventModel?>(
                context: context,
                delegate: EventSearchDelegate(items),
              );
              if (selected != null) {
                // ignore: use_build_context_synchronously
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => EventDetailView(event: selected),
                      ),
                    )
                    .then((value) async {
                      if (value == true) await loadEvents();
                    });
              }
            },
          ),
          IconButton(onPressed: loadEvents, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SfCalendar(
        controller: calendarController,
        dataSource: EventDataSource(items),
        monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
        onLongPress: (details) {
          if (details.targetElement == CalendarElement.calendarCell) {
            final newEvent = EventModel(
              subject: 'Sự kiện mới',
              startTime: details.date!,
              endTime: details.date!.add(const Duration(hours: 1)),
            );
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) {
                      return EventDetailView(event: newEvent);
                    },
                  ),
                )
                .then((value) async {
                  if (value == true) {
                    await loadEvents();
                  }
                });
          }
        },
        onTap: (details) {
          if (details.targetElement == CalendarElement.appointment) {
            final EventModel event = details.appointments![0];
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) {
                      return EventDetailView(event: event);
                    },
                  ),
                )
                .then((value) async {
                  if (value == true) {
                    await loadEvents();
                  }
                });
          }
        },
      ),
    );
  }

  Icon getCalendarviewIcon(CalendarView view) {
    switch (view) {
      case CalendarView.day:
        return const Icon(Icons.calendar_view_day_outlined);
      case CalendarView.week:
        return const Icon(Icons.calendar_view_week_outlined);
      case CalendarView.workWeek:
        return const Icon(Icons.work_history_outlined);
      case CalendarView.month:
        return const Icon(Icons.calendar_view_month_outlined);
      case CalendarView.schedule:
        return const Icon(Icons.schedule_outlined);
      default:
        return const Icon(Icons.calendar_today_outlined);
    }
  }
}
