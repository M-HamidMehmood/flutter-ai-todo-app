import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/constants/app_constants.dart';

void main() {
  group('Task Model Tests', () {
    final testDate = DateTime(2025, 5, 7, 10, 30);
    
    test('Task creation with required parameters', () {
      final task = Task(
        id: '1',
        title: 'Test Task',
        category: 'Work',
        dueDate: testDate,
        priority: PriorityConstants.medium,
      );
      
      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.category, 'Work');
      expect(task.dueDate, testDate);
      expect(task.priority, PriorityConstants.medium);
      expect(task.isCompleted, false); // default value
      expect(task.duration, 0); // default value
    });
    
    test('Task creation with all parameters', () {
      final task = Task(
        id: '1',
        title: 'Test Task',
        category: 'Work',
        dueDate: testDate,
        priority: PriorityConstants.high,
        isCompleted: true,
        duration: 60,
      );
      
      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.category, 'Work');
      expect(task.dueDate, testDate);
      expect(task.priority, PriorityConstants.high);
      expect(task.isCompleted, true);
      expect(task.duration, 60);
    });
    
    test('Task copyWith function', () {
      final task = Task(
        id: '1',
        title: 'Test Task',
        category: 'Work',
        dueDate: testDate,
        priority: PriorityConstants.low,
      );
      
      final updatedTask = task.copyWith(
        title: 'Updated Task',
        priority: PriorityConstants.high,
        isCompleted: true,
      );
      
      // Check changed properties
      expect(updatedTask.title, 'Updated Task');
      expect(updatedTask.priority, PriorityConstants.high);
      expect(updatedTask.isCompleted, true);
      
      // Check unchanged properties
      expect(updatedTask.id, task.id);
      expect(updatedTask.category, task.category);
      expect(updatedTask.dueDate, task.dueDate);
      expect(updatedTask.duration, task.duration);
    });
    
    test('Task toMap and fromMap conversion', () {
      final originalTask = Task(
        id: '1',
        title: 'Test Task',
        category: 'Work',
        dueDate: testDate,
        priority: PriorityConstants.medium,
        isCompleted: true,
        duration: 45,
      );
      
      final map = originalTask.toMap();
      final reconstructedTask = Task.fromMap(map);
      
      expect(reconstructedTask.id, originalTask.id);
      expect(reconstructedTask.title, originalTask.title);
      expect(reconstructedTask.category, originalTask.category);
      expect(reconstructedTask.dueDate.millisecondsSinceEpoch, 
             originalTask.dueDate.millisecondsSinceEpoch);
      expect(reconstructedTask.priority, originalTask.priority);
      expect(reconstructedTask.isCompleted, originalTask.isCompleted);
      expect(reconstructedTask.duration, originalTask.duration);
    });
    
    test('Task getPriorityColor function', () {
      final lowPriorityTask = Task(
        id: '1',
        title: 'Low Task',
        category: 'Work',
        dueDate: testDate,
        priority: PriorityConstants.low,
      );
      
      final mediumPriorityTask = Task(
        id: '2',
        title: 'Medium Task',
        category: 'Work',
        dueDate: testDate,
        priority: PriorityConstants.medium,
      );
      
      final highPriorityTask = Task(
        id: '3',
        title: 'High Task',
        category: 'Work',
        dueDate: testDate,
        priority: PriorityConstants.high,
      );
      
      expect(lowPriorityTask.getPriorityColor(), Colors.green);
      expect(mediumPriorityTask.getPriorityColor(), Colors.orange);
      expect(highPriorityTask.getPriorityColor(), Colors.red);
    });
    
    test('Task getPriorityText function', () {
      final lowPriorityTask = Task(
        id: '1',
        title: 'Low Task',
        category: 'Work',
        dueDate: testDate,
        priority: PriorityConstants.low,
      );
      
      final mediumPriorityTask = Task(
        id: '2',
        title: 'Medium Task',
        category: 'Work',
        dueDate: testDate,
        priority: PriorityConstants.medium,
      );
      
      final highPriorityTask = Task(
        id: '3',
        title: 'High Task',
        category: 'Work',
        dueDate: testDate,
        priority: PriorityConstants.high,
      );
      
      expect(lowPriorityTask.getPriorityText(), 'Low');
      expect(mediumPriorityTask.getPriorityText(), 'Medium');
      expect(highPriorityTask.getPriorityText(), 'High');
    });
  });
} 