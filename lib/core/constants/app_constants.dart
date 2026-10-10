import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Order lifecycle. The customer and the shop both see the SAME status,
/// so the customer always knows what is happening with their clothes.
enum OrderStatus {
  pending, // waiting for the shop to accept
  accepted, // shop accepted the order
  ready, // ready for pickup or delivery
  delivered, // handed to the customer
  cancelled, // cancelled (off the normal flow)
}

extension OrderStatusX on OrderStatus {
  int get step {
    final i = orderFlow.indexOf(this);
    return i < 0 ? 0 : i;
  }

  bool get isActive =>
      this != OrderStatus.delivered && this != OrderStatus.cancelled;

  /// A finished order (delivered or cancelled). These stay in the data but
  /// are sorted to the end of lists and shown muted.
  bool get isCompleted => !isActive;

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.stagePending;
      case OrderStatus.accepted:
        return AppColors.stageAccepted;
      case OrderStatus.ready:
        return AppColors.stageReady;
      case OrderStatus.delivered:
        return AppColors.stageDelivered;
      case OrderStatus.cancelled:
        return AppColors.stageCancelled;
    }
  }

  /// Kurdish (Sorani) label.
  String get ku {
    switch (this) {
      case OrderStatus.pending:
        return 'چاوەڕوانی پەسەندکردن';
      case OrderStatus.accepted:
        return 'پەسەندکردن';
      case OrderStatus.ready:
        return 'ئامادەیە';
      case OrderStatus.delivered:
        return 'گەیەنرا';
      case OrderStatus.cancelled:
        return 'هەڵوەشێنرا';
    }
  }

  String get en {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.hourglass_top_rounded;
      case OrderStatus.accepted:
        return Icons.thumb_up_alt_rounded;
      case OrderStatus.ready:
        return Icons.verified_rounded;
      case OrderStatus.delivered:
        return Icons.local_shipping_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }
}

/// The normal order flow: چاوەڕوانی پەسەندکردن → پەسەندکردن → ئامادەیە → گەیەنرا.
const List<OrderStatus> orderFlow = [
  OrderStatus.pending,
  OrderStatus.accepted,
  OrderStatus.ready,
  OrderStatus.delivered,
];

/// Shown in the header until the logged-in shop sets its own name.
const String kDefaultShopName = 'خەیاتو بەرگدروی شاڵ';

/// The styles a shop offers by default. Editable in the shop settings.
const List<String> kDefaultStyles = [
  'ستایلی بارزانی',
  'ستایلی ئدریس بارزانی',
  'ستایلی سورانی',
  'ستایلی بادینی',
];

/// Which measurements a garment needs.
enum GarmentMeasurements {
  /// Both بەشی سەرەوە and خوارەوە.
  upperLower,

  /// Only بەشی خوارەوە (e.g. شلوار).
  lowerOnly,

  /// Women's dress set: بەژن، کەمەر، سینگ.
  women,
}

/// Common garment types for a Kurdish tailor shop.
class GarmentType {
  final String id;
  final String ku;
  final String en;
  final IconData icon;
  final GarmentMeasurements measurements;

  const GarmentType({
    required this.id,
    required this.ku,
    required this.en,
    required this.icon,
    this.measurements = GarmentMeasurements.upperLower,
  });

  static const List<GarmentType> all = [
    GarmentType(
      id: 'shalwar',
      ku: 'شلوار',
      en: 'Trousers',
      icon: Icons.dry_cleaning,
      measurements: GarmentMeasurements.lowerOnly,
    ),
    GarmentType(
      id: 'kras_afratan',
      ku: 'کراسی ئافرەتان',
      en: 'Women\'s dress',
      icon: Icons.woman_2,
      measurements: GarmentMeasurements.women,
    ),
    GarmentType(
      id: 'qati_kurdi',
      ku: 'قاتی کوردی',
      en: 'Kurdish suit',
      icon: Icons.checkroom,
    ),
    GarmentType(
      id: 'destkari_jilo_berk',
      ku: 'دەستکاری جلو بەرک',
      en: 'Outfit alteration',
      icon: Icons.dry_cleaning_outlined,
    ),
  ];
}
