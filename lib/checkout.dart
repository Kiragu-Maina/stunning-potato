import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api.dart'; // Make sure this has your API details
import 'providers/cartitem.dart'; // Your CartItem model
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  List<CartItem> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final url = "${ApiClient
        .baseUrl}cart/items/"; // Your endpoint to fetch cart items

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {

      final List<dynamic> cartItemsJson = json.decode(response.body);
      setState(() {
        cartItems =
            cartItemsJson.map((json) => CartItem.fromJson(json)).toList();
        print(cartItemsJson);
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() => isLoading = false);
    }
  }

  Future<void> createOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final url = "${ApiClient
        .baseUrl}create-order/"; // Endpoint for order creation

    // Prepare data for order creation
    List<Map<String, dynamic>> itemsData = cartItems.map((item) =>
    {
      'medication_id': item.id,
      'quantity': item.quantity,

    }).toList();

    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Token $token',
      },
      body: json.encode({
        'items': itemsData, // Sending cart items as part of the order
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Handle successful order creation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order created successfully")),
      );
      // Optionally, navigate to an order confirmation page or clear the cart

    } else {
      // Handle error in order creation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create order")),
      );
    }
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(

          title: Text('Checkout'),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            final item = cartItems[index];
            return Card(
              margin: EdgeInsets.all(10),
              elevation: 5,
              child: ListTile(
                leading: Icon(Icons.medication),
                // Consider using an image if available
                title: Text(item.name),
                subtitle: Text('Quantity: ${item.quantity} - \$${item.price
                    .toStringAsFixed(2)} each'),
                trailing: Text(
                    'Total: \$${(item.price * item.quantity).toStringAsFixed(
                        2)}'),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: createOrder,
          label: Text('Place Order'),
          icon: Icon(Icons.check),
        ),
      );
    }
  }

