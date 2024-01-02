import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourpis/models/EventModel.dart';
import 'package:tourpis/models/EventRequestModel.dart';

class EventRequestRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> createRequest(String eventId, String userId, bool ownerRequest) async {
    EventRequestModel eventRequest = EventRequestModel(eventId: eventId, userId: userId, ownerRequest: true);
    await _db.collection('event_requests').doc().set(eventRequest.toJson());
  }

  Future<List<EventModel>> getRequestsForUser(String userId) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await _db.collection('event_requests').where('userId', isEqualTo: userId).get();

    List<EventModel> events = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
      String eventId = doc['eventId'];
      EventModel? event = await getEventById(eventId);

      if (event != null) {
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
}
