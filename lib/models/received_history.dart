class ReceivedHistoryModel {
  final String id;
  final String recordId;
  final int quantity;
  final String receiveDate;
  final String createdAt;

  ReceivedHistoryModel({
    required this.id,
    required this.recordId,
    required this.quantity,
    required this.receiveDate,
    required this.createdAt,
  });

  factory ReceivedHistoryModel.fromJson(Map<String, dynamic> json) {
    return ReceivedHistoryModel(
      id: json['id'] as String,
      recordId: json['record_id'] as String,
      quantity: json['quantity'] as int,
      receiveDate: json['receive_date'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'record_id': recordId,
      'quantity': quantity,
      'receive_date': receiveDate,
    };
  }
}
