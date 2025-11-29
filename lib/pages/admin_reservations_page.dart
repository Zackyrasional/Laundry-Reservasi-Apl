import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'admin_update_status_page.dart';

class AdminReservationsPage extends StatefulWidget {
  const AdminReservationsPage({super.key});

  @override
  State<AdminReservationsPage> createState() =>
      _AdminReservationsPageState();
}

class _AdminReservationsPageState extends State<AdminReservationsPage> {
  List reservations = [];
  bool loading = true;

  Future<void> loadData() async {
    setState(() => loading = true);
    final response = await Dio()
        .get('${ApiConfig.baseUrl}/admin/admin_get_reservations.php');
    reservations = response.data;
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservasi Masuk')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: reservations.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final r = reservations[i];
                return ListTile(
                  title: Text('${r['customer_name']} - ${r['package_name']}'),
                  subtitle: Text(
                    'Status: ${r['status']}'
                    '${r['weight_kg'] != null ? ' • ${r['weight_kg']} kg' : ''}'
                    '${r['total_price'] != null ? ' • Rp ${r['total_price']}' : ''}',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminUpdateStatusPage(
                          id: r['id'].toString(),
                          currentStatus: r['status'] as String,
                          currentWeight: r['weight_kg']?.toString(),
                          currentTotal: r['total_price']?.toString(),
                          pricePerKg:
                              int.parse(r['price_per_kg'].toString()),
                        ),
                      ),
                    ).then((_) => loadData());
                  },
                );
              },
            ),
    );
  }
}
