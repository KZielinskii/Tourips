import 'package:tourpis/models/UserModel.dart';

class EventModel {
  final String? id;
  final UserModel owner;
  final String title;
  final String description;
  //todo localization

  const EventModel({
    this.id,
    required this.owner,
    required this.title,
    required this.description,
  });

  toJson() {
    return {
      "owner": owner,
      "title": title,
      "description": description,
    };
  }
}