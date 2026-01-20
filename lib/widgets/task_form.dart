import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import '../services/ai_service.dart';
import '../constants/app_constants.dart';
import '../utils/validation_utils.dart';
import '../utils/date_utils.dart';

class TaskForm extends StatefulWidget {
  final Task? task; // If provided, we're editing an existing task

  const TaskForm({super.key, this.task});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  // ============================================================
  // FORM STATE VARIABLES
  // ============================================================
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  
  // Task properties state
  late String _category;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  late int _priority;
  late int _duration;
  
  // ============================================================
  // AI STATE VARIABLES
  // ============================================================
  // Stores the current AI suggestion based on task title
  AITaskSuggestion? _aiSuggestion;
  
  // Controls visibility of AI suggestions card
  bool _showAISuggestions = false;
  
  // Flag to check if AI is enabled (only for new tasks)
  bool _isAIEnabled = false;

  // ============================================================
  // INIT STATE - Initialize all state variables
  // ============================================================
  @override
  void initState() {
    super.initState();
    
    if (widget.task != null) {
      // --------------------------------------------------------
      // EDITING EXISTING TASK - Load saved values
      // --------------------------------------------------------
      _initializeForEditMode();
    } else {
      // --------------------------------------------------------
      // CREATING NEW TASK - Set defaults & enable AI
      // --------------------------------------------------------
      _initializeForCreateMode();
    }
  }
  
  /// Initialize state for editing an existing task
  void _initializeForEditMode() {
    // Load existing task data into state
    _titleController.text = widget.task!.title;
    _category = widget.task!.category;
    _dueDate = widget.task!.dueDate;
    _dueTime = TimeOfDay.fromDateTime(widget.task!.dueDate);
    _priority = widget.task!.priority;
    _duration = widget.task!.duration;
    
    // AI is disabled for editing (already has values)
    _isAIEnabled = false;
    _showAISuggestions = false;
    _aiSuggestion = null;
  }
  
  /// Initialize state for creating a new task with AI assistance
  void _initializeForCreateMode() {
    // Set default values
    _category = CategoryConstants.categories.first;
    _dueDate = DateTime.now().add(const Duration(days: 1));
    _dueTime = TimeOfDay.now();
    _priority = PriorityConstants.medium;
    _duration = 30;
    
    // Enable AI for new tasks
    _isAIEnabled = true;
    _showAISuggestions = false;
    _aiSuggestion = null;
    
    // --------------------------------------------------------
    // AI LISTENER: Attach listener to analyze title changes
    // This triggers AI analysis whenever user types
    // --------------------------------------------------------
    _titleController.addListener(_onTitleChangedForAI);
  }

  // ============================================================
  // AI METHODS
  // ============================================================
  
  /// Called whenever the title text changes
  /// Triggers AI analysis if conditions are met
  void _onTitleChangedForAI() {
    // Only run AI if:
    // 1. AI is enabled (new task mode)
    // 2. Title has at least 3 characters
    if (_isAIEnabled && _titleController.text.length >= 3) {
      // Run AI analysis on the title
      _runAIAnalysis(_titleController.text);
    } else {
      // Hide suggestions if title is too short
      setState(() {
        _showAISuggestions = false;
      });
    }
  }
  
  /// Run AI analysis on the given title
  /// Updates state with AI suggestions
  void _runAIAnalysis(String title) {
    // Get AI suggestions using the AI Service
    final suggestion = AIService.analyzeTask(title);
    
    // Update state with new suggestions
    setState(() {
      _aiSuggestion = suggestion;
      _showAISuggestions = true;
    });
  }
  
  /// Apply all AI suggestions to the form
  void _applyAllAISuggestions() {
    if (_aiSuggestion == null) return;
    
    setState(() {
      // Apply priority suggestion
      _priority = _aiSuggestion!.priority.priority;
      
      // Apply duration suggestion
      _duration = _aiSuggestion!.duration.duration;
      
      // Apply category suggestion
      _category = _aiSuggestion!.category.category;
      
      // Hide the suggestions card after applying
      _showAISuggestions = false;
    });
    
    // Show feedback to user
    _showAIAppliedFeedback();
  }
  
  /// Apply only the priority suggestion
  void _applyPrioritySuggestion() {
    if (_aiSuggestion == null) return;
    setState(() {
      _priority = _aiSuggestion!.priority.priority;
    });
  }
  
  /// Apply only the duration suggestion
  void _applyDurationSuggestion() {
    if (_aiSuggestion == null) return;
    setState(() {
      _duration = _aiSuggestion!.duration.duration;
    });
  }
  
  /// Apply only the category suggestion
  void _applyCategorySuggestion() {
    if (_aiSuggestion == null) return;
    setState(() {
      _category = _aiSuggestion!.category.category;
    });
  }
  
  /// Show snackbar feedback when AI suggestions are applied
  void _showAIAppliedFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white),
            SizedBox(width: 8),
            Text('AI suggestions applied!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
  
  /// Dismiss AI suggestions card
  void _dismissAISuggestions() {
    setState(() {
      _showAISuggestions = false;
    });
  }

  // ============================================================
  // DISPOSE - Clean up resources
  // ============================================================
  @override
  void dispose() {
    // Remove listener before disposing
    if (_isAIEnabled) {
      _titleController.removeListener(_onTitleChangedForAI);
    }
    _titleController.dispose();
    super.dispose();
  }

  // Date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  // Time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    
    if (picked != null && picked != _dueTime) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  // Save task
  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      // Combine date and time
      final dueDateTime = DateTime(
        _dueDate.year,
        _dueDate.month,
        _dueDate.day,
        _dueTime.hour,
        _dueTime.minute,
      );
      
      final taskService = Provider.of<TaskService>(context, listen: false);
      final notificationService = NotificationService();
      
      if (widget.task == null) {
        // Create new task
        final task = Task(
          id: '',  // Will be generated by the service
          title: _titleController.text,
          category: _category,
          dueDate: dueDateTime,
          priority: _priority,
          duration: _duration,
        );
        
        taskService.addTask(task).then((_) {
          // Schedule notification if due in future
          if (dueDateTime.isAfter(DateTime.now())) {
            notificationService.scheduleTaskReminder(
              taskService.tasks.firstWhere((t) => t.title == task.title)
            );
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task added successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
      } else {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text,
          category: _category,
          dueDate: dueDateTime,
          priority: _priority,
          duration: _duration,
        );
        
        // Cancel old notification
        notificationService.cancelTaskReminder(widget.task!);
        
        taskService.updateTask(updatedTask).then((_) {
          // Re-schedule notification if not completed and due in future
          if (!updatedTask.isCompleted && dueDateTime.isAfter(DateTime.now())) {
            notificationService.scheduleTaskReminder(updatedTask);
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task updated successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
      }
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => ValidationUtils.validateNonEmpty(value, 'a title'),
                textCapitalization: TextCapitalization.sentences,
                autofocus: widget.task == null,
              ),
              const SizedBox(height: UIConstants.defaultPadding),
              
              // AI Suggestions Card (only show for new tasks)
              if (_showAISuggestions && _aiSuggestion != null && widget.task == null)
                _buildAISuggestionsCard(),
              
              // Category dropdown
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: CategoryConstants.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: CategoryConstants.getCategoryColor(category),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),
              const SizedBox(height: UIConstants.defaultPadding),
              
              // Due date picker
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                      child: Text(
                        AppDateUtils.fullDateFormat.format(_dueDate),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.defaultPadding),
              
              // Due time picker
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Time',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        _dueTime.format(context),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selectTime(context),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.defaultPadding),
              
              // Priority selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('Priority', style: TextStyle(fontSize: 16)),
                  ),
                  SegmentedButton<int>(
                    segments: [
                      ButtonSegment(
                        value: PriorityConstants.low,
                        label: const Text('Low'),
                        icon: const Icon(Icons.arrow_downward),
                      ),
                      ButtonSegment(
                        value: PriorityConstants.medium,
                        label: const Text('Medium'),
                        icon: const Icon(Icons.remove),
                      ),
                      ButtonSegment(
                        value: PriorityConstants.high,
                        label: const Text('High'),
                        icon: const Icon(Icons.arrow_upward),
                      ),
                    ],
                    selected: {_priority},
                    onSelectionChanged: (Set<int> newSelection) {
                      setState(() {
                        _priority = newSelection.first;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return PriorityConstants.priorityColors[_priority]?.withOpacity(0.2);
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.defaultPadding),
              
              // Duration field
              TextFormField(
                initialValue: _duration.toString(),
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                  helperText: 'Estimated time needed to complete this task',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => ValidationUtils.validatePositiveInteger(value, 'duration'),
                onChanged: (value) {
                  setState(() {
                    _duration = int.tryParse(value) ?? 30;
                  });
                },
              ),
              const SizedBox(height: UIConstants.defaultPadding * 1.5),
              
              // Save button
              ElevatedButton.icon(
                onPressed: _saveTask,
                icon: Icon(widget.task == null ? Icons.add_task : Icons.save),
                label: Text(
                  widget.task == null ? 'Add Task' : 'Update Task',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build AI Suggestions Card
  Widget _buildAISuggestionsCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.defaultPadding),
      color: Colors.deepPurple.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.deepPurple.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.deepPurple.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'AI Suggestions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                // Apply All button
                TextButton.icon(
                  onPressed: _applyAllAISuggestions,
                  icon: const Icon(Icons.check_circle, size: 16),
                  label: const Text('Apply All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                // Close button
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: _dismissAISuggestions,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(),
            
            // Priority suggestion
            _buildSuggestionRow(
              icon: Icons.flag,
              label: 'Priority',
              value: _aiSuggestion!.priority.priorityText,
              color: PriorityConstants.priorityColors[_aiSuggestion!.priority.priority] ?? Colors.grey,
              reason: _aiSuggestion!.priority.reason,
              onApply: _applyPrioritySuggestion,
            ),
            const SizedBox(height: 8),
            
            // Duration suggestion
            _buildSuggestionRow(
              icon: Icons.timer,
              label: 'Duration',
              value: _aiSuggestion!.duration.durationText,
              color: Colors.blue,
              reason: _aiSuggestion!.duration.reason,
              onApply: _applyDurationSuggestion,
            ),
            const SizedBox(height: 8),
            
            // Category suggestion
            _buildSuggestionRow(
              icon: Icons.category,
              label: 'Category',
              value: _aiSuggestion!.category.category,
              color: CategoryConstants.getCategoryColor(_aiSuggestion!.category.category),
              reason: _aiSuggestion!.category.reason,
              onApply: _applyCategorySuggestion,
            ),
          ],
        ),
      ),
    );
  }
  
  // Build individual suggestion row
  Widget _buildSuggestionRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required String reason,
    required VoidCallback onApply,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            reason,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add_circle_outline, size: 18, color: Colors.deepPurple.shade400),
          onPressed: onApply,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: 'Apply this suggestion',
        ),
      ],
    );
  }
} 