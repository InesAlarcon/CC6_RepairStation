import 'package:cloud_firestore/cloud_firestore.dart';

class CarLine {
  static const String collection = "linea";
  final String brand;
  List<String> models;
  String? firestoreId;

  CarLine({required this.brand, required this.models, this.firestoreId});

  String formattedModels() {
    String formattedString = "";

    if (models.isEmpty) {
      formattedString = "Ninguno";
    } else {
      formattedString = models[0];

      for (int i = 1; i < models.length; i++) {
        formattedString += ", ${models[i]}";
      }
    }

    return formattedString;
  }

  Map<String, dynamic> toMap() {
    return {
      "brand": brand,
      "models": models,
    };
  }

  static CarLine mapToModel({
    required Map<String, dynamic> map,
    required String firestoreId,
  }) {
    return CarLine(
      brand: map["brand"],
      models: (map["models"] as List).map((item) => item as String).toList(),
      firestoreId: firestoreId,
    );
  }

  static Future<bool> addNewCarLine({required CarLine carLine}) async {
    try {
      final DocumentReference documentReference = await FirebaseFirestore
          .instance
          .collection(CarLine.collection)
          .add(carLine.toMap());
      carLine.firestoreId = documentReference.id;
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateCarLine({required CarLine carLine}) async {
    try {
      await FirebaseFirestore.instance
          .collection(CarLine.collection)
          .doc(carLine.firestoreId)
          .update(carLine.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteCarLine({required CarLine carLine}) async {
    try {
      await FirebaseFirestore.instance
          .collection(CarLine.collection)
          .doc(carLine.firestoreId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}

class AutomobileLines {
  List<CarLine> lines;

  AutomobileLines({List<CarLine>? lines}) : lines = lines ?? [];

  static Future<AutomobileLines> getLines() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshots =
      await FirebaseFirestore.instance.collection(CarLine.collection).get();
      final AutomobileLines automobilesLines = AutomobileLines();

      for (QueryDocumentSnapshot<Map<String, dynamic>> document
      in snapshots.docs) {
        automobilesLines.lines.add(
            CarLine.mapToModel(map: document.data(), firestoreId: document.id));
      }

      return automobilesLines;
    } catch (e) {
      return AutomobileLines();
    }
  }
}
