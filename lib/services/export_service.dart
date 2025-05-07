import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/task.dart';

class ExportService {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  // Convert tasks to CSV format
  static Future<void> exportTasksToCSV(List<Task> tasks) async {
    try {
      // Skip on web platform or in preview
      if (kIsWeb) {
        print('Export not supported on web platform');
        return;
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
      
      try {
        // Get temp directory to store the file
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/tasks_export.csv';
        
        // Write to file
        final File file = File(path);
        await file.writeAsString(csv);
        
        // Share the file
        await Share.shareXFiles(
          [XFile(path)],
          subject: 'Tasks Export',
        );
      } catch (e) {
        print('Error during file operations: $e');
        // Fallback option for environments where file operations fail
        // This might happen in online compiler/preview environments
      }
    } catch (e) {
      print('Export failed: $e');
      // Handle export failure gracefully
    }
  }
} 