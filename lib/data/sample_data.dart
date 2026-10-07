import '../core/constants/app_constants.dart';
import '../models/order.dart';

/// Temporary sample data so we can build and see the shop screens.
/// This will be replaced by Firestore later.
class SampleData {
  SampleData._();

  static const String shopName = 'خەیاتی و بەرگەڕۆیی شاڵ';
  static const String shopOwner = 'شاڵ';

  /// Background photo for the dashboard header.
  static const String headerImage =
      'https://loremflickr.com/800/500/tailor,suit?lock=9';

  static String _photo(int n) =>
      'https://loremflickr.com/600/400/suit,tailor?lock=$n';

  static List<Order> orders() {
    final now = DateTime.now();
    DateTime ago(int days) => now.subtract(Duration(days: days));
    DateTime ahead(int days) => now.add(Duration(days: days));

    const upper = MeasurementSet(
      title: 'پێوانەکانی بەشی سەرەوە',
      fields: [
        MeasurementField(label: 'سینگ', value: 96),
        MeasurementField(label: 'ئێخە', value: 42),
        MeasurementField(label: 'مل', value: 46),
        MeasurementField(label: 'شان', value: 16),
        MeasurementField(label: 'باڵ', value: 102),
        MeasurementField(label: 'قۆڵ', value: 64),
      ],
    );
    const lower = MeasurementSet(
      title: 'پێوانەکانی بەشی خوارەوە',
      fields: [
        MeasurementField(label: 'درێژی شەروال', value: 104),
        MeasurementField(label: 'کەمەر', value: 92),
        MeasurementField(label: 'ملەنگ', value: 24),
      ],
    );

    Customer c(String id, String name, String phone, String area) =>
        Customer(id: id, name: name, phone: phone, area: area);

    return [
      Order(
        id: '8842',
        customer: c('c1', 'داریا کاروان', '0770 123 4567', 'هەولێر'),
        status: OrderStatus.accepted,
        createdAt: ago(6),
        dueDate: ahead(1),
        discount: 15000,
        items: [
          OrderItem(
            garment: 'کراس و شەروال',
            style: 'ستایلی سلێمانی کلاسیک',
            unitPrice: 285000,
            imageUrl: _photo(1),
            colors: const ['شین', 'زێو'],
            fabrics: const ['شاڵ باڵ کۆن'],
            measurements: const [upper, lower],
          ),
        ],
        payments: [Payment(amount: 100000, date: ago(6))],
        notes: [
          OrderNote(
            text: 'کڕیار داوای دووبارەکردنەوەی قۆڵی کردووە.',
            date: ago(5),
          ),
        ],
      ),
      Order(
        id: '8843',
        customer: c('c2', 'ئاراس نەجمەدین', '0751 222 3344', 'سلێمانی'),
        status: OrderStatus.pending,
        createdAt: ago(1),
        dueDate: ahead(9),
        items: [
          OrderItem(
            garment: 'کراس و شەروال',
            style: 'ستایلی هەورامانی کلاسیک',
            unitPrice: 240000,
            imageUrl: _photo(2),
            measurements: const [upper, lower],
          ),
        ],
        payments: const [],
      ),
      Order(
        id: '8844',
        customer: c('c3', 'لیلا محمد', '0770 555 8899', 'دهۆک'),
        status: OrderStatus.accepted,
        createdAt: ago(9),
        dueDate: ahead(4),
        discount: 10000,
        items: [
          OrderItem(
            garment: 'کراسی ئافرەتان',
            style: 'دیزاینی ئێرانی',
            unitPrice: 320000,
            imageUrl: _photo(3),
            measurements: const [upper, lower],
          ),
        ],
        payments: [
          Payment(amount: 150000, date: ago(9)),
          Payment(amount: 50000, date: ago(3)),
        ],
      ),
      Order(
        id: '8845',
        customer: c('c4', 'بەهرام ئازاد', '0750 777 1122', 'هەولێر'),
        status: OrderStatus.ready,
        createdAt: ago(12),
        dueDate: ahead(0),
        items: [
          OrderItem(
            garment: 'چاکەت',
            style: 'ستایلی بادینی',
            unitPrice: 195000,
            imageUrl: _photo(4),
            measurements: const [upper],
          ),
        ],
        payments: [Payment(amount: 195000, date: ago(12))],
      ),
      Order(
        id: '8846',
        customer: c('c5', 'زێدان کرمانج', '0771 808 9090', 'سۆران'),
        status: OrderStatus.accepted,
        createdAt: ago(2),
        dueDate: ahead(7),
        items: [
          OrderItem(
            garment: 'شەروال',
            style: 'ستایلی مەهاباد',
            unitPrice: 120000,
            imageUrl: _photo(5),
            measurements: const [lower],
          ),
        ],
        payments: const [],
      ),
      Order(
        id: '8847',
        customer: c('c6', 'نارین عومەر', '0773 444 6677', 'کەرکوک'),
        status: OrderStatus.delivered,
        createdAt: ago(20),
        dueDate: ago(4),
        items: [
          OrderItem(
            garment: 'کراس',
            style: 'ستایلی ستار خەیی',
            unitPrice: 140000,
            imageUrl: _photo(6),
            measurements: const [upper],
          ),
        ],
        payments: [Payment(amount: 140000, date: ago(4))],
      ),
    ];
  }

  /// Unique customers derived from the orders.
  static List<Customer> customers() {
    final seen = <String, Customer>{};
    for (final o in orders()) {
      seen[o.customer.id] = o.customer;
    }
    return seen.values.toList();
  }

  static int ordersForCustomer(String customerId) =>
      orders().where((o) => o.customer.id == customerId).length;
}
