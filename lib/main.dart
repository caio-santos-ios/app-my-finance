import 'package:finance/finance_app.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  await Hive.initFlutter();
  
  await Hive.openBox('settings');
  await Hive.openBox('auth');

  runApp(ProviderScope(child: FinanceApp()));
}
