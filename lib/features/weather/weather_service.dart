import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_model.dart';

/// Service météo
/// Gère la communication avec l’API OpenWeather
class WeatherService {

  // Clé API OpenWeather (utilisée pour l’authentification)
  static const String _apiKey = 'ecd9a22ca89fc0b7ca2a6e517bac6dec';

  // URL de base de l’API météo
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  /// Récupère la météo d’une ville donnée
  /// Retourne un objet Weather
  Future<Weather> fetchWeather(String city) async {
    try {

      // Construction de l’URL avec les paramètres nécessaires
      final uri = Uri.parse(
        '$_baseUrl?q=$city&units=metric&lang=fr&appid=$_apiKey',
      );

      // Appel HTTP avec un délai maximum de 10 secondes
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));

      // Si la requête a réussi
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Weather.fromJson(data);
      }

      // Erreur d’authentification (clé API incorrecte)
      if (response.statusCode == 401) {
        throw Exception('Clé API invalide');
      }

      // Ville non trouvée
      if (response.statusCode == 404) {
        throw Exception('Ville introuvable');
      }

      // Autres erreurs côté serveur
      throw Exception(
        'Erreur serveur (${response.statusCode})',
      );
    } catch (e) {
      // Erreur réseau : pas d’internet ou délai dépassé
      throw Exception('Connexion réseau impossible');
    }
  }
}
