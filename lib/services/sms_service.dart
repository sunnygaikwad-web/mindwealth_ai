import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mindwealth_ai/models/transaction_model.dart';

class SmsService {
  static final SmsQuery _query = SmsQuery();

  /// Requests permission and fetches recent bank SMS
  static Future<List<TransactionModel>> syncBankTransactions() async {
    final permission = await Permission.sms.status;
    if (!permission.isGranted) {
      final status = await Permission.sms.request();
      if (!status.isGranted) return [];
    }

    final messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 200, // Look at last 200 messages for speed
    );

    List<TransactionModel> parsedTransactions = [];
    final seenIds = <String>{};

    for (var message in messages) {
      final text = message.body?.toLowerCase() ?? '';
      final sender = message.sender?.toLowerCase() ?? '';

      // Filter by relevant sender or bank keywords
      final isRelevantSender =
          sender.contains('phone') ||
          sender.contains('paytm') ||
          sender.contains('gpay') ||
          sender.contains('vpa') ||
          sender.contains('upi') ||
          sender.contains('bank') ||
          sender.contains('axis') ||
          sender.contains('hdfc') ||
          sender.contains('sbi') ||
          sender.contains('icici');

      // Comprehensive trigger keywords
      if (isRelevantSender &&
          (text.contains('debited') ||
              text.contains('credited') ||
              text.contains('spent') ||
              text.contains('received') ||
              text.contains('sent to') ||
              text.contains('paid to'))) {
        final amount = _extractAmount(text);
        if (amount != null && amount > 0) {
          final isExpense =
              text.contains('debited') ||
              text.contains('spent') ||
              text.contains('sent to') ||
              text.contains('paid to');

          // Smart category mapping based on merchant name
          String category = 'Bank Sync';
          if (text.contains('zomato') ||
              text.contains('swiggy') ||
              text.contains('food')) {
            category = 'Food';
          } else if (text.contains('amazon') ||
              text.contains('flipkart') ||
              text.contains('myntra')) {
            category = 'Shopping';
          } else if (text.contains('uber') ||
              text.contains('ola') ||
              text.contains('rapido')) {
            category = 'Transport';
          } else if (text.contains('netflix') ||
              text.contains('prime') ||
              text.contains('hotstar')) {
            category = 'Entertainment';
          } else if (text.contains('jio') ||
              text.contains('airtel') ||
              text.contains('vi') ||
              text.contains('recharge')) {
            category = 'Bills';
          }

          final date = message.date ?? DateTime.now();

          // Generate a stable ID based on amount, date, and text to prevent duplicates across syncs
          final stableId =
              '${amount}_${date.year}${date.month}${date.day}_${text.hashCode}'
                  .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '');

          if (!seenIds.contains(stableId)) {
            seenIds.add(stableId);
            parsedTransactions.add(
              TransactionModel(
                id: stableId,
                amount: amount,
                category: category,
                date: date,
                title: message.sender ?? 'Bank',
                type: isExpense ? 'expense' : 'income',
              ),
            );
          }
        }
      }
    }

    return parsedTransactions;
  }

  static double? _extractAmount(String text) {
    // Looks for Rs, INR, ₹ or number patterns reliably
    final regex = RegExp(
      r'(?:rs\.?|inr|₹|amount)\s*(?:of\s*)?([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    if (match != null) {
      final amountStr = match.group(1)?.replaceAll(',', '');
      return double.tryParse(amountStr ?? '');
    }
    // Fallback: look for generic number followed by "debited" pattern
    final regex2 = RegExp(
      r'([\d,]+(?:\.\d{1,2})?)\s*(?:has been|is)\s*(?:debited|credited|paid)',
    );
    final match2 = regex2.firstMatch(text);
    if (match2 != null) {
      final amountStr = match2.group(1)?.replaceAll(',', '');
      return double.tryParse(amountStr ?? '');
    }
    return null;
  }
}
