import '../../auth/domain/app_role.dart';

class StoreUser {
  const StoreUser({
    required this.id,
    required this.tenantId,
    required this.storeId,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.avatarUrl,
    this.isActive = true,
    this.status = 'active',
    this.lastLoginAt,
    this.customPermissions = const {},
  });

  final String id;
  final String tenantId;
  final String storeId;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final AppRole role;
  final bool isActive;
  final String status;
  final DateTime? lastLoginAt;

  /// permission_id → granted (false = explicit revoke)
  final Map<String, bool> customPermissions;

  String get roleLabel => role.label;
  String get statusLabel => isActive ? status : 'suspended';
}
