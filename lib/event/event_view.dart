import 'package:event_manager/event/event_service.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../l10n/app_localizations.dart';
import 'package:event_manager/main.dart';
import 'package:event_manager/event/event_detail_view.dart';
import 'package:event_manager/event/event_model.dart';
import 'package:event_manager/event/event_data_source.dart';

class EventView extends StatefulWidget {
  const EventView({super.key});

  @override
  State<EventView> createState() => _EventViewState();
}


class _EventViewState extends State<EventView> {
  final eventService = EventService();
  List<EventModel> items = [];
  final calendarController = CalendarController();
  EventCategory? _filterCategory; // null = all
  bool _isSearching = false;
  String _searchQuery = '';

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


  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    List<EventModel> visibleItems = items;
    if (_filterCategory != null) {
      visibleItems = visibleItems.where((e) => e.category == _filterCategory).toList();
    }
    if (_isSearching && _searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      visibleItems = visibleItems.where((e) {
        final subject = e.subject.toLowerCase();
        final notes = (e.notes ?? '').toLowerCase();
        return subject.contains(q) || notes.contains(q);
      }).toList();
    }
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : Text(al.apptitle),
        actions: [
          // lọc theo loại sự kiện
          PopupMenuButton<EventCategory?>(
            tooltip: al.category,
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterCategory = value;
              });
            },
            itemBuilder: (context) => <PopupMenuEntry<EventCategory?>>[
              PopupMenuItem<EventCategory?>(
                value: null,
                child: Text('${al.category}: ${al.categoryAll}'),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<EventCategory?>(
                value: EventCategory.personal,
                child: Text(al.categoryPersonal),
              ),
              PopupMenuItem<EventCategory?>(
                value: EventCategory.study,
                child: Text(al.categoryStudy),
              ),
              PopupMenuItem<EventCategory?>(
                value: EventCategory.work,
                child: Text(al.categoryWork),
              ),
              PopupMenuItem<EventCategory?>(
                value: EventCategory.health,
                child: Text(al.categoryHealth),
              ),
              PopupMenuItem<EventCategory?>(
                value: EventCategory.group,
                child: Text(al.categoryGroup),
              ),
              PopupMenuItem<EventCategory?>(
                value: EventCategory.travel,
                child: Text(al.categoryTravel),
              ),
            ],
          ),
          if (_filterCategory != null)
            IconButton(
              tooltip: '${al.category}: ${al.categoryAll}',
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () {
                setState(() {
                  _filterCategory = null; 
                });
              },
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'vi', child: Text('Tiếng Việt')),
              PopupMenuItem(value: 'en', child: Text('English')),
            ],
            onSelected: (code) => MyApp.of(context)?.setLocale(Locale(code)),
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
          if (_isSearching)
            IconButton(
              tooltip: 'Clear search',
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _isSearching = false;
                });
              },
            )
          else
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                  _searchQuery = '';
                });
              },
            ),
          IconButton(onPressed: loadEvents, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SfCalendar(
        controller: calendarController,
        dataSource: EventDataSource(visibleItems),
        monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
        onLongPress: (details) {
          if (details.targetElement == CalendarElement.calendarCell) {
            final newEvent = EventModel(
              subject: al.newEvent,
              startTime: details.date!,
              endTime: details.date!.add(const Duration(hours: 1)),
              category: _filterCategory ?? EventCategory.personal,
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
