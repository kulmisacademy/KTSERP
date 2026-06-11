import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/store/active_store_scope.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';

const _debtShareBaseUrl = 'https://kulmis.app/debt';

String _debtShareLink(String token) => '$_debtShareBaseUrl/$token';

String _buildDebtWhatsAppMessage({
  required String customerName,
  required String storeName,
  required String amount,
  required String link,
}) {
  return 'Asc $customerName,\n\n'
      'Waxaad leedahay deyn dhan $amount.\n\n'
      'Fadlan eeg invoice-ka:\n$link\n\n'
      'Mahadsanid,\n$storeName';
}

Future<void> shareCustomerDebt({
  required WidgetRef ref,
  required String customerId,
  required String customerName,
  required int balanceCents,
}) async {
  final scope = ref.read(activeStoreScopeProvider);
  final db = ref.read(appDatabaseProvider);
  final storeName =
      ref.read(storeSettingsProvider).value?.storeName ?? 'KULMIS';
  final currency = ref.read(storeSettingsProvider).value?.currencyCode ?? 'USD';

  final token = await db.ensureDebtShareLink(
    tenantId: scope.tenantId,
    storeId: scope.storeId,
    customerId: customerId,
  );
  final link = _debtShareLink(token);
  final balance = formatMoney(balanceCents, currency: currency);
  final message = _buildDebtWhatsAppMessage(
    customerName: customerName,
    storeName: storeName,
    amount: balance,
    link: link,
  );

  await SharePlus.instance.share(
    ShareParams(text: message, subject: 'Balance — $storeName'),
  );
}

Future<void> shareSupplierPayable({
  required WidgetRef ref,
  required String supplierName,
  required int balanceCents,
}) async {
  final storeName =
      ref.read(storeSettingsProvider).value?.storeName ?? 'KULMIS';
  final currency = ref.read(storeSettingsProvider).value?.currencyCode ?? 'USD';
  final balance = formatMoney(balanceCents, currency: currency);
  final message =
      'Hello $supplierName,\nOutstanding payable to you: $balance.\n\n'
      '— $storeName';

  await SharePlus.instance.share(
    ShareParams(text: message, subject: 'Payable — $storeName'),
  );
}

Future<void> shareDebtWhatsApp({
  required BuildContext context,
  required String? phone,
  required String message,
}) async {
  if (phone == null || phone.trim().isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on file')),
      );
    }
    return;
  }

  final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
  final uri = Uri.parse(
    'https://wa.me/$digits?text=${Uri.encodeComponent(message)}',
  );

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return;
  }

  await SharePlus.instance.share(ShareParams(text: message));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('WhatsApp not available — opened share instead'),
      ),
    );
  }
}

Future<void> shareCustomerDebtWhatsApp({
  required BuildContext context,
  required WidgetRef ref,
  required String customerId,
  required String customerName,
  required String? phone,
  required int balanceCents,
  String? debtId,
}) async {
  if (phone == null || phone.trim().isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on file')),
      );
    }
    return;
  }

  final scope = ref.read(activeStoreScopeProvider);
  final db = ref.read(appDatabaseProvider);
  final settings = ref.read(storeSettingsProvider).value;
  final storeName = settings?.storeName ?? 'KULMIS';
  final currency = settings?.currencyCode ?? 'USD';

  final token = await db.ensureDebtShareLink(
    tenantId: scope.tenantId,
    storeId: scope.storeId,
    customerId: customerId,
    debtId: debtId,
  );
  final link = _debtShareLink(token);
  final balance = formatMoney(balanceCents, currency: currency);
  final message = _buildDebtWhatsAppMessage(
    customerName: customerName,
    storeName: storeName,
    amount: balance,
    link: link,
  );

  if (!context.mounted) return;
  await shareDebtWhatsApp(context: context, phone: phone, message: message);
}

/// Legacy alias — opens WhatsApp instead of SMS.
Future<void> sendCustomerDebtSms({
  required BuildContext context,
  required WidgetRef ref,
  required String customerId,
  required String customerName,
  required String? phone,
  required int balanceCents,
  String? debtId,
  DateTime? dueDate,
  String? invoiceNumber,
}) =>
    shareCustomerDebtWhatsApp(
      context: context,
      ref: ref,
      customerId: customerId,
      customerName: customerName,
      phone: phone,
      balanceCents: balanceCents,
      debtId: debtId,
    );

Future<void> sendSupplierPayableSms({
  required BuildContext context,
  required WidgetRef ref,
  required String supplierName,
  required String? phone,
  required int balanceCents,
}) async {
  if (phone == null || phone.trim().isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on file')),
      );
    }
    return;
  }

  final storeName =
      ref.read(storeSettingsProvider).value?.storeName ?? 'KULMIS';
  final currency = ref.read(storeSettingsProvider).value?.currencyCode ?? 'USD';
  final balance = formatMoney(balanceCents, currency: currency);
  final message =
      'Hello $supplierName, payable balance: $balance. — $storeName';

  if (!context.mounted) return;
  await shareDebtWhatsApp(context: context, phone: phone, message: message);
}

/// @deprecated Use [shareDebtWhatsApp].
Future<void> sendDebtSmsDevice({
  required BuildContext context,
  required String? phone,
  required String message,
}) =>
    shareDebtWhatsApp(context: context, phone: phone, message: message);
