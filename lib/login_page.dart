import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Import other pages you want to navigate to
import 'main.dart'; // Assuming you have a HomePage widget
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  // Added for user feedback
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  Future<void> _login() async {
    final url = "${ApiClient.baseUrl}login/";
    try {
      final response = await http.post( Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode({"username": _email, "password": _password}));

      if (response.statusCode == 200) {
        // Decode the response
        final responseData = json.decode(response.body);
        // Extract the token (adjust the key according to your API response structure)
        final token = responseData['token'];

        // Save the token using SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Navigate to HomePage upon successful login
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
      } else {
        // If login fails, show an error message
        final responseData = json.decode(response.body);
        _showSnackBar(responseData['message'] ?? 'Error logging in');
      }
    } catch (e) {
      // Handle errors like no internet connection
      _showSnackBar('Failed to connect to the server');
    }
  }


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the key to Scaffold
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid username';
                  }
                  return null;
                },
                onSaved: (value) => _email = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
                onSaved: (value) => _password = value ?? '',
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _login();
                    }
                  },
                  child: Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
