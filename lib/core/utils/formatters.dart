/// Formatting helpers for money, numbers and dates.
///
/// The app uses **Iraqi Dinar (IQD)** only. IQD has no practical subunits,
/// so all money is stored as whole `int`s.
class Fmt {
  Fmt._();

  static const String _thousands = '.';
  static const String currencySuffix = 'د.ع';

  /// 285000 -> "285.000"
  static String number(num value) {
    final negative = value < 0;
    final s = value.abs().round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(_thousands);
      buf.write(s[i]);
    }
    return negative ? '-$buf' : buf.toString();
  }

  /// 285000 -> "285.000 د.ع"
  static String currency(num iqd) => '${number(iqd)} $currencySuffix';

  static const List<String> kurdishMonths = [
    'کانوونی دووەم',
    'شوبات',
    'ئازار',
    'نیسان',
    'ئایار',
    'حوزەیران',
    'تەممووز',
    'ئاب',
    'ئەیلوول',
    'تشرینی یەکەم',
    'تشرینی دووەم',
    'کانوونی یەکەم',
  ];

  /// 2023-10-28 -> "28 تشرینی یەکەم 2023"
  static String date(DateTime d) =>
      '${d.day} ${kurdishMonths[d.month - 1]} ${d.year}';

  /// 2023-10-28 -> "28/10/2023"
  static String shortDate(DateTime d) =>
      '${_two(d.day)}/${_two(d.month)}/${d.year}';

  static String _two(int v) => v < 10 ? '0$v' : '$v';

  /// 0.75 -> "75%"
  static String percent(double v) => '${(v * 100).round()}%';
}
