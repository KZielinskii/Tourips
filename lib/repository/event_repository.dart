import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourpis/repository/user_repository.dart';
import '../models/EventModel.dart';
import '../models/UserModel.dart';

class EventRepository {
  final _db = FirebaseFirestore.instance;
  final userRepository = UserRepository();

  Future<String?> createEvent(String title, String description, DateTime startDate, DateTime endDate, int capacity, List<GeoPoint> geoPoints) async {
    String? ownerId = await userRepository.getCurrentUserId();

    if (ownerId != null) {
      UserModel? owner = await userRepository.getUserByUid(ownerId);

      if (owner != null) {
        EventModel event = EventModel(
          title: title,
          description: description,
          owner: owner.login,
          startDate: startDate,
          endDate: endDate,
          capacity: capacity,
          participants: 1,
          route: geoPoints,
        );

        DocumentReference eventRef = await _db.collection('events').add(event.toJson());
        String eventId = eventRef.id;
        event.id = eventId;
        await _db.collection('events').doc(eventId).update(event.toJson());
        print('Stworzono wydarzenie');
        return eventId;
      } else {
        print('Błąd: Nie udało się pobrać informacji o właścicielu');
        return null;
      }
    } else {
      print('Błąd: Nie udało się pobrać ID użytkownika');
      return null;
    }
  }

  Future<List<EventModel>> getAllEvents() async {
    try {
      QuerySnapshot<Map<String, dynamic>> eventsSnapshot =
      await _db.collection('events').get();

      List<EventModel> events = eventsSnapshot.docs
          .map((eventDoc) => EventModel.fromJson(eventDoc.data()))
          .toList();

      return events;
    } catch (error) {
      print('Error fetching all events: $error');
      throw Exception('Error fetching all events');
    }
  }

  Future<EventModel?> getEventById(String eventId) async {
    DocumentSnapshot<Map<String, dynamic>> eventDoc =
    await _db.collection('events').doc(eventId).get();

    if (eventDoc.exists) {
      return EventModel.fromJson(eventDoc.data()!);
    } else {
      return null;
    }
  }

  Future<void> incrementParticipantsCount(String eventId) async {
    await _db.collection('events').doc(eventId).update({
      'participants': FieldValue.increment(1),
    });
  }
}
