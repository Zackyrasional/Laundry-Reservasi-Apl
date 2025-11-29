import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../models/laundry_package.dart';

class LaundryPackageNotifier extends AsyncNotifier<List<LaundryPackage>> {
  @override
  FutureOr<List<LaundryPackage>> build() async {
    return _fetchPackages();
  }

  Future<List<LaundryPackage>> _fetchPackages() async {
    final response =
        await Dio().get('${ApiConfig.baseUrl}/get_packages.php');

    final List data = response.data as List;

    return data.map((e) {
      return LaundryPackage(
        id: e['id'].toString(),
        name: e['name'] as String,
        description: 'Layanan ${e['name']} untuk pakaian Anda.',
        price: int.parse(e['price_per_kg'].toString()),
        durationInHours: int.parse(e['duration_hours'].toString()),
        imageUrl: e['image_url'] as String,
      );
    }).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final pkgs = await _fetchPackages();
      state = AsyncValue.data(pkgs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final laundryPackageProvider =
    AsyncNotifierProvider<LaundryPackageNotifier, List<LaundryPackage>>(
  LaundryPackageNotifier.new,
);
