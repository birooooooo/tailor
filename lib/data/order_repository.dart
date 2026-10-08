import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order.dart';
import 'sample_data.dart';

/// Where orders are stored.
///
/// Two implementations exist:
///  * [LocalOrderRepository] — offline-first, saved on the device.
///  * [FirestoreOrderRepository] — cloud, with Firestore's own offline cache.
///
/// The rest of the app only knows this interface, so swapping backends needs
/// no changes in the screens.
abstract class OrderRepository {
  Future<List<Order>> load();

  Future<void> save(List<Order> orders);

  /// The shop id this repository belongs to (used as the Firestore document).
  String get shopId;
}

// ---------------------------------------------------------------- local (offline)

class LocalOrderRepository implements OrderRepository {
  static const String _key = 'orders_v1';

  @override
  String get shopId => 'local-shop';

  @override
  Future<List<Order>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) {
        // First run: seed with the sample shop so the app is not empty.
        final seed = SampleData.orders();
        await save(seed);
        return seed;
      }
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((e) => Order.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    } catch (e) {
      debugPrint('Local load failed, using sample data: $e');
      return SampleData.orders();
    }
  }

  @override
  Future<void> save(List<Order> orders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(orders.map((o) => o.toJson()).toList());
      await prefs.setString(_key, raw);
    } catch (e) {
      debugPrint('Local save failed: $e');
    }
  }
}

// ---------------------------------------------------------------- cloud (Firestore)

class FirestoreOrderRepository implements OrderRepository {
  FirestoreOrderRepository(this.shopId);

  @override
  final String shopId;

  CollectionReference<Map<String, dynamic>> get _orders => FirebaseFirestore
      .instance
      .collection('shops')
      .doc(shopId)
      .collection('orders');

  @override
  Future<List<Order>> load() async {
    // Firestore serves this from its local cache when offline.
    final snap = await _orders.get();
    if (snap.docs.isEmpty) {
      final seed = SampleData.orders();
      await save(seed);
      return seed;
    }
    return snap.docs.map((d) => Order.fromJson(d.data())).toList();
  }

  @override
  Future<void> save(List<Order> orders) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final order in orders) {
      batch.set(_orders.doc(order.id), order.toJson());
    }
    await batch.commit();
  }
}

// ---------------------------------------------------------------- factory

class RepositoryFactory {
  RepositoryFactory._();

  /// Firestore when Firebase is configured, otherwise the offline store.
  static OrderRepository create({String shopId = 'shop1'}) {
    try {
      if (FirebaseServiceAvailable.value) {
        return FirestoreOrderRepository(shopId);
      }
    } catch (_) {
      // Ignore and fall back to local.
    }
    return LocalOrderRepository();
  }
}

/// Tiny holder so the data layer does not need to import firebase_core just to
/// know whether Firebase came up.
class FirebaseServiceAvailable {
  FirebaseServiceAvailable._();

  static bool value = false;
}
