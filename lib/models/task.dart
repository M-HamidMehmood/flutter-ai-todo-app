import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class Task {
  final String id;
  final String title;
  final String category;
  final DateTime dueDate;
  final int priority; // 1 = Low, 2 = Medium, 3 = High
  bool isCompleted;
  int duration; // Task duration in minutes

  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    this.duration = 0,
  });

  // Create a copy of the task with updated values
  Task copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? dueDate,
    int? priority,
    bool? isCompleted,
    int? duration,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      duration: duration ?? this.duration,
    );
  }

  // Convert task to a map for JSON storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'priority': priority,
      'isCompleted': isCompleted,
      'duration': duration,
    };
  }

  // Create a task from a map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate']),
      priority: map['priority'],
      isCompleted: map['isCompleted'],
      duration: map['duration'] ?? 0,
    );
  }

  // Get priority color
  Color getPriorityColor() {
    return PriorityConstants.priorityColors[priority] ?? Colors.blue;
  }

  // Get priority text
  String getPriorityText() {
    return PriorityConstants.priorityLabels[priority] ?? 'Normal';
  }
} 