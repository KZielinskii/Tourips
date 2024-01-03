import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourpis/models/EventParticipantsModel.dart';

class EventParticipantsRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> create(String eventId) async {
    EventParticipantsModel event =
    EventParticipantsModel(eventId: eventId, participants: []);
    await _db.collection('event_participants').doc().set(event.toJson());
  }

  Future<void> addUserToEvent(String userId, String eventId) async {
    final eventDocRef =
    _db.collection('event_participants').where('eventId', isEqualTo: eventId);

    final eventSnapshot = await eventDocRef.get();

    if (eventSnapshot.docs.isNotEmpty) {
      final existingDocRef = _db.collection('event_participants').doc(eventSnapshot.docs.first.id);

      await existingDocRef.update({
        'participants': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Future<void> removeUserFromEvent(String userId, String eventId) async {
    final eventDocRef =
    _db.collection('event_participants').where('eventId', isEqualTo: eventId);

    final eventSnapshot = await eventDocRef.get();

    if (eventSnapshot.docs.isNotEmpty) {
      final existingDocRef = _db.collection('event_participants').doc(eventSnapshot.docs.first.id);

      await existingDocRef.update({
        'participants': FieldValue.arrayRemove([userId]),
      });
    }
  }
}
