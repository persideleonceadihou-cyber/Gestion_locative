import 'dart:async';

import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/connect');
      }
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color:Color(0xFFFFF3E0),),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white),
                  ),
                  child: Image.asset(
                    'assets/images/logo (2).png',
                    width: 64,
                    height: 64,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.home_work_outlined,
                        size: 48,
                        color: Color(0xFF132238),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Gestion locative',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Suivez vos locataires, vos paiements, vos contrats et vos documents dans une seule application claire.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFDDEAF8),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
