class POModel {
  final String id;
  final String poNumber;
  final int totalQuantity;
  final String createdAt;

  POModel({
    required this.id,
    required this.poNumber,
    required this.totalQuantity,
    required this.createdAt,
  });

  factory POModel.fromJson(Map<String, dynamic> json) {
    return POModel(
      id: json['id'] as String,
      poNumber: json['po_number'] as String,
      totalQuantity: json['total_quantity'] as int,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'po_number': poNumber,
      'total_quantity': totalQuantity,
    };
  }
}
