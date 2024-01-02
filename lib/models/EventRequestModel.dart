class EventRequestModel {
  final String? id;
  final String eventId;
  final String userId;
  final bool ownerRequest;

  const EventRequestModel({
    this.id,
    required this.eventId,
    required this.userId,
    required this.ownerRequest,
  });

  toJson() {
    return {
      "eventId": eventId,
      "userId": userId,
      "ownerRequest": ownerRequest,
    };
  }

  factory EventRequestModel.fromJson(Map<String, dynamic> json) {
    return EventRequestModel(
      id: json['id'],
      eventId: json['eventId'],
      userId: json['userId'],
      ownerRequest: json['ownerRequest'],
    );
  }
}