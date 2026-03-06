import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:mindwealth_ai/models/transaction_model.dart';
import 'package:mindwealth_ai/models/goal_model.dart';
import 'package:mindwealth_ai/models/ai_insight_model.dart';
import 'package:mindwealth_ai/core/utils/formatters.dart';

class ExportService {
  // ─── PDF Export ───
  Future<File> exportPdf({
    required String userName,
    required double totalIncome,
    required double totalExpense,
    required List<TransactionModel> transactions,
    required List<GoalModel> goals,
    required List<AiInsightModel> insights,
    required Map<String, double> categorySpending,
  }) async {
    final document = PdfDocument();
    final page = document.pages.add();
    final graphics = page.graphics;
    final pageSize = page.getClientSize();
    double yPos = 0;

    // Title
    final titleFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      24,
      style: PdfFontStyle.bold,
    );
    graphics.drawString(
      'MindWealth AI',
      titleFont,
      bounds: Rect.fromLTWH(0, yPos, pageSize.width, 40),
      brush: PdfSolidBrush(PdfColor(108, 92, 231)),
    );
    yPos += 35;

    final subtitleFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
    graphics.drawString(
      'Financial Report - ${Formatters.monthYear(DateTime.now())}',
      subtitleFont,
      bounds: Rect.fromLTWH(0, yPos, pageSize.width, 20),
    );
    yPos += 30;

    graphics.drawString(
      'Prepared for: $userName',
      subtitleFont,
      bounds: Rect.fromLTWH(0, yPos, pageSize.width, 20),
    );
    yPos += 30;

    // Summary section
    final headerFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      16,
      style: PdfFontStyle.bold,
    );
    final bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 11);

    graphics.drawString(
      'Monthly Summary',
      headerFont,
      bounds: Rect.fromLTWH(0, yPos, pageSize.width, 25),
    );
    yPos += 30;

    graphics.drawString(
      'Total Income: ${Formatters.currency(totalIncome)}',
      bodyFont,
      bounds: Rect.fromLTWH(20, yPos, pageSize.width, 18),
    );
    yPos += 20;
    graphics.drawString(
      'Total Expense: ${Formatters.currency(totalExpense)}',
      bodyFont,
      bounds: Rect.fromLTWH(20, yPos, pageSize.width, 18),
    );
    yPos += 20;
    graphics.drawString(
      'Net Savings: ${Formatters.currency(totalIncome - totalExpense)}',
      bodyFont,
      bounds: Rect.fromLTWH(20, yPos, pageSize.width, 18),
    );
    yPos += 35;

    // Category breakdown
    graphics.drawString(
      'Spending by Category',
      headerFont,
      bounds: Rect.fromLTWH(0, yPos, pageSize.width, 25),
    );
    yPos += 30;

    for (final entry in categorySpending.entries) {
      if (yPos > pageSize.height - 50) {
        document.pages.add();
        yPos = 20;
        // Continue on new page (simplified - using same graphics reference pattern)
      }
      graphics.drawString(
        '${entry.key}: ${Formatters.currency(entry.value)}',
        bodyFont,
        bounds: Rect.fromLTWH(20, yPos, pageSize.width, 18),
      );
      yPos += 18;
    }
    yPos += 20;

    // Goals
    if (goals.isNotEmpty && yPos < pageSize.height - 100) {
      graphics.drawString(
        'Goals Progress',
        headerFont,
        bounds: Rect.fromLTWH(0, yPos, pageSize.width, 25),
      );
      yPos += 30;

      for (final goal in goals) {
        graphics.drawString(
          '${goal.icon} ${goal.name}: ${goal.progressPercent.toStringAsFixed(1)}% complete',
          bodyFont,
          bounds: Rect.fromLTWH(20, yPos, pageSize.width, 18),
        );
        yPos += 18;
      }
      yPos += 20;
    }

    // AI Insights
    if (insights.isNotEmpty && yPos < pageSize.height - 80) {
      graphics.drawString(
        'AI Insights',
        headerFont,
        bounds: Rect.fromLTWH(0, yPos, pageSize.width, 25),
      );
      yPos += 30;

      for (final insight in insights.take(5)) {
        graphics.drawString(
          '${insight.icon} ${insight.message}',
          bodyFont,
          bounds: Rect.fromLTWH(20, yPos, pageSize.width - 40, 36),
        );
        yPos += 38;
      }
    }

    final bytes = document.saveSync();
    document.dispose();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/mindwealth_report.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  // ─── Excel Export ───
  Future<File> exportExcel({
    required List<TransactionModel> transactions,
    required Map<String, double> categorySpending,
    required double totalIncome,
    required double totalExpense,
  }) async {
    final workbook = xlsio.Workbook();

    // Transaction sheet
    final txnSheet = workbook.worksheets[0];
    txnSheet.name = 'Transactions';

    txnSheet.getRangeByIndex(1, 1).setText('Date');
    txnSheet.getRangeByIndex(1, 2).setText('Title');
    txnSheet.getRangeByIndex(1, 3).setText('Category');
    txnSheet.getRangeByIndex(1, 4).setText('Type');
    txnSheet.getRangeByIndex(1, 5).setText('Amount');

    // Style header
    for (int col = 1; col <= 5; col++) {
      final cell = txnSheet.getRangeByIndex(1, col);
      cell.cellStyle.bold = true;
      cell.cellStyle.backColor = '#6C5CE7';
      cell.cellStyle.fontColor = '#FFFFFF';
    }

    for (int i = 0; i < transactions.length; i++) {
      final t = transactions[i];
      final row = i + 2;
      txnSheet.getRangeByIndex(row, 1).setText(Formatters.date(t.date));
      txnSheet.getRangeByIndex(row, 2).setText(t.title);
      txnSheet.getRangeByIndex(row, 3).setText(t.category);
      txnSheet.getRangeByIndex(row, 4).setText(t.type);
      txnSheet.getRangeByIndex(row, 5).setNumber(t.amount);
    }

    // Category breakdown sheet
    final catSheet = workbook.worksheets.addWithName('Category Breakdown');
    catSheet.getRangeByIndex(1, 1).setText('Category');
    catSheet.getRangeByIndex(1, 2).setText('Amount');
    catSheet.getRangeByIndex(1, 3).setText('Percentage');

    for (int col = 1; col <= 3; col++) {
      final cell = catSheet.getRangeByIndex(1, col);
      cell.cellStyle.bold = true;
      cell.cellStyle.backColor = '#6C5CE7';
      cell.cellStyle.fontColor = '#FFFFFF';
    }

    int rowIdx = 2;
    for (final entry in categorySpending.entries) {
      catSheet.getRangeByIndex(rowIdx, 1).setText(entry.key);
      catSheet.getRangeByIndex(rowIdx, 2).setNumber(entry.value);
      final pct = totalExpense > 0 ? (entry.value / totalExpense * 100) : 0;
      catSheet.getRangeByIndex(rowIdx, 3).setText('${pct.toStringAsFixed(1)}%');
      rowIdx++;
    }

    // Summary sheet
    final summSheet = workbook.worksheets.addWithName('Summary');
    summSheet.getRangeByIndex(1, 1).setText('Metric');
    summSheet.getRangeByIndex(1, 2).setText('Value');

    for (int col = 1; col <= 2; col++) {
      final cell = summSheet.getRangeByIndex(1, col);
      cell.cellStyle.bold = true;
      cell.cellStyle.backColor = '#6C5CE7';
      cell.cellStyle.fontColor = '#FFFFFF';
    }

    summSheet.getRangeByIndex(2, 1).setText('Total Income');
    summSheet.getRangeByIndex(2, 2).setNumber(totalIncome);
    summSheet.getRangeByIndex(3, 1).setText('Total Expense');
    summSheet.getRangeByIndex(3, 2).setNumber(totalExpense);
    summSheet.getRangeByIndex(4, 1).setText('Net Savings');
    summSheet.getRangeByIndex(4, 2).setNumber(totalIncome - totalExpense);
    summSheet.getRangeByIndex(5, 1).setText('Savings Rate');
    final rate = totalIncome > 0
        ? ((totalIncome - totalExpense) / totalIncome * 100)
        : 0;
    summSheet.getRangeByIndex(5, 2).setText('${rate.toStringAsFixed(1)}%');

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/mindwealth_data.xlsx');
    await file.writeAsBytes(bytes);
    return file;
  }

  // ─── Word Export ───
  Future<File> exportWord({
    required String userName,
    required double totalIncome,
    required double totalExpense,
    required List<AiInsightModel> insights,
    required List<GoalModel> goals,
  }) async {
    // Build a simple DOCX-compatible HTML that can be rendered
    final buffer = StringBuffer();
    buffer.writeln(
      '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word">',
    );
    buffer.writeln('<head><meta charset="UTF-8"></head>');
    buffer.writeln('<body>');
    buffer.writeln(
      '<h1 style="color:#6C5CE7;">MindWealth AI - Financial Summary</h1>',
    );
    buffer.writeln(
      '<p>Report for: <b>$userName</b> | ${Formatters.monthYear(DateTime.now())}</p>',
    );
    buffer.writeln('<hr/>');

    buffer.writeln('<h2>Financial Overview</h2>');
    buffer.writeln('<table border="1" cellpadding="8">');
    buffer.writeln(
      '<tr><td><b>Total Income</b></td><td>${Formatters.currency(totalIncome)}</td></tr>',
    );
    buffer.writeln(
      '<tr><td><b>Total Expense</b></td><td>${Formatters.currency(totalExpense)}</td></tr>',
    );
    buffer.writeln(
      '<tr><td><b>Net Savings</b></td><td>${Formatters.currency(totalIncome - totalExpense)}</td></tr>',
    );
    buffer.writeln('</table>');

    if (goals.isNotEmpty) {
      buffer.writeln('<h2>Goals Progress</h2>');
      buffer.writeln('<table border="1" cellpadding="8">');
      buffer.writeln(
        '<tr><th>Goal</th><th>Target</th><th>Saved</th><th>Progress</th></tr>',
      );
      for (final goal in goals) {
        buffer.writeln(
          '<tr><td>${goal.icon} ${goal.name}</td><td>${Formatters.currency(goal.target)}</td><td>${Formatters.currency(goal.saved)}</td><td>${goal.progressPercent.toStringAsFixed(1)}%</td></tr>',
        );
      }
      buffer.writeln('</table>');
    }

    if (insights.isNotEmpty) {
      buffer.writeln('<h2>AI Insights</h2>');
      for (final insight in insights) {
        buffer.writeln(
          '<p>${insight.icon} <b>${insight.title}</b><br/>${insight.message}</p>',
        );
      }
    }

    buffer.writeln('</body></html>');

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/mindwealth_report.doc');
    await file.writeAsString(buffer.toString());
    return file;
  }

  // ─── Share File ───
  Future<void> shareFile(File file) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }
}
