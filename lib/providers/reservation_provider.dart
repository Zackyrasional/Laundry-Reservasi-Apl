import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../models/app_user.dart';
import '../models/laundry_package.dart';
import '../models/reservation.dart';
import 'user_auth_provider.dart';

class ReservationNotifier extends AsyncNotifier<List<Reservation>> {
  @override
  FutureOr<List<Reservation>> build() async {
    final user = ref.watch(userAuthProvider);
    if (user == null) {
      // belum login -> tidak ada reservasi
      return [];
    }
    return _fetchReservations(user.id);
  }

  Future<List<Reservation>> _fetchReservations(String userId) async {
    final response = await Dio().get(
      '${ApiConfig.baseUrl}/get_reservations.php',
      queryParameters: {'user_id': userId},
    );

    final List data = response.data as List;

    return data.map((e) {
      final pkg = LaundryPackage(
        id: e['package_id'].toString(),
        name: e['package_name'] as String,
        description: 'Layanan ${e['package_name']} dari server.',
        price: int.parse(e['price_per_kg'].toString()),
        durationInHours: int.parse(e['duration_hours'].toString()),
        imageUrl: e['image_url'] as String,
      );

      final weight = e['weight_kg'];
      final total = e['total_price'];

      return Reservation(
        id: e['id'].toString(),
        customerName: e['customer_name'] as String,
        phone: e['phone'] as String,
        address: e['address'] as String,
        pickupDate: DateTime.parse(e['pickup_date'] as String),
        note: (e['note'] ?? '') as String,
        package: pkg,
        createdAt: DateTime.parse(e['created_at'] as String),
        weightKg:
            weight == null ? null : double.tryParse(weight.toString()),
        totalPrice:
            total == null ? null : int.tryParse(total.toString()),
        status: (e['status'] ?? 'pending') as String,
      );
    }).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(userAuthProvider);
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }
      final list = await _fetchReservations(user.id);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createReservation(Reservation r) async {
    final user = ref.read(userAuthProvider);
    final userId = user?.id;

    await Dio().post(
      '${ApiConfig.baseUrl}/create_reservation.php',
      data: {
        'customer_name': r.customerName,
        'phone': r.phone,
        'address': r.address,
        'pickup_date': r.pickupDate.toIso8601String(),
        'note': r.note,
        'package_id': r.package.id,
        'user_id': userId,
      },
    );

    await refresh();
  }
}

final reservationProvider =
    AsyncNotifierProvider<ReservationNotifier, List<Reservation>>(
  ReservationNotifier.new,
);
