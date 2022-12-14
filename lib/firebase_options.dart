// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB4mdf7f__aHGVJVg_00nMftnLJDwhSNcY',
    appId: '1:221735996752:web:5fa33e83ec2fe167b23055',
    messagingSenderId: '221735996752',
    projectId: 'paperless-v2-aa89b',
    authDomain: 'paperless-v2-aa89b.firebaseapp.com',
    storageBucket: 'paperless-v2-aa89b.appspot.com',
    measurementId: 'G-7B7RKW0G31',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAR49vp4ob01ypGKPtFAPPb5cnqBkW8TG4',
    appId: '1:221735996752:android:65c8cf6913de2338b23055',
    messagingSenderId: '221735996752',
    projectId: 'paperless-v2-aa89b',
    storageBucket: 'paperless-v2-aa89b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA2Hpg3F_wvW-VturxIZocJkp8kmoeic7I',
    appId: '1:221735996752:ios:15d10f40d924b71fb23055',
    messagingSenderId: '221735996752',
    projectId: 'paperless-v2-aa89b',
    storageBucket: 'paperless-v2-aa89b.appspot.com',
    iosClientId: '221735996752-ogteriachmdr77f1df28jph9orcng1u9.apps.googleusercontent.com',
    iosBundleId: 'com.example.testApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA2Hpg3F_wvW-VturxIZocJkp8kmoeic7I',
    appId: '1:221735996752:ios:15d10f40d924b71fb23055',
    messagingSenderId: '221735996752',
    projectId: 'paperless-v2-aa89b',
    storageBucket: 'paperless-v2-aa89b.appspot.com',
    iosClientId: '221735996752-ogteriachmdr77f1df28jph9orcng1u9.apps.googleusercontent.com',
    iosBundleId: 'com.example.testApp',
  );
}
