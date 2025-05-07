import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/task.dart';

class ExportService {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  // Convert tasks to CSV format
  static Future<void> exportTasksToCSV(List<Task> tasks) async {
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
  }
} 