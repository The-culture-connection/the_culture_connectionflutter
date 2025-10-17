/// Experience levels for user profiles
class ExperienceLevels {
  static const String entryLevel = 'Entry-Level';
  static const String midLevel = 'Mid-Level';
  static const String seniorLevel = 'Senior-Level';
  static const String executive = 'Executive';

  static const List<String> all = [
    entryLevel,
    midLevel,
    seniorLevel,
    executive,
  ];

  /// Get icon for experience level
  static String getIcon(String level) {
    switch (level) {
      case entryLevel:
        return '🌱';
      case midLevel:
        return '📈';
      case seniorLevel:
        return '⭐';
      case executive:
        return '👑';
      default:
        return '📊';
    }
  }

  /// Get description for experience level
  static String getDescription(String level) {
    switch (level) {
      case entryLevel:
        return '0-2 years of experience';
      case midLevel:
        return '3-7 years of experience';
      case seniorLevel:
        return '8-15 years of experience';
      case executive:
        return '15+ years of experience, leadership roles';
      default:
        return '';
    }
  }
}
