import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourpis/models/EventModel.dart';
import 'package:tourpis/models/EventRequestModel.dart';
import 'package:tourpis/repository/event_participants_repository.dart';
import 'package:tourpis/repository/event_repository.dart';
import 'package:tourpis/repository/user_repository.dart';

class EventRequestRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> createRequest(String eventId, String userId, bool ownerRequest) async {
    EventRequestModel eventRequest = EventRequestModel(eventId: eventId, userId: userId, ownerRequest: true);
    await _db.collection('event_requests').doc().set(eventRequest.toJson());
  }

  Future<int> getCountRequestsForUser() async {
    String? currentUserId = await UserRepository().getCurrentUserId();
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await _db.collection('event_requests').where('userId', isEqualTo: currentUserId).get();

    return querySnapshot.size;
  }

  Future<List<EventModel>> getRequestsForUser() async {

    String? userId = await UserRepository().getCurrentUserId();

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await _db.collection('event_requests').where('userId', isEqualTo: userId!).get();

    List<EventModel> events = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
      String eventId = doc['eventId'];
      EventModel? event = await getEventById(eventId);

      if (event != null) {
        event.id = eventId;
        events.add(event);
      }
    }

    return events;
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

  Future<void> deleteRequest(String eventId, String userId) async {
    await _db
        .collection('event_requests')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  Future<void> acceptRequest(String eventId, String userId) async {
    await EventRepository().incrementParticipantsCount(eventId);
    await deleteRequest(eventId, userId);
    await EventParticipantsRepository().addUserToEvent(userId, eventId);
  }
}
