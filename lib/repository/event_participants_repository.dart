import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourpis/models/EventParticipantsModel.dart';
import 'package:tourpis/repository/user_repository.dart';

import '../models/UserModel.dart';

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

  Future<List<UserModel?>> getParticipantsByEventId(String eventId) async {
    final eventDocRef = _db
        .collection('event_participants')
        .where('eventId', isEqualTo: eventId);

    final eventSnapshot = await eventDocRef.get();

    if (eventSnapshot.docs.isNotEmpty) {
      EventParticipantsModel eventParticipants = EventParticipantsModel.fromJson(
          eventSnapshot.docs.first.data());
      List<UserModel?> participants = [];
      List<String?> participantId = eventParticipants.participants;
      for(String? id in participantId) {
        UserModel? user = await UserRepository().getUserByUid(id!);
        participants.add(user);
      }
      return participants;
    } else {
      return [];
    }
  }
}
