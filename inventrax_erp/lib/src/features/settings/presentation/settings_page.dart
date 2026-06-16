import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_repository.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../sales/application/invoice_branding_provider.dart';
import '../../sales/application/invoice_display_provider.dart';
import '../../sales/application/invoice_preview_provider.dart';
import '../../sales/application/sale_invoice_provider.dart';
import '../../../features/ai_insights/application/ai_insights_providers.dart';
import '../../../core/media/image_storage_service.dart';
import '../../../ui/components/app_button.dart';
import '../../../ui/components/app_card.dart';
import '../../../ui/components/app_input.dart';
import '../../../core/ux/feedback_service.dart';
import '../../../core/l10n/language_selector.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/support/support_whatsapp.dart';
import '../../../core/ux/theme_mode_provider.dart';
import '../../../ui/layout/app_shell.dart';
import '../../../ui/widgets/store_logo_picker.dart';
import '../../auth/application/session_provider.dart';
import '../../users/domain/app_permission.dart';

final auditLogsProvider = StreamProvider.autoDispose<List<AuditLog>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchAuditLogs(storeId: StoreContext.storeId, limit: 50);
});

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _storeName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _taxRate = TextEditingController();
  final _receiptHeader = TextEditingController();
  final _invoiceFooter = TextEditingController();
  final _email = TextEditingController();
  final _taxNumber = TextEditingController();
  var _currency = 'USD';
  String? _logoLocalPath;
  String? _logoUrl;
  Uint8List? _logoPickedBytes;
  bool _logoClear = false;
  var _allowPriceOverride = true;
  var _autoPrintReceipt = false;
  var _taxInclusive = false;
  var _invoiceShowSku = false;
  var _invoiceShowDiscount = false;
  var _invoiceShowTax = false;
  var _invoiceCompactMode = true;
  var _saving = false;
  String? _saveError;
  String? _hydratedStoreId;
  DateTime? _hydratedUpdatedAt;

  @override
  void dispose() {
    _storeName.dispose();
    _phone.dispose();
    _address.dispose();
    _taxRate.dispose();
    _receiptHeader.dispose();
    _invoiceFooter.dispose();
    _email.dispose();
    _taxNumber.dispose();
    super.dispose();
  }

  void _applySettingsToForm(StoreSetting s) {
    _storeName.text = s.storeName;
    _phone.text = s.phone ?? '';
    _address.text = s.address ?? '';
    _currency = s.currencyCode;
    _taxRate.text = s.taxRateBps != null ? (s.taxRateBps! / 100).toString() : '';
    _receiptHeader.text = s.receiptHeader ?? '';
    _invoiceFooter.text = s.invoiceFooter ?? '';
    _email.text = s.email ?? '';
    _taxNumber.text = s.taxNumber ?? '';
    _logoLocalPath = s.logoLocalPath;
    _logoUrl = s.logoUrl;
    _allowPriceOverride = s.allowCashierPriceOverride;
    _autoPrintReceipt = s.autoPrintReceipt;
    _taxInclusive = s.taxInclusive;
    _invoiceShowSku = s.invoiceShowSku;
    _invoiceShowDiscount = s.invoiceShowDiscount;
    _invoiceShowTax = s.invoiceShowTax;
    _invoiceCompactMode = s.invoiceCompactMode;
    _hydratedStoreId = s.storeId;
    _hydratedUpdatedAt = s.updatedAt;
  }

  void _maybeHydrateForm(StoreSetting s) {
    final sameRevision = _hydratedStoreId == s.storeId &&
        _hydratedUpdatedAt != null &&
        s.updatedAt.isAtSameMomentAs(_hydratedUpdatedAt!);
    if (sameRevision) return;
    if (!mounted) return;
    setState(() => _applySettingsToForm(s));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<StoreSetting?>>(storeSettingsProvider, (_, next) {
      final s = next.value;
      if (s != null) _maybeHydrateForm(s);
    });

    final settings = ref.watch(storeSettingsProvider);

    final l10n = context.l10n;
    return AppShell(
      route: '/settings',
      child: settings.when(
        data: (s) {
          final audits = ref.watch(auditLogsProvider);
          final themeMode = ref.watch(appThemeModeProvider);
          final feedback = ref.watch(feedbackSettingsProvider);

          return ListView(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.appearanceTitle, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text(l10n.themeSystem),
                          icon: const Icon(Icons.brightness_auto, size: 18),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text(l10n.themeLight),
                          icon: const Icon(Icons.light_mode, size: 18),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text(l10n.themeDark),
                          icon: const Icon(Icons.dark_mode, size: 18),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (s) {
                        if (s.isEmpty) return;
                        ref.read(appThemeModeProvider.notifier).setMode(s.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.settingsPosFeedback, style: Theme.of(context).textTheme.titleMedium),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.settingsSoundEffects),
                      subtitle: Text(l10n.settingsScanCues),
                      value: feedback.soundsEnabled,
                      onChanged: (v) =>
                          ref.read(feedbackSettingsProvider.notifier).setSounds(v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.settingsHaptics),
                      value: feedback.hapticsEnabled,
                      onChanged: (v) =>
                          ref.read(feedbackSettingsProvider.notifier).setHaptics(v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (StoreContext.isSuperAdmin)
                AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.hub_outlined),
                    title: Text(l10n.settingsPlatformCenter),
                    subtitle: Text(l10n.settingsPlatformSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/platform/dashboard'),
                  ),
                ),
              if (StoreContext.isSuperAdmin) const SizedBox(height: 16),
              if (StoreContext.can(AppPermission.usersView))
                AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.manage_accounts_outlined),
                    title: Text(l10n.settingsUserMgmt),
                    subtitle: Text(l10n.settingsUserMgmtSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/users'),
                  ),
                ),
              if (StoreContext.can(AppPermission.usersView))
                const SizedBox(height: 16),
              if (StoreContext.can(AppPermission.systemHealthView) ||
                  StoreContext.isStoreOwner)
                AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.monitor_heart_outlined),
                    title: Text(l10n.settingsSystemHealth),
                    subtitle: Text(l10n.settingsHealthSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/settings/health'),
                  ),
                ),
              if (StoreContext.can(AppPermission.systemHealthView) ||
                  StoreContext.isStoreOwner)
                AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.fact_check_outlined),
                    title: Text(l10n.settingsQaValidation),
                    subtitle: Text(l10n.settingsQaSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/settings/qa'),
                  ),
                ),
              if (StoreContext.can(AppPermission.systemHealthView) ||
                  StoreContext.isStoreOwner)
                const SizedBox(height: 16),
              AppCard(
                child: ListTile(
                  leading: Icon(Icons.chat_outlined, color: Colors.green.shade600),
                  title: Text(l10n.supportWhatsAppTitle),
                  subtitle: Text(l10n.supportWhatsAppSubtitle),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => SupportWhatsApp.openChatOrSnackBar(
                    context,
                    message: l10n.supportWhatsAppPrefill,
                    unavailableMessage: l10n.supportWhatsAppUnavailable,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.settingsStoreBranding, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      l10n.settingsBrandingHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    StoreLogoPicker(
                      localPath: _logoLocalPath,
                      remoteUrl: _logoUrl,
                      onChanged: ({
                        localPath,
                        remoteUrl,
                        imageBytes,
                        clear = false,
                      }) {
                        setState(() {
                          if (clear) {
                            _logoClear = true;
                            _logoLocalPath = null;
                            _logoUrl = null;
                            _logoPickedBytes = null;
                          } else {
                            _logoClear = false;
                            _logoLocalPath = localPath;
                            _logoUrl = remoteUrl;
                            _logoPickedBytes = imageBytes;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    AppInput(controller: _storeName, label: l10n.settingsStoreName, prefixIcon: Icons.store),
                    const SizedBox(height: 12),
                    AppInput(controller: _phone, label: l10n.settingsPhone, prefixIcon: Icons.phone),
                    const SizedBox(height: 12),
                    AppInput(controller: _email, label: l10n.settingsEmail, prefixIcon: Icons.email_outlined),
                    const SizedBox(height: 12),
                    AppInput(controller: _address, label: l10n.settingsAddress, maxLines: 2),
                    const SizedBox(height: 12),
                    AppInput(
                      controller: _taxNumber,
                      label: l10n.settingsTaxNumber,
                      prefixIcon: Icons.numbers_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.localizationTitle, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    const LanguageSelector(),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: InputDecoration(labelText: l10n.currencyLabel),
                      items: ['USD', 'EUR', 'GBP', 'KES', 'SOS']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _currency = v ?? 'USD'),
                    ),
                    const SizedBox(height: 12),
                    AppInput(
                      controller: _taxRate,
                      label: l10n.settingsTaxRate,
                      prefixIcon: Icons.percent,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.settingsTaxInclusiveTitle),
                      subtitle: Text(l10n.settingsTaxInclusiveSubtitle),
                      value: _taxInclusive,
                      onChanged: (v) => setState(() => _taxInclusive = v),
                    ),
                    const SizedBox(height: 12),
                    AppInput(controller: _receiptHeader, label: l10n.settingsReceiptHeader, maxLines: 2),
                    const SizedBox(height: 12),
                    AppInput(
                      controller: _invoiceFooter,
                      label: l10n.settingsInvoiceFooter,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Invoice display preferences',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Default column visibility for invoice preview and PDF exports',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          label: const Text('Compact'),
                          onPressed: () => setState(() {
                            _invoiceShowSku = false;
                            _invoiceShowDiscount = false;
                            _invoiceShowTax = false;
                            _invoiceCompactMode = true;
                          }),
                        ),
                        ActionChip(
                          label: const Text('Detailed'),
                          onPressed: () => setState(() {
                            _invoiceShowSku = true;
                            _invoiceShowDiscount = true;
                            _invoiceShowTax = true;
                            _invoiceCompactMode = false;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Show SKU / barcode column'),
                      value: _invoiceShowSku,
                      onChanged: (v) => setState(() {
                        _invoiceShowSku = v;
                        _invoiceCompactMode = false;
                      }),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Show discount column'),
                      value: _invoiceShowDiscount,
                      onChanged: (v) => setState(() {
                        _invoiceShowDiscount = v;
                        _invoiceCompactMode = false;
                      }),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Show tax column'),
                      value: _invoiceShowTax,
                      onChanged: (v) => setState(() {
                        _invoiceShowTax = v;
                        _invoiceCompactMode = false;
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.settingsPosPermissionsTitle, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: Text(l10n.settingsAllowPriceOverride),
                      subtitle: Text(l10n.settingsAllowPriceOverrideSubtitle),
                      value: _allowPriceOverride,
                      onChanged: (v) => setState(() => _allowPriceOverride = v),
                    ),
                    SwitchListTile(
                      title: Text(l10n.settingsAutoPrintReceipt),
                      subtitle: Text(l10n.settingsAutoPrintSubtitle),
                      value: _autoPrintReceipt,
                      onChanged: (v) => setState(() => _autoPrintReceipt = v),
                    ),
                  ],
                ),
              ),
              if (StoreContext.can(AppPermission.subscriptionView) ||
                  StoreContext.isStoreOwner) ...[
                const SizedBox(height: 16),
                AppCard(
                  child: ListTile(
                    title: Text(l10n.settingsSubscriptionPlan),
                    subtitle: Text(s?.planName ?? l10n.planFreeTrial),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/billing'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.settingsAuditLog, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    audits.when(
                      data: (rows) {
                        if (rows.isEmpty) {
                          return Text(l10n.settingsNoAudit);
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: rows.length.clamp(0, 15),
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final a = rows[i];
                            return ListTile(
                              dense: true,
                              title: Text('${a.entity} · ${a.action}'),
                              subtitle: Text(
                                [
                                  if (a.field != null) '${a.field}: ${a.oldValue} → ${a.newValue}',
                                  a.createdAt.toString().substring(0, 16),
                                ].join('\n'),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text(l10n.commonErrorWithDetail(e.toString())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(l10n.signOut),
                  subtitle: Text(StoreContext.userEmail ?? l10n.notSignedIn),
                  onTap: () async {
                    await ref.read(sessionProvider.notifier).signOut();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ),
              if (_saveError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _saveError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: _saving ? l10n.savingSettings : l10n.saveSettings,
                expand: true,
                loading: _saving,
                onPressed: _saving ? null : () async {
                  final name = _storeName.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.storeNameRequired)),
                    );
                    return;
                  }
                  setState(() {
                    _saving = true;
                    _saveError = null;
                  });
                  try {
                    final taxBps = _taxRate.text.trim().isEmpty
                        ? null
                        : ((double.tryParse(_taxRate.text) ?? 0) * 100).round();
                    final storage = ImageStorageService();
                    String? logoLocal = _logoLocalPath;
                    String? logoRemote = _logoUrl;
                    if (_logoClear) {
                      logoLocal = null;
                      logoRemote = null;
                    } else if (_logoPickedBytes != null) {
                      final saved = await persistStoreLogo(
                        storage: storage,
                        tenantId: StoreContext.tenantId,
                        storeId: StoreContext.storeId,
                        pickedPath: _logoLocalPath,
                        imageBytes: _logoPickedBytes,
                      );
                      logoLocal = saved.localPath;
                      logoRemote = saved.logoUrl;
                      if (logoRemote == null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.settingsLogoUploadFailed),
                          ),
                        );
                      }
                    }
                    final localeCode = ref.read(appLocaleProvider).code;
                    final repo = ref.read(storeSettingsRepositoryProvider);
                    final saved = await repo.save(
                      StoreSettingsCompanion(
                        storeId: Value(StoreContext.storeId),
                        tenantId: Value(StoreContext.tenantId),
                        storeName: Value(_storeName.text.trim()),
                        localeCode: Value(localeCode),
                        phone: Value(_phone.text.trim()),
                        address: Value(_address.text.trim()),
                        email: Value(_email.text.trim()),
                        taxNumber: Value(_taxNumber.text.trim()),
                        currencyCode: Value(_currency),
                        taxRateBps: Value(taxBps),
                        taxInclusive: Value(_taxInclusive),
                        receiptHeader: Value(_receiptHeader.text.trim()),
                        invoiceFooter: Value(_invoiceFooter.text.trim()),
                        logoUrl: Value(logoRemote),
                        logoLocalPath: Value(logoLocal),
                        allowCashierPriceOverride: Value(_allowPriceOverride),
                        autoPrintReceipt: Value(_autoPrintReceipt),
                        invoiceShowSku: Value(_invoiceShowSku),
                        invoiceShowDiscount: Value(_invoiceShowDiscount),
                        invoiceShowTax: Value(_invoiceShowTax),
                        invoiceCompactMode: Value(_invoiceCompactMode),
                        updatedAt: Value(DateTime.now()),
                      ),
                    );
                    ref.invalidate(storeSettingsProvider);
                    ref.invalidate(storeProfileProvider);
                    ref.invalidate(storeDisplayNameProvider);
                    ref.invalidate(aiBusinessSnapshotProvider);
                    ref.invalidate(saleInvoiceProvider);
                    ref.invalidate(invoicePreviewProvider);
                    ref.invalidate(invoiceBrandingProvider);
                    ref.invalidate(storeInvoiceDisplayProvider);
                    if (mounted) {
                      setState(() {
                        _applySettingsToForm(saved);
                        _logoPickedBytes = null;
                        _logoClear = false;
                        _saveError = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.settingsSaved)),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() {
                        _saveError = l10n.commonErrorWithDetail('$e');
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.commonErrorWithDetail('$e'))),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _saving = false);
                  }
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
