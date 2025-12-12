import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../config/session_storage.dart';
import '../models/app_user.dart';

class UserAuthNotifier extends Notifier<AppUser?> {
  final Dio _dio = Dio();

  @override
  AppUser? build() => null;

  // LOGIN USER
  // Mengembalikan true jika sukses, false jika gagal (lihat errorMessage)
  String? errorMessage;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    errorMessage = null;

    try {
      final url = _url('/user/user_login.php');

      final res = await _dio.post(
        url,
        data: {
          'email': email.trim(),
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.json,
        ),
      );

      final data = res.data;

      if (data is Map && data['status'] == 'success') {
        final userJson = data['user'];

        // Beberapa backend mengembalikan user sebagai object,
        // pastikan mapping aman:
        final u = AppUser(
          id: (userJson['id'] ?? '').toString(),
          name: (userJson['name'] ?? '').toString(),
          email: (userJson['email'] ?? '').toString(),
          phone: (userJson['phone'] ?? '').toString(),
          address: (userJson['address'] ?? '').toString(),
        );

        state = u;

        // Simpan session agar saat app dibuka lagi langsung masuk
        await SessionStorage.saveUser(
          id: u.id,
          name: u.name,
          email: u.email,
          phone: u.phone,
          address: u.address,
        );

        return true;
      }

      errorMessage = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Login gagal. Periksa email/password.';
      return false;
    } catch (e) {
      errorMessage = 'Terjadi kesalahan saat login: $e';
      return false;
    }
  }

  // REGISTER USER (opsional, jika backend Anda punya user_register.php)
  // Jika Anda belum punya endpoint register, Anda boleh hapus method ini.
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String address = '',
  }) async {
    errorMessage = null;

    try {
      final url = _url('/user/user_register.php');

      final res = await _dio.post(
        url,
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'password': password,
          'address': address.trim(),
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.json,
        ),
      );

      final data = res.data;

      if (data is Map && data['status'] == 'success') {
        // Ada backend yang mengembalikan user baru,
        // kalau tidak ada, kita buat minimal dari input.
        final userJson = data['user'];

        final u = (userJson is Map)
            ? AppUser(
                id: (userJson['id'] ?? '').toString(),
                name: (userJson['name'] ?? name).toString(),
                email: (userJson['email'] ?? email).toString(),
                phone: (userJson['phone'] ?? phone).toString(),
                address: (userJson['address'] ?? address).toString(),
              )
            : AppUser(
                id: '',
                name: name,
                email: email,
                phone: phone,
                address: address,
              );

        state = u;

        // Simpan session
        await SessionStorage.saveUser(
          id: u.id,
          name: u.name,
          email: u.email,
          phone: u.phone,
          address: u.address,
        );

        return true;
      }

      errorMessage = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Registrasi gagal.';
      return false;
    } catch (e) {
      errorMessage = 'Terjadi kesalahan saat registrasi: $e';
      return false;
    }
  }

  // Dipanggil dari AwalPage untuk restore session user (tanpa hit API)
  void restoreUser(AppUser user) {
    state = user;
  }

  // LOGOUT
  Future<void> logout() async {
    state = null;
    await SessionStorage.clear();
  }

  // Helper URL
  String _url(String path) {
    // Opsi 1: Jika api_config.dart punya ApiConfig.baseUrl (disarankan)
    // contoh: http://192.168.1.12/laundry_api
    final base = ApiConfig.baseUrl;

    if (path.startsWith('/')) return '$base$path';
    return '$base/$path';
  }
}

final userAuthProvider =
    NotifierProvider<UserAuthNotifier, AppUser?>(() => UserAuthNotifier());
