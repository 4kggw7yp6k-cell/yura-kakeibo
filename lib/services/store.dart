import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class KakeiboStore {
  static const _txKey='transactions';
  static const _budgetKey='monthlyBudget';
  Future<List<KakeiboTransaction>> load() async {
    final p=await SharedPreferences.getInstance();
    final raw=p.getString(_txKey);
    if(raw==null) return [];
    return (jsonDecode(raw) as List).map((e)=>KakeiboTransaction.fromJson(Map<String,dynamic>.from(e))).toList();
  }
  Future<void> save(List<KakeiboTransaction> tx) async { final p=await SharedPreferences.getInstance(); await p.setString(_txKey,jsonEncode(tx.map((e)=>e.toJson()).toList())); }
  Future<int> budget() async { final p=await SharedPreferences.getInstance(); return p.getInt(_budgetKey) ?? 100000; }
  Future<void> setBudget(int v) async { final p=await SharedPreferences.getInstance(); await p.setInt(_budgetKey,v); }
}
