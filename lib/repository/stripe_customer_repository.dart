import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../../models/StripeCustomer.dart';

class StripeCustomerRepository {
  Future<void> createCustomer({
    required String email,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
      };

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      StripeCustomer stripeCustomer = StripeCustomer.fromJson(
        json: json.decode(response.body),
      );

      await addCustomerToFirebase(stripeCustomer);

    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<void> addCustomerToFirebase(StripeCustomer stripeCustomer) async {
    try {
      await FirebaseFirestore.instance.collection('stripe_customers').doc(stripeCustomer.id).set(
        {
          'id': stripeCustomer.id,
          'balance': stripeCustomer.balance,
          'created': stripeCustomer.created,
          'email': stripeCustomer.email,
        },
      );
    } catch (err) {
      print('Error adding customer to Firebase: $err');
      throw Exception(err.toString());
    }
  }

  Future<StripeCustomer?> getCustomerByEmail(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('stripe_customers')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot = querySnapshot.docs.first;
        return StripeCustomer.fromJson(json: documentSnapshot.data()!);
      } else {
        return null;
      }
    } catch (err) {
      print('Error getting customer by email: $err');
      throw Exception(err.toString());
    }
  }

  Future<void> giveMoneyToUser(String email, int amountToAdd) async {
    try {
      StripeCustomer? customer = await getCustomerByEmail(email);

      if (customer != null) {
        int currentBalance = customer.balance;
        int newBalance = currentBalance + amountToAdd;

        await FirebaseFirestore.instance.collection('stripe_customers').doc(customer.id).set(
          {
            'id': customer.id,
            'balance': newBalance,
            'created': customer.created,
            'email': customer.email,
          },
        );
      } else {
        print('Customer not found in Firebase.');
      }
    } catch (err) {
      print('Error giving money to user: $err');
      throw Exception(err.toString());
    }
  }


  Future<Map<String, dynamic>> createPaymentIntent({
    required String amount,
    required StripeCustomer stripeCustomer,
  }) async {
    try {
      final body = <String, dynamic>{
        'amount': (int.parse(amount) * 100).toString(),
        'currency': 'PLN',
        'customer': stripeCustomer.id,
        'receipt_email': stripeCustomer.email,
      };

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<void> initStripePayment({
    required int amount,
    required StripeCustomer stripeCustomer,
  }) async {
    final paymentIntent = await createPaymentIntent(
      amount: (amount).toString(),
      stripeCustomer: stripeCustomer,
    );

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customerId: stripeCustomer.id,
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'tourips',
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> topUpBalance({
    required int amount,
    required StripeCustomer stripeCustomer,
  }) async {
    try {
      final body = <String, dynamic>{
        'amount': (amount * 100).toInt().toString(),
        'currency': 'PLN',
      };

      await http.post(
        Uri.parse(
          'https://api.stripe.com/v1/customers/${stripeCustomer.id}/balance_transactions',
        ),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
    } catch (err) {
      print('topUpBalance() exception in PaymentStore: $err');
      throw Exception(err.toString());
    }
  }

  Future<void> withdrawCustomerBalance({
    required int amount,
    required StripeCustomer stripeCustomer,
  }) async {
    try {
      final body = <String, dynamic>{
        'balance': ((stripeCustomer.balance - amount) * 100).toInt().toString(),
      };

      final response = await http.post(
        Uri.parse(
          'https://api.stripe.com/v1/customers/${stripeCustomer.id}',
        ),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      if (response.statusCode == 402) {
        var withdrawError =
            json.decode(response.body)['error']['decline_code'].toString();
        print(withdrawError);
      }
    } catch (err) {
      print('withdrawCustomerBalance() exception in PaymentStore: $err');
      throw Exception(err.toString());
    }
  }
}
