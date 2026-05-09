// File generated based on Firebase project: thinktwice-kamihack
// Platform: Web only (Chrome testing)

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError('Android Firebase config not set up yet.');
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS Firebase config not set up yet.');
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS Firebase config not set up yet.');
      case TargetPlatform.windows:
        return web; // reuse web config for Windows desktop testing
      case TargetPlatform.linux:
        throw UnsupportedError('Linux Firebase config not set up yet.');
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC_a5mg2xY8Q3ngtQ3WMkE-lmIpfWCsYAo',
    authDomain: 'thinktwice-kamihack.firebaseapp.com',
    projectId: 'thinktwice-kamihack',
    storageBucket: 'thinktwice-kamihack.firebasestorage.app',
    messagingSenderId: '544887428499',
    appId: '1:544887428499:web:5cc3d4abd0946092f94466',
    measurementId: 'G-049399JY1L',
  );
}
