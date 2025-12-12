import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/session_storage.dart';
import '../models/app_user.dart';
import '../providers/admin_auth_provider.dart';
import '../providers/user_auth_provider.dart';
import 'admin_dashboard_page.dart';
import 'auth_page.dart';
import 'home_page.dart';

class AwalPage extends ConsumerStatefulWidget {
  const AwalPage({super.key});

  @override
  ConsumerState<AwalPage> createState() => _AwalPageState();
}

class _AwalPageState extends ConsumerState<AwalPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final role = await SessionStorage.getRole();

    if (!mounted) return;

    if (role == 'admin') {
      ref.read(adminAuthProvider.notifier).restoreLogin();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
      );
      return;
    }

    if (role == 'user') {
      final u = await SessionStorage.getUser();
      if (u != null) {
        ref.read(userAuthProvider.notifier).restoreUser(
              AppUser(
                id: u['id']!,
                name: u['name']!,
                email: u['email']!,
                phone: u['phone']!,
                address: u['address'] ?? '',
              ),
            );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        return;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
