import '../core/constants/app_constants.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final String? photoUrl;
  final String? area;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.photoUrl,
    this.area,
  });
}

class MeasurementField {
  final String label;
  final double value;
  final String unit;

  const MeasurementField({
    required this.label,
    required this.value,
    this.unit = 'سم',
  });
}

/// A group of measurements, e.g. "پێوانەکانی بەشی سەرەوە".
class MeasurementSet {
  final String title;
  final List<MeasurementField> fields;

  const MeasurementSet({required this.title, required this.fields});
}

class Payment {
  final int amount;
  final DateTime date;
  final String method;

  const Payment({
    required this.amount,
    required this.date,
    this.method = 'کاش',
  });
}

class OrderNote {
  final String text;
  final DateTime date;

  const OrderNote({required this.text, required this.date});
}

class OrderItem {
  final String garment;
  final String? style;
  final int quantity;
  final int unitPrice;
  final String? imageUrl;
  final List<String> colors;
  final List<String> fabrics;
  final List<MeasurementSet> measurements;

  const OrderItem({
    required this.garment,
    this.style,
    this.quantity = 1,
    required this.unitPrice,
    this.imageUrl,
    this.colors = const [],
    this.fabrics = const [],
    this.measurements = const [],
  });

  int get lineTotal => unitPrice * quantity;
}

class Order {
  final String id;
  final Customer customer;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime dueDate;
  final List<OrderItem> items;
  final int discount;
  final List<Payment> payments;
  final List<OrderNote> notes;
  final String? referenceImageUrl;

  const Order({
    required this.id,
    required this.customer,
    required this.status,
    required this.createdAt,
    required this.dueDate,
    required this.items,
    this.discount = 0,
    this.payments = const [],
    this.notes = const [],
    this.referenceImageUrl,
  });

  /// Sum of all item prices.
  int get subtotal => items.fold(0, (s, i) => s + i.lineTotal);

  /// What the customer must pay after the discount.
  int get payable => subtotal - discount;

  int get paid => payments.fold(0, (s, p) => s + p.amount);

  /// Never typed by hand — always computed.
  int get remaining => payable - paid;

  Order copyWith({
    OrderStatus? status,
    List<Payment>? payments,
    List<OrderNote>? notes,
  }) {
    return Order(
      id: id,
      customer: customer,
      status: status ?? this.status,
      createdAt: createdAt,
      dueDate: dueDate,
      items: items,
      discount: discount,
      payments: payments ?? this.payments,
      notes: notes ?? this.notes,
      referenceImageUrl: referenceImageUrl,
    );
  }
}
