import 'package:cloud_firestore/cloud_firestore.dart';

import 'my_repair_station.dart';

class OrderItem {
  static const String subCollection = "items";
  String item, itemId, model, brand;
  int quantity, year;
  double price, weight;
  String? firestoreId;

  OrderItem(
      {required this.item,
        required this.itemId,
        required this.brand,
        required this.model,
        required this.year,
        required this.quantity,
        required this.price,
        required this.weight,
        this.firestoreId});

  Map<String, dynamic> toMap() {
    return {
      "itemId": itemId,
      "item": item,
      "brand": brand,
      "model": model,
      "year": year,
      "quantity": quantity,
      "price": price,
      "weight": weight,
    };
  }

  static OrderItem mapToModel(
      {required Map<String, dynamic> map, String? firestoreId}) {
    return OrderItem(
      item: map["item"],
      itemId: map["itemId"],
      brand: map["brand"],
      model: map["model"],
      year: map["year"],
      quantity: map["quantity"],
      price: map["price"],
      weight: map["weight"],
      firestoreId: firestoreId,
    );
  }
}

class Order {
  static const String collection = "orders";
  final String orderId;
  List<OrderItem> orderItems;
  String clientName, issueDate, station;
  bool status;
  int totalItems;
  double totalCost, totalWeight, clientLatitud, clientLongitud;
  String? delivery;
  String? firestoreId;

  Order({
    required this.orderId,
    required this.station,
    required this.clientName,
    required this.clientLatitud,
    required this.clientLongitud,
    required this.issueDate,
    required this.status,
    required this.orderItems,
    required this.totalItems,
    required this.totalCost,
    required this.totalWeight,
    this.delivery,
    this.firestoreId,
  });

  String descriptionItems() {
    String formattedDescription = "";
    for (OrderItem orderItem in orderItems) {
      String str = "\nArtículo: ${orderItem.item} (${orderItem.itemId})\n"
          "Detalles: ${orderItem.brand} ${orderItem.model} ${orderItem.year}\n"
          "Cantidad: ${orderItem.quantity}\n"
          "Peso Subtotal: ${(orderItem.quantity * orderItem.weight).toStringAsFixed(2)} Kg\n"
          "Subtotal: Q${(orderItem.quantity * orderItem.price).toStringAsFixed(2)}\n";

      formattedDescription += str;
    }
    return formattedDescription;
  }

  String descriptionOrder() {
    String details = "Despachador: $station\n"
        "Cliente: $clientName ($clientLatitud:$clientLongitud)\n"
        "Fecha: $issueDate\n"
        "Status: ${status ? "Completado" : "Procesando"}\n"
        "Mensajero: ${(delivery ?? "---")}\n"
        "Total de Artículos: ${(totalItems)}\n"
        "Peso Total: ${(totalWeight.toStringAsFixed(2))} Kg\n"
        "Total: Q${(totalCost.toStringAsFixed(2))}\n\n"
        "Descripción:${descriptionItems()}";

    return details;
  }

  Map<String, dynamic> toMap() {
    return {
      "status": status,
      "delivery": delivery,
    };
  }

  Map<String, dynamic> toMapCraneStandard() {
    return {
      "orderId": orderId,
      "clientName": clientName,
      "clientLatitud": clientLatitud,
      "clientLongitud": clientLongitud,
      "pickupName": MyRepairStation.name,
      "pickupLatitud": MyRepairStation.latitud,
      "pickupLongitud": MyRepairStation.longitud,
      "totalItems": totalItems,
      "totalPrice": totalCost,
      "totalWeight": totalWeight,
    };
  }

  static Order mapToModel(
      {required Map<String, dynamic> map,
        required List<OrderItem> orderItems,
        required int totalItems,
        required double totalCost,
        required double totalWeight,
        String? firestoreId}) {
    return Order(
      orderId: map["orderId"],
      station: map["station"],
      clientName: map["clientName"],
      clientLatitud: map["clientLatitud"],
      clientLongitud: map["clientLongitud"],
      issueDate: map["issueDate"],
      status: map["status"],
      delivery: map["delivery"],
      orderItems: orderItems,
      totalItems: totalItems,
      totalCost: totalCost,
      totalWeight: totalWeight,
      firestoreId: firestoreId,
    );
  }

  static Future<bool> updateOrder({required Order order}) async {
    try {
      await FirebaseFirestore.instance
          .collection(Order.collection)
          .doc(order.firestoreId)
          .update(order.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }
}

class OrdersList {
  List<Order> orders;

  OrdersList({List<Order>? ordersList}) : orders = ordersList ?? [];

  static Future<OrdersList> getAllOrders() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> ordersSnapshots =
      await FirebaseFirestore.instance.collection(Order.collection).get();
      final OrdersList allOrders = OrdersList();

      for (QueryDocumentSnapshot<Map<String, dynamic>> orderDocument
      in ordersSnapshots.docs) {
        try {
          final QuerySnapshot<Map<String, dynamic>> orderItemsSnapshots =
          await FirebaseFirestore.instance
              .collection(Order.collection)
              .doc(orderDocument.id)
              .collection(OrderItem.subCollection)
              .get();

          List<OrderItem> orderItems = [];
          int totalItems = 0;
          double totalCost = 0, totalWeight = 0;
          for (QueryDocumentSnapshot<Map<String, dynamic>> orderItemDocument
          in orderItemsSnapshots.docs) {
            OrderItem orderItem = OrderItem.mapToModel(
              map: orderItemDocument.data(),
              firestoreId: orderItemDocument.id,
            );
            orderItems.add(orderItem);
            totalItems = orderItem.quantity + totalItems;
            totalCost = (orderItem.quantity * orderItem.price) + totalCost;
            totalWeight = (orderItem.quantity * orderItem.weight) + totalWeight;
          }

          Order order = Order.mapToModel(
            map: orderDocument.data(),
            orderItems: [],
            totalItems: totalItems,
            totalCost: totalCost,
            totalWeight: totalWeight,
            firestoreId: orderDocument.id,
          );
          order.orderItems.addAll(orderItems);
          allOrders.orders.add(order);
        } catch (error) {
          print("parsing item: ${error}");
          continue;
        }
      }

      return allOrders;
    } catch (e) {
      print(e);
      return OrdersList();
    }
  }
}
