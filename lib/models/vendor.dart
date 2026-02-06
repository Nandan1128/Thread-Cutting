class VendorModel{
  final String id;
  final String name;
  final String contact;
  final String email;
  final String address;
  final double ratePerPiece;

  VendorModel({
    required this.id,
    required this.name,
    required this.contact,
    required this.email,
    required this.address,
    required this.ratePerPiece,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] as String,
      name: json['name'],
      contact: json['contact'],
      email: json['email'],
      address: json['address'],
      ratePerPiece: (json['rate_per_piece'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contact': contact,
      'email': email,
      'address': address,
      'rate_per_piece': ratePerPiece,
    };
  }
}
