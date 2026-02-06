import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_app/models/record.dart';

class RecordRepository {
  final _client = Supabase.instance.client;

  /// READ – Get all records with vendor names
  Future<List<RecordModel>> fetchRecords() async {
    final res = await _client
        .from('records')
        .select('*, vendors(name)') // Join with vendors table to get the name
        .order('id', ascending: false);

    return (res as List)
        .map((e) => RecordModel.fromJson(e))
        .toList();
  }

  /// CREATE – Insert new record
  Future<void> addRecord(RecordModel record) async {
    await _client.from('records').insert(record.toJson());
  }

  /// UPDATE – Update record
  Future<void> updateRecord(RecordModel record) async {
    await _client
        .from('records')
        .update(record.toJson())
        .eq('id', record.id);
  }

  /// UPDATE STATUS ONLY
  Future<void> updateStatus({
    required String recordId,
    required String status,
    String? actualReturnDate,
  }) async {
    await _client.from('records').update({
      'status': status,
      'actual_return_date': actualReturnDate,
    }).eq('id', recordId);
  }

  /// DELETE – Admin only (RLS enforced)
  Future<void> deleteRecord(String id) async {
    await _client.from('records').delete().eq('id', id);
  }
}
