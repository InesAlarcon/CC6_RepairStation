class Sale {
  String description;
  String articleName, articleId;
  String? firestoreId;
  double discount;
  bool active;

  Sale(
      {required this.articleId,
        required this.articleName,
        required this.description,
        required this.discount,
        required this.active,
        this.firestoreId});

  Map<String, dynamic> modelToMap() {
    return {
      "articleId": articleId,
      "articleName": articleName,
      "description": description,
      "discount": discount,
      "active": active,
    };
  }

  static Sale mapToModel({required Map<String, dynamic> map}) {
    return Sale(
      articleId: map["articleId"],
      articleName: map["articleName"],
      description: map["description"],
      discount: map["discount"],
      active: map["active"],
    );
  }
}

class SalesCatalog {
  List<Sale> sales;

  SalesCatalog({List<Sale>? catalogSales}) : sales = catalogSales ?? [];
}
