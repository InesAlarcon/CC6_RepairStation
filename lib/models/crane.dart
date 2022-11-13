import 'package:cloud_firestore/cloud_firestore.dart';

class Crane {
  static const String collection = "gruas";
  final String name;
  String url;
  String? firestoreId;

  Crane({required this.name, required this.url, this.firestoreId});

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "url": url,
    };
  }

  static Crane mapToModel({
    required Map<String, dynamic> map,
    required String firestoreId,
  }) {
    return Crane(
      name: map["name"],
      url: map["url"],
      firestoreId: firestoreId,
    );
  }

  static Future<bool> addNewProduct({required Crane crane}) async {
    try {
      final DocumentReference documentReference = await FirebaseFirestore
          .instance
          .collection(Crane.collection)
          .add(crane.toMap());
      crane.firestoreId = documentReference.id;
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateProduct({required Crane crane}) async {
    try {
      await FirebaseFirestore.instance
          .collection(Crane.collection)
          .doc(crane.firestoreId)
          .update(crane.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteProduct({required Crane crane}) async {
    try {
      await FirebaseFirestore.instance
          .collection(Crane.collection)
          .doc(crane.firestoreId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}

class Cranes {
  List<Crane> cranes;

  Cranes({List<Crane>? cranes}) : cranes = cranes ?? [];

  static Future<Cranes> getCranes() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshots =
      await FirebaseFirestore.instance.collection(Crane.collection).get();
      final Cranes cranesList = Cranes();

      for (QueryDocumentSnapshot<Map<String, dynamic>> document
      in snapshots.docs) {
        cranesList.cranes.add(
            Crane.mapToModel(map: document.data(), firestoreId: document.id));
      }
      return cranesList;
    } catch (e) {
      return Cranes();
    }
  }
}
