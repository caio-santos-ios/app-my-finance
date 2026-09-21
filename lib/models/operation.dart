class Operation {
  final String id;
  final String description;
  final String bankId;
  final String categoryId;
  final String type;
  final double value;

  Operation({
    required this.id,
    required this.description,
    required this.type,
    required this.bankId,
    required this.categoryId,
    required this.value,
  });

  factory Operation.fromJson(Map<String, dynamic> json) {
    return Operation(
      id: json['id'],
      description: json['description'],
      type: json['type'],
      bankId: json['bankId'],
      categoryId: json['categoryId'],
      value: double.parse(json['value'].toString()),
    );
  }
}
