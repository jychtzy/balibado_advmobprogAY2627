class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String accessToken;
  final String refreshToken;
  final String phone;
  final String address;
  final String city;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    required this.accessToken,
    required this.refreshToken,
    this.phone = '',
    this.address = '',
    this.city = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // dummyjson's /users/{id} nests street + city under "address": { "address": { "address": "1745 T Street...", "city": "..." } }
    final addressJson = json['address'] is Map
        ? json['address'] as Map<String, dynamic>
        : null;

    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      gender: json['gender'] ?? '',
      image: json['image'] ?? '',
      accessToken: json['accessToken'] ?? json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      phone: json['phone'] ?? '',
      // When reading from SharedPreferences, json['streetAddress'] is a flat key. When reading from the live API response, json['address'] is a nested map with its own 'address' field.
      address: json['streetAddress'] ?? addressJson?['address'] ?? '',
      city: json['city'] ?? addressJson?['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'phone': phone,
      'streetAddress': address,
      'city': city,
    };
  }
}