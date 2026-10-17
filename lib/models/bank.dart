class Bank {
  final String id;
  final String name;
  final String code;
  final double balance;

  Bank({
    required this.id,
    required this.name,
    required this.code,
    this.balance = 0,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      balance: (json['balance'] is num)
          ? (json['balance'] as num).toDouble()
          : double.tryParse(json['balance']?.toString() ?? '0') ?? 0,
    );
  }
}
