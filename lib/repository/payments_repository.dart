import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourpis/models/PaymentsModel.dart';

class PaymentsRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> create(String eventId, String title, String payById, String amount, List<String> theyWillPayId) async {
    String paymentId = _db.collection('payments').doc().id;
    PaymentsModel paymentsModel = PaymentsModel(
      id: paymentId,
      eventId: eventId,
      title: title,
      paidById: payById,
      amount: amount,
      theyWillPayId: theyWillPayId,
    );
    await _db.collection('payments').doc(paymentId).set(paymentsModel.toJson());
  }

  Future<List<PaymentsModel>> getPaymentsByEventId(String eventId) async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('payments').where('eventId', isEqualTo: eventId).get();

      List<PaymentsModel> paymentsList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return PaymentsModel.fromJson(data);
      }).toList();

      return paymentsList;
    } catch (e) {
      print('Error fetching payments: $e');
      return [];
    }
  }

  Future<void> deletePaymentById(String paymentId) async {
    try {
      await _db.collection('payments').doc(paymentId).delete();
    } catch (e) {
      print('Error deleting payment: $e');
    }
  }
}
