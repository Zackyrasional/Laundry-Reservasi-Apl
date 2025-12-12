import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';

class AdminAuthNotifier extends Notifier<bool> {
  @override
  bool build() => false; // false = belum login

  Future<bool> login(String username, String password) async {
    final response = await Dio().post(
      '${ApiConfig.baseUrl}/admin/admin_login.php',
      data: {
        'username': username,
        'password': password,
      },
    );

    if (response.data['status'] == 'success') {
      state = true;
      return true;
    } else {
      return false;
    }
  }

  void logout() {
    state = false;
  }
}

final adminAuthProvider =
    NotifierProvider<AdminAuthNotifier, bool>(() => AdminAuthNotifier());
