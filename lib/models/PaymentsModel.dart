class PaymentsModel {
  final String id;
  final String eventId;
  final String paidById;
  final String title;
  final String amount;
  final List<String> theyWillPayId;



  PaymentsModel({
    required this.id,
    required this.eventId,
    required this.title,
    required this.paidById,
    required this.amount,
    required this.theyWillPayId,
  });

  toJson() {
    return {
      "id": id,
      "eventId": eventId,
      "paidById": paidById,
      "title": title,
      "amount": amount,
      "theyWillPayId": theyWillPayId,
    };
  }

  factory PaymentsModel.fromJson(Map<String, dynamic> json) {
    return PaymentsModel(
      id: json['id'],
      eventId: json['eventId'],
      paidById: json['paidById'],
      title: json['title'],
      amount: json['amount'],
      theyWillPayId: List<String>.from(json['theyWillPayId'] ?? [],),
    );
  }
}