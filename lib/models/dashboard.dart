import 'package:finance/models/operation.dart';

class Dashboard {
  final double totalAccount;
  final double totalAccountIncome;
  final double totalAccountExpense;
  final List<Operation> operations;

  Dashboard({
    required this.totalAccount,
    required this.totalAccountIncome,
    required this.totalAccountExpense,
    required this.operations,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      totalAccount: double.parse(json["totalAccount"].toString()),
      totalAccountIncome: double.parse(json["totalAccountIncome"].toString()),
      totalAccountExpense: double.parse(json["totalAccountExpense"].toString()),
      operations: (json["operations"] as List)
          .map((e) => Operation.fromJson(e))
          .toList(),
    );
  }
}
