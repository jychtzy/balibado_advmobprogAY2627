class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String phone;
  final String address;
  final String city;
  final String password;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    required this.address,
    required this.city,
    required this.phone,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final addressField = json['address'];
    final String streetAddress = (addressField is Map)
        ? (addressField['address'] ?? '')
        : (addressField is String ? addressField : '');
    final String cityValue = (addressField is Map)
        ? (addressField['city'] ?? '')
        : (json['city'] ?? '');

    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      image: json['image'] ?? '',
      address: streetAddress,
      city: cityValue,
      phone: json['phone'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': gender,
      'image': image,
      'address': address,
      'city': city,
      'phone': phone,
      'password': password,
    };
  }

  static User sample() {
    return sampleUsers().first;
  }

  static List<User> sampleUsers() {
    return [
      User(
        id: 1,
        username: 'emilys',
        email: 'emily.johnson@x.dummyjson.com',
        firstName: 'Emily',
        lastName: 'Johnson',
        gender: 'female',
        image: 'https://dummyjson.com/icon/emilys/128',
        address: '626 Main Street',
        city: 'Phoenix',
        phone: '+81 965-431-3024',
        password: 'emilyspass',
      ),
      User(
        id: 2,
        username: 'michaelw',
        email: 'michael.williams@x.dummyjson.com',
        firstName: 'Michael',
        lastName: 'Williams',
        gender: 'male',
        image: 'https://dummyjson.com/icon/michaelw/128',
        address: '385 Fifth Street',
        city: 'Houston',
        phone: '+49 258-627-6644',
        password: 'michaelwpass',
      ),
      User(
        id: 3,
        username: 'sophiab',
        email: 'sophia.brown@x.dummyjson.com',
        firstName: 'Sophia',
        lastName: 'Brown',
        gender: 'female',
        image: 'https://dummyjson.com/icon/sophiab/128',
        address: '1642 Ninth Street',
        city: 'Washington',
        phone: '+81 210-652-2785',
        password: 'sophiabpass',
      ),
      User(
        id: 4,
        username: 'jamesd',
        email: 'james.davis@x.dummyjson.com',
        firstName: 'James',
        lastName: 'Davis',
        gender: 'male',
        image: 'https://dummyjson.com/icon/jamesd/128',
        address: '238 Jefferson Street',
        city: 'Seattle',
        phone: '+49 614-958-9364',
        password: 'jamesdpass',
      ),
      User(
        id: 5,
        username: 'emmaj',
        email: 'emma.miller@x.dummyjson.com',
        firstName: 'Emma',
        lastName: 'Miller',
        gender: 'female',
        image: 'https://dummyjson.com/icon/emmaj/128',
        address: '607 Fourth Street',
        city: 'Jacksonville',
        phone: '+91 759-776-1614',
        password: 'emmajpass',
      ),
      User(
        id: 6,
        username: 'oliviaw',
        email: 'olivia.wilson@x.dummyjson.com',
        firstName: 'Olivia',
        lastName: 'Wilson',
        gender: 'female',
        image: 'https://dummyjson.com/icon/oliviaw/128',
        address: '547 First Street',
        city: 'Fort Worth',
        phone: '+91 607-295-6448',
        password: 'oliviawpass',
      ),
      User(
        id: 7,
        username: 'alexanderj',
        email: 'alexander.jones@x.dummyjson.com',
        firstName: 'Alexander',
        lastName: 'Jones',
        gender: 'male',
        image: 'https://dummyjson.com/icon/alexanderj/128',
        address: '664 Maple Street',
        city: 'Indianapolis',
        phone: '+61 260-824-4986',
        password: 'alexanderjpass',
      ),
      User(
        id: 8,
        username: 'avat',
        email: 'ava.taylor@x.dummyjson.com',
        firstName: 'Ava',
        lastName: 'Taylor',
        gender: 'female',
        image: 'https://dummyjson.com/icon/avat/128',
        address: '1197 First Street',
        city: 'Fort Worth',
        phone: '+1 458-853-7877',
        password: 'avatpass',
      ),
      User(
        id: 9,
        username: 'ethanm',
        email: 'ethan.martinez@x.dummyjson.com',
        firstName: 'Ethan',
        lastName: 'Martinez',
        gender: 'male',
        image: 'https://dummyjson.com/icon/ethanm/128',
        address: '466 Pine Street',
        city: 'San Antonio',
        phone: '+92 933-608-5081',
        password: 'ethanmpass',
      ),
      User(
        id: 10,
        username: 'isabellad',
        email: 'isabella.anderson@x.dummyjson.com',
        firstName: 'Isabella',
        lastName: 'Anderson',
        gender: 'female',
        image: 'https://dummyjson.com/icon/isabellad/128',
        address: '1964 Oak Street',
        city: 'New York',
        phone: '+49 770-658-4885',
        password: 'isabelladpass',
      ),
    ];
  }
}