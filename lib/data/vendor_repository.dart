import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vendor.dart';

class VendorRepository {
  final _client = Supabase.instance.client;

  /// READ
  Future<List<VendorModel>> fetchVendors() async {
    final res = await _client.from('vendors').select().order('name');
    return (res as List)
        .map((e) => VendorModel.fromJson(e))
        .toList();
  }

  /// CREATE
  Future<void> addVendor(VendorModel vendor) async {
    await _client.from('vendors').insert(vendor.toJson());
  }

  /// UPDATE
  Future<void> updateVendor(VendorModel vendor) async {
    await _client
        .from('vendors')
        .update(vendor.toJson())
        .eq('id', vendor.id);
  }

  /// DELETE (admin-only via RLS)
  Future<void> deleteVendor(String id) async {
    await _client.from('vendors').delete().eq('id', id);
  }
}
