/// Modèle météo
/// Représente les informations météo d’une ville
class Weather {

  // Nom de la ville
  final String city;

  // Température actuelle en degrés Celsius
  final double temperature;

  // Description de l’état du temps (ex: nuageux, ensoleillé)
  final String description;

  Weather({
    required this.city,
    required this.temperature,
    required this.description,
  });

  /// Crée un objet Weather à partir d’un JSON
  /// Utilisé lors de la récupération des données depuis l’API météo
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['name'],
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
    );
  }
}
