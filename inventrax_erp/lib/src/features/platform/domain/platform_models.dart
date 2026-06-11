// Super Admin SaaS models (from Supabase RPC / tables).

class PlatformDashboardMetrics {
  const PlatformDashboardMetrics({
    required this.totalStores,
    required this.activeStores,
    required this.trialStores,
    required this.expiredStores,
    required this.suspendedStores,
    required this.mrrCents,
    required this.totalProducts,
    required this.totalSales,
    required this.totalUsers,
    required this.totalStorageBytes,
    required this.paidStores,
  });

  final int totalStores;
  final int activeStores;
  final int trialStores;
  final int expiredStores;
  final int suspendedStores;
  final int mrrCents;
  final int totalProducts;
  final int totalSales;
  final int totalUsers;
  final int totalStorageBytes;
  final int paidStores;

  factory PlatformDashboardMetrics.fromJson(Map<String, dynamic> json) {
    return PlatformDashboardMetrics(
      totalStores: _int(json['total_stores']),
      activeStores: _int(json['active_stores']),
      trialStores: _int(json['trial_stores']),
      expiredStores: _int(json['expired_stores']),
      suspendedStores: _int(json['suspended_stores']),
      mrrCents: _int(json['mrr_cents']),
      totalProducts: _int(json['total_products']),
      totalSales: _int(json['total_sales']),
      totalUsers: _int(json['total_users']),
      totalStorageBytes: _int(json['total_storage_bytes']),
      paidStores: _int(json['paid_stores']),
    );
  }
}

class PlatformStoreRow {
  const PlatformStoreRow({
    required this.storeId,
    required this.tenantId,
    required this.storeName,
    this.logoUrl,
    this.country,
    this.currencyCode,
    required this.storeStatus,
    this.createdAt,
    this.subscriptionStatus,
    this.planId,
    this.planName,
    this.ownerName,
    this.ownerEmail,
    this.ownerPhone,
    required this.productCount,
    required this.saleCount,
    required this.revenueCents,
    required this.storageBytes,
    this.storageLimitBytes,
  });

  final String storeId;
  final String tenantId;
  final String storeName;
  final String? logoUrl;
  final String? country;
  final String? currencyCode;
  final String storeStatus;
  final DateTime? createdAt;
  final String? subscriptionStatus;
  final String? planId;
  final String? planName;
  final String? ownerName;
  final String? ownerEmail;
  final String? ownerPhone;
  final int productCount;
  final int saleCount;
  final int revenueCents;
  final int storageBytes;
  final int? storageLimitBytes;

  factory PlatformStoreRow.fromJson(Map<String, dynamic> json) {
    return PlatformStoreRow(
      storeId: json['store_id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      storeName: json['store_name'] as String? ?? 'Store',
      logoUrl: json['logo_url'] as String?,
      country: json['country'] as String?,
      currencyCode: json['currency_code'] as String?,
      storeStatus: json['store_status'] as String? ?? 'active',
      createdAt: _date(json['created_at']),
      subscriptionStatus: json['subscription_status'] as String?,
      planId: json['plan_id'] as String?,
      planName: json['plan_name'] as String?,
      ownerName: json['owner_name'] as String?,
      ownerEmail: json['owner_email'] as String?,
      ownerPhone: json['owner_phone'] as String?,
      productCount: _int(json['product_count']),
      saleCount: _int(json['sale_count']),
      revenueCents: _int(json['revenue_cents']),
      storageBytes: _int(json['storage_bytes']),
      storageLimitBytes: json['storage_limit_bytes'] == null
          ? null
          : _int(json['storage_limit_bytes']),
    );
  }
}

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    this.description,
    required this.monthlyPriceCents,
    required this.yearlyPriceCents,
    this.productLimit,
    this.userLimit,
    this.storageLimitBytes,
    this.branchLimit,
    required this.features,
    required this.isActive,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final String? description;
  final int monthlyPriceCents;
  final int yearlyPriceCents;
  final int? productLimit;
  final int? userLimit;
  final int? storageLimitBytes;
  final int? branchLimit;
  final List<String> features;
  final bool isActive;
  final int sortOrder;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final raw = json['features'];
    List<String> feats = [];
    if (raw is List) {
      feats = raw.map((e) => e.toString()).toList();
    }
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      monthlyPriceCents: _int(json['monthly_price_cents']),
      yearlyPriceCents: _int(json['yearly_price_cents']),
      productLimit: json['product_limit'] == null ? null : _int(json['product_limit']),
      userLimit: json['user_limit'] == null ? null : _int(json['user_limit']),
      storageLimitBytes: json['storage_limit_bytes'] == null
          ? null
          : _int(json['storage_limit_bytes']),
      branchLimit:
          json['branch_limit'] == null ? null : _int(json['branch_limit']),
      features: feats,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: _int(json['sort_order']),
    );
  }

  Map<String, dynamic> toUpsertJson() => {
        'id': id,
        'name': name,
        'description': description,
        'monthly_price_cents': monthlyPriceCents,
        'yearly_price_cents': yearlyPriceCents,
        'product_limit': productLimit,
        'user_limit': userLimit,
        'storage_limit_bytes': storageLimitBytes,
        'branch_limit': branchLimit,
        'features': features,
        'is_active': isActive,
        'sort_order': sortOrder,
      };
}

class PlatformStoreDetail {
  const PlatformStoreDetail({
    required this.store,
    this.owner,
    this.usage,
    this.storage,
  });

  final Map<String, dynamic> store;
  final Map<String, dynamic>? owner;
  final Map<String, dynamic>? usage;
  final Map<String, dynamic>? storage;

  factory PlatformStoreDetail.fromJson(Map<String, dynamic> json) {
    return PlatformStoreDetail(
      store: Map<String, dynamic>.from(json['store'] as Map? ?? {}),
      owner: json['owner'] == null
          ? null
          : Map<String, dynamic>.from(json['owner'] as Map),
      usage: json['usage'] == null
          ? null
          : Map<String, dynamic>.from(json['usage'] as Map),
      storage: json['storage'] == null
          ? null
          : Map<String, dynamic>.from(json['storage'] as Map),
    );
  }
}

class PlanLimitResult {
  const PlanLimitResult({required this.allowed, this.message});

  final bool allowed;
  final String? message;
}

class PlatformGrowthPoint {
  const PlatformGrowthPoint({required this.month, required this.count});

  final String month;
  final int count;

  factory PlatformGrowthPoint.fromJson(Map<String, dynamic> json) {
    return PlatformGrowthPoint(
      month: json['month'] as String? ?? '',
      count: _int(json['count']),
    );
  }
}

class PlatformPlanStat {
  const PlatformPlanStat({
    required this.planId,
    required this.planName,
    required this.storeCount,
    required this.mrrCents,
  });

  final String planId;
  final String planName;
  final int storeCount;
  final int mrrCents;

  factory PlatformPlanStat.fromJson(Map<String, dynamic> json) {
    return PlatformPlanStat(
      planId: json['plan_id'] as String? ?? '',
      planName: json['plan_name'] as String? ?? '',
      storeCount: _int(json['store_count']),
      mrrCents: _int(json['mrr_cents']),
    );
  }
}

class PlatformStorageRank {
  const PlatformStorageRank({
    required this.storeId,
    required this.storeName,
    required this.totalBytes,
    required this.imageCount,
  });

  final String storeId;
  final String storeName;
  final int totalBytes;
  final int imageCount;

  factory PlatformStorageRank.fromJson(Map<String, dynamic> json) {
    return PlatformStorageRank(
      storeId: json['store_id'] as String? ?? '',
      storeName: json['store_name'] as String? ?? '',
      totalBytes: _int(json['total_bytes']),
      imageCount: _int(json['image_count']),
    );
  }
}

class PlatformAlert {
  const PlatformAlert({
    required this.type,
    required this.storeId,
    required this.storeName,
    required this.message,
    this.detail,
  });

  final String type;
  final String storeId;
  final String storeName;
  final String message;
  final String? detail;

  factory PlatformAlert.fromJson(Map<String, dynamic> json) {
    return PlatformAlert(
      type: json['type'] as String? ?? 'info',
      storeId: json['store_id'] as String? ?? '',
      storeName: json['store_name'] as String? ?? '',
      message: json['message'] as String? ?? '',
      detail: json['detail']?.toString(),
    );
  }
}

class PlatformAnalytics {
  const PlatformAnalytics({
    required this.storeGrowth,
    required this.subscriptionsByPlan,
    required this.topStorageStores,
    required this.alerts,
  });

  final List<PlatformGrowthPoint> storeGrowth;
  final List<PlatformPlanStat> subscriptionsByPlan;
  final List<PlatformStorageRank> topStorageStores;
  final List<PlatformAlert> alerts;

  factory PlatformAnalytics.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(dynamic raw, T Function(Map<String, dynamic>) fn) {
      if (raw is! List) return [];
      return raw
          .map((e) => fn(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return PlatformAnalytics(
      storeGrowth: parseList(json['store_growth'], PlatformGrowthPoint.fromJson),
      subscriptionsByPlan:
          parseList(json['subscriptions_by_plan'], PlatformPlanStat.fromJson),
      topStorageStores:
          parseList(json['top_storage_stores'], PlatformStorageRank.fromJson),
      alerts: parseList(json['alerts'], PlatformAlert.fromJson),
    );
  }
}

class AdminActivityLogEntry {
  const AdminActivityLogEntry({
    required this.id,
    required this.action,
    this.adminEmail,
    this.targetType,
    this.targetId,
    required this.createdAt,
  });

  final String id;
  final String action;
  final String? adminEmail;
  final String? targetType;
  final String? targetId;
  final DateTime createdAt;

  factory AdminActivityLogEntry.fromJson(Map<String, dynamic> json) {
    return AdminActivityLogEntry(
      id: json['id'] as String? ?? '',
      action: json['action'] as String? ?? '',
      adminEmail: json['admin_email'] as String?,
      targetType: json['target_type'] as String?,
      targetId: json['target_id'] as String?,
      createdAt: _date(json['created_at']) ?? DateTime.now(),
    );
  }
}

class PlatformSearchResults {
  const PlatformSearchResults({
    required this.stores,
    required this.plans,
  });

  final List<PlatformStoreRow> stores;
  final List<Map<String, dynamic>> plans;

  factory PlatformSearchResults.fromJson(Map<String, dynamic> json) {
    final storesRaw = json['stores'];
    final plansRaw = json['plans'];
    return PlatformSearchResults(
      stores: storesRaw is List
          ? storesRaw
              .map((e) => PlatformStoreRow.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : [],
      plans: plansRaw is List
          ? plansRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList()
          : [],
    );
  }
}

int _int(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

DateTime? _date(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString());
}

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}
