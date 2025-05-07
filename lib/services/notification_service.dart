import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Skip initialization in web or if in testing/preview mode
    if (kIsWeb) {
      return;
    }

    try {
      // Initialize timezone
      tz_data.initializeTimeZones();
      final local = tz.local;
      
      // Request notification permissions
      if (!kIsWeb) {
        await Permission.notification.request();
      }

      // Initialize notification settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    } catch (e) {
      print('Notification initialization error: $e');
      // Continue without notifications
    }
  }

  // Schedule reminder 30 minutes before due date
  Future<void> scheduleTaskReminder(Task task) async {
    // Skip in web or if in testing/preview mode
    if (kIsWeb) {
      return;
    }

    try {
      // Calculate reminder time (30 minutes before due)
      final now = DateTime.now();
      final reminderTime = task.dueDate.subtract(const Duration(minutes: 30));
      
      // Don't schedule if reminder time is in the past
      if (reminderTime.isBefore(now)) {
        return;
      }
      
      // Convert to timezone-aware DateTime
      final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);
  
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'todo_reminder_channel',
        'Task Reminders',
        channelDescription: 'Notifications for task reminders',
        importance: Importance.high,
        priority: Priority.high,
      );
  
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
  
      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
  
      await flutterLocalNotificationsPlugin.zonedSchedule(
        task.id.hashCode, // Notification ID based on task ID
        'Reminder: ${task.title}',
        'Due in 30 minutes. Priority: ${task.getPriorityText()}',
        scheduledDate,
        platformDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      print('Failed to schedule notification: $e');
      // Continue without notifications
    }
  }

  // Cancel notification for a task
  Future<void> cancelTaskReminder(Task task) async {
    if (kIsWeb) {
      return;
    }
    
    try {
      await flutterLocalNotificationsPlugin.cancel(task.id.hashCode);
    } catch (e) {
      print('Failed to cancel notification: $e');
    }
  }
} 