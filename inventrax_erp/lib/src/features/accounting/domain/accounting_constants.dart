/// Standard chart-of-accounts codes for InventraX double-entry posting.
abstract final class AcctCode {
  static const cash = '1000';
  static const bank = '1010';
  static const evcPlus = '1020';
  static const zaad = '1030';
  static const sahal = '1040';
  static const accountsReceivable = '1100';
  static const inventory = '1200';
  static const accountsPayable = '2000';
  static const ownerCapital = '3000';
  static const ownerDrawings = '3100';
  static const retainedEarnings = '3200';
  static const salesRevenue = '4000';
  static const cogs = '5000';
  static const rent = '5200';
  static const salary = '5210';
  static const electricity = '5220';
  static const internet = '5230';
  static const transport = '5240';
  static const generalExpense = '5999';
}

abstract final class AccountType {
  static const asset = 'asset';
  static const liability = 'liability';
  static const equity = 'equity';
  static const revenue = 'revenue';
  static const expense = 'expense';

  static bool isDebitNormal(String type) =>
      type == asset || type == expense;
}

/// Default COA rows seeded per store.
const defaultChartAccounts = <({String code, String name, String type})>[
  (code: AcctCode.cash, name: 'Cash', type: AccountType.asset),
  (code: AcctCode.bank, name: 'Bank', type: AccountType.asset),
  (code: AcctCode.evcPlus, name: 'EVC Plus', type: AccountType.asset),
  (code: AcctCode.zaad, name: 'Zaad', type: AccountType.asset),
  (code: AcctCode.sahal, name: 'Sahal', type: AccountType.asset),
  (
    code: AcctCode.accountsReceivable,
    name: 'Accounts Receivable',
    type: AccountType.asset,
  ),
  (code: AcctCode.inventory, name: 'Inventory', type: AccountType.asset),
  (
    code: AcctCode.accountsPayable,
    name: 'Accounts Payable',
    type: AccountType.liability,
  ),
  (code: AcctCode.ownerCapital, name: 'Owner Capital', type: AccountType.equity),
  (
    code: AcctCode.ownerDrawings,
    name: 'Owner Drawings',
    type: AccountType.equity,
  ),
  (
    code: AcctCode.retainedEarnings,
    name: 'Retained Earnings',
    type: AccountType.equity,
  ),
  (
    code: AcctCode.salesRevenue,
    name: 'Product Sales',
    type: AccountType.revenue,
  ),
  (
    code: AcctCode.cogs,
    name: 'Cost of Goods Sold',
    type: AccountType.expense,
  ),
  (code: AcctCode.rent, name: 'Rent', type: AccountType.expense),
  (code: AcctCode.salary, name: 'Salary', type: AccountType.expense),
  (code: AcctCode.electricity, name: 'Electricity', type: AccountType.expense),
  (code: AcctCode.internet, name: 'Internet', type: AccountType.expense),
  (code: AcctCode.transport, name: 'Transportation', type: AccountType.expense),
  (
    code: AcctCode.generalExpense,
    name: 'General Expenses',
    type: AccountType.expense,
  ),
];

const defaultPaymentAccounts = <({
  String name,
  String accountType,
  String chartCode,
  bool isDefault,
})>[
  (
    name: 'Cash',
    accountType: 'cash',
    chartCode: AcctCode.cash,
    isDefault: true,
  ),
  (
    name: 'Bank',
    accountType: 'bank',
    chartCode: AcctCode.bank,
    isDefault: false,
  ),
  (
    name: 'EVC Plus',
    accountType: 'mobile',
    chartCode: AcctCode.evcPlus,
    isDefault: false,
  ),
  (
    name: 'Zaad',
    accountType: 'mobile',
    chartCode: AcctCode.zaad,
    isDefault: false,
  ),
  (
    name: 'Sahal',
    accountType: 'mobile',
    chartCode: AcctCode.sahal,
    isDefault: false,
  ),
];

String expenseCodeForCategory(String category) {
  final c = category.toLowerCase();
  if (c.contains('rent')) return AcctCode.rent;
  if (c.contains('salary') || c.contains('wage')) return AcctCode.salary;
  if (c.contains('electric')) return AcctCode.electricity;
  if (c.contains('internet') || c.contains('wifi')) return AcctCode.internet;
  if (c.contains('transport') || c.contains('fuel')) {
    return AcctCode.transport;
  }
  return AcctCode.generalExpense;
}
