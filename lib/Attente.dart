import 'package:flutter/material.dart';

class Attente extends StatefulWidget {
  const Attente({super.key});

  @override
  State<Attente> createState() => _AttenteState();
}

class _AttenteState extends State<Attente> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("En Attente"),
          ],
        ),
      ),
    );
  }
}
