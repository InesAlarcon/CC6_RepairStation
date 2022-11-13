import 'dart:core';

import 'package:repair_station/models/car_line.dart';
import 'package:repair_station/models/order.dart';
import 'package:repair_station/models/product.dart';
import 'package:repair_station/models/sale.dart';
import 'package:repair_station/models/crane.dart';
import 'dart:math';

class Examples {
  static List<RepairProduct> dummyProductList({int numberProducts = 15}) {
    List<RepairProduct> dummyProducts = [];
    var rng = Random();

    for (int i = 0; i < numberProducts; i++) {
      dummyProducts.add(RepairProduct(
          name: "Repair Product #${i + 1}",
          description: "<Descripción aquí>",
          articleId: "article-20$i",
          price: rng.nextDouble() * 500,
          stock: rng.nextInt(20),
          year: rng.nextInt(30) + 1992,
          brand: "Some Brand here",
          model: "Some Model",
          weight: 213.56,
          station: 'RSI'));
    }

    return dummyProducts;
  }

  static List<Sale> dummySalesList({int numberSales = 15}) {
    List<Sale> dummySales = [];
    var rng = Random();

    for (int i = 0; i < numberSales; i++) {
      dummySales.add(Sale(
        articleName: "Article #${i + 1}",
        articleId: "article-20$i",
        description: "<Descripción aquí>",
        discount: rng.nextDouble(),
        active: rng.nextBool(),
      ));
    }

    return dummySales;
  }

  static List<Crane> dummyCranesList({int numberCranes = 15}) {
    List<Crane> dummyCranes = [];

    for (int i = 0; i < numberCranes; i++) {
      dummyCranes.add(
        Crane(
          name: "Crane #${i + 1}",
          url: "Some URL #${i + 1}",
        ),
      );
    }

    return dummyCranes;
  }

  static List<CarLine> dummyCarLineList({int numberLines = 15}) {
    List<CarLine> dummyCarLines = [];

    dummyCarLines.addAll([
      CarLine(
        brand: "Toyota",
        models: [
          "Corolla",
          "Yaris",
          "Rav4",
          "Hilux",
        ],
      ),
      CarLine(
        brand: "Honda",
        models: [
          "Civic",
          "CRV",
        ],
      ),
      CarLine(
        brand: "Suzuki",
        models: [
          "Alto",
          "Jimny",
          "Swift",
        ],
      ),
      CarLine(
        brand: "Ford",
        models: [
          "Explorer",
          "Edge",
          "Ranger",
        ],
      ),
    ]);

    return dummyCarLines;
  }
}
