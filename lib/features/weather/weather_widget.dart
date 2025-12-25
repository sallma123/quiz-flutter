import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'weather_provider.dart';

/// Widget météo
/// Affiche la météo actuelle d’une ville en utilisant Riverpod
class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // Récupération de la météo de la ville de Rabat
    final weatherAsync = ref.watch(weatherProvider('Rabat'));

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return weatherAsync.when(

      // Affichage pendant le chargement des données
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(),
        ),
      ),

      // Affichage en cas d’erreur (problème réseau ou API)
      error: (err, _) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: colors.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Erreur météo : $err',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: colors.error),
                ),
              ),
            ],
          ),
        ),
      ),

      // Affichage des données météo lorsque la requête réussit
      data: (weather) => Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [

              // Icône représentant la météo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withOpacity(0.12),
                ),
                child: Icon(
                  Icons.cloud,
                  color: colors.primary,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // Informations de la ville et description du temps
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.city,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Température actuelle
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${weather.temperature.toStringAsFixed(1)}°C',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Actuel',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
