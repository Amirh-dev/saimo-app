// File generated to configure Firebase for each platform.
//
// Android values come from `android/app/google-services.json`; web values come
// from the Firebase console Web app registration for project `saimo-95714`.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
          'DefaultFirebaseOptions are not configured for '
          '$defaultTargetPlatform. Re-run flutterfire configure to add it.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDYdXaoynjBzipY88t36l1YAXuh-0cmUWA',
    appId: '1:1027951095819:web:1de602e687b5698d7fd70e',
    messagingSenderId: '1027951095819',
    projectId: 'saimo-95714',
    authDomain: 'saimo-95714.firebaseapp.com',
    storageBucket: 'saimo-95714.firebasestorage.app',
    measurementId: 'G-97PTCTEH7W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC4rRbCKcd91RcYVqTAK_3e2A8QrPu1lrE',
    appId: '1:1027951095819:android:9ce0e382351324977fd70e',
    messagingSenderId: '1027951095819',
    projectId: 'saimo-95714',
    storageBucket: 'saimo-95714.firebasestorage.app',
  );
}
