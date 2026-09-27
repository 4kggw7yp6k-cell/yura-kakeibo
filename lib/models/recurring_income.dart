class RecurringIncome {
  final String id;
  final String title;
  final int amount;
  final int day;
  final String account;
  final bool enabled;

  const RecurringIncome({
    required this.id,
    required this.title,
    required this.amount,
    required this.day,
    required this.account,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'day': day,
        'account': account,
        'enabled': enabled,
      };

  factory RecurringIncome.fromJson(Map<String, dynamic> j) => RecurringIncome(
        id: j['id'],
        title: j['title'],
        amount: j['amount'],
        day: j['day'] ?? 1,
        account: j['account'] ?? '銀行口座',
        enabled: j['enabled'] ?? true,
      );

  RecurringIncome copyWith({
    String? title,
    int? amount,
    int? day,
    String? account,
    bool? enabled,
  }) =>
      RecurringIncome(
        id: id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        day: day ?? this.day,
        account: account ?? this.account,
        enabled: enabled ?? this.enabled,
      );
}
