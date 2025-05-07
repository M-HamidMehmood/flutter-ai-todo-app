import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import '../widgets/task_item.dart';
import '../widgets/task_form.dart';
import '../constants/app_constants.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with SingleTickerProviderStateMixin {
  String _selectedCategory = 'All';
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: UIConstants.mediumAnimationDuration,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskService>(
      builder: (context, taskService, _) {
        // Get filtered tasks
        List<Task> filteredTasks = _selectedCategory == 'All'
            ? taskService.pendingTasks
            : taskService.getTasksByCategory(_selectedCategory);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tasks'),
            actions: [
              // AI Prioritize button
              IconButton(
                icon: const Icon(Icons.sort),
                tooltip: 'AI Prioritize',
                onPressed: () {
                  _showPrioritizeDialog(context, taskService);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Category filter chips
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: UIConstants.smallPadding,
                  horizontal: UIConstants.smallPadding,
                ),
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: CategoryConstants.categoriesWithAll.length,
                    itemBuilder: (context, index) {
                      final category = CategoryConstants.categoriesWithAll[index];
                      final isSelected = _selectedCategory == category;
                      
                      return Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? UIConstants.defaultPadding : UIConstants.smallPadding,
                          right: index == CategoryConstants.categoriesWithAll.length - 1 
                            ? UIConstants.defaultPadding : 0,
                        ),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                              _animationController.reset();
                              _animationController.forward();
                            });
                          },
                          backgroundColor: Colors.grey.shade200,
                          selectedColor: category != 'All' 
                            ? CategoryConstants.getCategoryColor(category).withOpacity(0.2)
                            : Theme.of(context).primaryColor.withOpacity(0.2),
                          checkmarkColor: category != 'All'
                            ? CategoryConstants.getCategoryColor(category)
                            : Theme.of(context).primaryColor,
                          labelStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? (category != 'All' 
                                    ? CategoryConstants.getCategoryColor(category)
                                    : Theme.of(context).primaryColor)
                                : Colors.black87,
                          ),
                          elevation: isSelected ? 2 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected
                                  ? (category != 'All' 
                                      ? CategoryConstants.getCategoryColor(category)
                                      : Theme.of(context).primaryColor)
                                  : Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: UIConstants.defaultPadding),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Task list
              Expanded(
                child: filteredTasks.isEmpty
                    ? _buildEmptyState()
                    : FadeTransition(
                        opacity: _animation,
                        child: ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            return TaskItem(task: filteredTasks[index]);
                          },
                        ),
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TaskForm()),
              );
              // Refresh animation when returning from task form
              if (mounted) {
                _animationController.reset();
                _animationController.forward();
              }
            },
            tooltip: 'Add Task',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: UIConstants.defaultPadding),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: UIConstants.smallPadding),
          Text(
            _selectedCategory == 'All'
                ? 'Add a new task to get started'
                : 'No tasks in this category',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: UIConstants.defaultPadding * 2),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TaskForm()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.defaultPadding * 2,
                vertical: UIConstants.defaultPadding,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrioritizeDialog(BuildContext context, TaskService taskService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Prioritize'),
        content: const Text(
          'This will sort your tasks based on priority and due date. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              taskService.prioritizeTasks();
              
              // Re-schedule notifications for pending tasks
              _rescheduleNotifications(taskService.pendingTasks);
              
              Navigator.pop(context);
              
              // Reset animation
              _animationController.reset();
              _animationController.forward();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tasks prioritized successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Prioritize'),
          ),
        ],
      ),
    );
  }

  void _rescheduleNotifications(List<Task> tasks) {
    final notificationService = NotificationService();
    
    for (var task in tasks) {
      if (task.dueDate.isAfter(DateTime.now())) {
        notificationService.scheduleTaskReminder(task);
      }
    }
  }
} 