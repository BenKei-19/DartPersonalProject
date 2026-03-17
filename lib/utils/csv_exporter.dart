import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/transaction.dart';
import 'formatters.dart';

class CsvExporter {
  static Future<void> exportAndShare(List<LixiTransaction> transactions) async {
    final csvData = <List<dynamic>>[
      ['STT', 'Loại', 'Số tiền', 'Người', 'Nhóm', 'Ghi chú', 'Ngày', 'Năm'],
    ];

    for (int i = 0; i < transactions.length; i++) {
      final t = transactions[i];
      csvData.add([
        i + 1,
        t.isReceived ? 'Nhận' : 'Cho',
        t.amount,
        t.personName,
        t.categoryName ?? 'Chưa phân loại',
        t.note ?? '',
        Formatters.formatDateString(t.date),
        t.year,
      ]);
    }

    final csv = const ListToCsvConverter().convert(csvData);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/lixi_export_$timestamp.csv');
    await file.writeAsString('\uFEFF$csv'); // BOM for UTF-8 Excel support

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Lì Xì Tracker - Xuất CSV',
    );
  }
}
