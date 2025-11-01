// A simple model class to hold our user data.
// This matches the 'user' object your backend sends on login.
class User {
  final String id;
  final String name;
  final String email;
  final String? sport;
  final int? age;
  final String? gender;
  final int? height; // <-- ADD THIS
  final int? weight;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.sport,
    this.age,
    this.gender,
    this.height,
    this.weight
  });

  // A 'factory constructor' to create a User from the JSON
  // map we get from the server.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'], // Your server might send '_id'
      name: json['name'],
      email: json['email'],
      sport: json['sport'],
      age: json['age'],
      gender: json['gender'],
    );
  }
}

