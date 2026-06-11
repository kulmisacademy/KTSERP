import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/registration_data.dart';

/// Persists in-progress registration so data survives OTP/network delays.
class RegistrationDraftStore {
  static const _key = 'kulmis_registration_draft_v1';

  Future<void> save(RegistrationData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({
        'storeName': data.storeName,
        'businessType': data.businessType,
        'country': data.country,
        'currencyCode': data.currencyCode,
        'address': data.address,
        'ownerName': data.ownerName,
        'email': data.email,
        'phone': data.phone,
        'taxNumber': data.taxNumber,
      }),
    );
  }

  Future<RegistrationData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return RegistrationData(
        storeName: m['storeName'] as String? ?? '',
        businessType: m['businessType'] as String? ?? 'Retail',
        country: m['country'] as String? ?? '',
        currencyCode: m['currencyCode'] as String? ?? 'USD',
        address: m['address'] as String? ?? '',
        ownerName: m['ownerName'] as String? ?? '',
        email: m['email'] as String? ?? '',
        phone: m['phone'] as String? ?? '',
        password: '',
        taxNumber: m['taxNumber'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
