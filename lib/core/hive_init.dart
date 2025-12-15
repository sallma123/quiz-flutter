import 'package:hive_flutter/hive_flutter.dart';
import '../models/question.dart';
import '../models/history_record.dart';

Future<void> initHiveAndSeed() async {
  // =========================
  // Initialisation Hive
  // =========================
  await Hive.initFlutter();

  // =========================
  // Enregistrement des adapters
  // =========================
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(QuestionAdapter());
  }

  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(HistoryRecordAdapter());
  }

  // =========================
  // Ouverture des boxes
  // =========================
  final questionBox = await Hive.openBox<Question>('questions');
  await Hive.openBox<HistoryRecord>('history');

  // =========================
  // Seed des questions (UNE SEULE FOIS)
  // =========================
  if (questionBox.isEmpty) {
    final sample = [
      Question(
        id: 'gen_1',
        categoryId: 'gen',
        text: 'Quelle est la capitale de la France ?',
        options: ['Lyon', 'Marseille', 'Paris', 'Bordeaux'],
        correctIndex: 2,
      ),
      Question(
        id: 'gen_2',
        categoryId: 'gen',
        text: 'Combien de continents existe-t-il ?',
        options: ['5', '6', '7', '8'],
        correctIndex: 2,
      ),
      Question(
        id: 'gen_3',
        categoryId: 'gen',
        text: 'Quel est le plus grand océan du monde ?',
        options: ['Atlantique', 'Indien', 'Arctique', 'Pacifique'],
        correctIndex: 3,
      ),
      Question(
        id: 'gen_4',
        categoryId: 'gen',
        text: 'Quelle est la planète la plus proche du Soleil ?',
        options: ['Mars', 'Vénus', 'Mercure', 'Terre'],
        correctIndex: 2,
      ),
      Question(
        id: 'gen_5',
        categoryId: 'gen',
        text: 'Quel est l\'élément chimique dont le symbole est "O" ?',
        options: ['Ozone', 'Or', 'Oxygène', 'Osmium'],
        correctIndex: 2,
      ),
      Question(
        id: 'gen_6',
        categoryId: 'gen',
        text: 'Combien y a-t-il de minutes dans une heure ?',
        options: ['60', '100', '80', '120'],
        correctIndex: 0,
      ),
      Question(
        id: 'gen_7',
        categoryId: 'gen',
        text: 'Quel pays est surnommé "Le pays du Soleil-Levant" ?',
        options: ['Chine', 'Corée du Sud', 'Japon', 'Thaïlande'],
        correctIndex: 2,
      ),
      Question(
        id: 'gen_8',
        categoryId: 'gen',
        text: 'Quelle est la langue la plus parlée dans le monde ?',
        options: ['Anglais', 'Mandarin', 'Espagnol', 'Hindi'],
        correctIndex: 1,
      ),
      Question(
        id: 'gen_9',
        categoryId: 'gen',
        text: 'Quel est l\'organe principal du système nerveux humain ?',
        options: ['Le cœur', 'Le cerveau', 'Les poumons', 'Le foie'],
        correctIndex: 1,
      ),
      Question(
        id: 'gen_10',
        categoryId: 'gen',
        text: 'Quelle est la capitale de l\'Italie ?',
        options: ['Rome', 'Milan', 'Naples', 'Florence'],
        correctIndex: 0,
      ),
      Question(
        id: 'gen_11',
        categoryId: 'gen',
        text: 'Quelle est la plus longue rivière du monde ?',
        options: ['Nil', 'Amazone', 'Yangtsé', 'Mississippi'],
        correctIndex: 1,
      ),
      Question(
        id: 'gen_12',
        categoryId: 'gen',
        text: 'Quel instrument mesure la température ?',
        options: ['Altimètre', 'Thermomètre', 'Baromètre', 'Hygromètre'],
        correctIndex: 1,
      ),
      Question(
        id: 'gen_13',
        categoryId: 'gen',
        text: 'Combien y a-t-il de jours dans une année bissextile ?',
        options: ['365', '366', '364', '360'],
        correctIndex: 1,
      ),
      Question(
        id: 'gen_14',
        categoryId: 'gen',
        text: 'Quelle est la monnaie officielle du Japon ?',
        options: ['Dollar', 'Euro', 'Yen', 'Won'],
        correctIndex: 2,
      ),
      Question(
        id: 'gen_15',
        categoryId: 'gen',
        text: 'Quel est l\'animal terrestre le plus rapide ?',
        options: ['Antilope', 'Guépard', 'Lion', 'Léopard'],
        correctIndex: 1,
      ),
      Question(
        id: 'gen_16',
        categoryId: 'gen',
        text: 'Quelle mer borde la France au sud ?',
        options: [
          'Mer du Nord',
          'Océan Atlantique',
          'Mer Méditerranée',
          'Mer Baltique'
        ],
        correctIndex: 2,
      ),
      Question(
        id: 'gen_17',
        categoryId: 'gen',
        text: 'Quel est le symbole chimique du Fer ?',
        options: ['Fe', 'Ir', 'F', 'Fa'],
        correctIndex: 0,
      ),
      Question(
        id: 'sport_1',
        categoryId: 'sport',
        text: 'Combien de joueurs par équipe au football ?',
        options: ['9', '10', '11', '12'],
        correctIndex: 2,
      ),
      Question(
        id: 'myth_1',
        categoryId: 'myth',
        text: 'Quel dieu grec est le roi des dieux ?',
        options: ['Hadès', 'Poséidon', 'Zeus', 'Hermès'],
        correctIndex: 2,
      ),
    ];

    for (final q in sample) {
      await questionBox.put(q.id, q);
    }

    print("Questions initialisées dans Hive ✔️");
  }

  print("Hive prêt : questions + historique ✔️");
}
