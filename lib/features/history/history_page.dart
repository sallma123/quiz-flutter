import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: const Center(
        child: Text(
          "Aucun quiz passé pour le moment.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
