import 'event_model.dart';
import 'package:localstore/localstore.dart';

class EventService {
  final db = Localstore.instance; // Sử dụng LocalStore instance từ package.
  final path = 'events';

  // Hàm lấy danh sách sự kiện từ LocalStore.
  Future<List<EventModel>> getAllEvents() async {
    final eventsMap = await db.collection(path).get();

    if (eventsMap != null) {
      return eventsMap.entries.map((entry) {
        try {
          final eventData = entry.value as Map<String, dynamic>;
          if (!eventData.containsKey('id')) {
            eventData['id'] = entry.key; // Lấy key làm id nếu thiếu
          }
          return EventModel.fromMap(eventData);
        } catch (e) {
          return null; 
        }
      }).whereType<EventModel>().toList();
    }
    return [];
  }

  // Hàm kiểm tra sự kiện đã tồn tại trong LocalStore
  Future<bool> isEventExist(String eventId) async {
    final existingEvent = await db.collection(path).doc(eventId).get();
    return existingEvent != null;
  }

  // Hàm lưu 1 sự kiện vào LocalStore
  Future<void> saveEvent(EventModel event) async {
    event.id ??= db.collection(path).doc().id; // Tạo id nếu không tồn tại
    await db.collection(path).doc(event.id).set(event.toMap());
  }

  // Hàm cập nhật 1 sự kiện
  Future<void> updateEvent(String eventId, EventModel updatedEvent) async {
    final isExisting = await isEventExist(eventId);
    if (isExisting) {
      await db.collection(path).doc(eventId).set(updatedEvent.toMap());
    }
  }

  // Hàm xóa 1 sự kiện khỏi LocalStore
  Future<void> deleteEvent(EventModel event) async {
    if (event.id != null) {
      final isExisting = await isEventExist(event.id!);
      if (isExisting) {
        await db.collection(path).doc(event.id).delete();
      } 
    }
  }
}