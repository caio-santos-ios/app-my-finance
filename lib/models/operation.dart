class Operation {
  final String id;
  final String description;
  final String bankId;
  final String? destinationBankId;
  final String categoryId;
  final String categoryName;
  final String type;
  final DateTime createdAt;
  final double value;
  final bool repeat;

  Operation({
    required this.id,
    required this.description,
    required this.type,
    required this.bankId,
    this.destinationBankId,
    required this.categoryId,
    required this.value,
    this.repeat = false,
    required this.categoryName,
    required this.createdAt,
  });

  factory Operation.fromJson(Map<String, dynamic> json) {
    return Operation(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      bankId: json['bankId'] ?? '',
      destinationBankId: json['destinationBankId'],
      categoryId: json['categoryId'] ?? '',
      value: json['value'] != null
          ? double.parse(json['value'].toString())
          : 0.0,
      repeat: json['repeat'] ?? false,
      categoryName: json['categoryName'],
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }
}
