
class Unadmitted {
  final String id; // Add the ID field
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String imageUrl;

  Unadmitted({
    required this.id, // Make sure to pass this in the constructor
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.imageUrl,
  });

  factory Unadmitted.fromJson(Map<String, dynamic> json) {
    return Unadmitted(
      id: json['_id'] ?? '', // Parse the ID from the response
      firstName: json['firstname'] ?? '',
      lastName: json['lastname'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}