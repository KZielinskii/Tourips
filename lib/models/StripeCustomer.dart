import 'package:cloud_firestore/cloud_firestore.dart';

class StripeCustomer {
  final String id;
  final int balance;
  final DateTime created;
  final String email;

  StripeCustomer({
    required this.id,
    required this.balance,
    required this.created,
    required this.email,
  });

  toJson() {
    return {
      "id": id,
      "balance": balance,
      "created": created,
      "email": email,
    };
  }

  factory StripeCustomer.fromJson({required Map<String, dynamic> json}) {
    return StripeCustomer(
      id: json['id'],
      balance: json['balance'],
      created: _parseTimestamp(json['created']),
      email: json['email'],
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else {
      throw FormatException('Invalid timestamp format');
    }
  }
}