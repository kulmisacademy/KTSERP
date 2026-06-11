import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/app_database.dart';
import '../domain/accounting_constants.dart';

const _uuid = Uuid();

class _Line {
  const _Line({
    required this.accountCode,
    required this.debitCents,
    required this.creditCents,
    this.description,
  });

  final String accountCode;
  final int debitCents;
  final int creditCents;
  final String? description;
}

/// Double-entry posting engine — debits must equal credits on every entry.
class AccountingEngine {
  AccountingEngine(this._db);

  final AppDatabase _db;

  Future<void> ensureInitialized({
    required String tenantId,
    required String storeId,
  }) =>
      _db.ensureAccountingSeeded(tenantId: tenantId, storeId: storeId);

  Future<String?> defaultPaymentAccountId({
    required String tenantId,
    required String storeId,
  }) =>
      _db.getDefaultPaymentAccountId(tenantId: tenantId, storeId: storeId);

  Future<String?> paymentAccountIdForMethod({
    required String tenantId,
    required String storeId,
    required String method,
  }) =>
      _db.resolvePaymentAccountForMethod(
        tenantId: tenantId,
        storeId: storeId,
        method: method,
      );

  Future<void> postSale({
    required Sale sale,
    required List<SaleItem> items,
    String? paymentAccountId,
  }) async {
    if (sale.status == 'voided') return;
    final existing = await _db.findJournalBySource(
      storeId: sale.storeId,
      sourceModule: 'sale',
      sourceId: sale.id,
    );
    if (existing != null) return;

    final revenue = sale.totalCents - sale.refundedTotalCents;
    if (revenue <= 0) return;

    var cogs = 0;
    for (final i in items) {
      cogs += i.unitCostCents * (i.quantity - i.refundedQuantity);
    }

    final payment = _parsePayment(sale.paymentJson);
    final isCredit = payment.isCredit;
    final paidFromSale = sale.paidCents > 0 ? sale.paidCents : payment.paidCents;
    final paid = isCredit ? 0 : (paidFromSale > 0 ? paidFromSale : revenue);
    final onCredit = (revenue - paid).clamp(0, revenue);

    final lines = <_Line>[];

    if (isCredit || onCredit == revenue) {
      lines.add(
        _Line(
          accountCode: AcctCode.accountsReceivable,
          debitCents: revenue,
          creditCents: 0,
          description: 'Credit sale',
        ),
      );
    } else if (payment.splitLines.isNotEmpty) {
      for (final e in payment.splitLines.entries) {
        final code = await _resolvePaymentAccountCode(
          tenantId: sale.tenantId,
          storeId: sale.storeId,
          accountIdOrMethod: e.key,
        );
        lines.add(
          _Line(
            accountCode: code,
            debitCents: e.value,
            creditCents: 0,
            description: 'Sale split',
          ),
        );
      }
    } else {
      String assetCode = AcctCode.cash;
      final paId = paymentAccountId ?? payment.paymentAccountId;
      if (paId != null) {
        assetCode =
            await _db.chartCodeForPaymentAccount(paId) ?? AcctCode.cash;
      } else {
        final fallback = await paymentAccountIdForMethod(
          tenantId: sale.tenantId,
          storeId: sale.storeId,
          method: payment.method,
        );
        if (fallback != null) {
          assetCode =
              await _db.chartCodeForPaymentAccount(fallback) ?? AcctCode.cash;
        }
      }
      if (paid > 0) {
        lines.add(
          _Line(
            accountCode: assetCode,
            debitCents: paid,
            creditCents: 0,
            description: 'Sale receipt',
          ),
        );
      }
      if (onCredit > 0) {
        lines.add(
          _Line(
            accountCode: AcctCode.accountsReceivable,
            debitCents: onCredit,
            creditCents: 0,
            description: 'Partial / credit balance',
          ),
        );
      }
    }

    lines.add(
      _Line(
        accountCode: AcctCode.salesRevenue,
        debitCents: 0,
        creditCents: revenue,
        description: 'Sales revenue',
      ),
    );

    if (cogs > 0) {
      lines.add(
        _Line(
          accountCode: AcctCode.cogs,
          debitCents: cogs,
          creditCents: 0,
          description: 'COGS',
        ),
      );
      lines.add(
        _Line(
          accountCode: AcctCode.inventory,
          debitCents: 0,
          creditCents: cogs,
          description: 'Inventory relief',
        ),
      );
    }

    try {
      await _post(
        tenantId: sale.tenantId,
        storeId: sale.storeId,
        entryDate: sale.createdAt,
        description: 'POS sale #${sale.id.substring(0, 8)}',
        sourceModule: 'sale',
        sourceId: sale.id,
        createdBy: sale.cashierUserId,
        lines: lines,
      );
    } catch (_) {
      // Sale is already saved — accounting must not block checkout.
    }
  }

  Future<void> postPurchase({
    required Purchase purchase,
    String? paymentAccountId,
  }) async {
    final existing = await _db.findJournalBySource(
      storeId: purchase.storeId,
      sourceModule: 'purchase',
      sourceId: purchase.id,
    );
    if (existing != null) return;

    final total = purchase.totalCents;
    final paid = purchase.paidCents.clamp(0, total);
    final onCredit = total - paid;
    if (total <= 0) return;

    final lines = <_Line>[
      _Line(
        accountCode: AcctCode.inventory,
        debitCents: total,
        creditCents: 0,
        description: 'Stock received',
      ),
    ];

    if (paid > 0) {
      var code = AcctCode.cash;
      if (paymentAccountId != null) {
        code =
            await _db.chartCodeForPaymentAccount(paymentAccountId) ??
                AcctCode.cash;
      }
      lines.add(
        _Line(
          accountCode: code,
          debitCents: 0,
          creditCents: paid,
          description: 'Purchase payment',
        ),
      );
    }
    if (onCredit > 0) {
      lines.add(
        _Line(
          accountCode: AcctCode.accountsPayable,
          debitCents: 0,
          creditCents: onCredit,
          description: 'Supplier payable',
        ),
      );
    }

    await _post(
      tenantId: purchase.tenantId,
      storeId: purchase.storeId,
      entryDate: purchase.purchaseDate,
      description: 'Purchase #${purchase.id.substring(0, 8)}',
      sourceModule: 'purchase',
      sourceId: purchase.id,
      lines: lines,
    );
  }

  Future<void> postExpense({
    required Expense expense,
    String? paymentAccountId,
  }) async {
    final existing = await _db.findJournalBySource(
      storeId: expense.storeId,
      sourceModule: 'expense',
      sourceId: expense.id,
    );
    if (existing != null) return;
    if (expense.amountCents <= 0) return;

    var cashCode = AcctCode.cash;
    if (paymentAccountId != null) {
      cashCode =
          await _db.chartCodeForPaymentAccount(paymentAccountId) ??
              AcctCode.cash;
    } else if (expense.paidBy != null && expense.paidBy!.isNotEmpty) {
      cashCode =
          await _db.chartCodeForPaymentAccount(expense.paidBy!) ??
              AcctCode.cash;
    }

    await _post(
      tenantId: expense.tenantId,
      storeId: expense.storeId,
      entryDate: expense.expenseDate,
      description: expense.name,
      sourceModule: 'expense',
      sourceId: expense.id,
      lines: [
        _Line(
          accountCode: expenseCodeForCategory(expense.category),
          debitCents: expense.amountCents,
          creditCents: 0,
          description: expense.category,
        ),
        _Line(
          accountCode: cashCode,
          debitCents: 0,
          creditCents: expense.amountCents,
          description: 'Paid from wallet',
        ),
      ],
    );
  }

  Future<void> postDebtPayment({
    required Debt debt,
    required int amountCents,
    String? method,
    String? paymentAccountId,
  }) async {
    if (amountCents <= 0) return;

    var cashCode = AcctCode.cash;
    if (paymentAccountId != null) {
      cashCode =
          await _db.chartCodeForPaymentAccount(paymentAccountId) ??
              AcctCode.cash;
    } else if (method != null) {
      final paId = await paymentAccountIdForMethod(
        tenantId: debt.tenantId,
        storeId: debt.storeId,
        method: method,
      );
      if (paId != null) {
        cashCode =
            await _db.chartCodeForPaymentAccount(paId) ?? AcctCode.cash;
      }
    }

    final lines = <_Line>[];
    if (debt.debtType == 'supplier') {
      lines.addAll([
        _Line(
          accountCode: AcctCode.accountsPayable,
          debitCents: amountCents,
          creditCents: 0,
          description: 'Supplier payment',
        ),
        _Line(
          accountCode: cashCode,
          debitCents: 0,
          creditCents: amountCents,
          description: 'Cash out',
        ),
      ]);
    } else {
      lines.addAll([
        _Line(
          accountCode: cashCode,
          debitCents: amountCents,
          creditCents: 0,
          description: 'Customer payment',
        ),
        _Line(
          accountCode: AcctCode.accountsReceivable,
          debitCents: 0,
          creditCents: amountCents,
          description: 'AR relief',
        ),
      ]);
    }

    await _post(
      tenantId: debt.tenantId,
      storeId: debt.storeId,
      entryDate: DateTime.now(),
      description: 'Debt payment',
      sourceModule: 'debt',
      sourceId: debt.id,
      lines: lines,
    );
  }

  Future<void> postDeposit({
    required String tenantId,
    required String storeId,
    required int amountCents,
    required String paymentAccountId,
    String? notes,
    String? userId,
  }) async {
    if (amountCents <= 0) return;
    final cashCode =
        await _db.chartCodeForPaymentAccount(paymentAccountId) ??
            AcctCode.cash;
    await _post(
      tenantId: tenantId,
      storeId: storeId,
      entryDate: DateTime.now(),
      description: notes ?? 'Owner deposit',
      sourceModule: 'deposit',
      sourceId: null,
      createdBy: userId,
      lines: [
        _Line(
          accountCode: cashCode,
          debitCents: amountCents,
          creditCents: 0,
        ),
        _Line(
          accountCode: AcctCode.ownerCapital,
          debitCents: 0,
          creditCents: amountCents,
        ),
      ],
    );
  }

  Future<void> postWithdrawal({
    required String tenantId,
    required String storeId,
    required int amountCents,
    required String paymentAccountId,
    String? notes,
    String? userId,
  }) async {
    if (amountCents <= 0) return;
    final cashCode =
        await _db.chartCodeForPaymentAccount(paymentAccountId) ??
            AcctCode.cash;
    await _post(
      tenantId: tenantId,
      storeId: storeId,
      entryDate: DateTime.now(),
      description: notes ?? 'Owner withdrawal',
      sourceModule: 'withdrawal',
      sourceId: null,
      createdBy: userId,
      lines: [
        _Line(
          accountCode: AcctCode.ownerDrawings,
          debitCents: amountCents,
          creditCents: 0,
        ),
        _Line(
          accountCode: cashCode,
          debitCents: 0,
          creditCents: amountCents,
        ),
      ],
    );
  }

  /// Reverses the journal posted for a completed sale (after void).
  Future<void> postVoidSale({
    required Sale sale,
  }) async {
    if (sale.status != 'voided') return;
    final existing = await _db.findJournalBySource(
      storeId: sale.storeId,
      sourceModule: 'sale_void',
      sourceId: sale.id,
    );
    if (existing != null) return;

    final original = await _db.findJournalBySource(
      storeId: sale.storeId,
      sourceModule: 'sale',
      sourceId: sale.id,
    );
    if (original == null) return;

    final journalLines = await _db.listLinesForJournal(original.id);
    final reversal = <_Line>[];
    for (final l in journalLines) {
      final acct = await _db.getAccountById(l.accountId);
      if (acct == null) continue;
      reversal.add(
        _Line(
          accountCode: acct.code,
          debitCents: l.creditCents,
          creditCents: l.debitCents,
          description: 'Void reversal',
        ),
      );
    }
    if (reversal.isEmpty) return;

    await _post(
      tenantId: sale.tenantId,
      storeId: sale.storeId,
      entryDate: sale.voidedAt ?? DateTime.now(),
      description: 'Void sale #${sale.id.substring(0, 8)}',
      sourceModule: 'sale_void',
      sourceId: sale.id,
      lines: reversal,
    );
  }

  Future<String> _resolvePaymentAccountCode({
    required String tenantId,
    required String storeId,
    required String accountIdOrMethod,
  }) async {
    final byId =
        await _db.chartCodeForPaymentAccount(accountIdOrMethod);
    if (byId != null) return byId;
    final paId = await paymentAccountIdForMethod(
      tenantId: tenantId,
      storeId: storeId,
      method: accountIdOrMethod,
    );
    if (paId != null) {
      return await _db.chartCodeForPaymentAccount(paId) ?? AcctCode.cash;
    }
    return AcctCode.cash;
  }

  Future<void> postManualJournal({
    required String tenantId,
    required String storeId,
    required DateTime entryDate,
    required String description,
    required List<({String accountId, int debitCents, int creditCents})> lines,
    String? notes,
    String? userId,
  }) async {
    final driftLines = <_Line>[];
    for (final l in lines) {
      final acct = await _db.getAccountById(l.accountId);
      if (acct == null) continue;
      driftLines.add(
        _Line(
          accountCode: acct.code,
          debitCents: l.debitCents,
          creditCents: l.creditCents,
        ),
      );
    }
    await _post(
      tenantId: tenantId,
      storeId: storeId,
      entryDate: entryDate,
      description: description,
      sourceModule: 'manual',
      sourceId: null,
      createdBy: userId,
      notes: notes,
      lines: driftLines,
    );
  }

  Future<void> _post({
    required String tenantId,
    required String storeId,
    required DateTime entryDate,
    required String description,
    required String sourceModule,
    required String? sourceId,
    required List<_Line> lines,
    String? createdBy,
    String? notes,
  }) async {
    await ensureInitialized(tenantId: tenantId, storeId: storeId);

    var debitTotal = 0;
    var creditTotal = 0;
    for (final l in lines) {
      debitTotal += l.debitCents;
      creditTotal += l.creditCents;
    }
    if (debitTotal != creditTotal || debitTotal == 0) {
      throw StateError(
        'Unbalanced journal: debits $debitTotal != credits $creditTotal',
      );
    }

    final entryId = _uuid.v4();
    await _db.transaction(() async {
      await _db.into(_db.journalEntries).insert(
            JournalEntriesCompanion.insert(
              id: entryId,
              tenantId: tenantId,
              storeId: storeId,
              entryDate: entryDate,
              description: description,
              sourceModule: sourceModule,
              sourceId: Value(sourceId),
              createdBy: Value(createdBy),
              notes: Value(notes),
            ),
          );
      await _db.enqueueSync(
        tenantId: tenantId,
        storeId: storeId,
        entity: 'journal_entries',
        entityId: entryId,
        operation: 'upsert',
        payload: const {},
      );

      for (final l in lines) {
        final account = await _db.getAccountByCode(
          tenantId: tenantId,
          storeId: storeId,
          code: l.accountCode,
        );
        if (account == null) {
          throw StateError('Missing account ${l.accountCode}');
        }
        final lineId = _uuid.v4();
        await _db.into(_db.journalLines).insert(
              JournalLinesCompanion.insert(
                id: lineId,
                tenantId: tenantId,
                storeId: storeId,
                journalEntryId: entryId,
                accountId: account.id,
                debitCents: Value(l.debitCents),
                creditCents: Value(l.creditCents),
                lineDescription: Value(l.description),
              ),
            );
        await _db.enqueueSync(
          tenantId: tenantId,
          storeId: storeId,
          entity: 'journal_lines',
          entityId: lineId,
          operation: 'upsert',
          payload: const {},
        );
      }
    });
  }
}

class _ParsedPayment {
  const _ParsedPayment({
    required this.method,
    required this.paidCents,
    required this.isCredit,
    required this.splitLines,
    this.paymentAccountId,
  });

  final String method;
  final int paidCents;
  final bool isCredit;
  final Map<String, int> splitLines;
  final String? paymentAccountId;
}

_ParsedPayment _parsePayment(String json) {
  try {
    final map = jsonDecode(json) as Map<String, dynamic>;
    final method = (map['method'] as String?) ?? 'cash';
    final paymentAccountId = map['paymentAccountId'] as String?;
    if (method == 'split' && map['lines'] is Map) {
      final raw = map['lines'] as Map;
      final lines = <String, int>{};
      for (final e in raw.entries) {
        lines[e.key.toString()] = (e.value as num).toInt();
      }
      return _ParsedPayment(
        method: method,
        paidCents: (map['totalCents'] as num?)?.toInt() ?? 0,
        isCredit: false,
        splitLines: lines,
        paymentAccountId: paymentAccountId,
      );
    }
    return _ParsedPayment(
      method: method,
      paidCents: (map['paidCents'] as num?)?.toInt() ?? 0,
      isCredit: method == 'credit',
      splitLines: const {},
      paymentAccountId: paymentAccountId,
    );
  } catch (_) {
    return const _ParsedPayment(
      method: 'cash',
      paidCents: 0,
      isCredit: false,
      splitLines: {},
    );
  }
}
