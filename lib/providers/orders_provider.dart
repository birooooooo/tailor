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

  OrderRepository _repo;

  /// Switches the data source to the given shop (called after login).
  void useShop(String shopId) {
    if (!FirebaseServiceAvailable.value || _repo.shopId == shopId) return;
    _repo = FirestoreOrderRepository(shopId);
    _loading = true;
    _orders = const [];
    notifyListeners();
    _load();
  }

  List<Order> _orders = const [];
  bool _loading = true;

  // Caches for derived data, invalidated whenever the orders change so the
  // UI never re-sorts or re-sums on every rebuild.
  List<Order>? _sortedCache;
  List<Order>? _homeCache;
  List<Order>? _loanCache;
  int? _incomeCache;

  void _invalidate() {
    _sortedCache = null;
    _homeCache = null;
    _loanCache = null;
    _incomeCache = null;
  }

  bool get isLoading => _loading;
  String get shopId => _repo.shopId;

  Future<void> _load() async {
    _orders = await _repo.load();
    _invalidate();
    _loading = false;
    notifyListeners();
  }

  /// Fire-and-forget save. Firestore queues writes while offline and syncs
  /// them when the connection returns.
  void _persist() {
    _invalidate();
    _repo.save(_orders);
  }

  List<Order> get orders => List.unmodifiable(_orders);

  /// Newest first, with finished (delivered/cancelled) orders pushed to the
  /// end so in-progress work always sits at the top.
  List<Order> get sortedOrders => _sortedCache ??= _computeSorted();

  List<Order> _computeSorted() {
    final list = [..._orders]..sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );
    final active = list.where((o) => o.status.isActive).toList();
    final done = list.where((o) => o.status.isCompleted).toList();
    return [...active, ...done];
  }

  /// Active orders for the home screen, newest first (no finished orders).
  List<Order> get homeOrders => _homeCache ??= _computeHome();

  List<Order> _computeHome() {
    return _orders.where((o) => o.status.isActive).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Order> get activeOrders =>
      _orders.where((o) => o.status.isActive).toList();

  int get activeCount => activeOrders.length;

  /// Orders waiting for the shop to accept them.
  List<Order> get pendingOrders =>
      _orders.where((o) => o.status == OrderStatus.pending).toList();

  int get pendingCount => pendingOrders.length;

  /// Income collected in the current month.
  int get monthlyIncome => _incomeCache ??= _computeIncome();

  int _computeIncome() {
    final now = DateTime.now();
    return _orders
        .expand((o) => o.payments)
        .where((p) => p.date.year == now.year && p.date.month == now.month)
        .fold(0, (sum, p) => sum + p.amount);
  }

  int get returnsCount =>
      _orders.where((o) => o.status == OrderStatus.cancelled).length;

  /// Delivered orders where money is still owed (قەرز), newest first.
  List<Order> get loanOrders => _loanCache ??= _computeLoans();

  List<Order> _computeLoans() {
    return _orders.where((o) => o.loan > 0).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Total outstanding loan across every delivered order.
  int get totalLoan => _orders.fold(0, (sum, o) => sum + o.loan);

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

  /// All orders for one customer, newest first.
  List<Order> ordersOfCustomer(String customerId) {
    return _orders.where((o) => o.customer.id == customerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Outstanding loan for one customer (قەرز).
  int loanForCustomer(String customerId) => _orders
      .where((o) => o.customer.id == customerId)
      .fold(0, (sum, o) => sum + o.loan);

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

  /// Wipes every order (used when a brand-new shop signs up).
  void clearAll() {
    _orders = const [];
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

  /// Hands the order over and records what the customer paid at that moment.
  /// Any balance left becomes a قەرز loan (see [Order.loan]).
  void deliver(String id, {required int paidNow}) {
    final i = _indexOf(id);
    if (i == -1) return;
    final order = _orders[i];
    var payments = order.payments;
    if (paidNow > 0) {
      payments = [
        ...payments,
        Payment(amount: paidNow, date: DateTime.now()),
      ];
    }
    _orders = [..._orders]
      ..[i] = order.copyWith(
        status: OrderStatus.delivered,
        payments: payments,
      );
    _persist();
    notifyListeners();
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

  /// Edits basic order info (customer name/phone, pickup date).
  void editOrder(
    String id, {
    String? customerName,
    String? customerPhone,
    DateTime? dueDate,
  }) {
    final i = _indexOf(id);
    if (i == -1) return;
    final order = _orders[i];
    final customer = (customerName == null && customerPhone == null)
        ? order.customer
        : order.customer.copyWith(name: customerName, phone: customerPhone);
    _orders = [..._orders]
      ..[i] = order.copyWith(customer: customer, dueDate: dueDate);
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
