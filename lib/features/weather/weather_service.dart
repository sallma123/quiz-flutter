import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_model.dart';

class WeatherService {
  // ✅ Clé API OpenWeather
  static const String _apiKey = 'ecd9a22ca89fc0b7ca2a6e517bac6dec';

  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<Weather> fetchWeather(String city) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?q=$city&units=metric&lang=fr&appid=$_apiKey',
      );

      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));

      // ✅ Succès
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Weather.fromJson(data);
      }

      // ❌ Erreurs connues
      if (response.statusCode == 401) {
        throw Exception('Clé API invalide');
      }

      if (response.statusCode == 404) {
        throw Exception('Ville introuvable');
      }

      // ❌ Autres erreurs serveur
      throw Exception(
        'Erreur serveur (${response.statusCode})',
      );
    } catch (e) {
      // ❌ Timeout / Pas d’internet
      throw Exception('Connexion réseau impossible');
    }
  }
}
