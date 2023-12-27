import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourpis/repository/user_repository.dart';
import '../models/EventModel.dart';
import '../models/UserModel.dart';

class EventRepository {
  final _db = FirebaseFirestore.instance;
  final userRepository = UserRepository();

  Future<void> createEvent(String title, String description, DateTime startDate, DateTime endDate, int capacity, List<GeoPoint> geoPoints) async {
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

        await _db.collection('events').doc().set(event.toJson());
        print('Stworzono wydarzenie');
      } else {
        print('Błąd: Nie udało się pobrać informacji o właścicielu');
      }
    } else {
      print('Błąd: Nie udało się pobrać ID użytkownika');
    }
  }
}
