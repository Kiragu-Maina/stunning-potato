class CartItem {
  final int id;
  final String name;
  final int quantity;
  final double price;

  CartItem({required this.id, required this.name, required this.quantity, required this.price});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      quantity: json['quantity'] as int,
      price: (json['price'] as num?)?.toDouble() ?? 0.0, // Adjusted line
    );
  }


}
