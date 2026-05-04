import 'package:flutter/material.dart';

class Propretaire extends StatelessWidget {
  const Propretaire({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Proprietes",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  "Liste des proprietes",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text("Nouvelle propriete"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildMaterialCard("Propriete 1", "Adresse 1", "Description 1"),
            buildMaterialCard("Propriete 2", "Adresse 2", "Description 2"),
            buildMaterialCard("Propriete 3", "Adresse 3", "Description 3"),
            buildMaterialCard("Propriete 4", "Adresse 4", "Description 4"),
            buildMaterialCard("Propriete 5", "Adresse 5", "Description 5"),
          ],
        ),
      ),
    );
  }
}

Widget buildMaterialCard(String title, String address, String description) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(address),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            child: const Text("Voir les details"),
          ),
        ],
      ),
    ),
  );
}
