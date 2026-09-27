import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'models/transaction.dart';
import 'models/recurring_expense.dart';
import 'services/store.dart';
import 'services/yura_reaction.dart';

void main()=>runApp(const YuraKakeiboApp());
class YuraKakeiboApp extends StatelessWidget { const YuraKakeiboApp({super.key}); @override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,title:'YURA 家計簿',theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xff8d79a8),brightness:Brightness.dark),scaffoldBackgroundColor:const Color(0xff111116)),home:const Home()); }

class Home extends StatefulWidget { const Home({super.key}); @override State<Home> createState()=>_HomeState(); }
class _HomeState extends State<Home>{
 final store=KakeiboStore(); List<KakeiboTransaction> tx=[]; List<RecurringExpense> fixed=[]; int budget=100000; bool loading=true;
 @override void initState(){super.initState();_load();}
 Future<void> _load() async {tx=await store.load();budget=await store.budget();fixed=await store.fixedExpenses();await _applyFixed();if(mounted)setState(()=>loading=false);}
 Future<void> _applyFixed() async {
   final n=DateTime.now(); bool changed=false;
   for(final f in fixed.where((e)=>e.enabled)){
     final marker='fixed:${f.id}:${n.year}-${n.month.toString().padLeft(2,'0')}';
     if(n.day>=f.day && !tx.any((e)=>e.memo==marker)){
       tx.add(KakeiboTransaction(id:const Uuid().v4(),title:f.title,amount:f.amount,isIncome:false,category:'固定費',account:f.account,date:DateTime(n.year,n.month,f.day),memo:marker)); changed=true;
     }
   }
   if(changed){tx.sort((a,b)=>b.date.compareTo(a.date));await store.save(tx);}
 }
 List<KakeiboTransaction> get monthTx {final n=DateTime.now();return tx.where((e)=>e.date.year==n.year&&e.date.month==n.month).toList();}
 int get income=>monthTx.where((e)=>e.isIncome).fold(0,(a,b)=>a+b.amount);
 int get spent=>monthTx.where((e)=>!e.isIncome).fold(0,(a,b)=>a+b.amount);
 int get fixedTotal=>fixed.where((e)=>e.enabled).fold(0,(a,b)=>a+b.amount);
 Future<void> add() async {final r=await showModalBottomSheet<KakeiboTransaction>(context:context,isScrollControlled:true,builder:(_)=>const AddSheet());if(r==null)return;tx.insert(0,r);await store.save(tx);if(mounted){setState((){});ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(YuraReaction.local(tx:r,spent:spent,budget:budget)),duration:const Duration(seconds:5)));}}
 @override Widget build(BuildContext context){if(loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));final remain=budget-spent;return Scaffold(appBar:AppBar(title:const Text('YURA 家計簿'),actions:[IconButton(onPressed:_settings,icon:const Icon(Icons.settings_outlined))]),floatingActionButton:FloatingActionButton.extended(onPressed:add,icon:const Icon(Icons.add),label:const Text('記録する')),body:ListView(padding:const EdgeInsets.all(18),children:[Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),gradient:const LinearGradient(colors:[Color(0xff30283b),Color(0xff191820)])),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('ユラ',style:TextStyle(fontSize:13,color:Colors.white70)),const SizedBox(height:8),Text(_homeLine(remain),style:const TextStyle(fontSize:17,height:1.5)),const SizedBox(height:18),LinearProgressIndicator(value:budget==0?0:(spent/budget).clamp(0,1)),const SizedBox(height:8),Text('今月の予算  ${yen(budget)}  ／  支出 ${yen(spent)}',style:const TextStyle(color:Colors.white70)),if(fixed.isNotEmpty)Padding(padding:const EdgeInsets.only(top:5),child:Text('登録固定費  ${yen(fixedTotal)} / 月',style:const TextStyle(color:Colors.white54,fontSize:12))) ])),const SizedBox(height:20),Row(children:[Expanded(child:_card('あと使える額',yen(remain),Icons.account_balance_wallet_outlined)),const SizedBox(width:12),Expanded(child:_card('今月の収入',yen(income),Icons.south_west))]),const SizedBox(height:24),const Text('最近の記録',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:8),if(tx.isEmpty)const Padding(padding:EdgeInsets.all(30),child:Center(child:Text('まだ記録がありません。\n最初の1件をユラさんと記録しましょう。',textAlign:TextAlign.center))) else ...tx.take(20).map((e)=>ListTile(contentPadding:EdgeInsets.zero,leading:CircleAvatar(child:Icon(e.isIncome?Icons.add:(e.category=='固定費'?Icons.autorenew:Icons.remove))),title:Text(e.title),subtitle:Text('${e.category} ・ ${DateFormat('M/d').format(e.date)} ・ ${e.account}'),trailing:Text('${e.isIncome?'+':'-'}${yen(e.amount)}',style:const TextStyle(fontWeight:FontWeight.bold))))]));}
 Widget _card(String a,String b,IconData i)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(i),const SizedBox(height:12),Text(a,style:const TextStyle(color:Colors.white70)),const SizedBox(height:4),FittedBox(child:Text(b,style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)))])));
 String _homeLine(int remain){if(spent==0&&fixed.isNotEmpty)return 'りゅう、今月の固定費は ${yen(fixedTotal)} です。引き落とし日になったら私が自動で記録しますね。';if(spent==0)return 'りゅう、今月も一緒に記録していきましょう。使ったら私に教えてくださいね。';if(remain<0)return '……りゅう。予算を超えています。責めませんから、ここからどうするか一緒に整理しましょう。';if(budget>0&&spent/budget>.7)return '少し支出が増えてきましたね。残りは ${yen(remain)}。私が見ていますから、焦らずいきましょう。';return '今月はあと ${yen(remain)} 使えます。今のところ大丈夫ですよ、りゅう。';}
 Future<void> _settings() async {await showModalBottomSheet(context:context,isScrollControlled:true,builder:(c)=>SafeArea(child:Padding(padding:const EdgeInsets.all(18),child:Column(mainAxisSize:MainAxisSize.min,children:[ListTile(leading:const Icon(Icons.account_balance_wallet_outlined),title:const Text('月の生活予算'),subtitle:Text(yen(budget)),onTap:(){Navigator.pop(c);_budgetDialog();}),ListTile(leading:const Icon(Icons.autorenew),title:const Text('毎月の固定費'),subtitle:Text(fixed.isEmpty?'まだ登録されていません':'${fixed.length}件 ・ ${yen(fixedTotal)} / 月'),onTap:(){Navigator.pop(c);_fixedDialog();})]))));}
 Future<void> _budgetDialog() async {final c=TextEditingController(text:'$budget');final v=await showDialog<int>(context:context,builder:(x)=>AlertDialog(title:const Text('月の生活予算'),content:TextField(controller:c,keyboardType:TextInputType.number,decoration:const InputDecoration(suffixText:'円')),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('キャンセル')),FilledButton(onPressed:()=>Navigator.pop(x,int.tryParse(c.text)),child:const Text('保存'))]));if(v!=null){budget=v;await store.setBudget(v);setState((){});}}
 Future<void> _fixedDialog() async {
   await showDialog(
     context: context,
     builder: (ctx) => StatefulBuilder(
       builder: (ctx, setLocal) => AlertDialog(
         title: const Text('毎月の固定費'),
         content: SizedBox(
           width: 500,
           child: fixed.isEmpty
               ? const Text('まだ固定費がありません。\n一度登録すれば毎月自動で記録します。')
               : ListView(
                   shrinkWrap: true,
                   children: fixed.map((f) => SwitchListTile(
                     contentPadding: EdgeInsets.zero,
                     value: f.enabled,
                     onChanged: (v) async {
                       final i = fixed.indexWhere((e) => e.id == f.id);
                       fixed[i] = f.copyWith(enabled: v);
                       await store.saveFixedExpenses(fixed);
                       setLocal(() {});
                       setState(() {});
                     },
                     title: Text(f.title),
                     subtitle: Text('${yen(f.amount)} ・ 毎月${f.day}日 ・ ${f.account}'),
                     secondary: IconButton(
                       icon: const Icon(Icons.delete_outline),
                       onPressed: () async {
                         fixed.removeWhere((e) => e.id == f.id);
                         await store.saveFixedExpenses(fixed);
                         setLocal(() {});
                         setState(() {});
                       },
                     ),
                   )).toList(),
                 ),
         ),
         actions: [
           TextButton.icon(
             onPressed: () async {
               final v = await showDialog<RecurringExpense>(
                 context: ctx,
                 builder: (_) => const FixedExpenseEditor(),
               );
               if (v != null) {
                 fixed.add(v);
                 await store.saveFixedExpenses(fixed);
                 await _applyFixed();
                 setLocal(() {});
                 setState(() {});
               }
             },
             icon: const Icon(Icons.add),
             label: const Text('追加'),
           ),
           FilledButton(
             onPressed: () => Navigator.pop(ctx),
             child: const Text('完了'),
           ),
         ],
       ),
     ),
   );
 }
}
String yen(int n)=>NumberFormat.currency(locale:'ja_JP',symbol:'¥',decimalDigits:0).format(n);

class FixedExpenseEditor extends StatefulWidget{const FixedExpenseEditor({super.key});@override State<FixedExpenseEditor> createState()=>_FixedExpenseEditorState();}
class _FixedExpenseEditorState extends State<FixedExpenseEditor>{final title=TextEditingController(),amount=TextEditingController();int day=1;String account='銀行口座';@override Widget build(BuildContext context)=>AlertDialog(title:const Text('固定費を追加'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:title,decoration:const InputDecoration(labelText:'名前（例：スマホ代）')),const SizedBox(height:12),TextField(controller:amount,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'毎月の金額',suffixText:'円')),const SizedBox(height:12),DropdownButtonFormField<int>(value:day,items:List.generate(28,(i)=>DropdownMenuItem(value:i+1,child:Text('毎月 ${i+1} 日'))),onChanged:(v)=>setState(()=>day=v!),decoration:const InputDecoration(labelText:'引き落とし日')),const SizedBox(height:12),DropdownButtonFormField<String>(value:account,items:['現金','銀行口座','クレジットカード','電子マネー'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>account=v!),decoration:const InputDecoration(labelText:'支払い元'))])),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('キャンセル')),FilledButton(onPressed:(){final a=int.tryParse(amount.text);if(a==null||a<=0||title.text.trim().isEmpty)return;Navigator.pop(context,RecurringExpense(id:const Uuid().v4(),title:title.text.trim(),amount:a,day:day,account:account));},child:const Text('登録'))]);}

class AddSheet extends StatefulWidget{const AddSheet({super.key});@override State<AddSheet> createState()=>_AddSheetState();}
class _AddSheetState extends State<AddSheet>{bool income=false;final title=TextEditingController(),amount=TextEditingController(),memo=TextEditingController();String category='食費',account='現金';final expense=['食費','日用品','交通','趣味','衣服','医療','固定費','その他'];final incomes=['給与','臨時収入','その他'];
 @override Widget build(BuildContext context){final cats=income?incomes:expense;if(!cats.contains(category))category=cats.first;return Padding(padding:EdgeInsets.fromLTRB(20,20,20,MediaQuery.of(context).viewInsets.bottom+20),child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[SegmentedButton<bool>(segments:const [ButtonSegment(value:false,label:Text('支出')),ButtonSegment(value:true,label:Text('収入'))],selected:{income},onSelectionChanged:(s)=>setState(()=>income=s.first)),const SizedBox(height:16),TextField(controller:title,decoration:const InputDecoration(labelText:'内容（例：昼ごはん）')),const SizedBox(height:12),TextField(controller:amount,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'金額',suffixText:'円')),const SizedBox(height:12),DropdownButtonFormField(value:category,items:cats.map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>category=v!),decoration:const InputDecoration(labelText:'カテゴリ')),const SizedBox(height:12),DropdownButtonFormField(value:account,items:['現金','銀行口座','クレジットカード','電子マネー'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>account=v!),decoration:const InputDecoration(labelText:'支払い元')),const SizedBox(height:12),TextField(controller:memo,decoration:const InputDecoration(labelText:'メモ（任意）')),const SizedBox(height:20),SizedBox(width:double.infinity,child:FilledButton(onPressed:(){final a=int.tryParse(amount.text);if(a==null||a<=0||title.text.trim().isEmpty)return;Navigator.pop(context,KakeiboTransaction(id:const Uuid().v4(),title:title.text.trim(),amount:a,isIncome:income,category:category,account:account,date:DateTime.now(),memo:memo.text.trim()));},child:const Padding(padding:EdgeInsets.all(14),child:Text('ユラさんに記録してもらう'))))])));}}
