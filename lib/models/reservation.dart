import 'laundry_package.dart';

class Reservation {
  final String id;
  final String customerName;
  final String phone;
  final String address;
  final DateTime pickupDate;
  final String note;
  final LaundryPackage package;
  final DateTime createdAt;

  final double? weightKg;   // boleh null (belum ditimbang)
  final int? totalPrice;    // boleh null
  final String status;      // pending / dijemput / dicuci / selesai / diantar

  const Reservation({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.pickupDate,
    required this.note,
    required this.package,
    required this.createdAt,
    this.weightKg,
    this.totalPrice,
    this.status = 'pending',
  });
}
