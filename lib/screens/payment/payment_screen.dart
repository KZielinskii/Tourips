import 'package:flutter/material.dart';
import 'package:tourpis/models/PaymentsModel.dart';
import 'package:tourpis/models/UserModel.dart';
import 'package:tourpis/repository/user_repository.dart';
import 'package:tourpis/screens/payment/payment_list_item.dart';
import 'package:tourpis/widgets/widget.dart';

import '../../repository/payments_repository.dart';

class PaymentScreen extends StatefulWidget {
  final String eventId;

  const PaymentScreen({super.key, required this.eventId});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
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
    for (var i in list) {
      UserModel? user = await UserRepository().getUserByUid(i.paidById);
      PaymentListItem newItem = PaymentListItem(
          title: i.title,
          login: user!.login,
          amount: "${i.amount} zł",
          color: Colors.white,
          id: i.id,
          ownerId: i.paidById,
          currentUserId: currentUser!,
      );
      items.add(newItem);
    }
    setState(() {
      isLoading = false;
      createSnackBar("(Przytrzymaj by usunąć wpis)", context);
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
    return RefreshIndicator(
      onRefresh: _refreshList,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: items,
      ),
    );
  }
}
