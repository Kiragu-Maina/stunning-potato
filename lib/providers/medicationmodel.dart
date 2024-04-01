class Medication {
  final String id;
  final String name;
  final String description;
  final String dosage;
  final double price;

  Medication({
    required this.id,
    required this.name,
    required this.description,
    required this.dosage,
    required this.price,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      dosage: json['dosage'],
      // Use double.parse to convert string to double
      price: double.parse(json['price'].toString()),
    );
  }

}

