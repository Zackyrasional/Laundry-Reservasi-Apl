class LaundryPackage {
  final String id;
  final String name;
  final String description;
  final int price; // per kg
  final int durationInHours; // estimasi selesai
  final String imageUrl;

  const LaundryPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationInHours,
    required this.imageUrl,
  });
}
