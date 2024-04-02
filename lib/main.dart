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
      ), 
       body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height, // Takes full screen height
            width: MediaQuery.of(context).size.width, // Takes full screen width
            child: Image.asset(
              'assets/images/back.png',
              fit: BoxFit.cover, // Covers the whole widget area
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 250),
                if (!isLoggedIn)
                  Container(
                    padding: EdgeInsets.all(16), // Padding around the text for better readability
                    color: Colors.white.withOpacity(0.85), // Slightly transparent white
                    child: Text(
                      'Welcome to Utibu Health! Access menu on top left to login and access your profile, view statements, and order medication.',
                      // textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16, // Slightly larger text for better readability
                        fontWeight: FontWeight.bold, // Bold text to grab attention
                        color: Colors.black, // Text in black for contrast
                      ),
                    ),
                  ),
               ])) // Adjusted space for the background image
          //       GridView.count(
          //         shrinkWrap: true,
          //         physics: NeverScrollableScrollPhysics(), // to disable GridView's scrolling
          //         crossAxisCount: 2,
          //         childAspectRatio: 1 / 1, // Adjusted for smaller cards
          //         crossAxisSpacing: 10, // Space between cards
          //         mainAxisSpacing: 10, // Space between rows
          //         padding: EdgeInsets.all(50), // Padding around the grid
          //         children: <Widget>[
          //           _buildHomeIcon(Icons.add_shopping_cart, 'Order Medication', () => Navigator.pushNamed(context, '/orderMedication')),
          //           _buildHomeIcon(Icons.shopping_cart, 'Cart', () => Navigator.pushNamed(context, '/checkout')),
          //           _buildHomeIcon(Icons.receipt, 'View Statement', () => Navigator.pushNamed(context, '/viewStatement')),
          //           if (isLoggedIn) _buildHomeIcon(Icons.account_circle, 'Profile', () => Navigator.pushNamed(context, '/profile')),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

Widget _buildHomeIcon(IconData icon, String label, VoidCallback onTap) {
  return Card(
    elevation: 4.0,
    child: InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 24.0), // Size reduced from 40.0 to 24.0
          SizedBox(height: 8), // Added some space between the icon and the label
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 14)), // Optionally, adjust font size for the label
        ],
      ),
    ),
  );
}
