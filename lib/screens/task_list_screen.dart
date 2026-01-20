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
  bool _showCompleted = false; // Toggle to show completed tasks
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
        // Get filtered tasks based on toggle
        List<Task> filteredTasks;
        if (_showCompleted) {
          filteredTasks = taskService.completedTasks;
        } else {
          filteredTasks = _selectedCategory == 'All'
              ? taskService.pendingTasks
              : taskService.getTasksByCategory(_selectedCategory);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tasks'),
            actions: [
              // AI Prioritize button (only show for pending tasks)
              if (!_showCompleted)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showPrioritizeDialog(context, taskService);
                    },
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('AI Prioritize'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              // Toggle between Pending and Completed
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: UIConstants.smallPadding,
                  horizontal: UIConstants.defaultPadding,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showCompleted = false;
                              _animationController.reset();
                              _animationController.forward();
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_showCompleted
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: !_showCompleted
                                  ? [
                                      BoxShadow(
                                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pending_actions,
                                  size: 18,
                                  color: !_showCompleted 
                                      ? Colors.white 
                                      : Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Pending (${taskService.pendingTaskCount})',
                                  style: TextStyle(
                                    color: !_showCompleted 
                                        ? Colors.white 
                                        : Theme.of(context).brightness == Brightness.dark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                    fontWeight: !_showCompleted ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showCompleted = true;
                              _animationController.reset();
                              _animationController.forward();
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _showCompleted
                                  ? Colors.green
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _showCompleted
                                  ? [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: _showCompleted 
                                      ? Colors.white 
                                      : Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Completed (${taskService.completedTaskCount})',
                                  style: TextStyle(
                                    color: _showCompleted 
                                        ? Colors.white 
                                        : Theme.of(context).brightness == Brightness.dark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                    fontWeight: _showCompleted ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Category filter chips (only show for pending tasks)
              if (!_showCompleted)
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
                        final categoryColor = category == 'All' 
                            ? Theme.of(context).primaryColor
                            : CategoryConstants.getCategoryColor(category);
                        
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
                            avatar: isSelected ? null : Icon(
                              category == 'All' ? Icons.list :
                              category == 'Work' ? Icons.work :
                              category == 'Study' ? Icons.school :
                              Icons.person,
                              size: 16,
                              color: categoryColor,
                            ),
                            backgroundColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                            selectedColor: categoryColor,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade700,
                            ),
                            elevation: isSelected ? 4 : 0,
                            shadowColor: categoryColor.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? categoryColor
                                    : Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: UIConstants.smallPadding),
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
          floatingActionButton: _showCompleted 
              ? null // Hide FAB when viewing completed tasks
              : FloatingActionButton(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _showCompleted ? Icons.celebration : Icons.check_circle_outline,
              size: 60,
              color: _showCompleted ? Colors.green : Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: UIConstants.defaultPadding),
          Text(
            _showCompleted ? 'No completed tasks' : 'No tasks found',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: UIConstants.smallPadding),
          Text(
            _showCompleted
                ? 'Complete some tasks to see them here'
                : _selectedCategory == 'All'
                    ? 'Add a new task to get started'
                    : 'No tasks in this category',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
          if (!_showCompleted) ...[
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
        ],
      ),
    );
  }

  void _showPrioritizeDialog(BuildContext context, TaskService taskService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'AI Prioritize',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const Text(
              'AI will analyze your tasks and:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildFeatureRow(Icons.schedule, 'Update priorities based on due dates', Colors.orange),
            const SizedBox(height: 12),
            _buildFeatureRow(Icons.text_fields, 'Detect urgent keywords in titles', Colors.red),
            const SizedBox(height: 12),
            _buildFeatureRow(Icons.sort, 'Sort tasks by importance', Colors.blue),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tasks due soon will become HIGH priority!',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('AI is analyzing tasks...'),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.deepPurple,
                  duration: const Duration(seconds: 1),
                ),
              );
              
              // Run AI prioritization
              await taskService.prioritizeTasks();
              
              // Re-schedule notifications for pending tasks
              _rescheduleNotifications(taskService.pendingTasks);
              
              // Reset animation
              _animationController.reset();
              _animationController.forward();
              
              // Show success
              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Tasks prioritized & sorted by AI!'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Run AI'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper widget for AI dialog feature rows
  Widget _buildFeatureRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
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