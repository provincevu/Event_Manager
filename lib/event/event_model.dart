import 'dart:convert';

enum EventCategory { personal, study, work, health, group, travel }

class EventModel {
  String? id;
  DateTime startTime;
  DateTime endTime;
  bool isAllDay;
  String subject;
  String? notes;
  String? recurrenceRule;
  EventCategory category;

  EventModel({
    this.id,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.subject = '',
    this.notes,
    this.recurrenceRule,
    this.category = EventCategory.personal,
  });

  // copyWith method
  EventModel copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    String? subject,
    String? notes,
    String? recurrenceRule,
    EventCategory? category,
  }) {
    return EventModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      subject: subject ?? this.subject,
      notes: notes ?? this.notes,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'isAllDay': isAllDay,
      'subject': subject,
      'notes': notes,
      'recurrenceRule': recurrenceRule,
      'category': category.name,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    final categoryStr = map['category'] as String?;
    final category = EventCategory.values.firstWhere(
      (e) => e.name == categoryStr,
      orElse: () => EventCategory.personal,
    );
    return EventModel(
      id: map['id'] as String?,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int),
      isAllDay: map['isAllDay'] as bool? ?? false,
      subject: map['subject'] as String? ?? '',
      notes: map['notes'] as String?,
      recurrenceRule: map['recurrenceRule'] as String?,
      category: category,
    );
  }

  String toJson() => json.encode(toMap());

  factory EventModel.fromJson(String source) =>
      EventModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EventModel(id: $id, startTime: $startTime, endTime: $endTime, isAllDay: $isAllDay, subject: $subject, notes: $notes, recurrenceRule: $recurrenceRule, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

  return other is EventModel &&
        other.id == id &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.isAllDay == isAllDay &&
        other.subject == subject &&
    other.notes == notes &&
    other.recurrenceRule == recurrenceRule &&
    other.category == category;
  }

  @override
  int get hashCode {
  return id.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        isAllDay.hashCode ^
        subject.hashCode ^
        notes.hashCode ^
    recurrenceRule.hashCode ^
    category.hashCode;
  }
}

extension ExtEventModel on EventModel {
  String get formatedStartTimeString => '${startTime.hour}: ${startTime.minute} , ${startTime.day}/${startTime.month}/ ${startTime.year}';
  String get formatedEndTimeString => '${endTime.hour}: ${endTime.minute} , ${endTime.day}/${endTime.month}/ ${endTime.year}';
}