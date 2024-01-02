import 'package:cloud_firestore_platform_interface/src/geo_point.dart';

class EventModel {
  final String? id;
  final String owner;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int capacity;
  final int participants;
  final List<GeoPoint> route;

  const EventModel({
    this.id,
    required this.owner,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.capacity,
    required this.participants,
    required this.route,
  });

  toJson() {
    return {
      "owner": owner,
      "title": title,
      "description": description,
      "startDate": startDate,
      "endDate": endDate,
      "capacity": capacity,
      "participants": participants,
      "route": route,
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      owner: json['owner'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      capacity: json['capacity'],
      participants: json['participants'],
      route: (json['route'] as List<dynamic>)
          .map((geoPoint) => GeoPoint(geoPoint['latitude'], geoPoint['longitude']))
          .toList(),
    );
  }
}