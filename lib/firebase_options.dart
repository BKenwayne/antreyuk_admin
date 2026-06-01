import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBVjFU_i0sGAZrVnlXNcFUOa16TnwJlliw',
    appId: '1:702321637397:web:929e8781b274842ed3761c',
    messagingSenderId: '702321637397',
    projectId: 'antreyuk-54847',
    authDomain: 'antreyuk-54847.firebaseapp.com',
    storageBucket: 'antreyuk-54847.firebasestorage.app',
    databaseURL:
        'https://antreyuk-54847-default-rtdb.asia-southeast1.firebasedatabase.app/',
    measurementId: 'G-FPZK6PRPHL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBVjFU_i0sGAZrVnlXNcFUOa16TnwJlliw',
    appId: '1:702321637397:android:dee89d12a43006b9d3761c',
    messagingSenderId: '702321637397',
    projectId: 'antreyuk-54847',
    storageBucket: 'antreyuk-54847.firebasestorage.app',
    databaseURL:
        'https://antreyuk-54847-default-rtdb.asia-southeast1.firebasedatabase.app',
  );
}
