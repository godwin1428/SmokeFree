class AppValidators {
  /// Validates username (required, 3-25 alphanumeric/underscore/dot characters)
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your username';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (trimmed.length > 25) {
      return 'Username cannot exceed 25 characters';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9._]+$');
    if (!usernameRegex.hasMatch(trimmed)) {
      return 'Letters, numbers, dots, and underscores only';
    }
    return null;
  }

  /// Validates doctor ID (required, at least 3 characters)
  static String? validateDoctorId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your Doctor ID';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Doctor ID must be at least 3 characters';
    }
    return null;
  }

  /// Validates password (required, at least 6 characters)
  static String? validatePassword(String? value, {bool requireComplexity = false}) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (requireComplexity) {
      final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
      final hasDigit = RegExp(r'[0-9]').hasMatch(value);
      if (!hasLetter || !hasDigit) {
        return 'Password must contain both letters and numbers';
      }
    }
    return null;
  }

  /// Validates password confirmation
  static String? validateConfirmPassword(String? confirmValue, String? originalPassword) {
    if (confirmValue == null || confirmValue.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmValue != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates email address format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    final trimmed = value.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates 10-digit phone number
  static String? validateContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your contact number';
    }
    final trimmed = value.trim();
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  /// Validates age (12 to 110)
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your age';
    }
    final age = int.tryParse(value.trim());
    if (age == null || age < 12 || age > 110) {
      return 'Please enter a valid age (12-110)';
    }
    return null;
  }

  /// Validates full name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
}
