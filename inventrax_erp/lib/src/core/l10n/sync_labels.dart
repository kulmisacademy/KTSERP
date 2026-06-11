import 'package:inventrax_erp/l10n/app_localizations.dart';

import '../../observability/sync_indicator_providers.dart';
import '../../observability/system_health_providers.dart';

/// Localized sync chip labels — keeps providers free of BuildContext.
SyncIndicatorUi localizeSyncUi(SyncIndicatorUi ui, AppLocalizations l10n) {
  String compact;
  String full;
  if (ui.offlineMode) {
    compact = l10n.syncOffline;
    full = l10n.syncOfflineMode;
  } else {
    switch (ui.state) {
      case GlobalSyncIndicatorState.syncing:
        compact = l10n.syncSyncing;
        full = l10n.syncSyncing;
      case GlobalSyncIndicatorState.warning:
        compact = ui.pendingQueue > 0 ? l10n.syncQueue : l10n.syncSyncing;
        full = ui.pendingQueue > 0
            ? l10n.syncQueueBanner(ui.pendingQueue)
            : l10n.syncReconnecting;
      case GlobalSyncIndicatorState.connected:
        compact = l10n.syncLive;
        full = l10n.syncConnected;
      case GlobalSyncIndicatorState.offline:
        compact = l10n.syncOffline;
        full = l10n.syncOfflineMode;
    }
  }
  return SyncIndicatorUi(
    state: ui.state,
    compactLabel: compact,
    fullLabel: full,
    offlineMode: ui.offlineMode,
    pendingQueue: ui.pendingQueue,
  );
}
