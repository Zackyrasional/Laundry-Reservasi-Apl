import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/laundry_package.dart';
import '../models/reservation.dart';
import '../providers/laundry_package_provider.dart';
import '../providers/reservation_provider.dart';
import '../providers/user_auth_provider.dart';
import 'reservation_form_page.dart';
import 'reservation_detail_page.dart';
import 'auth_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userAuthProvider);
    final packagesAsync = ref.watch(laundryPackageProvider);
    final reservationsAsync = ref.watch(reservationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          user == null
              ? 'Reservasi Laundry'
              : 'Halo, ${user.name}',
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(laundryPackageProvider.notifier).refresh();
              ref.read(reservationProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload data dari server',
          ),
          IconButton(
            onPressed: () {
              ref.read(userAuthProvider.notifier).logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout Pengguna',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Paket Laundry',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          packagesAsync.when(
            data: (packages) => _PackageList(packages: packages),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Gagal memuat paket: $err'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Daftar Reservasi Anda',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          reservationsAsync.when(
            data: (reservations) {
              if (reservations.isEmpty) {
                return const Text(
                  'Belum ada reservasi. Silakan buat reservasi baru dari paket di atas.',
                );
              }
              return _ReservationList(reservations: reservations);
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Gagal memuat reservasi: $err'),
          ),
        ],
      ),
    );
  }
}

class _PackageList extends StatelessWidget {
  final List<LaundryPackage> packages;

  const _PackageList({required this.packages});

  @override
  Widget build(BuildContext context) {
    double listHeight = MediaQuery.of(context).size.height * 0.28;
    if (listHeight < 220) listHeight = 220;
    if (listHeight > 280) listHeight = 280;

    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: packages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final pkg = packages[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReservationFormPage(package: pkg),
                ),
              );
            },
            child: SizedBox(
              width: 220,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'package_image_${pkg.id}',
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          pkg.imageUrl,
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pkg.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${pkg.price}/kg',
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '~ ${pkg.durationInHours} jam',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReservationList extends StatelessWidget {
  final List<Reservation> reservations;

  const _ReservationList({required this.reservations});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'dijemput':
        return 'Dijemput';
      case 'dicuci':
        return 'Dicuci';
      case 'selesai':
        return 'Selesai';
      case 'diantar':
        return 'Diantar';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: reservations.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final r = reservations[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(
              r.customerName.isNotEmpty
                  ? r.customerName[0].toUpperCase()
                  : '?',
            ),
          ),
          title: Text(r.package.name),
          subtitle: Text(
            '${_formatDate(r.pickupDate)} • Status: ${_statusText(r.status)}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReservationDetailPage(reservation: r),
              ),
            );
          },
        );
      },
    );
  }
}
