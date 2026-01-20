import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../constants/app_constants.dart';

class TaskService with ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;
  
  // Filtered tasks
  List<Task> get pendingTasks => _tasks.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
  
  // Get tasks by category
  List<Task> getTasksByCategory(String category) {
    if (category == 'All') return pendingTasks;
    return pendingTasks.where((task) => task.category == category).toList();
  }
  
  // Task statistics
  int get pendingTaskCount => pendingTasks.length;
  int get completedTaskCount => completedTasks.length;
  
  // ============================================================
  // LOAD TASKS - Load from storage or create demo tasks
  // ============================================================
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(StorageKeys.tasksKey) ?? [];
    
    // If no tasks exist, load demo tasks for FYP presentation
    if (tasksJson.isEmpty) {
      _loadDemoTasks();
      await saveTasks(); // Save demo tasks to storage
    } else {
      _tasks = tasksJson
          .map((taskJson) => Task.fromMap(json.decode(taskJson)))
          .toList();
    }
    
    notifyListeners();
  }
  
  // ============================================================
  // DEMO TASKS - Sample tasks for FYP presentation
  // ============================================================
  // These tasks demonstrate AI prioritization:
  // - Mixed priorities (some wrong on purpose)
  // - Different categories
  // - Various due dates
  // When you click "AI Prioritize", it will sort them correctly!
  // ============================================================
  void _loadDemoTasks() {
    final uuid = Uuid();
    final now = DateTime.now();
    
    _tasks = [
      // ---- WORK TASKS ----
      // Low priority but URGENT (AI should make this high)
      Task(
        id: uuid.v4(),
        title: 'URGENT: Client presentation deadline',
        category: 'Work',
        dueDate: now.add(const Duration(hours: 3)), // Due very soon!
        priority: PriorityConstants.low, // Wrong priority - AI will fix
        duration: 90,
      ),
      
      // Medium priority, due later
      Task(
        id: uuid.v4(),
        title: 'Review team meeting notes',
        category: 'Work',
        dueDate: now.add(const Duration(days: 5)),
        priority: PriorityConstants.medium,
        duration: 30,
      ),
      
      // High priority but due far away
      Task(
        id: uuid.v4(),
        title: 'Prepare quarterly report',
        category: 'Work',
        dueDate: now.add(const Duration(days: 14)),
        priority: PriorityConstants.high,
        duration: 120,
      ),
      
      // ---- STUDY TASKS ----
      // Exam tomorrow - should be top priority!
      Task(
        id: uuid.v4(),
        title: 'Study for final exam - IMPORTANT',
        category: 'Study',
        dueDate: now.add(const Duration(days: 1)), // Tomorrow!
        priority: PriorityConstants.medium, // Wrong - should be high
        duration: 180,
      ),
      
      // Assignment due in 3 days
      Task(
        id: uuid.v4(),
        title: 'Complete FYP documentation',
        category: 'Study',
        dueDate: now.add(const Duration(days: 3)),
        priority: PriorityConstants.high,
        duration: 120,
      ),
      
      // Low priority study task
      Task(
        id: uuid.v4(),
        title: 'Read chapter 5 notes - optional',
        category: 'Study',
        dueDate: now.add(const Duration(days: 10)),
        priority: PriorityConstants.low,
        duration: 45,
      ),
      
      // ---- PERSONAL TASKS ----
      // Today's task
      Task(
        id: uuid.v4(),
        title: 'Doctor appointment',
        category: 'Personal',
        dueDate: now.add(const Duration(hours: 6)),
        priority: PriorityConstants.medium,
        duration: 60,
      ),
      
      // Someday task
      Task(
        id: uuid.v4(),
        title: 'Maybe go to gym later',
        category: 'Personal',
        dueDate: now.add(const Duration(days: 7)),
        priority: PriorityConstants.high, // Wrong - "maybe/later" = low
        duration: 60,
      ),
      
      // Grocery shopping
      Task(
        id: uuid.v4(),
        title: 'Buy groceries for the week',
        category: 'Personal',
        dueDate: now.add(const Duration(days: 2)),
        priority: PriorityConstants.low,
        duration: 45,
      ),
    ];
  }
  
  // ============================================================
  // RESET TO DEMO - Reset tasks to demo state (for presentation)
  // ============================================================
  Future<void> resetToDemoTasks() async {
    _tasks.clear();
    _loadDemoTasks();
    await saveTasks();
    notifyListeners();
  }
  
  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks
        .map((task) => json.encode(task.toMap()))
        .toList();
    
    await prefs.setStringList(StorageKeys.tasksKey, tasksJson);
  }
  
  Future<void> addTask(Task task) async {
    final uuid = Uuid();
    final newTask = Task(
      id: uuid.v4(),
      title: task.title,
      category: task.category,
      dueDate: task.dueDate,
      priority: task.priority,
      duration: task.duration,
    );
    
    _tasks.add(newTask);
    notifyListeners();
    await saveTasks();
  }
  
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
      notifyListeners();
      await saveTasks();
    }
  }
  
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
    await saveTasks();
  }
  
  Future<void> toggleTaskStatus(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index >= 0) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      notifyListeners();
      await saveTasks();
    }
  }
  
  // ============================================================
  // AI PRIORITIZE - Smart priority assignment and sorting
  // ============================================================
  // This method does TWO things:
  // 1. Updates priority based on due date and keywords (AI)
  // 2. Sorts tasks by priority and due date
  // ============================================================
  Future<void> prioritizeTasks() async {
    final now = DateTime.now();
    
    // Step 1: AI analyzes and updates priority for each pending task
    for (int i = 0; i < _tasks.length; i++) {
      if (!_tasks[i].isCompleted) {
        final newPriority = _calculateAIPriority(_tasks[i], now);
        
        // Update the task with new priority
        _tasks[i] = _tasks[i].copyWith(priority: newPriority);
      }
    }
    
    // Step 2: Sort tasks
    // First, separate completed and pending tasks
    final pendingTasks = _tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = _tasks.where((t) => t.isCompleted).toList();
    
    // Sort pending tasks by priority (high first) then by due date (soon first)
    pendingTasks.sort((a, b) {
      // First compare by priority (high = 3, medium = 2, low = 1)
      final priorityCompare = b.priority.compareTo(a.priority);
      if (priorityCompare != 0) return priorityCompare;
      
      // If same priority, sort by due date (sooner first)
      return a.dueDate.compareTo(b.dueDate);
    });
    
    // Combine: pending first, then completed
    _tasks = [...pendingTasks, ...completedTasks];
    
    notifyListeners();
    await saveTasks();
  }
  
  // ============================================================
  // AI PRIORITY CALCULATION
  // ============================================================
  // Rules:
  // 1. Overdue tasks → HIGH priority
  // 2. Due within 24 hours → HIGH priority
  // 3. Due within 3 days → MEDIUM priority (unless keywords say otherwise)
  // 4. Contains urgent keywords → HIGH priority
  // 5. Contains low priority keywords → LOW priority
  // 6. Default → Keep existing or MEDIUM
  // ============================================================
  int _calculateAIPriority(Task task, DateTime now) {
    final hoursUntilDue = task.dueDate.difference(now).inHours;
    final titleLower = task.title.toLowerCase();
    
    // High priority keywords
    final urgentKeywords = [
      'urgent', 'asap', 'important', 'critical', 'deadline',
      'emergency', 'immediately', 'today', 'now', 'priority',
      'must', 'required', 'essential', 'crucial', 'final'
    ];
    
    // Low priority keywords
    final lowKeywords = [
      'someday', 'later', 'maybe', 'optional', 'whenever',
      'eventually', 'if possible', 'consider', 'low priority'
    ];
    
    // Rule 1: Overdue → HIGH
    if (hoursUntilDue < 0) {
      return PriorityConstants.high;
    }
    
    // Rule 2: Due within 24 hours → HIGH
    if (hoursUntilDue <= 24) {
      return PriorityConstants.high;
    }
    
    // Rule 3: Check for urgent keywords → HIGH
    for (var keyword in urgentKeywords) {
      if (titleLower.contains(keyword)) {
        return PriorityConstants.high;
      }
    }
    
    // Rule 4: Check for low priority keywords → LOW
    for (var keyword in lowKeywords) {
      if (titleLower.contains(keyword)) {
        return PriorityConstants.low;
      }
    }
    
    // Rule 5: Due within 3 days → MEDIUM
    if (hoursUntilDue <= 72) {
      return PriorityConstants.medium;
    }
    
    // Rule 6: Due within 7 days → Keep existing or MEDIUM
    if (hoursUntilDue <= 168) {
      return task.priority; // Keep existing
    }
    
    // Rule 7: Due far away → LOW
    return PriorityConstants.low;
  }
  
  // Lookup table for duration guessing
  int guessDuration(String title) {
    // Simple lookup based on keywords
    final titleLower = title.toLowerCase();
    
    if (titleLower.contains('meeting') || titleLower.contains('call')) {
      return 60; // 1 hour
    } else if (titleLower.contains('email') || titleLower.contains('message')) {
      return 15; // 15 minutes
    } else if (titleLower.contains('report') || titleLower.contains('document')) {
      return 120; // 2 hours
    } else if (titleLower.contains('review') || titleLower.contains('feedback')) {
      return 45; // 45 minutes
    } else if (titleLower.contains('presentation') || titleLower.contains('slide')) {
      return 90; // 1.5 hours
    }
    
    // Default duration
    return 30; // 30 minutes
  }
} 