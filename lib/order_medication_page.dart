import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/medicationprovider.dart'; // Import your MedicationProvider
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/medicationmodel.dart';
import 'addtocart.dart';

class OrderMedicationPage extends StatefulWidget {
  @override
  _OrderMedicationPageState createState() => _OrderMedicationPageState();
}

class _OrderMedicationPageState extends State<OrderMedicationPage> {
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<MedicationProvider>(context, listen: false)
            .fetchMedications()
    );
  }


  @override
  Widget build(BuildContext context) {
    final medicationProvider = Provider.of<MedicationProvider>(context);
    // Display a loading indicator if data is still being fetched
    if (medicationProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Order Medication"),
        ),
        body: Center(child: CircularProgressIndicator()), // Show loading indicator
      );
    }
    final displayedMedications = _searchTerm.isEmpty
        ? medicationProvider.medications
        : medicationProvider.medications.where((med) => med.name.toLowerCase().contains(_searchTerm.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Order Medication"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
              showSearch(context: context, delegate: MedicationSearch(medications: medicationProvider.medications));
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: displayedMedications.length,
        itemBuilder: (ctx, i) {
          final medication = displayedMedications[i]; // Reference to the medication
          return ListTile(
            title: Text(medication.name),
            subtitle: Text(medication.description),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(medication.name),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text("Description: ${medication.description}"),
                          Text("Dosage: ${medication.dosage}"),
                          Text("Price: \$${medication.price.toString()}"),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Add to Cart'),
                        onPressed: () {
                          // Implement Add to Cart functionality
                          // For example, navigate to an AddToCartPage
                          Navigator.of(context).pop(); // Close the dialog before navigating
                          // Navigate or add to cart logic here
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AddToCartPage(medication: medication)));
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class MedicationSearch extends SearchDelegate<Medication?> {
  final List<Medication> medications;

  MedicationSearch({required this.medications});

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: Icon(Icons.clear),
      onPressed: () => query = '',
    ),
  ];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? medications
        : medications.where((med) => med.name.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          title: Text(suggestion.name),
          subtitle: Text(suggestion.description),
            // Inside MedicationSearch buildSuggestions:
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(suggestion.name),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: [
                        Text("Dosage: ${suggestion.dosage}"),
                        Text("Price: \$${suggestion.price}"),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddToCartPage(medication: suggestion),
                          ),
                        );
                      },
                      child: Text('Add to Cart'),
                    ),
                  ],
                ),
              );
            }

        );
      },
    );
  }
}