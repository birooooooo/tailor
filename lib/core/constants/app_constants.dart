import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Order lifecycle. The customer and the shop both see the SAME status,
/// so the customer always knows what is happening with their clothes.
enum OrderStatus {
  pending, // waiting for the shop to accept
  accepted, // shop accepted the order
  measured, // measurements taken
  cutting, // fabric being cut
  stitching, // sewing
  trial, // trial / fitting
  ready, // ready for pickup or delivery
  delivered, // handed to the customer
  cancelled, // cancelled
}

extension OrderStatusX on OrderStatus {
  int get step {
    const steps = [
      OrderStatus.pending,
      OrderStatus.accepted,
      OrderStatus.measured,
      OrderStatus.cutting,
      OrderStatus.stitching,
      OrderStatus.trial,
      OrderStatus.ready,
      OrderStatus.delivered,
    ];
    final i = steps.indexOf(this);
    return i < 0 ? 0 : i;
  }

  bool get isActive =>
      this != OrderStatus.delivered && this != OrderStatus.cancelled;

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.stagePending;
      case OrderStatus.accepted:
        return AppColors.stageAccepted;
      case OrderStatus.measured:
      case OrderStatus.cutting:
      case OrderStatus.stitching:
        return AppColors.stageProducing;
      case OrderStatus.trial:
        return AppColors.stageTrial;
      case OrderStatus.ready:
        return AppColors.stageReady;
      case OrderStatus.delivered:
        return AppColors.stageDelivered;
      case OrderStatus.cancelled:
        return AppColors.stageCancelled;
    }
  }

  /// Kurdish (Sorani) label. Confirm wording with a native speaker.
  String get ku {
    switch (this) {
      case OrderStatus.pending:
        return 'چاوەڕوانی پەسەندکردن';
      case OrderStatus.accepted:
        return 'پەسەندکرا';
      case OrderStatus.measured:
        return 'پێوانەکرا';
      case OrderStatus.cutting:
        return 'بڕین';
      case OrderStatus.stitching:
        return 'دوورین';
      case OrderStatus.trial:
        return 'تاقیکردنەوە';
      case OrderStatus.ready:
        return 'ئامادەیە';
      case OrderStatus.delivered:
        return 'گەیەندرا';
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
      case OrderStatus.measured:
        return 'Measured';
      case OrderStatus.cutting:
        return 'Cutting';
      case OrderStatus.stitching:
        return 'Stitching';
      case OrderStatus.trial:
        return 'Trial';
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
      case OrderStatus.measured:
        return Icons.straighten_rounded;
      case OrderStatus.cutting:
        return Icons.content_cut_rounded;
      case OrderStatus.stitching:
        return Icons.auto_fix_high_rounded;
      case OrderStatus.trial:
        return Icons.checkroom_rounded;
      case OrderStatus.ready:
        return Icons.verified_rounded;
      case OrderStatus.delivered:
        return Icons.local_shipping_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }
}

/// Common garment types for a Kurdish tailor shop.
class GarmentType {
  final String id;
  final String ku;
  final String en;
  final IconData icon;

  const GarmentType({
    required this.id,
    required this.ku,
    required this.en,
    required this.icon,
  });

  static const List<GarmentType> all = [
    GarmentType(id: 'kras', ku: 'کراس', en: 'Shirt/Dress', icon: Icons.checkroom),
    GarmentType(id: 'shalwar', ku: 'شلوار', en: 'Trousers', icon: Icons.dry_cleaning),
    GarmentType(id: 'jaket', ku: 'چاکەت', en: 'Jacket', icon: Icons.dry_cleaning_outlined),
    GarmentType(id: 'abaya', ku: 'عەبا', en: 'Abaya', icon: Icons.woman),
    GarmentType(id: 'kras_afratan', ku: 'کراسی ئافرەتان', en: 'Women\'s dress', icon: Icons.woman_2),
    GarmentType(id: 'zir', ku: 'جلوبەرگی منداڵان', en: 'Kids wear', icon: Icons.child_care),
  ];
}
