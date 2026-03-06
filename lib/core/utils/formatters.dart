import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
    locale: 'en_IN',
  );

  static final _compactCurrency = NumberFormat.compactCurrency(
    symbol: '₹',
    decimalDigits: 1,
    locale: 'en_IN',
  );

  static final _dateFormat = DateFormat('dd MMM yyyy');
  static final _monthYearFormat = DateFormat('MMMM yyyy');
  static final _shortDateFormat = DateFormat('dd/MM');
  static final _apiDateFormat = DateFormat('yyyy-MM-dd');

  static String currency(double amount) => _currencyFormat.format(amount);
  static String compactCurrency(double amount) =>
      _compactCurrency.format(amount);

  static String date(DateTime date) => _dateFormat.format(date);
  static String monthYear(DateTime date) => _monthYearFormat.format(date);
  static String shortDate(DateTime date) => _shortDateFormat.format(date);
  static String apiDate(DateTime date) => _apiDateFormat.format(date);

  static DateTime parseApiDate(String dateStr) => _apiDateFormat.parse(dateStr);

  static String percentage(double value) => '${value.toStringAsFixed(1)}%';

  static String daysRemaining(DateTime deadline) {
    final diff = deadline.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Today';
    if (diff == 1) return '1 day left';
    return '$diff days left';
  }

  static String relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return date(dateTime);
  }
}
