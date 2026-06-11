/// User-friendly Waafi Pay errors — https://docs.waafipay.com/
String friendlyWaafiError({
  String? message,
  String? responseCode,
  bool sandbox = true,
}) {
  final code = responseCode?.trim();
  final lower = (message ?? '').toLowerCase();

  if (code == '5301' || lower.contains('invalid') && lower.contains('api')) {
    return 'Invalid Waafi API credentials. Check WAAFI_MERCHANT_UID, '
        'WAAFI_API_USER_ID, and WAAFI_API_KEY in Supabase secrets.';
  }
  if (code == '5308') {
    return 'Your Waafi merchant account is not enabled for API purchases. '
        'Contact Waafi support.';
  }
  if (code != null && code.startsWith('520')) {
    if (lower.contains('reject') || code == '5202') {
      return 'Payment rejected on your phone. You cancelled or declined the request.';
    }
    if (lower.contains('balance') || code == '5204') {
      return 'Insufficient wallet balance. Top up your mobile wallet and try again.';
    }
    if (lower.contains('pin') || code == '5203') {
      return 'Wrong PIN entered. Please try again.';
    }
    if (message != null && message.isNotEmpty) return message;
    return 'Payment failed on mobile wallet. Please try again.';
  }
  if (code == '5001' || lower.contains('could not be processed')) {
    if (lower.contains('authentication failed')) {
      if (sandbox) {
        return 'Waafi sandbox authentication failed. Your keys appear to be '
            'production credentials — set WAAFI_SANDBOX=false or request '
            'sandbox keys from Waafi.';
      }
      return 'Waafi authentication failed. Check merchant UID, API user ID, and API key.';
    }
    if (sandbox) {
      return 'Sandbox payment rejected. Use test wallet 252611111111 (PIN 1212).';
    }
    return 'Waafi could not process this payment. Check wallet number '
        '(25261… format), balance, and merchant credentials.';
  }
  if (code == '5206' || lower.contains('push notification')) {
    return 'Waafi could not send payment push to this number. '
        'Use your real mobile wallet (061… or 25261…) with sufficient balance.';
  }
  if (lower.contains('insufficient') || lower.contains('balance')) {
    return 'Insufficient wallet balance. Top up your mobile wallet and try again.';
  }
  if (message != null && message.isNotEmpty) {
    return message;
  }
  return 'Waafi payment failed. Please try again or contact support.';
}

String? parseWaafiErrorFromFunctionBody(dynamic data) {
  if (data is! Map) return null;
  final map = data.map((k, v) => MapEntry(k.toString(), v));
  return friendlyWaafiError(
    message: map['error']?.toString(),
    responseCode: map['response_code']?.toString(),
  );
}
