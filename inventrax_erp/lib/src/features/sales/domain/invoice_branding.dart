import '../../../core/store/store_branding.dart';
import '../../../data/local/app_database.dart';

/// Live store branding for invoice preview / PDF — always from latest settings.
class InvoiceBranding {
  const InvoiceBranding({
    required this.storeName,
    this.phone,
    this.email,
    this.address,
    this.taxNumber,
    this.invoiceFooter,
    this.logoLocalPath,
    this.logoRemoteUrl,
    required this.initials,
    this.currencyCode = 'USD',
    this.taxName,
  });

  final String storeName;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxNumber;
  final String? invoiceFooter;
  final String? logoLocalPath;
  final String? logoRemoteUrl;
  final String initials;
  final String currencyCode;
  final String? taxName;

  factory InvoiceBranding.fromSettings(StoreSetting? settings) {
    final name = StoreBranding.displayName(settings);
    return InvoiceBranding(
      storeName: name,
      phone: _trimOrNull(settings?.phone),
      email: _trimOrNull(settings?.email),
      address: _trimOrNull(settings?.address),
      taxNumber: _trimOrNull(settings?.taxNumber),
      invoiceFooter: _trimOrNull(settings?.invoiceFooter),
      logoLocalPath: _trimOrNull(settings?.logoLocalPath),
      logoRemoteUrl: StoreBranding.logoUrlWithCacheBust(settings),
      initials: _initialsFromName(name),
      currencyCode: settings?.currencyCode ?? 'USD',
      taxName: _trimOrNull(settings?.taxName),
    );
  }

  static String? _trimOrNull(String? v) {
    final t = v?.trim();
    return t == null || t.isEmpty ? null : t;
  }

  static String _initialsFromName(String storeName) {
    final parts = storeName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'S';
    if (parts.length == 1) {
      final w = parts.first;
      return (w.length >= 2 ? w.substring(0, 2) : w).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}
