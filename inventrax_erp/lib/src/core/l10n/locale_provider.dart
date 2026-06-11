import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/app_database.dart';
import '../../data/local/db_provider.dart';
import '../../data/local/store_settings_provider.dart';
import '../../core/store_context.dart';
import 'app_locale.dart';

const _localePrefsKey = 'inventrax_locale';

class AppLocaleController extends Notifier<AppLocale> {
  @override
  AppLocale build() {
    _loadInitial();
    ref.listen(storeSettingsProvider, (prev, next) {
      final code = next.value?.localeCode;
      if (code == null || code.isEmpty) return;
      final locale = AppLocale.fromCode(code);
      if (locale != state) state = locale;
    });
    return AppLocale.english;
  }

  Future<void> _loadInitial() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_localePrefsKey);
    if (stored != null && stored.isNotEmpty) {
      state = AppLocale.fromCode(stored);
      return;
    }
    if (StoreContext.storeId.isEmpty) return;
    try {
      final db = ref.read(appDatabaseProvider);
      final row = await db.getStoreSettings(storeId: StoreContext.storeId);
      if (row?.localeCode != null && row!.localeCode.isNotEmpty) {
        state = AppLocale.fromCode(row.localeCode);
      }
    } catch (_) {}
  }

  Future<void> setLocale(AppLocale locale, {bool persistStore = true}) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefsKey, locale.code);

    if (!persistStore || StoreContext.storeId.isEmpty) return;
    try {
      final db = ref.read(appDatabaseProvider);
      final existing = await db.getStoreSettings(storeId: StoreContext.storeId);
      if (existing == null) return;
      await db.upsertStoreSettings(
        StoreSettingsCompanion(
          storeId: Value(existing.storeId),
          tenantId: Value(existing.tenantId),
          storeName: Value(existing.storeName),
          localeCode: Value(locale.code),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (_) {}
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleController, AppLocale>(
  AppLocaleController.new,
);
