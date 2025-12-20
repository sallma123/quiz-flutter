import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'weather_service.dart';
import 'weather_model.dart';

final weatherServiceProvider = Provider((ref) {
  return WeatherService();
});

final weatherProvider =
FutureProvider.family<Weather, String>((ref, city) async {
  final service = ref.read(weatherServiceProvider);
  return service.fetchWeather(city);
});
