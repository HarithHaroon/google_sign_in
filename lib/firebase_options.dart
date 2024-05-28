// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'src/shared/environment_variables.dart';

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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDv9uYueBPGJ93Keu6z0gC6tAkw0nv1Z94',
    appId: '1:1026906332851:android:ac00d10c8f09b3de725ac6',
    messagingSenderId: '1026906332851',
    projectId: 'sign-in-e9763',
    storageBucket: 'sign-in-e9763.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDghz1eXpXO6ypsOmQluZK-Og7e65HlyJg',
    appId: '1:1026906332851:ios:6dd2196e7a54e31c725ac6',
    messagingSenderId: '1026906332851',
    projectId: 'sign-in-e9763',
    storageBucket: 'sign-in-e9763.appspot.com',
    androidClientId: '1026906332851-2071edv652i7pjupim1f5dbf5vh0h55j.apps.googleusercontent.com',
    iosClientId: '1026906332851-f8s2o1u48p5mqibt8mp5sh0qblgp5063.apps.googleusercontent.com',
    iosBundleId: 'com.example.googleSignIn',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC8813cFJo-yG89bom_JtQWCp3r43gQgmg',
    appId: '1:1026906332851:web:06fc54c1e5ef5d1e725ac6',
    messagingSenderId: '1026906332851',
    projectId: 'sign-in-e9763',
    authDomain: 'sign-in-e9763.firebaseapp.com',
    storageBucket: 'sign-in-e9763.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDghz1eXpXO6ypsOmQluZK-Og7e65HlyJg',
    appId: '1:1026906332851:ios:6dd2196e7a54e31c725ac6',
    messagingSenderId: '1026906332851',
    projectId: 'sign-in-e9763',
    storageBucket: 'sign-in-e9763.appspot.com',
    androidClientId: '1026906332851-2071edv652i7pjupim1f5dbf5vh0h55j.apps.googleusercontent.com',
    iosClientId: '1026906332851-f8s2o1u48p5mqibt8mp5sh0qblgp5063.apps.googleusercontent.com',
    iosBundleId: 'com.example.googleSignIn',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC8813cFJo-yG89bom_JtQWCp3r43gQgmg',
    appId: '1:1026906332851:web:44648824807e7f37725ac6',
    messagingSenderId: '1026906332851',
    projectId: 'sign-in-e9763',
    authDomain: 'sign-in-e9763.firebaseapp.com',
    storageBucket: 'sign-in-e9763.appspot.com',
  );

}