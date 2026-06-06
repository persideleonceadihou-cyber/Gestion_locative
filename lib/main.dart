import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:gestion_locative/mesBiens.dart';
import 'package:gestion_locative/conect.dart';
import 'package:gestion_locative/firebase_options.dart';
import 'package:gestion_locative/propretaire.dart';
import 'package:gestion_locative/locataire.dart';
import 'package:gestion_locative/document.dart';
import 'package:gestion_locative/paiement.dart';
import 'package:gestion_locative/profil.dart';
import 'package:gestion_locative/scan.dart';
import 'package:gestion_locative/PayeCash.dart';
import 'package:gestion_locative/home.dart';
import 'package:gestion_locative/ajoutMaison.dart';
import 'package:gestion_locative/ajout.dart';
import 'package:gestion_locative/Accueil.dart';
import 'package:gestion_locative/tenant_payment_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Intercepter /pay AVANT le flux d'authentification ──
  // Sans ça, Flutter redirige vers #/connect et bloque le locataire.
  if (kIsWeb) {
    usePathUrlStrategy();
    final String url = Uri.base.toString();
    
    // Intercepter toute variante de /pay ou /payer pour éviter la redirection vers la connexion
    if (url.contains('/pay') || url.contains('/payer')) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Paiement Loyer',
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: const Color(0xFF1F6FEB)),
          useMaterial3: true,
        ),
        home: TenantPaymentPage(
          code: Uri.base.queryParameters['code'] ?? '',
        ),
      ));
      return;
    }
  }

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion locative',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color(0xFF1F6FEB)),
        useMaterial3: true,
      ),
      home: const Home(),
      routes: {
        '/connect': (context) => const Connect(),
        '/accueil': (context) => Accueil(userName: "Utilisateur"),
        '/mesBiens': (context) => const MesBiens(),
        '/paiement': (context) => const Paiement(),
        '/document': (context) => const Document(),
        '/profil': (context) => const Profil(),
        '/scan': (context) => const Scan(),
        '/proprietaire': (context) => const Propretaire(),
        '/locataire': (context) => const LocatairesScreen(),
        '/ajout': (context) => const AjoutMaison(),
        '/ajoutLocataire': (context) => const Ajout(),
        '/payeCash': (context) => const PayeCash(),
      },
    );
  }
}
