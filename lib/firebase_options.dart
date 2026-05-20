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
    apiKey: 'AIzaSyBzEBhfUA5ZSPoNd2dYJP7AqBTbgSGYfDw',
    appId: '1:367212598540:web:c0a2351bf6cb3d293ee529',
    messagingSenderId: '367212598540',
    projectId: 'antreyuk-7738f',
    authDomain: 'antreyuk-7738f.firebaseapp.com',
    storageBucket: 'antreyuk-7738f.firebasestorage.app',
    databaseURL:
        'https://antreyuk-7738f-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzEBhfUA5ZSPoNd2dYJP7AqBTbgSGYfDw',
    appId: '1:367212598540:android:c80baeafdc58b3e23ee529',
    messagingSenderId: '367212598540',
    projectId: 'antreyuk-7738f',
    storageBucket: 'antreyuk-7738f.firebasestorage.app',
    databaseURL:
        'https://antreyuk-7738f-default-rtdb.asia-southeast1.firebasedatabase.app',
  );
}
