import 'package:isar_community/isar.dart';

part 'recurring_transaction_model.g.dart';

enum RecurringTransactionType {
  expense,
  income,
}

@Collection()
class RecurringTransactionModel {
  Id id = Isar.autoIncrement;

  @Enumerated(EnumType.name)
  late RecurringTransactionType type;

  late int amount;

  /// Day of month to execute (1~31)
  late int dayOfMonth;

  String? category;

  String? memo;

  late bool isActive;

  /// Start month in "YYYY-MM" format
  late String startMonth;

  /// End month in "YYYY-MM" format (null = indefinite)
  String? endMonth;

  late DateTime createdAt;

  late DateTime updatedAt;

  RecurringTransactionModel({
    required this.type,
    required this.amount,
    required this.dayOfMonth,
    this.category,
    this.memo,
    required this.isActive,
    required this.startMonth,
    this.endMonth,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecurringTransactionModel.create({
    required RecurringTransactionType type,
    required int amount,
    required int dayOfMonth,
    String? category,
    String? memo,
    bool isActive = true,
    required String startMonth,
    String? endMonth,
  }) {
    final now = DateTime.now();
    return RecurringTransactionModel(
      type: type,
      amount: amount,
      dayOfMonth: dayOfMonth,
      category: category,
      memo: memo,
      isActive: isActive,
      startMonth: startMonth,
      endMonth: endMonth,
      createdAt: now,
      updatedAt: now,
    );
  }

  RecurringTransactionModel.empty()
      : type = RecurringTransactionType.expense,
        amount = 0,
        dayOfMonth = 1,
        isActive = true,
        startMonth = _getCurrentYearMonth(),
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  static String _getCurrentYearMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// Get year from startMonth (YYYY-MM)
  int get startYear => int.parse(startMonth.split('-')[0]);

  /// Get month from startMonth (YYYY-MM)
  int get startMonthNumber => int.parse(startMonth.split('-')[1]);

  /// Get year from endMonth (YYYY-MM), null if no endMonth
  int? get endYear => endMonth != null ? int.parse(endMonth!.split('-')[0]) : null;

  /// Get month from endMonth (YYYY-MM), null if no endMonth
  int? get endMonthNumber => endMonth != null ? int.parse(endMonth!.split('-')[1]) : null;

  @override
  String toString() =>
      'RecurringTransaction(${type.name}, $amount원, 매월 $dayOfMonth일, ${isActive ? "활성" : "비활성"})';
}
