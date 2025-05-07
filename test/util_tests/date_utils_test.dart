import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/utils/date_utils.dart';
import 'package:intl/intl.dart';

void main() {
  group('AppDateUtils Tests', () {
    test('DateFormat constants are correctly initialized', () {
      expect(AppDateUtils.dueDateFormat, isA<DateFormat>());
      expect(AppDateUtils.fullDateFormat, isA<DateFormat>());
      expect(AppDateUtils.filenameDateFormat, isA<DateFormat>());
    });

    test('isToday function', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 15, 30); // Same day, different time
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      
      expect(AppDateUtils.isToday(today), true);
      expect(AppDateUtils.isToday(yesterday), false);
      expect(AppDateUtils.isToday(tomorrow), false);
    });

    test('isTomorrow function', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      
      expect(AppDateUtils.isTomorrow(today), false);
      expect(AppDateUtils.isTomorrow(yesterday), false);
      expect(AppDateUtils.isTomorrow(tomorrow), true);
    });

    test('getRelativeDateString function', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 15, 30);
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 16, 0);
      final nextWeek = DateTime(now.year, now.month, now.day + 7);
      
      final expectedTodayString = 'Today at ${DateFormat('HH:mm').format(today)}';
      final expectedTomorrowString = 'Tomorrow at ${DateFormat('HH:mm').format(tomorrow)}';
      final expectedNextWeekString = AppDateUtils.dueDateFormat.format(nextWeek);
      
      expect(AppDateUtils.getRelativeDateString(today), expectedTodayString);
      expect(AppDateUtils.getRelativeDateString(tomorrow), expectedTomorrowString);
      expect(AppDateUtils.getRelativeDateString(nextWeek), expectedNextWeekString);
    });

    test('isDueSoon function', () {
      final now = DateTime.now();
      final justNow = now.add(const Duration(minutes: 5));
      final soonish = now.add(const Duration(hours: 23));
      final notSoon = now.add(const Duration(hours: 25));
      final past = now.subtract(const Duration(hours: 1));
      
      expect(AppDateUtils.isDueSoon(justNow), true);
      expect(AppDateUtils.isDueSoon(soonish), true);
      expect(AppDateUtils.isDueSoon(notSoon), false);
      expect(AppDateUtils.isDueSoon(past), false);
    });

    test('isOverdue function', () {
      final now = DateTime.now();
      final future = now.add(const Duration(hours: 1));
      final past = now.subtract(const Duration(hours: 1));
      
      expect(AppDateUtils.isOverdue(future), false);
      expect(AppDateUtils.isOverdue(past), true);
    });
  });
} 