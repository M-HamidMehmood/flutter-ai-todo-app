import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/utils/validation_utils.dart';

void main() {
  group('ValidationUtils Tests', () {
    group('validateNonEmpty', () {
      test('returns null for non-empty strings', () {
        expect(ValidationUtils.validateNonEmpty('test', 'field'), isNull);
        expect(ValidationUtils.validateNonEmpty('a', 'field'), isNull);
      });

      test('returns error message for null or empty strings', () {
        expect(ValidationUtils.validateNonEmpty(null, 'field'), 'Please enter field');
        expect(ValidationUtils.validateNonEmpty('', 'field'), 'Please enter field');
      });
    });

    group('validateInteger', () {
      test('returns null for valid integers', () {
        expect(ValidationUtils.validateInteger('123', 'field'), isNull);
        expect(ValidationUtils.validateInteger('0', 'field'), isNull);
        expect(ValidationUtils.validateInteger('-10', 'field'), isNull);
      });

      test('returns error message for non-integer values', () {
        expect(ValidationUtils.validateInteger(null, 'field'), 'Please enter field');
        expect(ValidationUtils.validateInteger('', 'field'), 'Please enter field');
        expect(ValidationUtils.validateInteger('abc', 'field'), 'Please enter a valid number for field');
        expect(ValidationUtils.validateInteger('1.23', 'field'), 'Please enter a valid number for field');
      });
    });

    group('validatePositiveInteger', () {
      test('returns null for positive integers', () {
        expect(ValidationUtils.validatePositiveInteger('1', 'field'), isNull);
        expect(ValidationUtils.validatePositiveInteger('123', 'field'), isNull);
      });

      test('returns error message for non-positive integers', () {
        expect(ValidationUtils.validatePositiveInteger(null, 'field'), 'Please enter field');
        expect(ValidationUtils.validatePositiveInteger('', 'field'), 'Please enter field');
        expect(ValidationUtils.validatePositiveInteger('abc', 'field'), 'Please enter a valid number for field');
        expect(ValidationUtils.validatePositiveInteger('0', 'field'), 'field must be greater than 0');
        expect(ValidationUtils.validatePositiveInteger('-1', 'field'), 'field must be greater than 0');
      });
    });

    group('validateEmail', () {
      test('returns null for valid email formats', () {
        expect(ValidationUtils.validateEmail('test@example.com'), isNull);
        expect(ValidationUtils.validateEmail('user@domain.co.uk'), isNull);
        expect(ValidationUtils.validateEmail('name+tag@example.org'), isNull);
      });

      test('returns error message for invalid email formats', () {
        expect(ValidationUtils.validateEmail(null), 'Please enter an email');
        expect(ValidationUtils.validateEmail(''), 'Please enter an email');
        expect(ValidationUtils.validateEmail('test'), 'Please enter a valid email address');
        expect(ValidationUtils.validateEmail('test@'), 'Please enter a valid email address');
        expect(ValidationUtils.validateEmail('@example.com'), 'Please enter a valid email address');
      });
    });

    group('validateMinLength', () {
      test('returns null when length meets minimum', () {
        expect(ValidationUtils.validateMinLength('12345', 'field', 5), isNull);
        expect(ValidationUtils.validateMinLength('123456', 'field', 5), isNull);
      });

      test('returns error message when length is too short', () {
        expect(ValidationUtils.validateMinLength(null, 'field', 5), 'Please enter field');
        expect(ValidationUtils.validateMinLength('', 'field', 5), 'Please enter field');
        expect(ValidationUtils.validateMinLength('1234', 'field', 5), 'field must be at least 5 characters');
      });
    });
  });
} 