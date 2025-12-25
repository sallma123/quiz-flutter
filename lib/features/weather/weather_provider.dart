import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'weather_service.dart';
import 'weather_model.dart';

/// Provider du service météo
/// Permet d’accéder à la classe WeatherService dans toute l’application
final weatherServiceProvider = Provider((ref) {
  return WeatherService();
});

/// Provider asynchrone de la météo
/// Récupère les informations météo d’une ville donnée
final weatherProvider =
FutureProvider.family<Weather, String>((ref, city) async {

  // Récupération du service météo
  final service = ref.read(weatherServiceProvider);

  // Appel de l’API pour obtenir la météo de la ville
  return service.fetchWeather(city);
});
