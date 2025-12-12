import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const _kRole = 'role'; // 'user' | 'admin'
  static const _kUserId = 'user_id';
  static const _kUserName = 'user_name';
  static const _kUserEmail = 'user_email';
  static const _kUserPhone = 'user_phone';
  static const _kUserAddress = 'user_address';

  static Future<void> saveUser({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kRole, 'user');
    await sp.setString(_kUserId, id);
    await sp.setString(_kUserName, name);
    await sp.setString(_kUserEmail, email);
    await sp.setString(_kUserPhone, phone);
    await sp.setString(_kUserAddress, address);
  }

  static Future<void> saveAdmin() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kRole, 'admin');
  }

  static Future<String?> getRole() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kRole);
  }

  static Future<Map<String, String>?> getUser() async {
    final sp = await SharedPreferences.getInstance();
    final role = sp.getString(_kRole);
    if (role != 'user') return null;

    final id = sp.getString(_kUserId);
    final name = sp.getString(_kUserName);
    final email = sp.getString(_kUserEmail);
    final phone = sp.getString(_kUserPhone);
    final address = sp.getString(_kUserAddress);

    if (id == null || name == null || email == null || phone == null) return null;

    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address ?? '',
    };
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kRole);
    await sp.remove(_kUserId);
    await sp.remove(_kUserName);
    await sp.remove(_kUserEmail);
    await sp.remove(_kUserPhone);
    await sp.remove(_kUserAddress);
  }
}
