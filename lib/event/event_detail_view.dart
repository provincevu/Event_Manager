import 'package:event_manager/event/event_model.dart';
import 'package:event_manager/event/event_service.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class EventDetailView extends StatefulWidget {
  final EventModel event;
  const EventDetailView({super.key, required this.event});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  final subjectController = TextEditingController();
  final notesController = TextEditingController();
  final eventService = EventService();

  @override
  void initState() {
    super.initState();
    subjectController.text = widget.event.subject;
    notesController.text = widget.event.notes ?? '';
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? widget.event.startTime : widget.event.endTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStart ? widget.event.startTime : widget.event.endTime,
        ),
      );

      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStart) {
            widget.event.startTime = newDateTime;
            if (widget.event.startTime.isAfter(widget.event.endTime)) {
              widget.event.endTime = widget.event.startTime.add(
                const Duration(hours: 1),
              );
            }
          }
          else{
            widget.event.endTime = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _saveEvent() async {
    widget.event.subject = subjectController.text;
    widget.event.notes = notesController.text;
    await eventService.saveEvent(widget.event);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _deleteEvent() async {
    await eventService.deleteEvent(widget.event);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.id == null ? al.addEvent : al.eventDetails),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: subjectController,
                decoration: InputDecoration(labelText: al.labelText),
              ),
              const SizedBox(height: 16),
              // Category selector
              DropdownButtonFormField<EventCategory>(
                value: widget.event.category,
                decoration: InputDecoration(labelText: al.category),
                items: [
                  DropdownMenuItem(
                    value: EventCategory.personal,
                    child: Text(al.categoryPersonal),
                  ),
                  DropdownMenuItem(
                    value: EventCategory.study,
                    child: Text(al.categoryStudy),
                  ),
                  DropdownMenuItem(
                    value: EventCategory.work,
                    child: Text(al.categoryWork),
                  ),
                  DropdownMenuItem(
                    value: EventCategory.health,
                    child: Text(al.categoryHealth),
                  ),
                  DropdownMenuItem(
                    value: EventCategory.group,
                    child: Text(al.categoryGroup),
                  ),
                  DropdownMenuItem(
                    value: EventCategory.travel,
                    child: Text(al.categoryTravel),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    widget.event.category = value;
                  });
                },
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(al.allDayEvent),
                trailing: Switch(
                  value: widget.event.isAllDay,
                  onChanged: (value) {
                    setState(() {
                      widget.event.isAllDay = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(widget.event.isAllDay
                    ? '${al.start}: ${widget.event.startTime.day}/${widget.event.startTime.month}/${widget.event.startTime.year}'
                    : '${al.start}: ${widget.event.formatedStartTimeString}'),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  if (widget.event.isAllDay) {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: widget.event.startTime,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setState(() {
                        widget.event.startTime = DateTime(picked.year, picked.month, picked.day);
                        if (!widget.event.endTime.isAfter(widget.event.startTime)) {
                          widget.event.endTime = widget.event.startTime.add(const Duration(days: 1));
                        }
                      });
                    }
                  } else {
                    await _pickDateTime(isStart: true);
                  }
                },
              ),
            
              if (widget.event.isAllDay)
                ListTile(
                  title: Text('${al.chooseStartTime}: ${TimeOfDay.fromDateTime(widget.event.startTime).format(context)}'),
                  trailing: const Icon(Icons.access_time_outlined),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(widget.event.startTime),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        widget.event.startTime = DateTime(
                          widget.event.startTime.year,
                          widget.event.startTime.month,
                          widget.event.startTime.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        if (!widget.event.endTime.isAfter(widget.event.startTime)) {
                          widget.event.endTime = widget.event.startTime.add(const Duration(hours: 1));
                        }
                      });
                    }
                  },
                ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(widget.event.isAllDay
                    ? '${al.end}: ${widget.event.endTime.day}/${widget.event.endTime.month}/${widget.event.endTime.year}'
                    : '${al.end}: ${widget.event.formatedEndTimeString}'),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  if (widget.event.isAllDay) {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: widget.event.endTime,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setState(() {
                        widget.event.endTime = DateTime(picked.year, picked.month, picked.day).add(const Duration(days: 1));
                        if (!widget.event.endTime.isAfter(widget.event.startTime)) {
                          widget.event.endTime = widget.event.startTime.add(const Duration(days: 1));
                        }
                      });
                    }
                  } else {
                    await _pickDateTime(isStart: false);
                  }
                },
              ),
              if (widget.event.isAllDay)
                ListTile(
                  title: Text('${al.chooseEndTime}: ${TimeOfDay.fromDateTime(widget.event.endTime).format(context)}'),
                  trailing: const Icon(Icons.access_time_outlined),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(widget.event.endTime),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        widget.event.endTime = DateTime(
                          widget.event.endTime.year,
                          widget.event.endTime.month,
                          widget.event.endTime.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        if (!widget.event.endTime.isAfter(widget.event.startTime)) {
                          widget.event.endTime = widget.event.startTime.add(const Duration(hours: 1));
                        }
                      });
                    }
                  },
                ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: al.eventNotes,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.event.id != null)
                    FilledButton.tonalIcon(
                      onPressed: _deleteEvent,
                      icon: const Icon(Icons.delete),
                      label: Text(al.deleteEvent),
                    ),
                  FilledButton.icon(
                    onPressed: _saveEvent,
                    icon: const Icon(Icons.save),
                    label: Text(al.saveEvent),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
