// Copy this file to firebase_options.dart and fill in your values.
// Get them from Firebase Console → Project settings → Your apps (Web).
// Do NOT commit firebase_options.dart — it is in .gitignore.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class FirebaseOptionsConfig {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    authDomain: 'YOUR_PROJECT.firebaseapp.com',
    databaseURL: 'https://YOUR_PROJECT.firebaseio.com',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT.appspot.com',
    messagingSenderId: 'YOUR_SENDER_ID',
    appId: 'YOUR_APP_ID',
    measurementId: 'YOUR_MEASUREMENT_ID',
  );
}
