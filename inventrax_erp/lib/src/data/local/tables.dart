import 'package:drift/drift.dart';

class Products extends Table {
  TextColumn get id => text()(); // UUID (string)
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();

  TextColumn get name => text()();
  TextColumn get secondaryName => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get barcodeType =>
      text().withDefault(const Constant('code128'))();
  TextColumn get sku => text().nullable()();
  IntColumn get scanCount => integer().withDefault(const Constant(0))();
  TextColumn get categoryId => text().nullable()();
  TextColumn get brandId => text().nullable()();
  TextColumn get unitType => text().withDefault(const Constant('Piece'))();

  IntColumn get quantity => integer().withDefault(const Constant(0))();
  IntColumn get minStockAlert => integer().nullable()();

  IntColumn get purchasePriceCents => integer()(); // cost
  IntColumn get sellingPriceCents => integer()(); // default POS price

  DateTimeColumn get expiryDate => dateTime().nullable()();
  /// Local file path for offline product photo.
  TextColumn get imagePath => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  /// Fallback POS/catalog icon id (e.g. grocery, bottle).
  TextColumn get categoryIcon => text().nullable()();
  BoolColumn get hasImage => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Sales extends Table {
  TextColumn get id => text()(); // UUID (string)
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();

  TextColumn get cashierUserId => text().nullable()();
  TextColumn get customerId => text().nullable()();
  TextColumn get notes => text().nullable()();

  IntColumn get subtotalCents => integer()();
  IntColumn get discountCents => integer().withDefault(const Constant(0))();
  IntColumn get taxCents => integer().withDefault(const Constant(0))();
  IntColumn get totalCents => integer()();

  TextColumn get paymentJson =>
      text()(); // JSON string for mixed payments (future)

  IntColumn get paidCents => integer().withDefault(const Constant(0))();

  /// paid | partially_paid | unpaid
  TextColumn get paymentStatus => text().withDefault(const Constant('paid'))();

  TextColumn get status => text().withDefault(
        const Constant('completed'),
      )(); // completed | voided | partial_refund
  IntColumn get refundedTotalCents =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get voidedAt => dateTime().nullable()();
  TextColumn get voidReason => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SaleItems extends Table {
  TextColumn get id => text()(); // UUID (string)
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();

  TextColumn get saleId => text()();
  TextColumn get productId => text().nullable()(); // null for direct sale
  TextColumn get name => text()();
  TextColumn get barcode => text().nullable()();

  IntColumn get quantity => integer()();
  IntColumn get unitPriceCents => integer()();
  IntColumn get unitCostCents => integer().withDefault(const Constant(0))();
  IntColumn get lineTotalCents => integer()();
  IntColumn get refundedQuantity =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class InventoryMovements extends Table {
  TextColumn get id => text()(); // UUID (string)
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();

  TextColumn get productId => text()();
  TextColumn get reasonCode => text()(); // sale, purchase, adjustment, etc.
  IntColumn get deltaQuantity => integer()(); // negative for sale
  TextColumn get referenceType => text().nullable()(); // sale, purchase
  TextColumn get referenceId => text().nullable()(); // saleId, purchaseId
  TextColumn get notes => text().nullable()();
  TextColumn get userId => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Suppliers extends Table {
  TextColumn get id => text()(); // UUID (string)
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();

  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get paymentTerms => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Purchases extends Table {
  TextColumn get id => text()(); // UUID (string)
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();

  TextColumn get supplierId => text()();
  TextColumn get invoiceNumber => text().nullable()();
  DateTimeColumn get purchaseDate => dateTime()();
  TextColumn get notes => text().nullable()();

  IntColumn get totalCents => integer()();
  IntColumn get paidCents => integer().withDefault(const Constant(0))();

  /// paid | partially_paid | unpaid
  TextColumn get paymentStatus => text().withDefault(const Constant('paid'))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseItems extends Table {
  TextColumn get id => text()(); // UUID (string)
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();

  TextColumn get purchaseId => text()();
  TextColumn get productId => text()();
  IntColumn get quantity => integer()();
  IntColumn get purchasePriceCents => integer()(); // cost per unit
  IntColumn get lineTotalCents => integer()();

  IntColumn get newSellingPriceCents => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Debts extends Table {
  TextColumn get id => text()(); // UUID (string)
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();

  TextColumn get debtType => text()(); // supplier | customer
  TextColumn get supplierId => text().nullable()();
  TextColumn get customerId => text().nullable()();

  IntColumn get originalCents => integer()();
  IntColumn get paidCents => integer().withDefault(const Constant(0))();
  IntColumn get remainingCents => integer()();

  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get status => text()(); // active | partially_paid | paid | overdue
  TextColumn get notes => text().nullable()();

  TextColumn get saleId => text().nullable()();
  TextColumn get purchaseId => text().nullable()();
  TextColumn get invoiceNumber => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class DebtPayments extends Table {
  TextColumn get id => text()(); // UUID (string)
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();

  TextColumn get debtId => text()();
  IntColumn get amountCents => integer()();
  DateTimeColumn get paidAt => dateTime()();
  TextColumn get method => text().nullable()(); // cash, momo, bank
  TextColumn get paymentAccountId => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get userId => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Public share link for customer debt visibility (WhatsApp/SMS).
class DebtShareLinks extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  TextColumn get token => text()();
  TextColumn get customerId => text()();
  TextColumn get debtId => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get expiresAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Expenses extends Table {
  TextColumn get id => text()(); // UUID (string)
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();

  TextColumn get name => text()();
  TextColumn get category => text()();
  IntColumn get amountCents => integer()();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get paidBy => text().nullable()();
  TextColumn get receiptImagePath => text().nullable()(); // local path; cloud later
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Brands extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  BoolColumn get blacklisted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class StoreSettings extends Table {
  TextColumn get storeId => text()();
  TextColumn get tenantId => text()();
  TextColumn get storeName => text()();
  TextColumn get businessType => text().withDefault(const Constant('Retail'))();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get currencyCode => text().withDefault(const Constant('USD'))();
  TextColumn get currencySymbol => text().withDefault(const Constant(r'$'))();
  TextColumn get country => text().withDefault(const Constant('Somalia'))();
  TextColumn get localeCode => text().withDefault(const Constant('en'))();
  IntColumn get taxRateBps => integer().nullable()();
  TextColumn get taxName => text().nullable()();
  BoolColumn get taxInclusive =>
      boolean().withDefault(const Constant(false))();
  TextColumn get receiptHeader => text().nullable()();
  TextColumn get invoiceFooter => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get taxNumber => text().nullable()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get logoLocalPath => text().nullable()();
  BoolColumn get allowCashierPriceOverride =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get autoPrintReceipt =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get invoiceShowSku =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get invoiceShowDiscount =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get invoiceShowTax =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get invoiceCompactMode =>
      boolean().withDefault(const Constant(true))();
  TextColumn get planName => text().withDefault(const Constant('Free Trial'))();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {storeId};
}

/// Persisted login session (offline-first; Supabase sync later).
class AppSessions extends Table {
  TextColumn get id => text()(); // always 'active'
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get displayName => text().nullable()();
  TextColumn get storeName => text().nullable()();
  TextColumn get role =>
      text().withDefault(const Constant('store_owner'))();
  BoolColumn get rememberMe =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastLoginAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Parked POS carts (hold sale).
class HeldSales extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  TextColumn get label => text().nullable()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class AppNotifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Store staff (offline user directory; mirrors Supabase profiles).
class StoreStaff extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  TextColumn get email => text()();
  TextColumn get fullName => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get roleId => text()();
  TextColumn get passwordHash => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get customPermissionsJson => text().nullable()();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get field => text().nullable()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();

  TextColumn get entity => text()(); // e.g. products, sales
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // upsert/delete
  TextColumn get payloadJson => text()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastTriedAt => dateTime().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

/// Chart of accounts — asset, liability, equity, revenue, expense.
class ChartOfAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // asset|liability|equity|revenue|expense
  TextColumn get parentId => text().nullable()();
  IntColumn get openingBalanceCents =>
      integer().withDefault(const Constant(0))();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cash, bank, and mobile money wallets linked to a GL account.
class PaymentAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get accountType => text()(); // cash|bank|mobile
  TextColumn get chartAccountId => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  DateTimeColumn get entryDate => dateTime()();
  TextColumn get description => text()();
  TextColumn get sourceModule => text()(); // manual|sale|purchase|expense|debt|deposit|withdrawal
  TextColumn get sourceId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('posted'))();
  TextColumn get createdBy => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class JournalLines extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  TextColumn get journalEntryId => text()();
  TextColumn get accountId => text()();
  IntColumn get debitCents => integer().withDefault(const Constant(0))();
  IntColumn get creditCents => integer().withDefault(const Constant(0))();
  TextColumn get lineDescription => text().nullable()();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Platform SMS package catalog (Super Admin managed).
class SmsPackages extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get smsCount => integer()();
  IntColumn get priceCents => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Per-store SMS credit wallet.
class StoreSmsWallets extends Table {
  TextColumn get storeId => text()();
  TextColumn get tenantId => text()();
  IntColumn get balanceRemaining =>
      integer().withDefault(const Constant(0))();
  IntColumn get totalPurchased => integer().withDefault(const Constant(0))();
  IntColumn get totalSent => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {storeId};
}

/// Store-customizable SMS templates.
class SmsTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get templateType => text()();
  TextColumn get localeCode => text().withDefault(const Constant('en'))();
  TextColumn get body => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Outbound SMS queue — never send directly from UI.
class SmsQueue extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  TextColumn get recipientPhone => text()();
  TextColumn get messageBody => text()();
  TextColumn get senderName => text().nullable()();
  TextColumn get status => text()();
  TextColumn get source => text()();
  TextColumn get customerId => text().nullable()();
  TextColumn get debtId => text().nullable()();
  TextColumn get campaignId => text().nullable()();
  TextColumn get provider =>
      text().withDefault(const Constant('hormuud'))();
  TextColumn get providerMessageId => text().nullable()();
  TextColumn get lastError => text().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get maxRetries => integer().withDefault(const Constant(3))();
  DateTimeColumn get scheduledAt => dateTime()();
  DateTimeColumn get sentAt => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Immutable SMS delivery log.
class SmsLogs extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  TextColumn get queueId => text().nullable()();
  TextColumn get recipientPhone => text()();
  TextColumn get messageBody => text()();
  TextColumn get status => text()();
  TextColumn get source => text()();
  TextColumn get customerId => text().nullable()();
  TextColumn get debtId => text().nullable()();
  TextColumn get provider => text()();
  TextColumn get providerMessageId => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Scheduled debt reminder jobs.
class SmsReminders extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get storeId => text()();
  TextColumn get debtId => text()();
  TextColumn get customerId => text()();
  TextColumn get reminderType => text()();
  DateTimeColumn get scheduledFor => dateTime()();
  TextColumn get status => text()();
  TextColumn get queueId => text().nullable()();
  DateTimeColumn get sentAt => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Per-store SMS reminder and rate-limit settings.
class StoreSmsSettings extends Table {
  TextColumn get storeId => text()();
  TextColumn get tenantId => text()();
  BoolColumn get remindersEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get remindOnDueDate =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get remindOneDayBefore =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get remindThreeDaysBefore =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get remindOnOverdue =>
      boolean().withDefault(const Constant(true))();
  IntColumn get dailySendCap =>
      integer().withDefault(const Constant(200))();
  IntColumn get sentTodayCount =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get sentTodayDate => dateTime().nullable()();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {storeId};
}

