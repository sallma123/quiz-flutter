import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'weather_provider.dart';

class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider('Rabat'));

    return weatherAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, _) => Text(
        'Erreur météo : $err',
        style: const TextStyle(color: Colors.red),
      ),
      data: (weather) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: const Icon(Icons.cloud),
          title: Text(weather.city),
          subtitle: Text(weather.description),
          trailing: Text(
            '${weather.temperature.toStringAsFixed(1)} °C',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
