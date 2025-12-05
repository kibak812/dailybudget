/// Status of a day based on spending vs daily budget
enum DayStatus {
  /// Future day (after today)
  future,

  /// Perfect day: net spent <= 50% of daily budget
  perfect,

  /// Safe day: 0 < net spent <= daily budget
  safe,

  /// Warning day: daily budget < net spent <= 1.5x daily budget
  warning,

  /// Danger day: net spent > 1.5x daily budget
  danger,

  /// No budget set for this month OR daily budget <= 0
  noBudget,
}
