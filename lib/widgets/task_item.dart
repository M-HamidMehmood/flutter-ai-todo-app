import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import '../constants/app_constants.dart';
import '../utils/date_utils.dart';
import 'task_form.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  
  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context, listen: false);
    final notificationService = NotificationService();

    // Calculate if task is due soon (within 24 hours)
    final isDueSoon = AppDateUtils.isDueSoon(task.dueDate);
    
    // Calculate if task is overdue
    final isOverdue = AppDateUtils.isOverdue(task.dueDate) && !task.isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.defaultPadding, 
        vertical: UIConstants.smallPadding,
      ),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            // Edit action
            SlidableAction(
              onPressed: (context) => _editTask(context),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            // Delete action
            SlidableAction(
              onPressed: (context) {
                taskService.deleteTask(task.id);
                notificationService.cancelTaskReminder(task);
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
          ],
        ),
        child: Card(
          elevation: UIConstants.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
            side: BorderSide(
              color: task.isCompleted 
                  ? Colors.grey.withOpacity(0.3)
                  : task.getPriorityColor().withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(UIConstants.defaultPadding),
            child: Row(
              children: [
                // Checkbox
                Container(
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? Colors.grey.withOpacity(0.1)
                        : task.getPriorityColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Checkbox(
                    value: task.isCompleted,
                    activeColor: task.getPriorityColor(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (value) {
                      taskService.toggleTaskStatus(task.id);
                      
                      // Cancel notification if task is completed
                      if (value == true) {
                        notificationService.cancelTaskReminder(task);
                      } else {
                        // Re-schedule notification if uncompleted and due in future
                        if (task.dueDate.isAfter(DateTime.now())) {
                          notificationService.scheduleTaskReminder(task);
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: UIConstants.smallPadding),
                
                // Task details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with decoration if completed
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : TextDecoration.none,
                          color: task.isCompleted 
                              ? Colors.grey 
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Category and due date
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, 
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: CategoryConstants.getCategoryColor(task.category),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  task.category == 'Work' ? Icons.work :
                                  task.category == 'Study' ? Icons.school :
                                  Icons.person,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  task.category,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: isOverdue 
                                ? Colors.red 
                                : (isDueSoon ? Colors.orange : Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppDateUtils.getRelativeDateString(task.dueDate),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isOverdue || isDueSoon ? FontWeight.w600 : FontWeight.normal,
                              color: isOverdue 
                                  ? Colors.red 
                                  : (isDueSoon ? Colors.orange : Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.duration} min',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Right side - Priority indicator with label
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Priority badge with icon and text
                    Tooltip(
                      message: '${task.getPriorityText()} Priority',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: task.isCompleted 
                              ? Colors.grey.withOpacity(0.1) 
                              : task.getPriorityColor().withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: task.isCompleted 
                                ? Colors.grey.withOpacity(0.3) 
                                : task.getPriorityColor().withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              task.priority == PriorityConstants.high
                                  ? Icons.keyboard_double_arrow_up
                                  : task.priority == PriorityConstants.medium
                                      ? Icons.remove
                                      : Icons.keyboard_double_arrow_down,
                              size: 14,
                              color: task.isCompleted 
                                  ? Colors.grey 
                                  : task.getPriorityColor(),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.getPriorityText(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: task.isCompleted 
                                    ? Colors.grey 
                                    : task.getPriorityColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    if (isOverdue && !task.isCompleted)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.red.withOpacity(0.5), width: 1),
                          ),
                          child: Text(
                            'OVERDUE',
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    
                    if (isDueSoon && !task.isCompleted && !isOverdue)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1),
                          ),
                          child: Text(
                            'SOON',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _editTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskForm(task: task),
      ),
    );
  }

  // Helper method to ensure dark text color
  Color darkenColor(Color color) {
    // Check if color is light
    if (color.computeLuminance() > 0.5) {
      // If light color, darken it
      final HSLColor hsl = HSLColor.fromColor(color);
      return hsl.withLightness((hsl.lightness - 0.3).clamp(0.0, 1.0)).toColor();
    }
    return color;
  }
} 