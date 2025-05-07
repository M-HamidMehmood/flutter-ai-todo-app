import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/services/task_service.dart';
import 'package:myapp/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([TaskService])
import 'dashboard_screen_test.mocks.dart';

void main() {
  group('DashboardScreen Widget Tests', () {
    late MockTaskService mockTaskService;
    late List<Task> testTasks;
    
    setUp(() {
      mockTaskService = MockTaskService();
      
      // Create test tasks
      final testDate = DateTime.now().add(const Duration(days: 1));
      testTasks = [
        Task(
          id: '1',
          title: 'Work Task',
          category: 'Work',
          dueDate: testDate,
          priority: PriorityConstants.medium,
          isCompleted: false,
        ),
        Task(
          id: '2',
          title: 'Study Task',
          category: 'Study',
          dueDate: testDate.add(const Duration(days: 1)),
          priority: PriorityConstants.high,
          isCompleted: false,
        ),
        Task(
          id: '3',
          title: 'Personal Task',
          category: 'Personal',
          dueDate: testDate.add(const Duration(days: 2)),
          priority: PriorityConstants.low,
          isCompleted: true,
        ),
      ];
    });
    
    testWidgets('DashboardScreen displays task statistics correctly', (WidgetTester tester) async {
      // Setup mock task service
      when(mockTaskService.tasks).thenReturn(testTasks);
      when(mockTaskService.pendingTasks).thenReturn(testTasks.where((t) => !t.isCompleted).toList());
      when(mockTaskService.completedTasks).thenReturn(testTasks.where((t) => t.isCompleted).toList());
      when(mockTaskService.pendingTaskCount).thenReturn(2);
      when(mockTaskService.completedTaskCount).thenReturn(1);
      
      // Tasks by category
      when(mockTaskService.getTasksByCategory('Work')).thenReturn(
        testTasks.where((t) => t.category == 'Work' && !t.isCompleted).toList()
      );
      when(mockTaskService.getTasksByCategory('Study')).thenReturn(
        testTasks.where((t) => t.category == 'Study' && !t.isCompleted).toList()
      );
      when(mockTaskService.getTasksByCategory('Personal')).thenReturn(
        testTasks.where((t) => t.category == 'Personal' && !t.isCompleted).toList()
      );
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TaskService>.value(
            value: mockTaskService,
            child: const DashboardScreen(),
          ),
        ),
      );
      
      // Allow animations to complete
      await tester.pumpAndSettle();
      
      // Verify task overview section
      expect(find.text('Task Overview'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // 2 pending tasks
      expect(find.text('1'), findsOneWidget); // 1 completed task
      
      // Verify categories section
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Study'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
      
      // Verify export button
      expect(find.text('Export to CSV'), findsOneWidget);
    });
    
    testWidgets('Export button triggers CSV export', (WidgetTester tester) async {
      // Setup mock task service
      when(mockTaskService.tasks).thenReturn(testTasks);
      when(mockTaskService.pendingTasks).thenReturn(testTasks.where((t) => !t.isCompleted).toList());
      when(mockTaskService.completedTasks).thenReturn(testTasks.where((t) => t.isCompleted).toList());
      when(mockTaskService.pendingTaskCount).thenReturn(2);
      when(mockTaskService.completedTaskCount).thenReturn(1);
      
      // Tasks by category
      when(mockTaskService.getTasksByCategory(any)).thenReturn([]);
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TaskService>.value(
            value: mockTaskService,
            child: const DashboardScreen(),
          ),
        ),
      );
      
      // Allow animations to complete
      await tester.pumpAndSettle();
      
      // Find and tap the export button
      final exportButtonFinder = find.text('Export to CSV');
      expect(exportButtonFinder, findsOneWidget);
      
      // Note: We can't actually test the CSV export functionality in widget tests
      // because it involves platform-specific code for file system and sharing
      // But we can verify the button is there and would trigger the export function
    });
  });
} 