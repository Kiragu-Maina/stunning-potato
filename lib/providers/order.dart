class OrderItem {
  final String medicationName;
  final int quantity;
  final double price;

  OrderItem({required this.medicationName, required this.quantity, required this.price});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      medicationName: json['medicationName'] as String? ?? '',
      // Use int.parse to convert a string to an int
      quantity: int.parse(json['quantity'].toString()),
      // Use double.parse to convert a string to a double
      price: double.parse(json['price'].toString()),
    );
  }
}



class Order {
  final int id;
  final String status;
  final double totalCost;
  final List<OrderItem> items;

  Order({required this.id, required this.status, required this.totalCost, required this.items});

  factory Order.fromJson(Map<String, dynamic> json) {
    // Safely parse the total_cost, providing a default value if the source is null or parsing fails
    double parsedTotalCost = json['total_cost'] != null ? double.tryParse(json['total_cost'].toString()) ?? 0.0 : 0.0;

    // Parsing the items list
    var list = json['items'] as List? ?? [];
    List<OrderItem> itemsList = list.map((itemJson) => OrderItem.fromJson(itemJson)).toList();

    return Order(
      id: json['id'] as int,
      status: json['status'] as String,
      totalCost: parsedTotalCost,
      items: itemsList,
    );
  }
}
