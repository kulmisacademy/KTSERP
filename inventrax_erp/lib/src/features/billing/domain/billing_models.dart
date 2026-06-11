class StoreBillingSnapshot {
  const StoreBillingSnapshot({
    required this.storeId,
    required this.tenantId,
    required this.subscription,
    required this.smsWallet,
    required this.billingSettings,
  });

  final String storeId;
  final String tenantId;
  final StoreSubscriptionInfo subscription;
  final SmsWalletInfo smsWallet;
  final BillingSettingsInfo billingSettings;

  factory StoreBillingSnapshot.fromJson(Map<String, dynamic> json) {
    return StoreBillingSnapshot(
      storeId: json['store_id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      subscription: StoreSubscriptionInfo.fromJson(
        Map<String, dynamic>.from(json['subscription'] as Map? ?? {}),
      ),
      smsWallet: SmsWalletInfo.fromJson(
        Map<String, dynamic>.from(json['sms_wallet'] as Map? ?? {}),
      ),
      billingSettings: BillingSettingsInfo.fromJson(
        Map<String, dynamic>.from(json['billing_settings'] as Map? ?? {}),
      ),
    );
  }
}

class StoreSubscriptionInfo {
  const StoreSubscriptionInfo({
    this.id,
    this.planId,
    this.planName,
    this.status,
    this.billingCycle,
    this.trialEndsAt,
    this.currentPeriodEnd,
    this.daysRemaining,
    this.monthlyPriceCents,
    this.yearlyPriceCents,
    this.features = const [],
  });

  final String? id;
  final String? planId;
  final String? planName;
  final String? status;
  final String? billingCycle;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodEnd;
  final int? daysRemaining;
  final int? monthlyPriceCents;
  final int? yearlyPriceCents;
  final List<String> features;

  bool get isTrialing => status == 'trialing';
  bool get isActive => status == 'active' || isTrialing;
  bool get isExpired =>
      status == 'expired' || status == 'suspended' || status == 'cancelled';

  bool hasFeature(String feature) {
    if (features.contains('*')) return true;
    return features.contains(feature);
  }

  factory StoreSubscriptionInfo.fromJson(Map<String, dynamic> json) {
    final raw = json['features'];
    List<String> feats = [];
    if (raw is List) feats = raw.map((e) => e.toString()).toList();
    return StoreSubscriptionInfo(
      id: json['id'] as String?,
      planId: json['plan_id'] as String?,
      planName: json['plan_name'] as String?,
      status: json['status'] as String?,
      billingCycle: json['billing_cycle'] as String?,
      trialEndsAt: _date(json['trial_ends_at']),
      currentPeriodEnd: _date(json['current_period_end']),
      daysRemaining: json['days_remaining'] as int?,
      monthlyPriceCents: json['monthly_price_cents'] as int?,
      yearlyPriceCents: json['yearly_price_cents'] as int?,
      features: feats,
    );
  }
}

class SmsWalletInfo {
  const SmsWalletInfo({
    this.balanceRemaining = 0,
    this.balancePurchased = 0,
    this.balanceUsed = 0,
  });

  final int balanceRemaining;
  final int balancePurchased;
  final int balanceUsed;

  factory SmsWalletInfo.fromJson(Map<String, dynamic> json) {
    return SmsWalletInfo(
      balanceRemaining: json['balance_remaining'] as int? ?? 0,
      balancePurchased: json['balance_purchased'] as int? ?? 0,
      balanceUsed: json['balance_used'] as int? ?? 0,
    );
  }
}

class BillingSettingsInfo {
  const BillingSettingsInfo({
    this.defaultTrialDays = 14,
    this.gracePeriodDays = 3,
    this.waafiEnabled = true,
  });

  final int defaultTrialDays;
  final int gracePeriodDays;
  final bool waafiEnabled;

  factory BillingSettingsInfo.fromJson(Map<String, dynamic> json) {
    return BillingSettingsInfo(
      defaultTrialDays: json['default_trial_days'] as int? ?? 14,
      gracePeriodDays: json['grace_period_days'] as int? ?? 3,
      waafiEnabled: json['waafi_enabled'] as bool? ?? true,
    );
  }
}

class CloudSmsPackage {
  const CloudSmsPackage({
    required this.id,
    required this.name,
    this.description,
    required this.smsCount,
    required this.priceCents,
    this.currencyCode = 'USD',
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String? description;
  final int smsCount;
  final int priceCents;
  final String currencyCode;
  final bool isActive;
  final int sortOrder;

  factory CloudSmsPackage.fromJson(Map<String, dynamic> json) {
    return CloudSmsPackage(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      smsCount: json['sms_count'] as int? ?? 0,
      priceCents: json['price_cents'] as int? ?? 0,
      currencyCode: json['currency_code'] as String? ?? 'USD',
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toUpsertJson() => {
        'id': id,
        'name': name,
        'description': description,
        'sms_count': smsCount,
        'price_cents': priceCents,
        'currency_code': currencyCode,
        'is_active': isActive,
        'sort_order': sortOrder,
        'updated_at': DateTime.now().toIso8601String(),
      };
}

class PaymentTransaction {
  const PaymentTransaction({
    required this.id,
    required this.paymentType,
    required this.status,
    required this.amountCents,
    this.currencyCode = 'USD',
    this.planId,
    this.smsPackageId,
    this.provider,
    this.providerReferenceId,
    this.createdAt,
    this.completedAt,
  });

  final String id;
  final String paymentType;
  final String status;
  final int amountCents;
  final String currencyCode;
  final String? planId;
  final String? smsPackageId;
  final String? provider;
  final String? providerReferenceId;
  final DateTime? createdAt;
  final DateTime? completedAt;

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] as String,
      paymentType: json['payment_type'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      amountCents: json['amount_cents'] as int? ?? 0,
      currencyCode: json['currency_code'] as String? ?? 'USD',
      planId: json['plan_id'] as String?,
      smsPackageId: json['sms_package_id'] as String?,
      provider: json['provider'] as String?,
      providerReferenceId: json['provider_reference_id'] as String?,
      createdAt: _date(json['created_at']),
      completedAt: _date(json['completed_at']),
    );
  }
}

class BillingAnalytics {
  const BillingAnalytics({
    this.totalRevenueCents = 0,
    this.subscriptionRevenueCents = 0,
    this.smsRevenueCents = 0,
    this.activeSubscriptions = 0,
    this.trialingSubscriptions = 0,
    this.expiringTrials7d = 0,
    this.failedPayments30d = 0,
    this.mrrCents = 0,
  });

  final int totalRevenueCents;
  final int subscriptionRevenueCents;
  final int smsRevenueCents;
  final int activeSubscriptions;
  final int trialingSubscriptions;
  final int expiringTrials7d;
  final int failedPayments30d;
  final int mrrCents;

  factory BillingAnalytics.fromJson(Map<String, dynamic> json) {
    return BillingAnalytics(
      totalRevenueCents: _int(json['total_revenue_cents']),
      subscriptionRevenueCents: _int(json['subscription_revenue_cents']),
      smsRevenueCents: _int(json['sms_revenue_cents']),
      activeSubscriptions: _int(json['active_subscriptions']),
      trialingSubscriptions: _int(json['trialing_subscriptions']),
      expiringTrials7d: _int(json['expiring_trials_7d']),
      failedPayments30d: _int(json['failed_payments_30d']),
      mrrCents: _int(json['mrr_cents']),
    );
  }
}

class SubscriptionAccessResult {
  const SubscriptionAccessResult({required this.allowed, this.message});

  final bool allowed;
  final String? message;

  static const ok = SubscriptionAccessResult(allowed: true);
}

/// Payment flow outcome for Waafi mobile push.
enum PaymentOutcome {
  completed,
  processing,
  failed,
}

/// Checkout UI phases — server-driven, no optimistic success.
enum PaymentCheckoutPhase {
  idle,
  sendingRequest,
  waitingConfirmation,
  processing,
  success,
  failed,
  cancelled,
  timeout,
}

class PaymentStatusSnapshot {
  const PaymentStatusSnapshot({
    required this.transactionId,
    required this.status,
    this.errorMessage,
    this.completedAt,
    this.verified = false,
    this.payerPhone,
    this.smsCreditsAdded,
    this.smsPackageName,
    this.walletBalance,
    this.planName,
    this.providerTransactionId,
    this.paymentType,
  });

  final String transactionId;
  final String status;
  final String? paymentType;
  final String? errorMessage;
  final DateTime? completedAt;
  final bool verified;
  final String? payerPhone;
  final int? smsCreditsAdded;
  final String? smsPackageName;
  final int? walletBalance;
  final String? planName;
  final String? providerTransactionId;

  bool get isTerminal =>
      status == 'completed' ||
      status == 'failed' ||
      status == 'cancelled' ||
      status == 'expired';

  /// True only when backend marked completed AND SMS ledger exists (if SMS purchase).
  bool get isVerifiedSuccess {
    if (status != 'completed' || !verified || completedAt == null) return false;
    if (paymentType == 'sms_package') {
      return (smsCreditsAdded ?? 0) > 0 && (walletBalance ?? 0) > 0;
    }
    return true;
  }

  bool get isSuccess => isVerifiedSuccess;

  String? get activationDetail {
    if (!isVerifiedSuccess) return null;
    if (smsCreditsAdded != null && smsCreditsAdded! > 0) {
      return '$smsCreditsAdded SMS credits added to your wallet.';
    }
    if (planName != null && planName!.isNotEmpty) {
      return '$planName plan is now active.';
    }
    return 'Your purchase has been activated.';
  }

  factory PaymentStatusSnapshot.fromJson(Map<String, dynamic> json) {
    return PaymentStatusSnapshot(
      transactionId: json['transaction_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      errorMessage: json['error_message']?.toString(),
      completedAt: _date(json['completed_at']),
      verified: json['verified'] == true,
      payerPhone: json['payer_phone']?.toString(),
      smsCreditsAdded: _intOrNull(json['sms_credits_added']),
      smsPackageName: json['sms_package_name']?.toString(),
      walletBalance: _intOrNull(json['wallet_balance']),
      planName: json['plan_name']?.toString(),
      providerTransactionId: json['provider_transaction_id']?.toString(),
      paymentType: json['payment_type']?.toString(),
    );
  }
}

int? _intOrNull(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

class PaymentResult {
  const PaymentResult({
    required this.outcome,
    this.transactionId,
    this.message,
    this.error,
    this.statusSnapshot,
  });

  final PaymentOutcome outcome;
  final String? transactionId;
  final String? message;
  final String? error;
  final PaymentStatusSnapshot? statusSnapshot;

  bool get success => outcome == PaymentOutcome.completed;
  bool get isProcessing => outcome == PaymentOutcome.processing;
}

DateTime? _date(Object? v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

int _int(Object? v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}
