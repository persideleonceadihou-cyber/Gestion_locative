import 'package:flutter/material.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String? _scanLabel;

  void _startScan() {
    final now = DateTime.now();
    final label =
        'Dossier scanné le ${now.day}/${now.month}/${now.year} à ${now.hour}:${now.minute}';

    setState(() {
      _scanLabel = label;
    });

    // Affiche un message en bas de l’écran
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scan du dossier terminé.'),
        duration: Duration(seconds: 2),
      ),
    );

    // Renvoie le résultat à la page précédente si besoin
    Navigator.pop(context, label);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text("Scanner un dossier"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _startScan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Lancer le scan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FA3D9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_scanLabel != null)
              Text(
                _scanLabel!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF132238),
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
