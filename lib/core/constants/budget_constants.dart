/// Budget-related constants used throughout the app
/// Centralizes magic numbers for easy maintenance
class BudgetThresholds {
  BudgetThresholds._();

  /// Perfect status: spending at or below 50% of daily budget
  static const double perfect = 0.5;

  /// Safe status: spending at or below 100% of daily budget
  static const double safe = 1.0;

  /// Warning status: spending at or below 150% of daily budget
  static const double warning = 1.5;
}

/// Category-related constants
class CategoryConstants {
  CategoryConstants._();

  /// Threshold percentage for grouping small categories in charts
  static const double otherThreshold = 5.0;
}
