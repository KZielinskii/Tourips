
class EventModel {
  final String? id;
  final String? owner;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int capacity;
  final int participants;
  //todo localization

  const EventModel({
    this.id,
    required this.owner,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.capacity,
    required this.participants,
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
    };
  }
}