import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/widgets/task_item.dart';
import 'package:myapp/services/task_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([TaskService, NotificationService])
import 'task_item_test.mocks.dart';

void main() {
  group('TaskItem Widget Tests', () {
    late MockTaskService mockTaskService;
    late MockNotificationService mockNotificationService;
    late Task testTask;
    
    setUp(() {
      mockTaskService = MockTaskService();
      mockNotificationService = MockNotificationService();
      
      // Create a test task
      testTask = Task(
        id: 'test-id',
        title: 'Test Task',
        category: 'Work',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: PriorityConstants.medium,
      );
    });
    
    testWidgets('TaskItem displays task information', (WidgetTester tester) async {
      // Build our widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<TaskService>.value(value: mockTaskService),
              ],
              child: TaskItem(task: testTask),
            ),
          ),
        ),
      );
      
      // Verify task title is displayed
      expect(find.text('Test Task'), findsOneWidget);
      
      // Verify task category is displayed
      expect(find.text('Work'), findsOneWidget);
      
      // Verify duration is displayed
      expect(find.text('0 min'), findsOneWidget);
    });
    
    testWidgets('TaskItem shows SOON tag for tasks due within 24 hours', (WidgetTester tester) async {
      // Create a task due soon
      final dueSoonTask = Task(
        id: 'due-soon-id',
        title: 'Due Soon Task',
        category: 'Work',
        dueDate: DateTime.now().add(const Duration(hours: 2)),
        priority: PriorityConstants.medium,
      );
      
      // Build widget with the due soon task
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<TaskService>.value(value: mockTaskService),
              ],
              child: TaskItem(task: dueSoonTask),
            ),
          ),
        ),
      );
      
      // Verify the SOON tag is displayed
      expect(find.text('SOON'), findsOneWidget);
    });
    
    testWidgets('TaskItem shows OVERDUE tag for overdue tasks', (WidgetTester tester) async {
      // Create an overdue task
      final overdueTask = Task(
        id: 'overdue-id',
        title: 'Overdue Task',
        category: 'Work',
        dueDate: DateTime.now().subtract(const Duration(hours: 2)),
        priority: PriorityConstants.medium,
      );
      
      // Build widget with the overdue task
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<TaskService>.value(value: mockTaskService),
              ],
              child: TaskItem(task: overdueTask),
            ),
          ),
        ),
      );
      
      // Verify the OVERDUE tag is displayed
      expect(find.text('OVERDUE'), findsOneWidget);
    });
    
    testWidgets('TaskItem applies strikethrough for completed tasks', (WidgetTester tester) async {
      // Create a completed task
      final completedTask = Task(
        id: 'completed-id',
        title: 'Completed Task',
        category: 'Work',
        dueDate: DateTime.now(),
        priority: PriorityConstants.medium,
        isCompleted: true,
      );
      
      // Build widget with the completed task
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<TaskService>.value(value: mockTaskService),
              ],
              child: TaskItem(task: completedTask),
            ),
          ),
        ),
      );
      
      // Find the Text widget for the task title
      final titleFinder = find.text('Completed Task');
      expect(titleFinder, findsOneWidget);
      
      // Verify it has strikethrough decoration
      final Text titleWidget = tester.widget(titleFinder);
      expect(titleWidget.style?.decoration, TextDecoration.lineThrough);
    });
    
    testWidgets('TaskItem calls toggleTaskStatus when checkbox is tapped', (WidgetTester tester) async {
      // Setup mock behavior
      when(mockTaskService.toggleTaskStatus(any)).thenAnswer((_) => Future.value());
      
      // Build our widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<TaskService>.value(value: mockTaskService),
              ],
              child: TaskItem(task: testTask),
            ),
          ),
        ),
      );
      
      // Find and tap the checkbox
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);
      await tester.tap(checkboxFinder);
      await tester.pump();
      
      // Verify the toggle function was called
      verify(mockTaskService.toggleTaskStatus(testTask.id)).called(1);
    });
  });
} 