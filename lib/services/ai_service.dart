import '../constants/app_constants.dart';

/// AI Service - Simple rule-based AI for task management
/// 
/// This service uses keyword matching and rule-based logic to provide
/// intelligent suggestions for tasks. Easy to explain:
/// 
/// 1. Priority Suggestion: Looks for urgent keywords → suggests priority
/// 2. Duration Estimation: Matches task type → estimates time needed
/// 3. Category Detection: Finds category-related words → suggests category
/// 
class AIService {
  
  // ============================================================
  // AI FEATURE 1: Smart Priority Suggestion
  // ============================================================
  // How it works: Scans task title for keywords that indicate urgency
  // - "urgent", "asap", "important" → High Priority
  // - "soon", "this week" → Medium Priority  
  // - "someday", "later", "maybe" → Low Priority
  // ============================================================
  
  static AIPrioritySuggestion suggestPriority(String title) {
    final titleLower = title.toLowerCase();
    
    // High priority keywords
    final highPriorityKeywords = [
      'urgent', 'asap', 'important', 'critical', 'deadline', 
      'emergency', 'immediately', 'today', 'now', 'priority',
      'must', 'required', 'essential', 'crucial'
    ];
    
    // Low priority keywords
    final lowPriorityKeywords = [
      'someday', 'later', 'maybe', 'optional', 'whenever',
      'free time', 'not urgent', 'low priority', 'eventually',
      'if possible', 'consider'
    ];
    
    // Check for high priority keywords
    for (var keyword in highPriorityKeywords) {
      if (titleLower.contains(keyword)) {
        return AIPrioritySuggestion(
          priority: PriorityConstants.high,
          reason: 'Found "$keyword" - suggests high priority',
          confidence: 0.9,
        );
      }
    }
    
    // Check for low priority keywords
    for (var keyword in lowPriorityKeywords) {
      if (titleLower.contains(keyword)) {
        return AIPrioritySuggestion(
          priority: PriorityConstants.low,
          reason: 'Found "$keyword" - suggests low priority',
          confidence: 0.8,
        );
      }
    }
    
    // Default to medium priority
    return AIPrioritySuggestion(
      priority: PriorityConstants.medium,
      reason: 'No urgency keywords found - default priority',
      confidence: 0.5,
    );
  }
  
  // ============================================================
  // AI FEATURE 2: Smart Duration Estimation
  // ============================================================
  // How it works: Matches task type based on keywords
  // - "meeting", "call" → 60 minutes
  // - "email", "message" → 15 minutes
  // - "report", "project" → 120 minutes
  // ============================================================
  
  static AIDurationSuggestion suggestDuration(String title) {
    final titleLower = title.toLowerCase();
    
    // Duration lookup table (keyword → minutes)
    final durationRules = <String, DurationRule>{
      // Quick tasks (15 min)
      'email': DurationRule(15, 'Emails usually take about 15 minutes'),
      'message': DurationRule(15, 'Messages are quick tasks'),
      'reply': DurationRule(15, 'Replies are usually quick'),
      'call back': DurationRule(15, 'Quick callback'),
      
      // Short tasks (30 min)
      'review': DurationRule(30, 'Reviews take about 30 minutes'),
      'check': DurationRule(30, 'Checking tasks are moderate'),
      'update': DurationRule(30, 'Updates take about 30 minutes'),
      'fix': DurationRule(30, 'Quick fixes take about 30 minutes'),
      
      // Medium tasks (45 min)
      'feedback': DurationRule(45, 'Giving feedback takes time'),
      'analyze': DurationRule(45, 'Analysis requires focus'),
      'plan': DurationRule(45, 'Planning needs thought'),
      
      // Standard tasks (60 min / 1 hour)
      'meeting': DurationRule(60, 'Meetings typically last 1 hour'),
      'call': DurationRule(60, 'Calls usually take about 1 hour'),
      'discussion': DurationRule(60, 'Discussions need time'),
      'interview': DurationRule(60, 'Interviews are about 1 hour'),
      
      // Long tasks (90 min)
      'presentation': DurationRule(90, 'Presentations need preparation'),
      'slides': DurationRule(90, 'Creating slides takes time'),
      'design': DurationRule(90, 'Design work needs focus'),
      'write': DurationRule(90, 'Writing takes concentration'),
      
      // Extended tasks (120 min / 2 hours)
      'report': DurationRule(120, 'Reports require detailed work'),
      'document': DurationRule(120, 'Documentation is time-consuming'),
      'project': DurationRule(120, 'Projects need extended time'),
      'research': DurationRule(120, 'Research requires deep focus'),
      'study': DurationRule(120, 'Studying needs dedicated time'),
      'assignment': DurationRule(120, 'Assignments take about 2 hours'),
      'homework': DurationRule(120, 'Homework needs focus time'),
      
      // Very long tasks (180 min / 3 hours)
      'exam': DurationRule(180, 'Exam preparation is intensive'),
      'test prep': DurationRule(180, 'Test prep needs extended time'),
    };
    
    // Find matching rule
    for (var entry in durationRules.entries) {
      if (titleLower.contains(entry.key)) {
        return AIDurationSuggestion(
          duration: entry.value.minutes,
          reason: entry.value.reason,
          confidence: 0.85,
        );
      }
    }
    
    // Default duration
    return AIDurationSuggestion(
      duration: 30,
      reason: 'Default estimate for general tasks',
      confidence: 0.5,
    );
  }
  
  // ============================================================
  // AI FEATURE 3: Smart Category Detection
  // ============================================================
  // How it works: Matches keywords to categories
  // - "meeting", "client", "office" → Work
  // - "homework", "exam", "class" → Study
  // - "gym", "shopping", "family" → Personal
  // ============================================================
  
  static AICategorySuggestion suggestCategory(String title) {
    final titleLower = title.toLowerCase();
    
    // Work keywords
    final workKeywords = [
      'meeting', 'client', 'office', 'boss', 'project', 'deadline',
      'presentation', 'report', 'email', 'colleague', 'team',
      'work', 'job', 'business', 'professional', 'manager'
    ];
    
    // Study keywords
    final studyKeywords = [
      'homework', 'exam', 'class', 'lecture', 'assignment', 'study',
      'course', 'professor', 'university', 'school', 'college',
      'test', 'quiz', 'research', 'thesis', 'paper', 'learn',
      'tutorial', 'lesson', 'chapter', 'book'
    ];
    
    // Personal keywords
    final personalKeywords = [
      'gym', 'shopping', 'family', 'friend', 'home', 'clean',
      'cook', 'exercise', 'doctor', 'appointment', 'birthday',
      'grocery', 'laundry', 'relax', 'hobby', 'game', 'movie',
      'travel', 'vacation', 'personal', 'health'
    ];
    
    // Count matches for each category
    int workScore = _countMatches(titleLower, workKeywords);
    int studyScore = _countMatches(titleLower, studyKeywords);
    int personalScore = _countMatches(titleLower, personalKeywords);
    
    // Find best match
    if (workScore > studyScore && workScore > personalScore && workScore > 0) {
      return AICategorySuggestion(
        category: 'Work',
        reason: 'Found work-related keywords',
        confidence: 0.8,
      );
    } else if (studyScore > workScore && studyScore > personalScore && studyScore > 0) {
      return AICategorySuggestion(
        category: 'Study',
        reason: 'Found study-related keywords',
        confidence: 0.8,
      );
    } else if (personalScore > 0) {
      return AICategorySuggestion(
        category: 'Personal',
        reason: 'Found personal-related keywords',
        confidence: 0.8,
      );
    }
    
    // Default category
    return AICategorySuggestion(
      category: 'Personal',
      reason: 'No specific category detected - default to Personal',
      confidence: 0.4,
    );
  }
  
  // Helper: Count keyword matches
  static int _countMatches(String text, List<String> keywords) {
    int count = 0;
    for (var keyword in keywords) {
      if (text.contains(keyword)) count++;
    }
    return count;
  }
  
  // ============================================================
  // AI FEATURE 4: Get All Suggestions at Once
  // ============================================================
  
  static AITaskSuggestion analyzeTask(String title) {
    return AITaskSuggestion(
      priority: suggestPriority(title),
      duration: suggestDuration(title),
      category: suggestCategory(title),
    );
  }
}

// ============================================================
// AI Result Classes
// ============================================================

class AIPrioritySuggestion {
  final int priority;
  final String reason;
  final double confidence; // 0.0 to 1.0

  AIPrioritySuggestion({
    required this.priority,
    required this.reason,
    required this.confidence,
  });
  
  String get priorityText => PriorityConstants.priorityLabels[priority] ?? 'Medium';
}

class AIDurationSuggestion {
  final int duration; // in minutes
  final String reason;
  final double confidence;

  AIDurationSuggestion({
    required this.duration,
    required this.reason,
    required this.confidence,
  });
  
  String get durationText {
    if (duration < 60) return '$duration min';
    if (duration == 60) return '1 hour';
    if (duration < 120) return '${duration ~/ 60}h ${duration % 60}m';
    return '${duration ~/ 60} hours';
  }
}

class AICategorySuggestion {
  final String category;
  final String reason;
  final double confidence;

  AICategorySuggestion({
    required this.category,
    required this.reason,
    required this.confidence,
  });
}

class AITaskSuggestion {
  final AIPrioritySuggestion priority;
  final AIDurationSuggestion duration;
  final AICategorySuggestion category;

  AITaskSuggestion({
    required this.priority,
    required this.duration,
    required this.category,
  });
}

// Helper class for duration rules
class DurationRule {
  final int minutes;
  final String reason;
  
  DurationRule(this.minutes, this.reason);
}
