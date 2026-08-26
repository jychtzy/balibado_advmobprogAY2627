import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserService {
  static const String _userKey = 'user';
  static const String _loginUrl = 'https://dummyjson.com/auth/login';

  Future<User> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(_loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Invalid username or password.');
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    final user = User.fromJson(json);

    // Persist immediately so ProfileScreen's getUser() can find it.
    await saveUser(user);

    return user;
  }

  Future<User> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) {
      throw Exception('No user data found in storage.');
    }
    final Map<String, dynamic> map = jsonDecode(userJson);
    return User.fromJson(map);
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    // remove any auth token keys here too, if you store them separately
  }
}