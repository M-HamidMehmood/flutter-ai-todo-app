import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';
import '../services/export_service.dart';
import '../constants/app_constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
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
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
          ),
          body: FadeTransition(
            opacity: _animation,
            child: ListView(
              padding: const EdgeInsets.all(UIConstants.defaultPadding),
              children: [
                _buildTaskStatistics(context, taskService),
                const SizedBox(height: UIConstants.defaultPadding * 1.5),
                _buildCategoryStatistics(context, taskService),
                const SizedBox(height: UIConstants.defaultPadding * 1.5),
                _buildExportButton(context, taskService),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskStatistics(BuildContext context, TaskService taskService) {
    return Card(
      elevation: UIConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: UIConstants.smallPadding),
                const Text(
                  'Task Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.pending_actions,
                    'Pending',
                    taskService.pendingTaskCount.toString(),
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: UIConstants.defaultPadding),
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.check_circle,
                    'Completed',
                    taskService.completedTaskCount.toString(),
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStatistics(BuildContext context, TaskService taskService) {
    return Card(
      elevation: UIConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: UIConstants.smallPadding),
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...CategoryConstants.categories.map((category) {
              final count = taskService.getTasksByCategory(category).length;
              final total = taskService.pendingTasks.length;
              final percentage = total > 0 ? (count / total * 100).round() : 0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.smallPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: CategoryConstants.getCategoryColor(category),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: UIConstants.smallPadding),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$count tasks',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CategoryConstants.getCategoryColor(category),
                          ),
                        ),
                        const SizedBox(width: UIConstants.smallPadding),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: CategoryConstants.getCategoryColor(category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: CategoryConstants.getCategoryColor(category).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: CategoryConstants.getCategoryColor(category),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: total > 0 ? count / total : 0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        CategoryConstants.getCategoryColor(category),
                      ),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                    const SizedBox(height: UIConstants.smallPadding),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(BuildContext context, TaskService taskService) {
    return Card(
      elevation: UIConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
      ),
      child: InkWell(
        onTap: () {
          ExportService.exportTasksToCSV(taskService.tasks);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exporting tasks to CSV...'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.defaultPadding),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(UIConstants.smallPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.file_download,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: UIConstants.defaultPadding),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Export to CSV',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${taskService.tasks.length} tasks',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.defaultPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: UIConstants.smallPadding),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.smallPadding),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
} 