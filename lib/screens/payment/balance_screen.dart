
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tourpis/models/StripeCustomer.dart';
import 'package:tourpis/repository/event_participants_repository.dart';
import 'package:tourpis/repository/stripe_customer_repository.dart';
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
  StripeCustomerRepository stripeCustomerRepository = StripeCustomerRepository();
  late String amount;
  late String emailUser;
  late String emailReceiver;
  late String currentUserId;

  late List<PaymentListItem> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadList();

  }

  Future<void> _loadList() async {
    String? currentUser = await UserRepository().getCurrentUserId();
    currentUserId = currentUser!;
    UserModel? userModel = await UserRepository().getUserByUid(currentUser);
    emailUser = userModel!.email;


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
          currentUserId: currentUser,
        );
      } else {
        newItem = PaymentListItem(
          title: user!.login,
          login: "Do zapłaty",
          amount: "${total.toString()} zł",
          color: Colors.red,
          id: "0",
          ownerId: user.uid,
          currentUserId: currentUser,
        );
        if (user.uid == currentUser) {
          double amountDouble = double.parse(total.toString());
          amountDouble = -amountDouble;
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
      StripeCustomer? stripeCustomer = await StripeCustomerRepository().getCustomerByEmail(emailUser);
      await stripeCustomerRepository.initStripePayment(amount: int.parse(amount), stripeCustomer: stripeCustomer!);
      await Stripe.instance.presentPaymentSheet();
      findAndPayUsers();

    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> findAndPayUsers() async {
    int toPay = int.parse(amount);
    for(var item in items) {
      String amountToPay = item.amount.substring(0, item.amount.length - 5);
      if(int.parse(amountToPay) > 0 && toPay > 0) {
        if(toPay > int.parse(amountToPay)) {
          UserModel? userModel = await UserRepository().getUserByUid(item.ownerId);
          StripeCustomer? stripeCustomer = await StripeCustomerRepository().getCustomerByEmail(userModel!.email);
          await stripeCustomerRepository.topUpBalance(amount: int.parse(amountToPay), stripeCustomer: stripeCustomer!);
          await stripeCustomerRepository.giveMoneyToUser(userModel.email, int.parse(amountToPay));
          removeDebt(userModel.uid, amountToPay);
        } else {
          UserModel? userModel = await UserRepository().getUserByUid(item.ownerId);
          StripeCustomer? stripeCustomer = await StripeCustomerRepository().getCustomerByEmail(userModel!.email);
          await stripeCustomerRepository.topUpBalance(amount: toPay, stripeCustomer: stripeCustomer!);
          await stripeCustomerRepository.giveMoneyToUser(userModel.email, toPay);
          removeDebt(userModel.uid, toPay.toString());
        }
      }
    }
  }

  Future<void> removeDebt(String? id, String amountToPay) async {
    try {
      List<String> list = [];
      list.add(id!);
      await PaymentsRepository().create(
        widget.eventId,
        "Zwrot kosztów",
        currentUserId,
        amountToPay,
        list,
      );
    } catch (e) {
      print(e);
    }
  }
}
