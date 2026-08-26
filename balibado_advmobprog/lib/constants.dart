import 'package:flutter_dotenv/flutter_dotenv.dart';

var host = dotenv.env['HOST'];

String get apiBase =>
    (host ?? 'https://dummyjson.com/products').replaceFirst('/products', '');

// No longer a hardcoded constant - this gets updated to the real logged-in user's id after splash_screen or signin_screen confirms authentication.
int currentUserId = 1;