import 'package:flutter_test/flutter_test.dart';
import 'package:smokefree/core/validators.dart';

void main() {
  group('AppValidators - Username & Doctor ID', () {
    test('Username validation returns error on empty or null', () {
      expect(AppValidators.validateUsername(null), 'Please enter your username');
      expect(AppValidators.validateUsername(''), 'Please enter your username');
      expect(AppValidators.validateUsername('   '), 'Please enter your username');
    });

    test('Username validation checks minimum and maximum length', () {
      expect(AppValidators.validateUsername('ab'), 'Username must be at least 3 characters');
      expect(AppValidators.validateUsername('a' * 26), 'Username cannot exceed 25 characters');
    });

    test('Username allows valid characters and rejects invalid symbols', () {
      expect(AppValidators.validateUsername('john_doe.99'), isNull);
      expect(AppValidators.validateUsername('john doe'), 'Letters, numbers, dots, and underscores only');
      expect(AppValidators.validateUsername('john@doe!'), 'Letters, numbers, dots, and underscores only');
    });

    test('Doctor ID validation requires at least 3 characters', () {
      expect(AppValidators.validateDoctorId(null), 'Please enter your Doctor ID');
      expect(AppValidators.validateDoctorId(''), 'Please enter your Doctor ID');
      expect(AppValidators.validateDoctorId('dr'), 'Doctor ID must be at least 3 characters');
      expect(AppValidators.validateDoctorId('DOC123'), isNull);
    });
  });

  group('AppValidators - Password & Confirm Password', () {
    test('Password validation requires at least 6 characters', () {
      expect(AppValidators.validatePassword(null), 'Please enter your password');
      expect(AppValidators.validatePassword(''), 'Please enter your password');
      expect(AppValidators.validatePassword('12345'), 'Password must be at least 6 characters');
      expect(AppValidators.validatePassword('secret123'), isNull);
    });

    test('Password complexity check works when enabled', () {
      expect(
        AppValidators.validatePassword('letters', requireComplexity: true),
        'Password must contain both letters and numbers',
      );
      expect(
        AppValidators.validatePassword('12345678', requireComplexity: true),
        'Password must contain both letters and numbers',
      );
      expect(
        AppValidators.validatePassword('pass1234', requireComplexity: true),
        isNull,
      );
    });

    test('Confirm password verifies match', () {
      expect(AppValidators.validateConfirmPassword(null, 'pass123'), 'Please confirm your password');
      expect(AppValidators.validateConfirmPassword('', 'pass123'), 'Please confirm your password');
      expect(AppValidators.validateConfirmPassword('pass999', 'pass123'), 'Passwords do not match');
      expect(AppValidators.validateConfirmPassword('pass123', 'pass123'), isNull);
    });
  });

  group('AppValidators - Email, Contact, Age, and Name', () {
    test('Email validator enforces valid format', () {
      expect(AppValidators.validateEmail(null), 'Please enter your email address');
      expect(AppValidators.validateEmail('invalid_email'), 'Please enter a valid email address');
      expect(AppValidators.validateEmail('user@domain.com'), isNull);
    });

    test('Contact validator requires exactly 10 digits', () {
      expect(AppValidators.validateContact(null), 'Please enter your contact number');
      expect(AppValidators.validateContact('12345'), 'Please enter a valid 10-digit phone number');
      expect(AppValidators.validateContact('98765432101'), 'Please enter a valid 10-digit phone number');
      expect(AppValidators.validateContact('9876543210'), isNull);
    });

    test('Age validator checks valid age range', () {
      expect(AppValidators.validateAge(null), 'Please enter your age');
      expect(AppValidators.validateAge('5'), 'Please enter a valid age (12-110)');
      expect(AppValidators.validateAge('150'), 'Please enter a valid age (12-110)');
      expect(AppValidators.validateAge('28'), isNull);
    });

    test('Name validator requires at least 2 characters', () {
      expect(AppValidators.validateName(null), 'Please enter your name');
      expect(AppValidators.validateName('A'), 'Name must be at least 2 characters');
      expect(AppValidators.validateName('Ravi Kumar'), isNull);
    });
  });
}
