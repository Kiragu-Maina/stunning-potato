import 'package:flutter/material.dart';
import 'package:utibu/login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Import the HomePage or any other page you want to navigate to after registration
import 'main.dart'; // Assuming you have a HomePage widget or similar
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _register() async {
    final url = "${ApiClient.baseUrl}register/";
     try {
      final response = await http.post(Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode({"username": _username, "email": _email, "password": _password}));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Navigate to HomePage or any other page after successful registration
        final responseData = json.decode(response.body);
        final token = responseData['token'];

        // Save the token using SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
      } else {
        // If registration fails, show an error message
        final responseData = json.decode(response.body);
        _showSnackBar(responseData['message'] ?? 'Error registering');
      }
    } catch (e) {
      // Handle errors like no internet connection
      _showSnackBar('Try logging in:');
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));

     }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Register'),
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
                onSaved: (value) => _username = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
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
                onChanged: (value) {
                  // Update the state variable whenever the text changes
                  _password = value;
                },
                onSaved: (value) => _password = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true, // Ensure the text is obscured
                validator: (value) {
                  print("Password: $_password, Confirm: $value"); // Debug print
                  if (value != _password) {
                    return 'Passwords do not match';
                  }
                  return null;
                },

                onSaved: (value) => _confirmPassword = value ?? '',
              ),

              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _register();
                    }
                  },
                  child: Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
