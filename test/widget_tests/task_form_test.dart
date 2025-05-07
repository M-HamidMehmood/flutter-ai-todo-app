import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/widgets/task_form.dart';
import 'package:myapp/services/task_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/constants/app_constants.dart';
import 'package:provider/provider.dart';

@GenerateMocks([TaskService, NotificationService])
import 'task_form_test.mocks.dart';

void main() {
  group('TaskForm Widget Tests', () {
    late MockTaskService mockTaskService;
    late MockNotificationService mockNotificationService;
    
    setUp(() {
      mockTaskService = MockTaskService();
      mockNotificationService = MockNotificationService();
    });
    
    testWidgets('TaskForm displays all form fields for a new task', (WidgetTester tester) async {
      // Add task setup
      when(mockTaskService.guessDuration(any)).thenReturn(30);
      when(mockTaskService.addTask(any)).thenAnswer((_) => Future.value());
      when(mockTaskService.tasks).thenReturn([]);
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TaskService>.value(value: mockTaskService),
            ],
            child: const TaskForm(),
          ),
        ),
      );
      
      // Verify the form has all fields
      expect(find.text('Add Task'), findsOneWidget);
      expect(find.byIcon(Icons.title), findsOneWidget);
      expect(find.text('Task Title'), findsOneWidget);
      
      // Check for category dropdown
      expect(find.text(CategoryConstants.categories.first), findsOneWidget);
      
      // Check for priority selection
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget); // Default is medium priority
      
      // Check for duration field
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('min'), findsOneWidget);
      
      // Save button
      expect(find.text('Save'), findsOneWidget);
    });
    
    testWidgets('TaskForm shows validation errors if submitted empty', (WidgetTester tester) async {
      // Add task setup
      when(mockTaskService.guessDuration(any)).thenReturn(30);
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TaskService>.value(value: mockTaskService),
            ],
            child: const TaskForm(),
          ),
        ),
      );
      
      // Try to save without entering a title
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      
      // Verify validation error appears
      expect(find.text('Please enter a title'), findsOneWidget);
    });
    
    testWidgets('TaskForm loads existing task data when editing', (WidgetTester tester) async {
      // Create a test task to edit
      final testTask = Task(
        id: 'test-id',
        title: 'Existing Task',
        category: 'Study',
        dueDate: DateTime(2025, 5, 7, 10, 30),
        priority: PriorityConstants.high,
        duration: 45,
      );
      
      // Edit task setup
      when(mockTaskService.updateTask(any)).thenAnswer((_) => Future.value());
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TaskService>.value(value: mockTaskService),
            ],
            child: TaskForm(task: testTask),
          ),
        ),
      );
      
      // Verify the form is pre-filled with existing task data
      expect(find.text('Edit Task'), findsOneWidget);
      expect(find.text('Existing Task'), findsOneWidget);
      expect(find.text('Study'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      
      // Duration should be pre-filled
      expect(find.text('45'), findsOneWidget);
    });
    
    testWidgets('TaskForm guesses duration for new tasks based on title', (WidgetTester tester) async {
      // Setup mock duration guess
      when(mockTaskService.guessDuration('Meeting with team')).thenReturn(60);
      when(mockTaskService.addTask(any)).thenAnswer((_) => Future.value());
      when(mockTaskService.tasks).thenReturn([]);
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TaskService>.value(value: mockTaskService),
            ],
            child: const TaskForm(),
          ),
        ),
      );
      
      // Enter a title that should trigger duration guess
      await tester.enterText(find.byType(TextFormField).first, 'Meeting with team');
      
      // Wait for the listener to update the state
      await tester.pumpAndSettle();
      
      // Verify the duration field was updated with the guessed value (60)
      expect(find.text('60'), findsOneWidget);
    });
  });
} 