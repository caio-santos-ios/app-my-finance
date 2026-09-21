import 'package:finance/finance_app.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  
  await Hive.openBox('settings');
  await Hive.openBox('auth');

  runApp(const FinanceApp());
}
