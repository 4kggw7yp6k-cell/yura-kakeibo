class KakeiboTransaction {
  final String id;
  final String title;
  final int amount;
  final bool isIncome;
  final String category;
  final String account;
  final DateTime date;
  final String memo;

  KakeiboTransaction({required this.id, required this.title, required this.amount, required this.isIncome, required this.category, required this.account, required this.date, this.memo = ''});

  Map<String, dynamic> toJson() => {'id':id,'title':title,'amount':amount,'isIncome':isIncome,'category':category,'account':account,'date':date.toIso8601String(),'memo':memo};
  factory KakeiboTransaction.fromJson(Map<String,dynamic> j) => KakeiboTransaction(id:j['id'], title:j['title'], amount:j['amount'], isIncome:j['isIncome'], category:j['category'], account:j['account'] ?? '現金', date:DateTime.parse(j['date']), memo:j['memo'] ?? '');
}
