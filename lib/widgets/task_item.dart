import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import '../constants/app_constants.dart';
import '../utils/date_utils.dart';
import 'task_form.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  
  const TaskItem({Key? key, required this.task}) : super(key: key);

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
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: task.getPriorityColor().withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              task.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: task.getPriorityColor(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: isOverdue 
                                ? Colors.red 
                                : (isDueSoon ? Colors.orange : Colors.grey),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppDateUtils.getRelativeDateString(task.dueDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue 
                                  ? Colors.red 
                                  : (isDueSoon ? Colors.orange : Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.duration} min',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Right side
                Column(
                  children: [
                    // Priority indicator
                    Container(
                      width: 8,
                      height: 40,
                      decoration: BoxDecoration(
                        color: task.isCompleted 
                            ? Colors.grey.withOpacity(0.3) 
                            : task.getPriorityColor(),
                        borderRadius: BorderRadius.circular(4),
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
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: const Text(
                            'OVERDUE',
                            style: TextStyle(
                              color: Colors.red,
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
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: const Text(
                            'SOON',
                            style: TextStyle(
                              color: Colors.orange,
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
} 