import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../data/sample_data.dart';
import '../models/order.dart';

/// Holds the shop's orders and customers.
///
/// Right now it is backed by in-memory sample data. Later this class will talk
/// to Firestore instead — the screens will not need to change.
class OrdersProvider extends ChangeNotifier {
  OrdersProvider() : _orders = SampleData.orders();

  final List<Order> _orders;

  List<Order> get orders => List.unmodifiable(_orders);

  List<Order> get activeOrders =>
      _orders.where((o) => o.status.isActive).toList();

  int get activeCount => activeOrders.length;

  /// Income collected in the current month.
  int get monthlyIncome {
    final now = DateTime.now();
    return _orders
        .expand((o) => o.payments)
        .where((p) => p.date.year == now.year && p.date.month == now.month)
        .fold(0, (sum, p) => sum + p.amount);
  }

  int get returnsCount =>
      _orders.where((o) => o.status == OrderStatus.cancelled).length;

  /// Active orders whose delivery date is today.
  int get dueToday {
    final now = DateTime.now();
    return _orders.where((o) {
      return o.status.isActive &&
          o.dueDate.year == now.year &&
          o.dueDate.month == now.month &&
          o.dueDate.day == now.day;
    }).length;
  }

  /// Distinct customers, newest order first.
  List<Customer> get customers {
    final seen = <String, Customer>{};
    for (final o in _orders) {
      seen[o.customer.id] = o.customer;
    }
    return seen.values.toList();
  }

  int ordersForCustomer(String customerId) =>
      _orders.where((o) => o.customer.id == customerId).length;

  Order? byId(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  List<Order> byStatus(OrderStatus? status) {
    if (status == null) return orders;
    return _orders.where((o) => o.status == status).toList();
  }

  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void updateStatus(String id, OrderStatus status) {
    final i = _indexOf(id);
    if (i == -1) return;
    _orders[i] = _orders[i].copyWith(status: status);
    notifyListeners();
  }

  /// Moves an order one stage forward (used by swipe-to-advance).
  void advanceStatus(String id) {
    final order = byId(id);
    if (order == null || !order.status.isActive) return;
    final i = orderFlow.indexOf(order.status);
    if (i < 0 || i >= orderFlow.length - 1) return;
    updateStatus(id, orderFlow[i + 1]);
  }

  void addPayment(String id, int amount) {
    final i = _indexOf(id);
    if (i == -1) return;
    final order = _orders[i];
    _orders[i] = order.copyWith(
      payments: [
        ...order.payments,
        Payment(amount: amount, date: DateTime.now()),
      ],
    );
    notifyListeners();
  }

  void addNote(String id, String text) {
    final i = _indexOf(id);
    if (i == -1) return;
    final order = _orders[i];
    _orders[i] = order.copyWith(
      notes: [
        ...order.notes,
        OrderNote(text: text, date: DateTime.now()),
      ],
    );
    notifyListeners();
  }

  String nextOrderId() {
    int max = 1000;
    for (final o in _orders) {
      final n = int.tryParse(o.id);
      if (n != null && n > max) max = n;
    }
    return (max + 1).toString();
  }

  int _indexOf(String id) => _orders.indexWhere((o) => o.id == id);
}
