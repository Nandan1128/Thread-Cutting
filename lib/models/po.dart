class POModel {
  final String id;
  final String poNumber;
  final int totalQuantity;
  final String createdAt;
  final String? color;

  POModel({
    required this.id,
    required this.poNumber,
    required this.totalQuantity,
    required this.createdAt,
    this.color,
  });

  factory POModel.fromJson(Map<String, dynamic> json) {
    return POModel(
      id: json['id'] as String,
      poNumber: json['po_number'] as String,
      totalQuantity: json['total_quantity'] as int,
      createdAt: json['created_at'] as String,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'po_number': poNumber,
      'total_quantity': totalQuantity,
      'color': color,
    };
  }
}
