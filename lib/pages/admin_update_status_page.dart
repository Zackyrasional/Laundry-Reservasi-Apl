import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../config/api_config.dart';

class AdminUpdateStatusPage extends StatefulWidget {
  final String id;
  final String currentStatus;
  final String? currentWeight;
  final String? currentTotal;
  final int pricePerKg;

  const AdminUpdateStatusPage({
    super.key,
    required this.id,
    required this.currentStatus,
    required this.pricePerKg,
    this.currentWeight,
    this.currentTotal,
  });

  @override
  State<AdminUpdateStatusPage> createState() =>
      _AdminUpdateStatusPageState();
}

class _AdminUpdateStatusPageState extends State<AdminUpdateStatusPage> {
  String? status;
  final weightController = TextEditingController();
  int? totalPrice;

  @override
  void initState() {
    super.initState();
    status = widget.currentStatus;
    if (widget.currentWeight != null) {
      weightController.text = widget.currentWeight!;
    }
    if (widget.currentTotal != null) {
      totalPrice = int.tryParse(widget.currentTotal!);
    }
    weightController.addListener(_recalculateTotal);
  }

  void _recalculateTotal() {
    final w = double.tryParse(weightController.text.replaceAll(',', '.'));
    if (w == null) {
      setState(() {
        totalPrice = null;
      });
      return;
    }
    setState(() {
      totalPrice = (w * widget.pricePerKg).round();
    });
  }

  Future<void> update() async {
    final weightText = weightController.text.trim();
    final weight = double.tryParse(weightText.replaceAll(',', '.'));

    await Dio().post(
      '${ApiConfig.baseUrl}/admin/admin_update_status.php',
      data: {
        'id': widget.id,
        'status': status,
        'weight_kg': weight,
        'total_price': totalPrice,
      },
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Status & Harga')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(
                labelText: 'Status Reservasi',
              ),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'dijemput', child: Text('Dijemput')),
                DropdownMenuItem(value: 'dicuci', child: Text('Dicuci')),
                DropdownMenuItem(value: 'selesai', child: Text('Selesai')),
                DropdownMenuItem(value: 'diantar', child: Text('Diantar')),
              ],
              onChanged: (v) => setState(() => status = v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Berat cucian (kg)',
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                totalPrice == null
                    ? 'Total Harga: -'
                    : 'Total Harga: Rp $totalPrice',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: update,
                child: const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
