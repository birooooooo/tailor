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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'photoUrl': photoUrl,
    'area': area,
  };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    photoUrl: json['photoUrl'] as String?,
    area: json['area'] as String?,
  );
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

  Map<String, dynamic> toJson() => {
    'label': label,
    'value': value,
    'unit': unit,
  };

  factory MeasurementField.fromJson(Map<String, dynamic> json) =>
      MeasurementField(
        label: json['label'] as String? ?? '',
        value: (json['value'] as num?)?.toDouble() ?? 0,
        unit: json['unit'] as String? ?? 'سم',
      );
}

/// A group of measurements, e.g. "پێوانەکانی بەشی سەرەوە".
class MeasurementSet {
  final String title;
  final List<MeasurementField> fields;

  const MeasurementSet({required this.title, required this.fields});

  Map<String, dynamic> toJson() => {
    'title': title,
    'fields': fields.map((f) => f.toJson()).toList(),
  };

  factory MeasurementSet.fromJson(Map<String, dynamic> json) => MeasurementSet(
    title: json['title'] as String? ?? '',
    fields: ((json['fields'] as List?) ?? const [])
        .map((e) => MeasurementField.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
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

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'date': date.toIso8601String(),
    'method': method,
  };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    amount: (json['amount'] as num?)?.toInt() ?? 0,
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    method: json['method'] as String? ?? 'کاش',
  );
}

class OrderNote {
  final String text;
  final DateTime date;

  const OrderNote({required this.text, required this.date});

  Map<String, dynamic> toJson() => {
    'text': text,
    'date': date.toIso8601String(),
  };

  factory OrderNote.fromJson(Map<String, dynamic> json) => OrderNote(
    text: json['text'] as String? ?? '',
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
  );
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

  Map<String, dynamic> toJson() => {
    'garment': garment,
    'style': style,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'imageUrl': imageUrl,
    'colors': colors,
    'fabrics': fabrics,
    'measurements': measurements.map((m) => m.toJson()).toList(),
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    garment: json['garment'] as String? ?? '',
    style: json['style'] as String?,
    quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    unitPrice: (json['unitPrice'] as num?)?.toInt() ?? 0,
    imageUrl: json['imageUrl'] as String?,
    colors: ((json['colors'] as List?) ?? const []).cast<String>(),
    fabrics: ((json['fabrics'] as List?) ?? const []).cast<String>(),
    measurements: ((json['measurements'] as List?) ?? const [])
        .map((e) => MeasurementSet.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer': customer.toJson(),
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'items': items.map((i) => i.toJson()).toList(),
    'discount': discount,
    'payments': payments.map((p) => p.toJson()).toList(),
    'notes': notes.map((n) => n.toJson()).toList(),
    'referenceImageUrl': referenceImageUrl,
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String? ?? '',
    customer: Customer.fromJson(
      (json['customer'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    status: OrderStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => OrderStatus.pending,
    ),
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    dueDate:
        DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
    items: ((json['items'] as List?) ?? const [])
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    discount: (json['discount'] as num?)?.toInt() ?? 0,
    payments: ((json['payments'] as List?) ?? const [])
        .map((e) => Payment.fromJson(e as Map<String, dynamic>))
        .toList(),
    notes: ((json['notes'] as List?) ?? const [])
        .map((e) => OrderNote.fromJson(e as Map<String, dynamic>))
        .toList(),
    referenceImageUrl: json['referenceImageUrl'] as String?,
  );
}
