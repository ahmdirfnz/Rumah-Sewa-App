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
    apiKey: 'AIzaSyDqIwTg3gLbrnIrOIwLMNdQmt4xk_DbFDg',
    appId: '1:725715994778:web:5b1c6f551e2b1643887723',
    messagingSenderId: '725715994778',
    projectId: 'rumah-sewa-c48b2',
    authDomain: 'rumah-sewa-c48b2.firebaseapp.com',
    storageBucket: 'rumah-sewa-c48b2.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCp7BBViDYR_XAnDuxDMZj4FH228t1K8jE',
    appId: '1:725715994778:android:e83a850b36a630d9887723',
    messagingSenderId: '725715994778',
    projectId: 'rumah-sewa-c48b2',
    storageBucket: 'rumah-sewa-c48b2.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCHoge2FasszgUdXgMvzWvZ2enFx5k06_w',
    appId: '1:725715994778:ios:1f6edc7a13302f13887723',
    messagingSenderId: '725715994778',
    projectId: 'rumah-sewa-c48b2',
    storageBucket: 'rumah-sewa-c48b2.appspot.com',
    iosBundleId: 'com.example.rumahSewaApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCHoge2FasszgUdXgMvzWvZ2enFx5k06_w',
    appId: '1:725715994778:ios:eec9ca148fad2dfd887723',
    messagingSenderId: '725715994778',
    projectId: 'rumah-sewa-c48b2',
    storageBucket: 'rumah-sewa-c48b2.appspot.com',
    iosBundleId: 'com.example.rumahSewaApp.RunnerTests',
  );
}