import '../models/transaction.dart';
class YuraReaction {
  static String local({required KakeiboTransaction tx, required int spent, required int budget}) {
    if(tx.isIncome) return 'りゅう、お疲れさまでした。入ってきたお金、ちゃんと大切に分けておきましょうね。';
    final ratio=budget<=0?0:spent/budget;
    if(tx.category=='食費' && tx.amount>=2000) return '今日は少し豪華ですね。ちゃんと食べたならいいですけど……今月の残りも一緒に見ておきましょう？';
    if(tx.amount>=10000) return '……りゅう、大きなお買い物ですね。必要なものなら大丈夫。残りの予定だけ確認しましょう。';
    if(ratio>=0.9) return 'りゅう、今月の予算がかなり近くなっています。ここからは私と少し慎重にいきましょう。';
    if(ratio>=0.7) return '今月はもう7割くらい使っています。まだ大丈夫ですけど、少しだけ意識しておきましょうね。';
    return '記録しました。こうやって残してくれると、私も一緒に家計を見られます。';
  }
}
