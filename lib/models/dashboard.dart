import 'package:finance/models/operation.dart';

class Dashboard {
  final double totalAccount;
  final double totalAccountIncome;
  final double totalAccountExpense;

  Dashboard({
    required this.totalAccount,
    required this.totalAccountIncome,
    required this.totalAccountExpense
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      totalAccount: double.parse(json["totalAccount"].toString()),
      totalAccountIncome: double.parse(json["totalAccountIncome"].toString()),
      totalAccountExpense: double.parse(json["totalAccountExpense"].toString()),
    );
  }
}
