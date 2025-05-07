class ValidationUtils {
  // Validate that string is not empty
  static String? validateNonEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
  
  // Validate that a string can be parsed as an integer
  static String? validateInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a valid number for $fieldName';
    }
    return null;
  }
  
  // Validate that a string can be parsed as a positive integer
  static String? validatePositiveInteger(String? value, String fieldName) {
    final intError = validateInteger(value, fieldName);
    if (intError != null) {
      return intError;
    }
    
    if (int.parse(value!) <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }
  
  // Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    
    // Simple email regex
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  // Validate min length
  static String? validateMinLength(String? value, String fieldName, int minLength) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    return null;
  }
} 