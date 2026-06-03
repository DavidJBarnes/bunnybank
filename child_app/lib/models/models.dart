class ChildBalance {
  final String childId;
  final String name;
  final double balance;

  ChildBalance({required this.childId, required this.name, required this.balance});

  factory ChildBalance.fromJson(Map<String, dynamic> json) {
    return ChildBalance(
      childId: json['child_id'],
      name: json['name'],
      balance: (json['balance'] as num).toDouble(),
    );
  }
}

class Transaction {
  final String id;
  final String childId;
  final String reasonId;
  final double amount;
  final String createdAt;

  Transaction({
    required this.id,
    required this.childId,
    required this.reasonId,
    required this.amount,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      childId: json['child_id'],
      reasonId: json['reason_id'],
      amount: (json['amount'] as num).toDouble(),
      createdAt: json['created_at'],
    );
  }
}
