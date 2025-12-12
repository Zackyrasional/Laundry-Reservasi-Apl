import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../config/session_storage.dart';

class AdminAuthNotifier extends Notifier<bool> {
  final Dio _dio = Dio();

  @override
  bool build() => false;

  String? errorMessage;

  // LOGIN ADMIN
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    errorMessage = null;

    try {
      // FIX: endpoint admin yang benar ada di folder /admin/
      final url = _url('/admin/admin_login.php');

      final res = await _dio.post(
        url,
        data: {
          'username': username.trim(),
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.json,
        ),
      );

      final data = res.data;

      if (data is Map && data['status'] == 'success') {
        state = true;

        // Simpan session admin
        await SessionStorage.saveAdmin();
        return true;
      }

      errorMessage = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Login admin gagal.';
      return false;
    } catch (e) {
      errorMessage = 'Terjadi kesalahan saat login admin: $e';
      return false;
    }
  }

  // Dipanggil dari AwalPage jika role == admin
  void restoreLogin() {
    state = true;
  }

  // LOGOUT
  Future<void> logout() async {
    state = false;
    await SessionStorage.clear();
  }

  String _url(String path) {
    final base = ApiConfig.baseUrl;

    if (path.startsWith('/')) return '$base$path';
    return '$base/$path';
  }
}

final adminAuthProvider =
    NotifierProvider<AdminAuthNotifier, bool>(() => AdminAuthNotifier());
