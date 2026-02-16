import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  static final _client = Supabase.instance.client;

  static Future<String> getUserRole() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 'user';

      final res = await _client
          .from('app_user')
          .select('role')
          .eq('id', user.id)
          .maybeSingle(); // Safer than single()

      if (res == null) return 'user';
      return res['role'] ?? 'user';
    } catch (e) {
      print('Error fetching role: $e');
      return 'user'; // Fallback to basic user if query fails
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
