import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase_config.dart';
import '../../../sync/supabase_bootstrap.dart';

/// Password reset via Resend email OTP (send-email-otp / verify-email-otp / reset-password).
class EmailResetService {
  const EmailResetService();

  static const otpExpirySec = 600;
  static const resendCooldownSec = 30;

  Future<EmailOtpSendResult> sendResetOtp(String email) async {
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty) {
      throw const EmailResetException('Email is required');
    }

    if (!SupabaseConfig.isConfigured) {
      if (kDebugMode) {
        return const EmailOtpSendResult(
          requestId: 'dev-request',
          expiresInSec: otpExpirySec,
          resendCooldownSec: resendCooldownSec,
          devOtp: '123456',
        );
      }
      throw const EmailResetException('Supabase not configured');
    }

    final client = supabaseClient;
    if (client == null) {
      throw const EmailResetException('Supabase not initialized');
    }

    final res = await client.functions.invoke(
      'send-email-otp',
      body: {
        'email': trimmed,
        'purpose': 'password_reset',
      },
    );

    final data = _map(res.data);
    if (res.status != 200) {
      throw EmailResetException(
        _friendlyError(data['error']?.toString()) ??
            'Could not send verification code',
        retryAfterSec: data['retry_after_sec'] as int?,
      );
    }

    final devMode = data['dev_mode'] == true;
    final devOtp = data['dev_otp']?.toString();

    return EmailOtpSendResult(
      requestId: data['request_id']?.toString() ?? '',
      expiresInSec: data['expires_in_sec'] as int? ?? otpExpirySec,
      resendCooldownSec:
          data['resend_cooldown_sec'] as int? ?? resendCooldownSec,
      emailSent: data['email_sent'] == true,
      devMode: devMode,
      devOtp: devMode ? devOtp : null,
    );
  }

  Future<EmailOtpVerifyResult> verifyResetOtp({
    required String email,
    required String code,
    String? requestId,
  }) async {
    final trimmed = email.trim().toLowerCase();
    final client = supabaseClient;
    if (client == null) {
      throw const EmailResetException('Supabase not initialized');
    }

    if (!SupabaseConfig.isConfigured) {
      if (kDebugMode && code == '123456') {
        return const EmailOtpVerifyResult(
          requestId: 'dev-request',
          resetToken: 'dev-reset-token',
        );
      }
      throw const EmailResetException('Invalid verification code');
    }

    final res = await client.functions.invoke(
      'verify-email-otp',
      body: {
        'email': trimmed,
        'code': code.trim(),
        'purpose': 'password_reset',
        if (requestId != null) 'request_id': requestId,
      },
    );

    final data = _map(res.data);
    if (res.status != 200) {
      throw EmailResetException(
        _friendlyError(data['error']?.toString()) ??
            'Invalid or expired code',
        attemptsRemaining: data['attempts_remaining'] as int?,
      );
    }

    final resetToken = data['reset_token']?.toString() ?? '';
    if (resetToken.isEmpty) {
      throw const EmailResetException('Verification failed');
    }

    return EmailOtpVerifyResult(
      requestId: data['request_id']?.toString() ?? requestId ?? '',
      resetToken: resetToken,
    );
  }

  Future<void> resetPassword({
    required String email,
    required String requestId,
    required String resetToken,
    required String newPassword,
  }) async {
    if (!SupabaseConfig.isConfigured) {
      if (kDebugMode) return;
      throw const EmailResetException('Supabase not configured');
    }

    final client = supabaseClient;
    if (client == null) {
      throw const EmailResetException('Supabase not initialized');
    }

    final res = await client.functions.invoke(
      'reset-password',
      body: {
        'email': email.trim().toLowerCase(),
        'request_id': requestId,
        'reset_token': resetToken,
        'new_password': newPassword,
      },
    );

    final data = _map(res.data);
    if (res.status != 200 || data['success'] != true) {
      throw EmailResetException(
        _friendlyError(data['error']?.toString()) ?? 'Password reset failed',
      );
    }
  }

  String? _friendlyError(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final lower = raw.toLowerCase();
    if (lower.contains('invalid verification') || lower.contains('invalid')) {
      return 'Invalid verification code';
    }
    if (lower.contains('expired')) return 'Code expired';
    if (lower.contains('too many')) return 'Too many attempts. Try again later.';
    if (lower.contains('wait')) return raw;
    return raw;
  }

  Map<String, dynamic> _map(dynamic data) {
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return {};
  }
}

class EmailOtpSendResult {
  const EmailOtpSendResult({
    required this.requestId,
    required this.expiresInSec,
    required this.resendCooldownSec,
    this.emailSent = false,
    this.devMode = false,
    this.devOtp,
  });

  final String requestId;
  final int expiresInSec;
  final int resendCooldownSec;
  final bool emailSent;
  final bool devMode;
  final String? devOtp;
}

class EmailOtpVerifyResult {
  const EmailOtpVerifyResult({
    required this.requestId,
    required this.resetToken,
  });

  final String requestId;
  final String resetToken;
}

class EmailResetException implements Exception {
  const EmailResetException(this.message, {this.retryAfterSec, this.attemptsRemaining});

  final String message;
  final int? retryAfterSec;
  final int? attemptsRemaining;

  @override
  String toString() => message;
}

final emailResetServiceProvider = Provider<EmailResetService>(
  (ref) => const EmailResetService(),
);
