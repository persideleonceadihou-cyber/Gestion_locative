import 'package:flutter/material.dart';
import 'package:gestion_locative/app_background.dart';

class Scan extends StatelessWidget {
  const Scan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Scanner un dossier',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.document_scanner_outlined,
                        color: Color(0xFF1F6FEB),
                        size: 56,
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Scanner indisponible sur Web',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF132238),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Le scanner de documents utilise la camera native du telephone. Ouvrez cette page depuis l\'application mobile pour numeriser un dossier.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF526072), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
