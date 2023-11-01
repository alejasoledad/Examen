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
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBbzf-mOfKkSNeomG1SNKnrkOe4CuQlEzY',
    appId: '1:952309437787:web:eadd66f8ae74378d4c367e',
    messagingSenderId: '952309437787',
    projectId: 'flutterapp-b9384',
    authDomain: 'flutterapp-b9384.firebaseapp.com',
    databaseURL: 'https://flutterapp-b9384-default-rtdb.firebaseio.com',
    storageBucket: 'flutterapp-b9384.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCANcz1MJvhoApLmFKVqnWBS_WFsCz49Oc',
    appId: '1:952309437787:android:161f9b48ad93bc274c367e',
    messagingSenderId: '952309437787',
    projectId: 'flutterapp-b9384',
    databaseURL: 'https://flutterapp-b9384-default-rtdb.firebaseio.com',
    storageBucket: 'flutterapp-b9384.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDrfMF-Bvx-NoGLvGbKRj0aoKuPsoNLZWk',
    appId: '1:952309437787:ios:3df3c9d12043e76a4c367e',
    messagingSenderId: '952309437787',
    projectId: 'flutterapp-b9384',
    databaseURL: 'https://flutterapp-b9384-default-rtdb.firebaseio.com',
    storageBucket: 'flutterapp-b9384.appspot.com',
    iosBundleId: 'com.appflutter.crudFirebase',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDrfMF-Bvx-NoGLvGbKRj0aoKuPsoNLZWk',
    appId: '1:952309437787:ios:5f9c4dc981d0f9f14c367e',
    messagingSenderId: '952309437787',
    projectId: 'flutterapp-b9384',
    databaseURL: 'https://flutterapp-b9384-default-rtdb.firebaseio.com',
    storageBucket: 'flutterapp-b9384.appspot.com',
    iosBundleId: 'com.appflutter.crudFirebase.RunnerTests',
  );
}