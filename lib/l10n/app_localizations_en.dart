// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get apptitle => 'Event Manager';

  @override
  String get addEvent => 'Add Event';

  @override
  String get eventDetails => 'Event Details';

  @override
  String get labelText => 'Event Name';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get chooseStartTime => 'Choose Start Time';

  @override
  String get chooseEndTime => 'Choose End Time';

  @override
  String get eventNotes => 'Event Notes';

  @override
  String get deleteEvent => 'Delete Event';

  @override
  String get saveEvent => 'Save Event';

  @override
  String get allDayEvent => 'All-day Event';

  @override
  String get noEventsFound => 'No events found';

  @override
  String get noTitle => '(No Title)';

  @override
  String get newEvent => 'New Event';
}
