import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourpis/models/EventRequestModel.dart';

class EventRepository {
  final _db = FirebaseFirestore.instance;
  final eventRepository = EventRepository();

  Future<void> createRequest(String eventId, String userId, bool ownerRequest) async {
    EventRequestModel eventRequest = EventRequestModel(eventId: 'eventId', userId: 'userId', ownerRequest: ownerRequest);
    await _db.collection('event_requests').doc().set(eventRequest.toJson());
  }
}
