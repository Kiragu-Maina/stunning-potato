import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'providers/medicationmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'order_medication_page.dart';

class AddToCartPage extends StatefulWidget {
  final Medication medication;

  AddToCartPage({required this.medication});

  @override
  _AddToCartPageState createState() => _AddToCartPageState();
}

class _AddToCartPageState extends State<AddToCartPage> {
  final TextEditingController _quantityController = TextEditingController();

  Future<void> addToCart(BuildContext context) async {
    final quantity = _quantityController.text; // Get the quantity from the controller
    if (quantity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a quantity")),
      );
      return;
    }

    try {
      final url = "${ApiClient.baseUrl}addtocart/";
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Token $token',
        },
        body: json.encode({
          "medication_id": widget.medication.id,
          "quantity": int.tryParse(quantity) ?? 1, // Use the entered quantity or default to 1
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Medication added to cart successfully")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OrderMedicationPage()),
        );
      } else {
        final responseData = json.decode(response.body);

        String errorMessage = responseData['error'] ?? 'An unexpected error occurred';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error making add-to-cart request: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add to Cart'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Add ${widget.medication.name} to your cart?'),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: "Quantity",
                hintText: "Enter quantity here",
              ),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () => addToCart(context),
              child: Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
}
