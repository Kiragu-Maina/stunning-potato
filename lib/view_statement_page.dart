import 'package:flutter/material.dart';
import 'providers/order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Order> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }


  Future<void> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final url = "${ApiClient.baseUrl}orders/"; // Endpoint for fetching orders

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Order> loadedOrders = body.map((dynamic item) => Order.fromJson(item)).toList();
      print(body);
      setState(() {
        orders = loadedOrders;
        isLoading = false; // Update loading state
      });
    } else {
      setState(() {
        isLoading = false; // Update loading state even if there's an error
      });
      throw Exception('Failed to load orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            child: ExpansionTile(
              title: Text("Order #${order.id} - ${order.status}"),
              subtitle: Text("Total: \$${order.totalCost.toStringAsFixed(2)}"),

              children: order.items.map((item) => ListTile(
                title: Text(item.medicationName),
                subtitle: Text("Quantity: ${item.quantity} - \$${item.price.toStringAsFixed(2)} each"),
              )).toList(),
            ),
          );
        },
      ),
    );
  }
}
