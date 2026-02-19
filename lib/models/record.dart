class RecordModel {
  final String id;
  final String? date;
  final String challanNumber;
  final String clothType;
  final int quantity;
  final int receivedQuantity;
  final String vendorId;
  final String? vendorName;
  final double? vendorRate; // Added vendorRate field
  final String status;
  final String sentDate;
  final String? expectedReturnDate;
  final String? actualReturnDate;
  final String? poNumber;
  final String? notes;

  RecordModel({
    required this.id,
    this.date,
    required this.challanNumber,
    required this.clothType,
    required this.quantity,
    this.receivedQuantity = 0,
    required this.vendorId,
    this.vendorName,
    this.vendorRate,
    required this.status,
    required this.sentDate,
    this.expectedReturnDate,
    this.actualReturnDate,
    this.poNumber,
    this.notes,
  });

  RecordModel copyWith({
    String? id,
    String? date,
    String? challanNumber,
    String? clothType,
    int? quantity,
    int? receivedQuantity,
    String? vendorId,
    String? vendorName,
    double? vendorRate,
    String? status,
    String? sentDate,
    String? expectedReturnDate,
    String? actualReturnDate,
    String? poNumber,
    String? notes,
  }) {
    return RecordModel(
      id: id ?? this.id,
      date: date ?? this.date,
      challanNumber: challanNumber ?? this.challanNumber,
      clothType: clothType ?? this.clothType,
      quantity: quantity ?? this.quantity,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      vendorRate: vendorRate ?? this.vendorRate,
      status: status ?? this.status,
      sentDate: sentDate ?? this.sentDate,
      expectedReturnDate: expectedReturnDate ?? this.expectedReturnDate,
      actualReturnDate: actualReturnDate ?? this.actualReturnDate,
      poNumber: poNumber ?? this.poNumber,
      notes: notes ?? this.notes,
    );
  }

  factory RecordModel.fromJson(Map<String, dynamic> json) {
    return RecordModel(
      id: json['id'] as String,
      date: json['date'],
      challanNumber: json['challan_number'] ?? '',
      clothType: json['cloth_type'] ?? '',
      quantity: json['quantity'] ?? 0,
      receivedQuantity: json['received_quantity'] ?? 0,
      vendorId: json['vendor_id'] ?? '',
      vendorName: json['vendors']?['name'],
      vendorRate: (json['vendors']?['rate_per_piece'] as num?)?.toDouble(), // Fetch rate from joined vendor
      status: json['status'] ?? 'Sent',
      sentDate: json['sent_date'] ?? '',
      expectedReturnDate: json['expected_return_date'],
      actualReturnDate: json['actual_return_date'],
      poNumber: json['po_number'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'challan_number': challanNumber,
      'cloth_type': clothType,
      'quantity': quantity,
      'received_quantity': receivedQuantity,
      'vendor_id': vendorId,
      'status': status,
      'sent_date': sentDate,
      'expected_return_date': expectedReturnDate,
      'actual_return_date': actualReturnDate,
      'po_number': poNumber,
      'notes': notes,
    };
  }
}
