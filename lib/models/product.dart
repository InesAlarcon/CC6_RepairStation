import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class RepairProduct {
  static const String collection = "pieces";
  final String articleId;
  String name, description, model, brand, station;
  String? firestoreId;
  double price, weight;
  int stock, year;

  RepairProduct(
      {required this.articleId,
        required this.name,
        required this.description,
        required this.price,
        required this.weight,
        required this.stock,
        required this.model,
        required this.brand,
        required this.year,
        required this.station,
        this.firestoreId});

  Map<String, dynamic> toMap() {
    return {
      "articleId": articleId,
      "name": name,
      "description": description,
      "price": price,
      "weight": weight,
      "stock": stock,
      "model": model,
      "brand": brand,
      "year": year,
      "station": station
    };
  }

  static RepairProduct mapToModel(
      {required Map<String, dynamic> map, String? firestoreId}) {
    return RepairProduct(
      articleId: map["articleId"],
      name: map["name"],
      description: map["description"],
      price: map["price"],
      weight: map["weight"],
      stock: map["stock"],
      model: map["model"],
      brand: map["brand"],
      year: map["year"],
      station: map["station"],
      firestoreId: firestoreId,
    );
  }

  static Future<bool> addNewProduct(
      {required RepairProduct repairProduct}) async {
    try {
      final DocumentReference documentReference = await FirebaseFirestore
          .instance
          .collection(RepairProduct.collection)
          .add(repairProduct.toMap());
      repairProduct.firestoreId = documentReference.id;
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateProduct(
      {required RepairProduct repairProduct}) async {
    try {
      await FirebaseFirestore.instance
          .collection(RepairProduct.collection)
          .doc(repairProduct.firestoreId)
          .update(repairProduct.toMap());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> deleteProduct(
      {required RepairProduct repairProduct}) async {
    try {
      await FirebaseFirestore.instance
          .collection(RepairProduct.collection)
          .doc(repairProduct.firestoreId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}

class RepairProductsCatalog {
  List<RepairProduct> products;

  RepairProductsCatalog({List<RepairProduct>? catalogProducts})
      : products = catalogProducts ?? [];

  static Future<RepairProductsCatalog> getCatalog({String? stationId}) async {
    try {

      debugPrint(stationId);

      final RepairProductsCatalog repairProductsCatalog = RepairProductsCatalog();

      if (stationId == null) {
        final QuerySnapshot<Map<String, dynamic>> snapshots =
        await FirebaseFirestore.instance.collection(RepairProduct.collection).get();

        for (QueryDocumentSnapshot<Map<String, dynamic>> document in snapshots.docs) {
          repairProductsCatalog.products.add(
              RepairProduct.mapToModel(map: document.data(), firestoreId: document.id));
        }
        debugPrint(repairProductsCatalog.toString());

      } else {
        final QuerySnapshot<Map<String, dynamic>> snapshots =
        await FirebaseFirestore.instance.collection(RepairProduct.collection).where("station", isEqualTo: stationId).get();

        for (QueryDocumentSnapshot<Map<String, dynamic>> document in snapshots.docs) {
          repairProductsCatalog.products.add(RepairProduct.mapToModel(map: document.data(), firestoreId: document.id));
        }
        debugPrint(repairProductsCatalog.toString());
      }

      return repairProductsCatalog;

    } catch (e) {
      return RepairProductsCatalog();
    }
  }
}
