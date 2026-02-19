import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_app/models/record.dart';
import 'package:test_app/models/received_history.dart';

class RecordRepository {
  final _client = Supabase.instance.client;

  /// READ – Get all records with vendor names and rates
  Future<List<RecordModel>> fetchRecords() async {
    // Sorted by challan_number in descending order
    final res = await _client
        .from('records')
        .select('*, vendors(name, rate_per_piece)')
        .order('challan_number', ascending: false);

    return (res as List)
        .map((e) => RecordModel.fromJson(e))
        .toList();
  }

  /// FETCH RECEIVED HISTORY for a specific record
  Future<List<ReceivedHistoryModel>> fetchReceivedHistory(String recordId) async {
    final res = await _client
        .from('received_history')
        .select()
        .eq('record_id', recordId)
        .order('receive_date', ascending: false);

    return (res as List)
        .map((e) => ReceivedHistoryModel.fromJson(e))
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

  /// UPDATE RECEIVED QUANTITY AND ADD TO HISTORY
  Future<void> receiveQuantity({
    required String recordId,
    required int newlyReceived,
    required int totalQuantity,
    required int alreadyReceived,
    required String receiveDate,
  }) async {
    final int updatedReceived = alreadyReceived + newlyReceived;
    String newStatus = 'In Progress';
    String? actualReturnDate = receiveDate;

    if (updatedReceived >= totalQuantity) {
      newStatus = 'Returned';
    }

    // 1. Update the record
    await _client.from('records').update({
      'received_quantity': updatedReceived,
      'status': newStatus,
      'actual_return_date': actualReturnDate,
    }).eq('id', recordId);

    // 2. Add entry to history table
    await _client.from('received_history').insert({
      'record_id': recordId,
      'quantity': newlyReceived,
      'receive_date': receiveDate,
    });
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

  /// DELETE – Admin only
  Future<void> deleteRecord(String id) async {
    await _client.from('records').delete().eq('id', id);
  }
}
