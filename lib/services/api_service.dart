import 'package:flutter_dotenv/flutter_dotenv.dart';

class APIService {
  APIService._instantiate();
  static final APIService instance = APIService._instantiate();
  static const String _baseUrl = 'https://api.spoonacular.com';
  final String apiKey = dotenv.env['SPOONACULAR_API_KEY']!;
}
