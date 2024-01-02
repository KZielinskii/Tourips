
class EventParticipantsModel {
  final String? id;
  final String eventId;
  final List<String?> participants;

  const EventParticipantsModel({
    this.id,
    required this.eventId,
    required this.participants,
  });

  toJson() {
    return {
      "eventId": eventId,
      "participants": participants,
    };
  }

  factory EventParticipantsModel.fromJson(Map<String, dynamic> json) {
    return EventParticipantsModel(
      id: json['id'],
      eventId: json['eventId'],
      participants: List<String?>.from(json['participants'] ?? []),
    );
  }
}