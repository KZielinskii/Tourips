import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:tourpis/repository/event_participants_repository.dart';
import 'package:tourpis/screens/payment/payment_list_item.dart';

import '../../models/PaymentsModel.dart';
import '../../models/UserModel.dart';
import '../../repository/payments_repository.dart';
import '../../repository/user_repository.dart';

class BalanceScreen extends StatefulWidget {
  final String eventId;

  const BalanceScreen({super.key, required this.eventId});

  @override
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  Map<String, dynamic>? paymentIntent;
  late String amount;
  late String currentUser;

  late List<PaymentListItem> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  Future<void> _loadList() async {
    String? currentUser = await UserRepository().getCurrentUserId();
    List<PaymentsModel> list =
    await PaymentsRepository().getPaymentsByEventId(widget.eventId);
    List<UserModel?> participants =
    await EventParticipantsRepository().getParticipantsByEventId(widget.eventId);
    for (var user in participants) {
      double paid = 0;
      double toPay = 0;

      for (var i in list) {
        if (user?.uid == i.paidById) {
          paid += double.parse(i.amount);
        }

        for (var j in i.theyWillPayId) {
          if (j == user?.uid) {
            toPay += (double.parse(i.amount)) / i.theyWillPayId.length;
          }
        }
      }
      double total = paid - toPay;
      total = double.parse(total.toStringAsFixed(2));

      PaymentListItem newItem;
      if (total >= 0) {
        newItem = PaymentListItem(
          title: user!.login,
          login: "Nie wymaga działań.",
          amount: "${total.toString()} zł",
          color: Colors.green,
          id: "0",
          ownerId: user.uid,
          currentUserId: currentUser!,
        );
      } else {
        newItem = PaymentListItem(
          title: user!.login,
          login: "Do zapłaty",
          amount: "${total.toString()} zł",
          color: Colors.red,
          id: "0",
          ownerId: user.uid,
          currentUserId: currentUser!,
        );
        if (user.uid == currentUser) {
          double amountDouble = double.parse(total.toString());
          amountDouble = amountDouble * -100;
          amount = amountDouble.toInt().toString();
        }
      }

      items.add(newItem);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _refreshList() async {
    setState(() {
      isLoading = true;
      items.clear();
    });
    await _loadList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshList,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
              children: items,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: ElevatedButton(
            onPressed: () async {
              await stripeMakePayment();
            },
            style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all<Color>(Colors.white),
              minimumSize:
              MaterialStateProperty.all<Size>(const Size(double.infinity, 50)),
            ),
            child: const Text(
              'Zapłać',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> stripeMakePayment() async {
    try {
      await createPaymentIntent();

      var gpay = const PaymentSheetGooglePay(
        merchantCountryCode: "PL",
        currencyCode: "PLN",
        testEnv: true,
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!["client_secret"],
          style: ThemeMode.dark,
          merchantDisplayName: "Tourips",
          googlePay: gpay,
        ),
      );


      await displayPaymentSheet();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      print(amount);
      await Stripe.instance.presentPaymentSheet();
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<void> createPaymentIntent() async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': 'PLN',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      paymentIntent = json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }
}
