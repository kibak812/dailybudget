import 'package:isar_community/isar.dart';

part 'budget_model.g.dart';

@Collection()
class BudgetModel {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('month')])
  late int year;

  late int month;

  late int amount;

  BudgetModel({
    required this.year,
    required this.month,
    required this.amount,
  });

  BudgetModel.empty()
      : year = DateTime.now().year,
        month = DateTime.now().month,
        amount = 0;

  /// Composite key helper: year_month (e.g., "2024_11")
  String get compositeKey => '${year}_$month';

  @override
  String toString() => 'Budget($year-$month: $amount원)';
}
