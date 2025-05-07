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
  
  // CRUD Operations
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(StorageKeys.tasksKey) ?? [];
    
    _tasks = tasksJson
        .map((taskJson) => Task.fromMap(json.decode(taskJson)))
        .toList();
    
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
  
  // AI Prioritize - sort tasks by due date
  void prioritizeTasks() {
    // First sort by priority (high to low)
    _tasks.sort((a, b) => b.priority.compareTo(a.priority));
    
    // Then sort by due date (nearest first)
    _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    
    notifyListeners();
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