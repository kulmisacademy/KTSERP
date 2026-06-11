import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai_config.dart';
import '../../../core/design/design_system.dart';
import 'package:inventrax_erp/l10n/app_localizations.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../ui/layout/app_shell.dart';
import '../../../ui/widgets/brand_hero_banner.dart';
import '../application/ai_insights_providers.dart';
import '../domain/ai_models.dart';
import 'widgets/ai_chart_panel.dart';
import 'widgets/ai_typing_indicator.dart';

class AiInsightsPage extends ConsumerWidget {
  const AiInsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return AppShell(
      route: '/ai-insights',
      subtitle: AiConfig.isConfigured ? l10n.aiPoweredBy : l10n.aiConfigureKey,
      actions: [
        IconButton(
          tooltip: l10n.aiClearChat,
          onPressed: () => ref.read(aiInsightsChatProvider.notifier).clear(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: const _AiInsightsBody(),
    );
  }
}

/// Analytics + chat only — AppShell/sidebar stay stable when snapshot refreshes.
class _AiInsightsBody extends ConsumerWidget {
  const _AiInsightsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final snapshot = ref.watch(aiBusinessSnapshotProvider);
    final currency = ref.watch(
      storeSettingsProvider.select((a) => a.value?.currencyCode ?? 'USD'),
    );
    final wide = MediaQuery.sizeOf(context).width >= 1000;

    return snapshot.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.errorLoadAnalytics(e.toString()))),
      data: (snap) {
        final risks = ref.watch(aiLocalRisksProvider);
        return _AiInsightsLoaded(
          snap: snap,
          risks: risks,
          currency: currency,
          wide: wide,
        );
      },
    );
  }
}

/// Main AI workspace — hero/risk static; chat subtree isolated.
class _AiInsightsLoaded extends StatelessWidget {
  const _AiInsightsLoaded({
    required this.snap,
    required this.risks,
    required this.currency,
    required this.wide,
  });

  final AiBusinessSnapshot snap;
  final List<AiBusinessRisk> risks;
  final String currency;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: wide ? 3 : 1,
          child: Column(
            children: [
              RepaintBoundary(
                child: _HeroStrip(
                  snap: snap,
                  currency: currency,
                  riskCount: risks.length,
                  summaryTemplate: l10n,
                ),
              ),
              if (risks.isNotEmpty)
                RepaintBoundary(
                  child: _RiskStrip(risks: risks.take(3).toList()),
                ),
              const Expanded(
                child: _AiChatRegion(),
              ),
            ],
          ),
        ),
        if (wide)
          RepaintBoundary(
            child: Container(
              width: 360,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(left: BorderSide(color: AppColors.borderLight)),
              ),
              child: _InsightsSidebar(snapshot: snap),
            ),
          ),
      ],
    );
  }
}

/// Chat + prompts — only this subtree rebuilds when messages change.
class _AiChatRegion extends ConsumerStatefulWidget {
  const _AiChatRegion();

  @override
  ConsumerState<_AiChatRegion> createState() => _AiChatRegionState();
}

class _AiChatRegionState extends ConsumerState<_AiChatRegion> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final q = text ?? _input.text;
    if (text != null) _input.text = text;
    _input.clear();
    ref.read(aiInsightsChatProvider.notifier).ask(q);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomIfNearEnd());
  }

  void _scrollToBottomIfNearEnd() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.maxScrollExtent - pos.pixels > 140) return;
    _scroll.animateTo(
      pos.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiInsightsChatProvider);
    final l10n = context.l10n;

    return Column(
      children: [
        Expanded(
          child: _ChatList(
            messages: messages,
            scroll: _scroll,
            emptyHint: l10n.aiEmptyHint,
            analyzingLabel: l10n.aiAnalyzing,
          ),
        ),
        _PromptChips(
          onTap: _send,
          prompts: [
            l10n.aiPromptSalesSummary,
            l10n.aiPromptCompareWeeks,
            l10n.aiPromptTopProducts,
            l10n.aiPromptRisks,
            l10n.aiPromptExpenses,
            l10n.aiPromptDebts,
            l10n.aiPromptSlowStock,
            l10n.aiPromptForecast,
          ],
        ),
        _InputBar(controller: _input, onSend: () => _send(), hint: l10n.aiInputHint),
      ],
    );
  }
}

class _HeroStrip extends StatelessWidget {
  const _HeroStrip({
    required this.snap,
    required this.currency,
    required this.riskCount,
    required this.summaryTemplate,
  });

  final AiBusinessSnapshot snap;
  final String currency;
  final int riskCount;
  final AppLocalizations summaryTemplate;

  @override
  Widget build(BuildContext context) {
    final l10n = summaryTemplate;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: BrandHeroBanner(
        padding: AppSpacing.card,
        child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          AppSpacing.gapMd(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snap.storeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  l10n.aiMonthSummary(
                    formatMoney(snap.monthSalesCents, currency: currency),
                    formatMoney(snap.monthProfitCents, currency: currency),
                    riskCount,
                  ),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _RiskStrip extends StatelessWidget {
  const _RiskStrip({required this.risks});
  final List<AiBusinessRisk> risks;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: risks.length,
        separatorBuilder: (_, _) => AppSpacing.gapSm(),
        itemBuilder: (_, i) {
          final r = risks[i];
          final color = r.severity == 'high'
              ? AppColors.errorContainer
              : AppColors.warningContainer;
          return Container(
            width: 220,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.mdAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  r.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
                Text(
                  r.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, height: 1.2),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  const _ChatList({
    required this.messages,
    required this.scroll,
    required this.emptyHint,
    required this.analyzingLabel,
  });

  final List<AiChatMessage> messages;
  final ScrollController scroll;
  final String emptyHint;
  final String analyzingLabel;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.cardLg,
          child: Text(
            emptyHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }
    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.all(AppSpacing.md),
      cacheExtent: 480,
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final m = messages[i];
        return RepaintBoundary(
          child: _MessageBubble(
            key: ValueKey('ai-msg-${m.id ?? i}'),
            message: m,
            analyzingLabel: analyzingLabel,
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    super.key,
    required this.message,
    required this.analyzingLabel,
  });

  final AiChatMessage message;
  final String analyzingLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isUser = message.role == 'user';
    if (message.isLoading) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AiTypingIndicator(label: analyzingLabel),
        ),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        constraints: const BoxConstraints(maxWidth: 640),
        padding: AppSpacing.card,
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: AppRadius.lgAll,
          border: isUser ? null : Border.all(color: AppColors.borderLight),
          boxShadow: isUser
              ? null
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.error != null)
              Text(message.error!, style: const TextStyle(color: AppColors.error))
            else ...[
              Text(
                isUser ? message.text : (message.response?.summary ?? message.text),
                style: TextStyle(
                  color: isUser ? Colors.white : AppColors.textPrimaryLight,
                  height: 1.45,
                ),
              ),
              if (!isUser && message.response != null) ...[
                AppSpacing.gapMd(),
                _ResponseSections(
                  response: message.response!,
                  warningsTitle: l10n.aiWarnings,
                  recommendationsTitle: l10n.aiRecommendations,
                  opportunitiesTitle: l10n.aiOpportunities,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ResponseSections extends StatelessWidget {
  const _ResponseSections({
    required this.response,
    required this.warningsTitle,
    required this.recommendationsTitle,
    required this.opportunitiesTitle,
  });

  final AiInsightResponse response;
  final String warningsTitle;
  final String recommendationsTitle;
  final String opportunitiesTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (response.metrics.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: response.metrics
                .map(
                  (m) => Chip(
                    label: Text('${m.label}: ${m.value}', style: const TextStyle(fontSize: 11)),
                  ),
                )
                .toList(),
          ),
          AppSpacing.gapSm(),
        ],
        if (response.warnings.isNotEmpty)
          _BulletSection(title: warningsTitle, items: response.warnings, color: AppColors.error),
        if (response.recommendations.isNotEmpty)
          _BulletSection(title: recommendationsTitle, items: response.recommendations, color: AppColors.accent),
        if (response.opportunities.isNotEmpty)
          _BulletSection(title: opportunitiesTitle, items: response.opportunities, color: AppColors.info),
      ],
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({required this.title, required this.items, required this.color});
  final String title;
  final List<String> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13)),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color)),
                  Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PromptChips extends StatelessWidget {
  const _PromptChips({required this.onTap, required this.prompts});
  final void Function(String) onTap;
  final List<String> prompts;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: prompts.length,
        separatorBuilder: (_, _) => AppSpacing.gapSm(),
        itemBuilder: (_, i) {
          return ActionChip(
            label: Text(prompts[i], style: const TextStyle(fontSize: 12)),
            onPressed: () => onTap(prompts[i]),
          );
        },
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend, required this.hint});
  final TextEditingController controller;
  final VoidCallback onSend;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: AppSpacing.page,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: AppRadius.pillAll),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            AppSpacing.gapSm(),
            FilledButton(
              onPressed: onSend,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightsSidebar extends ConsumerWidget {
  const _InsightsSidebar({required this.snapshot});
  final AiBusinessSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(
      aiInsightsChatProvider.select((list) {
        for (final m in list.reversed) {
          if (m.response != null) return m.response;
        }
        return null;
      }),
    );

    return ListView(
      padding: AppSpacing.page,
      children: [
        Text(
          context.l10n.aiLiveAnalytics,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        AppSpacing.gapMd(),
        AiChartPanel(
          snapshot: snapshot,
          hints: messages?.chartHints ?? const [],
        ),
      ],
    );
  }
}
