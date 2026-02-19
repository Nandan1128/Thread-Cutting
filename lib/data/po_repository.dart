import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/po.dart';

class PORepository {
  final _client = Supabase.instance.client;

  Future<List<POModel>> fetchPOs() async {
    final res = await _client.from('pos').select().order('po_number');
    return (res as List).map((e) => POModel.fromJson(e)).toList();
  }

  Future<void> addPO(POModel po) async {
    await _client.from('pos').insert(po.toJson());
  }

  Future<void> updatePO(POModel po) async {
    await _client.from('pos').update(po.toJson()).eq('id', po.id);
  }

  Future<void> deletePO(String id) async {
    await _client.from('pos').delete().eq('id', id);
  }
}
