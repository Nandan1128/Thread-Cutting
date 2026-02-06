class RecordModel {
  final String id;
  final String? date; // Added date field
  final String challanNumber;
  final String clothType;
  final int quantity;
  final String vendorId;
  final String? vendorName;
  final String status;
  final String sentDate;
  final String? expectedReturnDate; // Made nullable
  final String? actualReturnDate;
  final String? poNumber;
  final String? notes;

  RecordModel({
    required this.id,
    this.date,
    required this.challanNumber,
    required this.clothType,
    required this.quantity,
    required this.vendorId,
    this.vendorName,
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
    String? vendorId,
    String? vendorName,
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
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
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
      vendorId: json['vendor_id'] ?? '',
      vendorName: json['vendors']?['name'],
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
