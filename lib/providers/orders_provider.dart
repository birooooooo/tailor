import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../data/order_repository.dart';
import '../models/order.dart';

/// Holds the shop's orders and customers.
///
/// It talks to an [OrderRepository] — either the offline local store or
/// Firestore — so the screens never care where the data lives.
class OrdersProvider extends ChangeNotifier {
  OrdersProvider([OrderRepository? repository])
    : _repo = repository ?? RepositoryFactory.create() {
    _load();
  }

  final OrderRepository _repo;

  List<Order> _orders = const [];
  bool _loading = true;

  bool get isLoading => _loading;
  String get shopId => _repo.shopId;

  Future<void> _load() async {
    _orders = await _repo.load();
    _loading = false;
    notifyListeners();
  }

  /// Fire-and-forget save. Firestore queues writes while offline and syncs
  /// them when the connection returns.
  void _persist() {
    _repo.save(_orders);
  }

  List<Order> get orders => List.unmodifiable(_orders);

  List<Order> get activeOrders =>
      _orders.where((o) => o.status.isActive).toList();

  int get activeCount => activeOrders.length;

  /// Orders waiting for the shop to accept them.
  List<Order> get pendingOrders =>
      _orders.where((o) => o.status == OrderStatus.pending).toList();

  int get pendingCount => pendingOrders.length;

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
    _orders = [order, ..._orders];
    _persist();
    notifyListeners();
  }

  void updateStatus(String id, OrderStatus status) {
    final i = _indexOf(id);
    if (i == -1) return;
    _orders = [..._orders]..[i] = _orders[i].copyWith(status: status);
    _persist();
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
    _orders = [..._orders]
      ..[i] = order.copyWith(
        payments: [
          ...order.payments,
          Payment(amount: amount, date: DateTime.now()),
        ],
      );
    _persist();
    notifyListeners();
  }

  void addNote(String id, String text) {
    final i = _indexOf(id);
    if (i == -1) return;
    final order = _orders[i];
    _orders = [..._orders]
      ..[i] = order.copyWith(
        notes: [
          ...order.notes,
          OrderNote(text: text, date: DateTime.now()),
        ],
      );
    _persist();
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
