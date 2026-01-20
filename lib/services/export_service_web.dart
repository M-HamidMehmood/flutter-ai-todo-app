// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'export_service.dart';

ExportResult exportForWeb(String csv) {
  try {
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'tasks_export_${DateTime.now().millisecondsSinceEpoch}.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
    
    return ExportResult(
      success: true,
      message: 'CSV file downloaded successfully',
    );
  } catch (e) {
    return ExportResult(
      success: false,
      message: 'Web export failed: ${e.toString()}',
    );
  }
}
