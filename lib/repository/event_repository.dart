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
          owner: ownerId,
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

  Future<void> updateEvent(
      String eventId,
      String title,
      String description,
      DateTime startDate,
      DateTime endDate,
      int capacity,
      int participants,
      List<GeoPoint> geoPoints,
      String owner,
      ) async {
    try {
      EventModel updatedEvent = EventModel(
        id: eventId,
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        capacity: capacity,
        participants: participants,
        route: geoPoints,
        owner: owner,
      );

      await _db.collection('events').doc(eventId).update(updatedEvent.toJson());

      print('Zaktualizowano wydarzenie o ID: $eventId');
    } catch (error) {
      print('Error updating event: $error');
      throw Exception('Error updating event');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _db.collection('events').doc(eventId).delete();

      await _db.collection('event_participants').where('eventId', isEqualTo: eventId).get().then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });

      await _db.collection('event_requests').where('eventId', isEqualTo: eventId).get().then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });

      print('Usunięto wydarzenie o ID: $eventId');
    } catch (error) {
      print('Error deleting event: $error');
      throw Exception('Error deleting event');
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

  Future<List<EventModel>> getUserEvents() async {
    try {
      String? userId = await userRepository.getCurrentUserId();

      if (userId != null) {
        QuerySnapshot<Map<String, dynamic>> participantEventsSnapshot =
        await _db.collection('event_participants').where('participants', arrayContains: userId).get();

        List<EventModel> participantEvents = [];

        for (var doc in participantEventsSnapshot.docs) {
          String eventId = doc['eventId'];
          EventModel? event = await getEventById(eventId);
          if (event != null) {
            participantEvents.add(event);
          }
        }

        return participantEvents;
      } else {
        print('Błąd: Nie udało się pobrać ID użytkownika');
        return [];
      }
    } catch (error) {
      print('Error fetching user event: $error');
      throw Exception('Error fetching user event');
    }
  }

  Future<List<EventModel>> getOtherEvents() async {
    try {
      String? userId = await userRepository.getCurrentUserId();

      if (userId != null) {
        QuerySnapshot<Map<String, dynamic>> allEventsSnapshot =
        await _db.collection('events').get();

        QuerySnapshot<Map<String, dynamic>> participantEventsSnapshot =
        await _db.collection('event_participants').where('participants', arrayContains: userId).get();

        List<String> participantEventIds = participantEventsSnapshot.docs
            .map((doc) => doc['eventId'].toString())
            .toList();

        List<EventModel> otherEvents = allEventsSnapshot.docs
            .where((eventDoc) => !participantEventIds.contains(eventDoc.id))
            .map((eventDoc) => EventModel.fromJson(eventDoc.data()))
            .toList();

        return otherEvents;
      } else {
        print('Błąd: Nie udało się pobrać ID użytkownika');
        return [];
      }
    } catch (error) {
      print('Error fetching other events: $error');
      throw Exception('Error fetching other events');
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
