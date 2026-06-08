import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDpq3esF8ij4SH4Whdeo3e6qBgioOHjKII',
    appId: '1:1099273148171:web:3f45105101ce51bf54f40e',
    messagingSenderId: '1099273148171',
    projectId: 'gest-loca',
    authDomain: 'gest-loca.firebaseapp.com',
    storageBucket: 'gest-loca.firebasestorage.app',
    measurementId: 'G-9P4BPP29X0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVedsXphE_AgIkjxWFlkK6YK1wmwxLMP8',
    appId: '1:1099273148171:android:03c39426ccc8d58554f40e',
    messagingSenderId: '1099273148171',
    projectId: 'gest-loca',
    storageBucket: 'gest-loca.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDb8IXqJ1p5fbiqGbW-mmibquP49amx6pA',
    appId: '1:1099273148171:ios:38239a5e87a5c13854f40e',
    messagingSenderId: '1099273148171',
    projectId: 'gest-loca',
    storageBucket: 'gest-loca.firebasestorage.app',
    iosBundleId: 'com.example.gestionLocative',
  );
}
