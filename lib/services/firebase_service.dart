import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../data/order_repository.dart';

/// Starts Firebase if the app has been configured for it.
///
/// If there is no `google-services.json` yet, this fails quietly and the app
/// keeps working **offline** with [LocalOrderRepository]. Add the file later
/// and the app switches to Firestore automatically — no code change needed.
class FirebaseService {
  FirebaseService._();

  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      FirebaseServiceAvailable.value = true;

      // Offline-first: Firestore keeps a local cache and syncs automatically
      // when the phone gets internet again.
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      debugPrint('Firebase ready — Firestore with offline cache.');
    } catch (e) {
      FirebaseServiceAvailable.value = false;
      debugPrint('Firebase not configured — running offline only. ($e)');
    }
  }
}
