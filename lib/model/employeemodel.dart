class Employeemodel {
  final String firstname;
  final String lastname;
   final String email;
  final String phoneNumber;
  final String imageUrl;

  Employeemodel({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phoneNumber,
    required this.imageUrl,
  });

  // Factory method to create Employeemodel from JSON
  factory Employeemodel.fromJson(Map<String, dynamic> json) {
    return Employeemodel(
      firstname: json['firstname'] ?? '', // Default to an empty string
      lastname: json['lastname'] ?? '',  // Default to an empty string
       email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
