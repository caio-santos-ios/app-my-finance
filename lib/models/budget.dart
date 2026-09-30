class Budget {
  final String id;
  final String name;
  final String categoryId;
  final String? categoryName;
  final double limit;
  final double spent;
  final double remaining;
  final bool receiveAlert;
  final int alertPercentage;
  final DateTime? createdAt;

  Budget({
    required this.id,
    required this.name,
    required this.categoryId,
    this.categoryName,
    required this.limit,
    this.spent = 0.0,
    this.remaining = 0.0,
    this.receiveAlert = false,
    this.alertPercentage = 80,
    this.createdAt,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'],
      limit: json['limit'] != null ? double.parse(json['limit'].toString()) : 0.0,
      spent: json['spent'] != null ? double.parse(json['spent'].toString()) : 0.0,
      remaining: json['remaining'] != null ? double.parse(json['remaining'].toString()) : 0.0,
      receiveAlert: json['receiveAlert'] ?? false,
      alertPercentage: json['alertPercentage'] != null ? int.parse(json['alertPercentage'].toString()) : 80,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'limit': limit,
      'receiveAlert': receiveAlert,
      'alertPercentage': alertPercentage,
    };
  }
}
