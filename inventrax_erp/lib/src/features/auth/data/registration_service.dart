import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase_config.dart';
import '../../../sync/supabase_bootstrap.dart';
import '../domain/registration_data.dart';

enum RegistrationEmailStatus {
  newAccount('new'),
  existingNoStore('existing_no_store'),
  hasStore('has_store'),
  invalid('invalid');

  const RegistrationEmailStatus(this.key);
  final String key;

  static RegistrationEmailStatus fromKey(String? key) {
    return RegistrationEmailStatus.values.firstWhere(
      (v) => v.key == key,
      orElse: () => RegistrationEmailStatus.newAccount,
    );
  }
}

class RegistrationPrecheckResult {
  const RegistrationPrecheckResult({
    required this.status,
    this.message,
  });

  final RegistrationEmailStatus status;
  final String? message;
}

class RegistrationException implements Exception {
  const RegistrationException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Registration precheck via Supabase RPC (no SMS / auth-otp).
class RegistrationService {
  const RegistrationService();

  Future<RegistrationPrecheckResult> precheckRegistration({
    required String email,
    String? phone,
  }) async {
    final trimmed = email.trim().toLowerCase();
    if (!SupabaseConfig.isConfigured) {
      return const RegistrationPrecheckResult(
        status: RegistrationEmailStatus.newAccount,
      );
    }

    final client = supabaseClient;
    if (client == null) {
      throw const RegistrationException('Supabase not initialized');
    }

    try {
      final raw = await client.rpc(
        'inventrax_check_registration_email',
        params: {'p_email': trimmed},
      );
      final data = _map(raw);
      final statusKey = data['status']?.toString();

      if (phone != null && phone.trim().isNotEmpty) {
        final phoneRaw = await client.rpc(
          'inventrax_check_registration_phone',
          params: {'p_phone': phone.trim()},
        );
        final phoneData = _map(phoneRaw);
        final phoneStatus = phoneData['status']?.toString();
        if (phoneStatus == 'taken' || phoneStatus == 'invalid') {
          return RegistrationPrecheckResult(
            status: RegistrationEmailStatus.invalid,
            message: phoneData['message']?.toString() ??
                'This phone number is already registered.',
          );
        }
      }

      if (statusKey == 'invalid') {
        return RegistrationPrecheckResult(
          status: RegistrationEmailStatus.invalid,
          message: data['message']?.toString() ?? 'Invalid email',
        );
      }

      return RegistrationPrecheckResult(
        status: RegistrationEmailStatus.fromKey(statusKey),
        message: data['message']?.toString(),
      );
    } catch (e) {
      if (e is RegistrationException) rethrow;
      if (kDebugMode) {
        return const RegistrationPrecheckResult(
          status: RegistrationEmailStatus.newAccount,
        );
      }
      throw const RegistrationException('Could not check email. Try again.');
    }
  }

  Future<RegistrationPrecheckResult> precheckEmail(String email) =>
      precheckRegistration(email: email);

  Map<String, dynamic> _map(dynamic data) {
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return {};
  }
}

final registrationServiceProvider =
    Provider<RegistrationService>((ref) => const RegistrationService());
