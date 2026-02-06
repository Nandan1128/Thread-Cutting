import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  static final _client = Supabase.instance.client;

  static Future<String> getUserRole() async {
    final userId = _client.auth.currentUser!.id;

    final res = await _client
        .from('app_user')
        .select('role')
        .eq('id', userId)
        .single();

    return res['role'];
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
