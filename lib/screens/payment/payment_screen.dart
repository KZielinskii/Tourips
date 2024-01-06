
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final String eventId;

  const PaymentScreen({super.key, required this.eventId});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Płatności",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {

          },
          child: const Text("Zapłać"),
        ),
      ),
    );
  }
}
