/// Card transaction information parsed from SMS
class CardTransactionInfo {
  final String cardCompany;
  final int amount;
  final String merchantName;
  final DateTime transactionTime;
  final String originalMessage;

  CardTransactionInfo({
    required this.cardCompany,
    required this.amount,
    required this.merchantName,
    required this.transactionTime,
    required this.originalMessage,
  });

  @override
  String toString() =>
      'CardTransaction($cardCompany, $amount원, $merchantName, ${transactionTime.toString().split('.')[0]})';
}
