import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Payment {
  static const String collection = "payments";
  final String orderId;
  int paymentId;
  String? firestoreId;

  Payment({required this.orderId, required this.paymentId, this.firestoreId});

  Map<String, dynamic> toMap() {
    return {
      "orderId": orderId,
      "payment": paymentId,
    };
  }

  static Payment mapToModel({
    required Map<String, dynamic> map,
    required String firestoreId,
  }) {
    return Payment(
      orderId: map["orderId"],
      paymentId: map["paymentId"],
      firestoreId: firestoreId,
    );
  }
}

class Payments {
  List<Payment> payments;

  Payments({List<Payment>? payments}) : payments = payments ?? [];

  static Future<Payments> getPayments() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshots =
      await FirebaseFirestore.instance.collection(Payment.collection).get();
      final Payments paymentsList = Payments();

      for (QueryDocumentSnapshot<Map<String, dynamic>> document in snapshots.docs) {
        paymentsList.payments.add(Payment.mapToModel(map: document.data(), firestoreId: document.id));
      }
      debugPrint(paymentsList.toString());
      return paymentsList;
    } catch (e) {
      return Payments();
    }
  }
}
