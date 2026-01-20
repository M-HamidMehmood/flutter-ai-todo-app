import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/task.dart';

// Web-specific imports (conditional)
import 'export_service_web.dart' if (dart.library.io) 'export_service_stub.dart' as web_export;

class ExportService {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  // Result class for export operation
  static Future<ExportResult> exportTasksToCSV(List<Task> tasks) async {
    try {
      if (tasks.isEmpty) {
        return ExportResult(
          success: false,
          message: 'No tasks to export',
        );
      }

      // Create CSV rows
      List<List<dynamic>> rows = [];
      
      // Add header
      rows.add([
        'Title',
        'Category',
        'Due Date',
        'Priority',
        'Status',
        'Duration (min)'
      ]);
      
      // Add task data
      for (var task in tasks) {
        rows.add([
          task.title,
          task.category,
          _dateFormat.format(task.dueDate),
          task.getPriorityText(),
          task.isCompleted ? 'Completed' : 'Pending',
          task.duration,
        ]);
      }
      
      // Convert to CSV
      String csv = const ListToCsvConverter().convert(rows);
      
      // Handle web platform
      if (kIsWeb) {
        return web_export.exportForWeb(csv);
      }
      
      // Handle mobile/desktop platforms
      return await _exportForMobile(csv);
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Export failed: ${e.toString()}',
      );
    }
  }

  // Export for mobile/desktop platforms
  static Future<ExportResult> _exportForMobile(String csv) async {
    try {
      // Get temp directory to store the file
      final directory = await getTemporaryDirectory();
      final fileName = 'tasks_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final path = '${directory.path}/$fileName';
      
      // Write to file
      final File file = File(path);
      await file.writeAsString(csv);
      
      // Share the file
      final result = await Share.shareXFiles(
        [XFile(path)],
        subject: 'Tasks Export',
      );
      
      if (result.status == ShareResultStatus.success) {
        return ExportResult(
          success: true,
          message: 'CSV exported successfully',
        );
      } else if (result.status == ShareResultStatus.dismissed) {
        return ExportResult(
          success: true,
          message: 'Export ready - share was cancelled',
        );
      } else {
        return ExportResult(
          success: false,
          message: 'Share was not completed',
        );
      }
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'File export failed: ${e.toString()}',
      );
    }
  }
}

class ExportResult {
  final bool success;
  final String message;

  ExportResult({required this.success, required this.message});
} 