import 'package:isar/isar.dart';

part 'transaction_model.g.dart';

enum TransactionType {
  expense,
  income,
}

@Collection()
class TransactionModel {
  Id id = Isar.autoIncrement;

  @Enumerated(EnumType.name)
  late TransactionType type;

  late int amount;

  /// Date in "YYYY-MM-DD" format
  @Index()
  late String date;

  String? category;

  String? memo;

  late DateTime createdAt;

  late DateTime updatedAt;

  /// ID of recurring transaction if this was auto-generated
  String? recurringId;

  TransactionModel({
    required this.type,
    required this.amount,
    required this.date,
    this.category,
    this.memo,
    required this.createdAt,
    required this.updatedAt,
    this.recurringId,
  });

  factory TransactionModel.create({
    required TransactionType type,
    required int amount,
    required String date,
    String? category,
    String? memo,
    String? recurringId,
  }) {
    final now = DateTime.now();
    return TransactionModel(
      type: type,
      amount: amount,
      date: date,
      category: category,
      memo: memo,
      createdAt: now,
      updatedAt: now,
      recurringId: recurringId,
    );
  }

  TransactionModel.empty()
      : type = TransactionType.expense,
        amount = 0,
        date = DateTime.now().toIso8601String().split('T')[0],
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  /// Get year from date (YYYY-MM-DD)
  int get year => int.parse(date.split('-')[0]);

  /// Get month from date (YYYY-MM-DD)
  int get month => int.parse(date.split('-')[1]);

  /// Get day from date (YYYY-MM-DD)
  int get day => int.parse(date.split('-')[2]);

  @override
  String toString() =>
      'Transaction(${type.name}, $amount원, $date, ${category ?? "미분류"})';
}
