import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_auth_provider.dart';
import 'admin_reservations_page.dart';
import 'auth_page.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(adminAuthProvider.notifier).logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout Admin',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Lihat Semua Reservasi'),
              subtitle: const Text('Kelola daftar reservasi pelanggan'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminReservationsPage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Petunjuk Singkat'),
              subtitle: const Text(
                '1. Buka menu "Lihat Semua Reservasi"\n'
                '2. Pilih salah satu reservasi\n'
                '3. Atur status, isi berat (kg), dan total harga\n'
                '4. Simpan perubahan agar pengguna bisa melihat update',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
