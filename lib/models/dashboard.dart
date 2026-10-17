class Dashboard {
  final double totalAccount;
  final double totalAccountIncome;
  final double totalAccountExpense;
  final double totalMonthAccount;
  final double totalAccountMonthIncome;
  final double totalAccountMonthExpense;

  Dashboard({
    required this.totalAccount,
    required this.totalAccountIncome,
    required this.totalAccountExpense,
    required this.totalMonthAccount,
    required this.totalAccountMonthIncome,
    required this.totalAccountMonthExpense
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      totalAccount: double.parse(json["totalAccount"].toString()),
      totalMonthAccount: double.parse(json["totalMonthAccount"].toString()),
      totalAccountIncome: double.parse(json["totalAccountIncome"].toString()),
      totalAccountExpense: double.parse(json["totalAccountExpense"].toString()),
      totalAccountMonthIncome: double.parse(json["totalAccountMonthIncome"].toString()),
      totalAccountMonthExpense: double.parse(json["totalAccountMonthExpense"].toString())
    );
  }
}
