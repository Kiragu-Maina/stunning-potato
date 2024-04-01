import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api.dart'; // Ensure you have this file that contains your ApiClient class
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';
  String about = '';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final url = "${ApiClient.baseUrl}user/info";
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          name = data['name'];
          email = data['email'];
          about = data['about'];
        });
      } else {
        print("Failed to fetch user info: ${response.body}");
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    // Redirect to home page after logging out
    Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Name'),
            subtitle: Text(name),
          ),
          ListTile(
            title: Text('Email'),
            subtitle: Text(email),
          ),
          ListTile(
            title: Text('About'),
            subtitle: Text(about),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            child: ElevatedButton(
              onPressed: _logout,
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white70, // Set the background color to red for emphasis on logout action
              ),
            ),
          ),
        ],
      ),
    );
  }
}
