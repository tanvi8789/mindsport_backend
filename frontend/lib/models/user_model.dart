class User {
  final String id;
  final String name;
  final String email;
  final String? sport;
  final int? age;
  final String? gender;
  final int? height;
  final int? weight;
  final List<String> wellnessGoals; // <--- NEW FIELD

  User({
    required this.id,
    required this.name,
    required this.email,
    this.sport,
    this.age,
    this.gender,
    this.height,
    this.weight,
    required this.wellnessGoals, // <--- NEW
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      sport: json['sport'],
      age: json['age'],
      gender: json['gender'],
      height: json['height'],
      weight: json['weight'],
      // JSON lists need to be explicitly cast to List<String> in Dart
      wellnessGoals: json['wellnessGoals'] != null
          ? List<String>.from(json['wellnessGoals'])
          : [],
    );
  }
}