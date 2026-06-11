import 'package:inventrax_erp/l10n/app_localizations.dart';

import '../../features/accounting/domain/accounting_constants.dart';

/// Accounting sub-nav labels (rebuild when locale changes).
String localizedAcctNavLabel(AppLocalizations l10n, String path) {
  return switch (path) {
    '/accounting' => l10n.acctNavOverview,
    '/accounting/chart' => l10n.acctNavChartOfAccounts,
    '/accounting/journals' => l10n.acctJournals,
    '/accounting/ledger' => l10n.acctNavGeneralLedger,
    '/accounting/cash' => l10n.acctNavDeposits,
    '/accounting/payment-accounts' => l10n.acctNavPaymentAccounts,
    '/accounting/reports/trial-balance' => l10n.acctTrialBalance,
    '/accounting/reports/profit-loss' => l10n.acctNavProfitLoss,
    '/accounting/reports/balance-sheet' => l10n.acctBalanceSheet,
    '/accounting/reports/cash-flow' => l10n.acctNavCashFlow,
    _ => path,
  };
}

/// Section headers and list subtitles for COA / ledger.
String localizedAccountTypeLabel(AppLocalizations l10n, String type) {
  return switch (type) {
    AccountType.asset => l10n.acctTypeSectionAsset,
    AccountType.liability => l10n.acctTypeSectionLiability,
    AccountType.equity => l10n.acctTypeSectionEquity,
    AccountType.revenue => l10n.acctTypeSectionRevenue,
    AccountType.expense => l10n.acctTypeSectionExpense,
    _ => type,
  };
}

/// Dropdown item for a single account type.
String localizedAccountTypeOption(AppLocalizations l10n, String type) {
  return switch (type) {
    AccountType.asset => l10n.acctAccountTypeAsset,
    AccountType.liability => l10n.acctAccountTypeLiability,
    AccountType.equity => l10n.acctAccountTypeEquity,
    AccountType.revenue => l10n.acctAccountTypeRevenue,
    AccountType.expense => l10n.acctAccountTypeExpense,
    _ => type,
  };
}
