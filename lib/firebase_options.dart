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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBYWT7L2wcrpMCTPixjRo78Zx-CVt7y0IA',
    appId: '1:56626745106:web:19e99bb3d72717a24c2dcb',
    messagingSenderId: '56626745106',
    projectId: 'sample-firebase-ai-app-g-96d78',
    authDomain: 'sample-firebase-ai-app-g-96d78.firebaseapp.com',
    storageBucket: 'sample-firebase-ai-app-g-96d78.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCYx3zFCVInMFGbBgJp2i4KTnngY059J4o',
    appId: '1:822380501516:android:a0a88f1ff1561b7fc76c29',
    messagingSenderId: '822380501516',
    projectId: 'gestion-locative-3f02c',
    storageBucket: 'gestion-locative-3f02c.firebasestorage.app',
  );
}
