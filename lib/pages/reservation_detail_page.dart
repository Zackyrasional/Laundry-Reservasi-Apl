import 'package:flutter/material.dart';
import '../models/reservation.dart';

class ReservationDetailPage extends StatelessWidget {
  final Reservation reservation;

  const ReservationDetailPage({super.key, required this.reservation});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Reservasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'package_image_${r.package.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    r.package.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.local_laundry_service),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              r.package.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Rp ${r.package.price}/kg • ~ ${r.package.durationInHours} jam',
            ),
            const Divider(height: 32),
            const Text(
              'Data Pelanggan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Nama: ${r.customerName}'),
            Text('Nomor HP: ${r.phone}'),
            Text('Alamat: ${r.address}'),
            const SizedBox(height: 16),
            const Text(
              'Detail Reservasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Tanggal Jemput: ${_formatDate(r.pickupDate)}'),
            if (r.weightKg != null)
              Text('Berat Cucian: ${r.weightKg!.toStringAsFixed(2)} kg'),
            if (r.totalPrice != null)
              Text('Total Harga: Rp ${r.totalPrice}'),
            Text('Status: ${r.status}'),
            if (r.note.isNotEmpty) Text('Catatan: ${r.note}'),
            const SizedBox(height: 16),
            Text(
              'Dibuat pada: ${_formatDate(r.createdAt)}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
