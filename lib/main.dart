import 'package:flutter/material.dart';
import 'package:utibu/providers/medicationprovider.dart';
import 'package:provider/provider.dart';
import 'login_page.dart'; // Assume this exists and handles user login
import 'registration_page.dart'; // Assume this exists and handles user registration
import 'order_medication_page.dart'; // Stub for medication ordering page
import 'view_statement_page.dart'; // Stub for viewing account statements
import 'package:shared_preferences/shared_preferences.dart';
import 'checkout.dart';
import 'profile.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MedicationProvider(),
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Utibu Health App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColorDark: Color(0xff1F2432),
        primaryColor: Color(0xff51586B),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xffFF9C02),
        ),
      ),
      home: HomePage(),
      // Routes for navigating to other pages
      routes: {
       '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
        '/orderMedication': (context) => OrderMedicationPage(),
        '/viewStatement': (context) => OrdersPage(),
        '/checkout': (context) => CheckoutPage(),
        '/profile': (context) => ProfilePage(),

      }
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      setState(() {
        isLoggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Utibu Health'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 25)),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            if (!isLoggedIn) ...[
              ListTile(
                leading: Icon(Icons.login),
                title: Text('Login'),
                onTap: () => Navigator.pushNamed(context, '/login'),
              ),
              ListTile(
                leading: Icon(Icons.app_registration),
                title: Text('Register'),
                onTap: () => Navigator.pushNamed(context, '/register'),
              ),
            ] else ...[
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Profile'),
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
            ],
            ListTile(
              leading: Icon(Icons.add_shopping_cart),
              title: Text('Order Medication'),
              onTap: () => Navigator.pushNamed(context, '/orderMedication'),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Cart'),
              onTap: () => Navigator.pushNamed(context, '/checkout'),
            ),
            ListTile(
              leading: Icon(Icons.receipt),
              title: Text('View Statement'),
              onTap: () => Navigator.pushNamed(context, '/viewStatement'),
            ),
          ],
        ),
      ), body: SingleChildScrollView( // Allows for scrolling if content exceeds screen size
        child: Column(
          children: [
            SizedBox(
              height: 200, // Adjust the height as needed
              width: double.infinity, // Ensures the image takes full width
              child: Image.asset(
                'assets/images/back.png',
                fit: BoxFit.cover, // Ensures the image covers the widget size
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Welcome to Utibu Health!'),
            ),
            // Add more widgets as needed
          ],
        ),
      ),
    );
  }
}
