import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../ui/components/app_button.dart';
import '../../../ui/components/app_input.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _page = PageController();
  var _step = 0;

  final _storeName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  var _businessType = 'Retail';
  var _currency = 'USD';
  var _country = 'Somalia';
  final _taxRate = TextEditingController();
  final _receiptHeader = TextEditingController();
  var _plan = 'Free Trial';

  static const _businessTypes = [
    'Retail',
    'Supermarket',
    'Pharmacy',
    'Electronics',
    'Wholesale',
    'Mini Market',
    'Service',
  ];

  static const _currencies = ['USD', 'EUR', 'GBP', 'KES', 'SOS'];

  @override
  void dispose() {
    _page.dispose();
    _storeName.dispose();
    _phone.dispose();
    _address.dispose();
    _taxRate.dispose();
    _receiptHeader.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final db = ref.read(appDatabaseProvider);
    final taxBps = _taxRate.text.trim().isEmpty
        ? null
        : ((double.tryParse(_taxRate.text) ?? 0) * 100).round();

    await db.upsertStoreSettings(
      StoreSettingsCompanion.insert(
        storeId: StoreContext.storeId,
        tenantId: StoreContext.tenantId,
        storeName: _storeName.text.trim().isEmpty
            ? (StoreContext.storeName ?? 'My Store')
            : _storeName.text.trim(),
        businessType: Value(_businessType),
        phone: Value(_phone.text.trim()),
        address: Value(_address.text.trim()),
        currencyCode: Value(_currency),
        country: Value(_country),
        currencySymbol: const Value(r'$'),
        taxRateBps: Value(taxBps),
        taxName: const Value('VAT'),
        receiptHeader: Value(_receiptHeader.text.trim()),
        planName: Value(_plan),
        updatedAt: Value(DateTime.now()),
      ),
    );

    if (mounted) context.go('/dashboard');
  }

  void _next() {
    final l10n = context.l10n;
    if (_step == 0 && _storeName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.storeNameRequired)),
      );
      return;
    }
    if (_step < 3) {
      setState(() => _step++);
      _page.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  static const _plans = ['Free Trial', 'Starter', 'Business'];

  String _planLabel(String plan) {
    final l10n = context.l10n;
    return switch (plan) {
      'Free Trial' => l10n.onboardingPlanFreeTrialName,
      'Starter' => l10n.onboardingPlanStarter,
      'Business' => l10n.onboardingPlanBusiness,
      _ => plan,
    };
  }

  String _planSubtitle(String plan) {
    final l10n = context.l10n;
    if (plan == 'Free Trial') return l10n.onboardingPlanFreeTrialDesc;
    return l10n.onboardingPlanBilledMonthly;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingStoreSetup),
        actions: [
          TextButton(
            onPressed: () => context.go('/dashboard'),
            child: Text(l10n.onboardingSkip),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Row(
              children: List.generate(4, (i) {
                final active = i <= _step;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: active
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _page,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _stepCard(
                  title: l10n.onboardingBusinessInfo,
                  subtitle: l10n.onboardingBusinessSubtitle,
                  children: [
                    AppInput(
                      controller: _storeName,
                      label: l10n.storeNameField,
                      prefixIcon: Icons.store,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _businessType,
                      decoration: InputDecoration(labelText: l10n.businessType),
                      items: _businessTypes
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => _businessType = v ?? 'Retail'),
                    ),
                    const SizedBox(height: 12),
                    AppInput(
                      controller: _phone,
                      label: l10n.phoneRequired,
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    AppInput(
                      controller: _address,
                      label: l10n.addressRequired,
                      prefixIcon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                  ],
                ),
                _stepCard(
                  title: l10n.onboardingLocalization,
                  subtitle: l10n.onboardingLocalizationSubtitle,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: InputDecoration(labelText: l10n.currencyLabel),
                      items: _currencies
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _currency = v ?? 'USD'),
                    ),
                    const SizedBox(height: 12),
                    AppInput(
                      controller: _taxRate,
                      label: l10n.onboardingTaxRateOptional,
                      prefixIcon: Icons.percent,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
                _stepCard(
                  title: l10n.onboardingBranding,
                  subtitle: l10n.onboardingBrandingSubtitle,
                  children: [
                    AppInput(
                      controller: _receiptHeader,
                      label: l10n.receiptHeaderText,
                      prefixIcon: Icons.receipt_long,
                      maxLines: 2,
                    ),
                  ],
                ),
                _stepCard(
                  title: l10n.onboardingChoosePlan,
                  subtitle: l10n.onboardingPlanSubtitle,
                  children: [
                    for (final p in _plans)
                      RadioListTile<String>(
                        title: Text(_planLabel(p)),
                        subtitle: Text(_planSubtitle(p)),
                        value: p,
                        groupValue: _plan,
                        onChanged: (v) => setState(() => _plan = v ?? _plan),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_step > 0)
                  OutlinedButton(
                    onPressed: () {
                      setState(() => _step--);
                      _page.previousPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                      );
                    },
                    child: Text(l10n.onboardingBack),
                  ),
                const Spacer(),
                AppButton(
                  label: _step == 3 ? l10n.onboardingFinishSetup : l10n.onboardingContinue,
                  icon: Icons.arrow_forward,
                  onPressed: _next,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
