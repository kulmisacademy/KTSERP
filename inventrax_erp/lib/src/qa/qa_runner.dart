import 'package:drift/drift.dart';

import '../core/store_context.dart';
import '../data/local/app_database.dart';
import 'qa_check.dart';

/// Automated integrity + performance checks for production validation.
class QaRunner {
  QaRunner(this._db);

  final AppDatabase _db;

  Future<QaRunReport> runAll({String? storeId}) async {
    final sid = storeId ?? StoreContext.storeId;
    final started = DateTime.now();
    final checks = <QaCheckResult>[];

    Future<QaCheckResult> timed(
      String id,
      String title,
      String category,
      Future<QaCheckResult> Function() fn,
    ) async {
      final sw = Stopwatch()..start();
      final r = await fn();
      sw.stop();
      return QaCheckResult(
        id: id,
        title: title,
        category: category,
        passed: r.passed,
        message: r.message,
        durationMs: sw.elapsedMilliseconds,
        severity: r.severity,
      );
    }

    checks.addAll([
      await timed('stock_non_negative', 'Stock never negative', 'Inventory', () => _checkNonNegativeStock(sid)),
      await timed('sync_queue_payload', 'Sync queue payloads', 'Sync', () => _checkSyncQueuePayloads(sid)),
      await timed('sync_queue_dupes', 'Sync queue duplicates', 'Sync', () => _checkSyncQueueDuplicates(sid)),
      await timed('sales_indexes', 'Sales query uses index', 'SQL', () => _checkSalesQueryPlan(sid)),
      await timed('product_search', 'POS product search', 'Performance', () => _benchPosSearch(sid)),
      await timed('sales_page', 'Sales history page', 'Performance', () => _benchSalesPage(sid)),
      await timed('dashboard_metrics', 'Dashboard aggregates', 'Performance', () => _benchDashboard(sid)),
      await timed('debt_balance', 'Debt balances consistent', 'Debts', () => _checkDebtBalances(sid)),
      await timed('journal_balance', 'Journal lines balanced', 'Accounting', () => _checkJournalBalance(sid)),
    ]);

    return QaRunReport(
      checks: checks,
      startedAt: started,
      finishedAt: DateTime.now(),
    );
  }

  Future<QaCheckResult> _checkNonNegativeStock(String storeId) async {
    final row = await _db.customSelect(
      'SELECT COUNT(*) AS c FROM products WHERE store_id = ? AND quantity < 0',
      variables: [Variable(storeId)],
      readsFrom: {_db.products},
    ).getSingle();
    final count = row.read<int>('c');
    return QaCheckResult(
      id: 'stock',
      title: '',
      category: '',
      passed: count == 0,
      message: count == 0
          ? 'All product quantities are >= 0'
          : '$count product(s) have negative stock',
      severity: count == 0 ? QaSeverity.info : QaSeverity.critical,
    );
  }

  Future<QaCheckResult> _checkSyncQueuePayloads(String storeId) async {
    final bad = await _db.customSelect(
      '''
      SELECT COUNT(*) AS c FROM sync_queue
      WHERE store_id = ? AND (entity_id = '' OR entity = '')
      ''',
      variables: [Variable(storeId)],
      readsFrom: {_db.syncQueue},
    ).getSingle();
    final count = bad.read<int>('c');
    return QaCheckResult(
      id: 'queue',
      title: '',
      category: '',
      passed: count == 0,
      message: count == 0
          ? 'Sync queue rows have valid entity references'
          : '$count malformed sync queue row(s)',
      severity: count == 0 ? QaSeverity.info : QaSeverity.critical,
    );
  }

  Future<QaCheckResult> _checkSyncQueueDuplicates(String storeId) async {
    final row = await _db.customSelect(
      '''
      SELECT COUNT(*) AS c FROM (
        SELECT entity, entity_id, operation, COUNT(*) AS n
        FROM sync_queue
        WHERE store_id = ?
        GROUP BY entity, entity_id, operation
        HAVING n > 1
      )
      ''',
      variables: [Variable(storeId)],
      readsFrom: {_db.syncQueue},
    ).getSingle();
    final dupGroups = row.read<int>('c');
    return QaCheckResult(
      id: 'dupes',
      title: '',
      category: '',
      passed: dupGroups == 0,
      message: dupGroups == 0
          ? 'No duplicate pending sync operations'
          : '$dupGroups duplicate sync group(s) — review queue',
      severity: dupGroups == 0 ? QaSeverity.info : QaSeverity.warning,
    );
  }

  Future<QaCheckResult> _checkSalesQueryPlan(String storeId) async {
    if (storeId.isEmpty) {
      return const QaCheckResult(
        id: 'plan',
        title: '',
        category: '',
        passed: false,
        message: 'No store context',
        severity: QaSeverity.warning,
      );
    }
    final plans = await _db.customSelect(
      '''
      EXPLAIN QUERY PLAN
      SELECT * FROM sales
      WHERE store_id = ? AND created_at >= ?
      ORDER BY created_at DESC, id DESC
      LIMIT 50
      ''',
      variables: [
        Variable(storeId),
        Variable(DateTime.now().subtract(const Duration(days: 30)).toIso8601String()),
      ],
      readsFrom: {_db.sales},
    ).get();

    final text = plans.map((r) => r.data.values.join(' ')).join('\n').toLowerCase();
    final usesScan = text.contains('scan table sales') && !text.contains('using index');
    return QaCheckResult(
      id: 'plan',
      title: '',
      category: '',
      passed: !usesScan || text.contains('using index'),
      message: usesScan
          ? 'Sales list may full-scan — verify indexes on (store_id, created_at, id)'
          : 'Sales pagination query plan looks index-friendly',
      severity: usesScan ? QaSeverity.warning : QaSeverity.info,
    );
  }

  Future<QaCheckResult> _benchPosSearch(String storeId) async {
    final sw = Stopwatch()..start();
    await _db.searchProductsForPos(storeId: storeId, query: 'a', limit: 60);
    sw.stop();
    final ms = sw.elapsedMilliseconds;
    return QaCheckResult(
      id: 'pos',
      title: '',
      category: '',
      passed: ms < 300,
      message: 'POS search completed in ${ms}ms (target <300ms)',
      severity: ms < 300 ? QaSeverity.info : QaSeverity.warning,
    );
  }

  Future<QaCheckResult> _benchSalesPage(String storeId) async {
    final from = DateTime.now().subtract(const Duration(days: 30));
    final to = DateTime.now().add(const Duration(days: 1));
    final sw = Stopwatch()..start();
    await _db.fetchSalesPage(
      storeId: storeId,
      from: from,
      to: to,
      limit: 50,
    );
    sw.stop();
    final ms = sw.elapsedMilliseconds;
    return QaCheckResult(
      id: 'sales',
      title: '',
      category: '',
      passed: ms < 500,
      message: 'Sales page fetch in ${ms}ms (target <500ms)',
      severity: ms < 500 ? QaSeverity.info : QaSeverity.warning,
    );
  }

  Future<QaCheckResult> _benchDashboard(String storeId) async {
    final sw = Stopwatch()..start();
    await _db.fetchDashboardMetrics(
      tenantId: StoreContext.tenantId,
      storeId: storeId,
    );
    sw.stop();
    final ms = sw.elapsedMilliseconds;
    return QaCheckResult(
      id: 'dash',
      title: '',
      category: '',
      passed: ms < 2000,
      message: 'Dashboard metrics in ${ms}ms (target <2s)',
      severity: ms < 2000 ? QaSeverity.info : QaSeverity.warning,
    );
  }

  Future<QaCheckResult> _checkDebtBalances(String storeId) async {
    final row = await _db.customSelect(
      '''
      SELECT COUNT(*) AS c FROM debts
      WHERE store_id = ? AND remaining_cents < 0
      ''',
      variables: [Variable(storeId)],
      readsFrom: {_db.debts},
    ).getSingle();
    final bad = row.read<int>('c');
    final mismatch = await _db.customSelect(
      '''
      SELECT COUNT(*) AS c FROM debts
      WHERE store_id = ?
        AND (paid_cents + remaining_cents) != original_cents
      ''',
      variables: [Variable(storeId)],
      readsFrom: {_db.debts},
    ).getSingle();
    final mis = mismatch.read<int>('c');
    final ok = bad == 0 && mis == 0;
    return QaCheckResult(
      id: 'debt',
      title: '',
      category: '',
      passed: ok,
      message: ok
          ? 'Debt paid + remaining equals original for all rows'
          : 'Debt inconsistencies: negative=$bad mismatch=$mis',
      severity: ok ? QaSeverity.info : QaSeverity.critical,
    );
  }

  Future<QaCheckResult> _checkJournalBalance(String storeId) async {
    final row = await _db.customSelect(
      '''
      SELECT COUNT(*) AS c FROM (
        SELECT jl.journal_entry_id AS eid,
               SUM(jl.debit_cents) AS d,
               SUM(jl.credit_cents) AS c
        FROM journal_lines jl
        INNER JOIN journal_entries je ON je.id = jl.journal_entry_id
        WHERE je.store_id = ?
        GROUP BY jl.journal_entry_id
        HAVING d != c
      )
      ''',
      variables: [Variable(storeId)],
      readsFrom: {_db.journalLines, _db.journalEntries},
    ).getSingle();
    final unbalanced = row.read<int>('c');
    return QaCheckResult(
      id: 'journal',
      title: '',
      category: '',
      passed: unbalanced == 0,
      message: unbalanced == 0
          ? 'All journal entries balance (debits = credits)'
          : '$unbalanced unbalanced journal entry(ies)',
      severity: unbalanced == 0 ? QaSeverity.info : QaSeverity.critical,
    );
  }
}
