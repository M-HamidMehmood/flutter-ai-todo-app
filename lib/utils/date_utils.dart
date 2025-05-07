import 'package:intl/intl.dart';

class AppDateUtils {
  // Format for due date
  static final DateFormat dueDateFormat = DateFormat('MMM dd, HH:mm');
  static final DateFormat fullDateFormat = DateFormat('EEE, MMM dd, yyyy');
  static final DateFormat filenameDateFormat = DateFormat('yyyy-MM-dd_HH-mm-ss');
  
  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }
  
  // Get relative date string
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) {
      return 'Today at ${DateFormat('HH:mm').format(date)}';
    } else if (isTomorrow(date)) {
      return 'Tomorrow at ${DateFormat('HH:mm').format(date)}';
    } else {
      return dueDateFormat.format(date);
    }
  }
  
  // Check if date is due soon (within 24 hours)
  static bool isDueSoon(DateTime date) {
    final now = DateTime.now();
    return date.difference(now).inHours <= 24 && date.isAfter(now);
  }
  
  // Check if date is overdue
  static bool isOverdue(DateTime date) {
    return date.isBefore(DateTime.now());
  }
} 