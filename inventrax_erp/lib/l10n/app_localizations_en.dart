// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KULMIS ERP';

  @override
  String get brandName => 'KULMIS ERP';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navPos => 'POS';

  @override
  String get navCustomSales => 'Custom Sales';

  @override
  String get navDraftInvoices => 'Draft Invoices';

  @override
  String get navSalesHistory => 'Sales History';

  @override
  String get navSales => 'Sales History';

  @override
  String get navProducts => 'Products';

  @override
  String get navCategories => 'Categories';

  @override
  String get navBrands => 'Brands';

  @override
  String get navInventory => 'Inventory';

  @override
  String get navPurchases => 'Purchases';

  @override
  String get navAddPurchase => 'Add Purchase';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navSuppliers => 'Suppliers';

  @override
  String get navDebts => 'Debts';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navAccounting => 'Accounting';

  @override
  String get navReports => 'Reports';

  @override
  String get navAiInsights => 'AI Insights';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navSync => 'Sync';

  @override
  String get navUserManagement => 'User Management';

  @override
  String get navSettings => 'Settings';

  @override
  String get navPurchaseHistory => 'Purchase history';

  @override
  String get navReceiveStock => 'Purchase';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSomali => 'Somali';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageEnglishNative => 'English';

  @override
  String get languageSomaliNative => 'Soomaali';

  @override
  String get languageArabicNative => 'العربية';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get localizationTitle => 'Localization';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get saveSettings => 'Save settings';

  @override
  String get savingSettings => 'Saving…';

  @override
  String get settingsSaved => 'Store settings updated successfully';

  @override
  String get signOut => 'Sign out';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get syncOffline => 'Offline';

  @override
  String get syncSyncing => 'Sync';

  @override
  String get syncQueue => 'Queue';

  @override
  String get syncLive => 'Live';

  @override
  String get syncConnected => 'Connected';

  @override
  String get syncReconnecting => 'Reconnecting';

  @override
  String get syncOfflineMode => 'OFFLINE MODE';

  @override
  String get syncOfflineBanner =>
      'Offline mode — checkout and edits work locally. Changes sync when you\'re back online.';

  @override
  String syncQueueBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting to sync',
      one: '1 change waiting to sync',
    );
    return '$_temp0';
  }

  @override
  String get retry => 'Retry';

  @override
  String get details => 'Details';

  @override
  String get metricSyncQueue => 'Sync queue';

  @override
  String get openPos => 'Open POS';

  @override
  String get walkIn => 'Walk-in';

  @override
  String get paymentLabel => 'Payment';

  @override
  String get splitPayment => 'Split';

  @override
  String get filterToday => 'Today';

  @override
  String get filterWeek => 'Week';

  @override
  String get filterMonth => 'Month';

  @override
  String get filterCustom => 'Custom';

  @override
  String get filterAll => 'All';

  @override
  String get salesRangeToday => 'Today';

  @override
  String get salesRangeWeek => 'Last 7 days';

  @override
  String get salesRangeMonth => 'This month';

  @override
  String get salesRangeCustom => 'Custom range';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusPartial => 'Partial';

  @override
  String get statusUnpaid => 'Unpaid';

  @override
  String get statusRefunded => 'Refunded';

  @override
  String get statusVoided => 'Voided';

  @override
  String get netRevenue => 'Net revenue';

  @override
  String get transactions => 'Transactions';

  @override
  String get unpaidCount => 'Unpaid';

  @override
  String get salesSearchHint => 'Invoice, customer, barcode…';

  @override
  String get noMatchingSales => 'No matching sales';

  @override
  String get noMatchingSalesSubtitle =>
      'Try another filter or record a sale from POS.';

  @override
  String get colInvoice => 'Invoice #';

  @override
  String get colCustomer => 'Customer';

  @override
  String get colStatus => 'Status';

  @override
  String get colTotal => 'Total';

  @override
  String get colPayment => 'Payment';

  @override
  String get colDate => 'Date';

  @override
  String get colActions => 'Actions';

  @override
  String get voidSaleTitle => 'Void sale?';

  @override
  String get voidSaleBody =>
      'This restores stock and removes the sale from totals.';

  @override
  String get reason => 'Reason';

  @override
  String get voidAction => 'Void';

  @override
  String get saleVoidedSnack => 'Sale voided — stock restored';

  @override
  String get partialRefundTitle => 'Partial refund';

  @override
  String get qty => 'Qty';

  @override
  String get refundAction => 'Refund';

  @override
  String get nothingToRefund => 'Nothing left to refund';

  @override
  String refundedAmountSnack(String amount) {
    return 'Refunded $amount — stock restored';
  }

  @override
  String get noItemsRefunded => 'No items refunded';

  @override
  String get printAction => 'Print';

  @override
  String get catalogAndPricing => 'Catalog & pricing';

  @override
  String get addProduct => 'Add product';

  @override
  String get searchProducts => 'Search name, SKU, barcode…';

  @override
  String get searchCustomersHint => 'Search name or phone…';

  @override
  String get noProducts => 'No products yet';

  @override
  String get noProductsSubtitle =>
      'Add your first product or import from spreadsheet.';

  @override
  String get noExpenses => 'No expenses yet';

  @override
  String get noExpensesSubtitle =>
      'Track rent, utilities, and other operating costs.';

  @override
  String get addExpense => 'Add expense';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noNotificationsSubtitle =>
      'Low stock, debt reminders, and system alerts appear here.';

  @override
  String get noCustomers => 'No customers yet';

  @override
  String get noCustomersSubtitle =>
      'Add customers to track debt and sales history.';

  @override
  String get addCustomer => 'Add customer';

  @override
  String get noSuppliers => 'No suppliers yet';

  @override
  String get noSuppliersSubtitle => 'Add suppliers for purchases and payables.';

  @override
  String get addSupplier => 'Add supplier';

  @override
  String get noDebts => 'No open debts';

  @override
  String get noDebtsSubtitle => 'Customer and supplier balances appear here.';

  @override
  String get noCustomerDebts => 'No customer debts';

  @override
  String get noCustomerDebtsSubtitle =>
      'Credit or partial POS sales appear here.';

  @override
  String get noSupplierPayables => 'No supplier payables';

  @override
  String get noSupplierPayablesSubtitle =>
      'Partial or credit purchases appear here.';

  @override
  String get recordPayment => 'Record payment';

  @override
  String get noInventory => 'No stock movements';

  @override
  String get noInventorySubtitle =>
      'Purchases and adjustments update inventory here.';

  @override
  String get noCategories => 'No categories yet';

  @override
  String get noCategoriesSubtitle => 'Organize products with categories.';

  @override
  String get noBrands => 'No brands yet';

  @override
  String get noBrandsSubtitle => 'Group products by brand.';

  @override
  String get noPurchases => 'No purchases yet';

  @override
  String get noPurchasesSubtitle => 'Purchase from suppliers to get started.';

  @override
  String get receiveStock => 'Purchase';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle =>
      'Sign in to manage inventory, POS, and reports for your store.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get createStore => 'Create a store';

  @override
  String get reportsExport => 'Export';

  @override
  String get reportsProfitLoss => 'Profit & loss';

  @override
  String get reportsSales => 'Sales report';

  @override
  String get posCart => 'Cart';

  @override
  String get posCheckout => 'Checkout';

  @override
  String get posHold => 'Hold';

  @override
  String get posClear => 'Clear';

  @override
  String get posSearchProducts => 'Search or scan barcode…';

  @override
  String get posEmptyCart => 'Cart is empty';

  @override
  String get posEmptyCartSubtitle =>
      'Scan a barcode or tap a product to start.';

  @override
  String get posTotal => 'Total';

  @override
  String get posDiscount => 'Discount';

  @override
  String get posTax => 'Tax';

  @override
  String get posPay => 'Pay';

  @override
  String get posCompleteSale => 'Complete sale';

  @override
  String get accountingOverview =>
      'Chart of accounts, journals, and financial reports';

  @override
  String get aiInsightsTitle => 'AI Insights';

  @override
  String get aiPoweredBy => 'Powered by OpenAI';

  @override
  String get aiConfigureKey => 'Offline rules + add OPENAI_API_KEY';

  @override
  String get aiClearChat => 'Clear chat';

  @override
  String get aiAnalyzing => 'Analyzing your business data…';

  @override
  String get aiEmptyHint =>
      'Ask anything about sales, profit, inventory, debts, or expenses.\nAnalytics are computed locally — only summaries go to OpenAI.';

  @override
  String get aiInputHint => 'Ask about sales, profit, stock, debts…';

  @override
  String get aiLiveAnalytics => 'Live analytics';

  @override
  String get aiWarnings => 'Warnings';

  @override
  String get aiRecommendations => 'Recommendations';

  @override
  String get aiOpportunities => 'Opportunities';

  @override
  String aiMonthSummary(String sales, String profit, int alerts) {
    return 'Month sales $sales • Profit $profit • $alerts alert(s)';
  }

  @override
  String get aiPromptSalesSummary =>
      'Give me this month sales and profit summary';

  @override
  String get aiPromptCompareWeeks => 'Compare last 7 days vs previous 7 days';

  @override
  String get aiPromptTopProducts => 'Which products sell the most?';

  @override
  String get aiPromptRisks => 'What are my biggest business risks?';

  @override
  String get aiPromptExpenses => 'Analyze expenses and suggest cuts';

  @override
  String get aiPromptDebts => 'Who owes the most debt?';

  @override
  String get aiPromptSlowStock => 'Which stock is slow-moving?';

  @override
  String get aiPromptForecast => 'Forecast next month based on trends';

  @override
  String get aiRateLimit => 'Please wait a few seconds between AI requests.';

  @override
  String get errorNetwork =>
      'Unable to reach the server. Your changes are saved locally and will sync when you\'re back online.';

  @override
  String get errorTimeout =>
      'That took too long. Please try again — your local data is safe.';

  @override
  String get errorPermission =>
      'You don\'t have permission for this action. Ask your store admin if you need access.';

  @override
  String get errorDuplicate =>
      'This record already exists. Check barcode, SKU, or name and try again.';

  @override
  String get errorSync =>
      'Unable to sync right now. Changes are queued and will retry automatically.';

  @override
  String get errorDatabase =>
      'Something went wrong saving locally. Please try again or contact support.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String errorLoadAnalytics(String message) {
    return 'Could not load analytics: $message';
  }

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonNoData => 'No data yet';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonNoMatches => 'No matches';

  @override
  String get commonTryDifferentSearch => 'Try a different search.';

  @override
  String get commonDone => 'Done';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonChange => 'Change';

  @override
  String get commonViewAll => 'View all';

  @override
  String commonErrorWithDetail(String detail) {
    return 'Error: $detail';
  }

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonName => 'Name';

  @override
  String get commonPhone => 'Phone';

  @override
  String get commonNotes => 'Notes';

  @override
  String get commonQuantity => 'Quantity';

  @override
  String get commonPrice => 'Price';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonSubtotal => 'Subtotal';

  @override
  String get commonScan => 'Scan';

  @override
  String get commonPrint => 'Print';

  @override
  String get commonExport => 'Export';

  @override
  String get commonImport => 'Import';

  @override
  String get commonFilter => 'Filter';

  @override
  String get commonAllStatuses => 'All statuses';

  @override
  String get commonRequired => 'Required';

  @override
  String get commonOptional => 'Optional';

  @override
  String get posDirectSale => 'Direct sale';

  @override
  String get posAddToCart => 'Add to cart';

  @override
  String posCheckoutError(String detail) {
    return 'Checkout error: $detail';
  }

  @override
  String get posSaleComplete => 'Sale complete';

  @override
  String get posPrintReceipt => 'Print receipt';

  @override
  String get posHoldSale => 'Hold sale';

  @override
  String get posSaleHeld => 'Sale held — cart cleared';

  @override
  String get posQuickAddCustomer => 'Quick add customer';

  @override
  String get posNoCustomer => 'No customer';

  @override
  String get posNewCustomer => 'New customer';

  @override
  String get posNoHeldSales => 'No held sales';

  @override
  String get posHeldSales => 'Held sales';

  @override
  String get posProductAdded => 'Product added';

  @override
  String posEditPrice(String name) {
    return 'Edit price · $name';
  }

  @override
  String get posPriceOverrideDisabled => 'Price override disabled in Settings';

  @override
  String get posOrderDiscount => 'Order discount';

  @override
  String get posAddDiscount => 'Add discount';

  @override
  String get posCheckoutShortcut => 'Checkout · F10';

  @override
  String get posQuickAddProduct => 'Quick add product';

  @override
  String posCartItems(int count) {
    return '$count items';
  }

  @override
  String get posChangeCustomer => 'Change customer';

  @override
  String get posMobileCart => 'Cart';

  @override
  String get posItemName => 'Item name';

  @override
  String posSaleCompletedSummary(String summary) {
    return 'Sale completed ($summary)';
  }

  @override
  String get posLabelOptional => 'Label (optional)';

  @override
  String get posLabelHint => 'e.g. Customer waiting';

  @override
  String get posHeldRestored => 'Held sale restored';

  @override
  String get posClearCartFirst => 'Clear cart first to restore';

  @override
  String get dashboardWelcome => 'Welcome back';

  @override
  String get dashboardTodaySales => 'Today\'s sales';

  @override
  String get dashboardMonthProfit => 'Month profit';

  @override
  String get dashboardLowStock => 'Low stock';

  @override
  String get dashboardOpenPos => 'Open POS';

  @override
  String get dashboardNoSalesYet => 'No sales yet — open POS to get started';

  @override
  String get dashboardSalesLast7Days => 'Sales · last 7 days';

  @override
  String get dashboardDailyRevenue => 'Daily revenue';

  @override
  String dashboardChartError(String detail) {
    return 'Chart error: $detail';
  }

  @override
  String get dashboardNoSalesRecorded => 'No sales recorded yet';

  @override
  String get dashboardLowStockAlerts => 'Low stock alerts';

  @override
  String dashboardQtyAlert(int qty, int alert) {
    return 'Qty $qty / alert $alert';
  }

  @override
  String dashboardTodaySalesDot(String amount) {
    return 'Today\'s sales · $amount';
  }

  @override
  String get dashboardMonthlySales => 'Monthly sales';

  @override
  String get dashboardTodayExpenses => 'Today\'s expenses';

  @override
  String get dashboardMonthlyExpenses => 'Monthly expenses';

  @override
  String get dashboardRecentSales => 'Recent sales';

  @override
  String get dashboardAllStockGood => 'All stock levels look good';

  @override
  String get dashboardYourStore => 'Your store';

  @override
  String get settingsSystemHealth => 'System health';

  @override
  String get settingsEmail => 'Email';

  @override
  String get settingsTaxNumber => 'Tax number';

  @override
  String get planFreeTrial => 'Free Trial';

  @override
  String get settingsPosFeedback => 'POS feedback';

  @override
  String get settingsSoundEffects => 'Sound effects';

  @override
  String get settingsScanCues => 'Scan and checkout cues';

  @override
  String get settingsHaptics => 'Haptic feedback';

  @override
  String get settingsPlatformCenter => 'Platform command center';

  @override
  String get settingsPlatformSubtitle =>
      'Stores, plans, revenue, SaaS analytics';

  @override
  String get settingsUserMgmt => 'User management';

  @override
  String get settingsUserMgmtSubtitle => 'Staff, roles, and permissions';

  @override
  String get settingsHealthSubtitle => 'Sync, realtime, queue & diagnostics';

  @override
  String get settingsQaValidation => 'QA validation';

  @override
  String get settingsQaSubtitle => 'Automated checks & pre-launch checklist';

  @override
  String get settingsStoreBranding => 'Store branding';

  @override
  String get settingsBrandingHint =>
      'Logo appears on receipts, invoices, and shared debt links.';

  @override
  String get settingsStoreName => 'Store name';

  @override
  String get settingsPhone => 'Phone';

  @override
  String get settingsAddress => 'Address';

  @override
  String get settingsTaxRate => 'Tax rate %';

  @override
  String get settingsReceiptHeader => 'Receipt header';

  @override
  String get settingsInvoiceFooter => 'Invoice footer text';

  @override
  String get settingsTaxInclusiveTitle => 'Tax-inclusive prices';

  @override
  String get settingsTaxInclusiveSubtitle =>
      'Prices already include tax (POS extracts tax for display)';

  @override
  String get settingsPosPermissionsTitle => 'POS permissions';

  @override
  String get settingsAllowPriceOverride => 'Allow cashier price override';

  @override
  String get settingsAllowPriceOverrideSubtitle =>
      'When off, cart prices cannot be edited at checkout';

  @override
  String get settingsAutoPrintReceipt => 'Auto-print receipt after sale';

  @override
  String get settingsAutoPrintSubtitle => 'Skips the print prompt at checkout';

  @override
  String get settingsSubscriptionPlan => 'Subscription plan';

  @override
  String get settingsAuditLog => 'Audit log';

  @override
  String get settingsNoAudit => 'No audit entries yet.';

  @override
  String get settingsExpenseSaved => 'Expense saved';

  @override
  String get settingsLogoUploadFailed =>
      'Logo upload failed. Run supabase db push for storage buckets, then try again.';

  @override
  String get signInFailed => 'Sign in failed. Please try again.';

  @override
  String get customerDirectory => 'Customer directory';

  @override
  String get customerReceivablesSubtitle => 'Credit sales and receivables';

  @override
  String get totalReceivable => 'Total receivable';

  @override
  String get supplierDirectory => 'Supplier directory';

  @override
  String get supplierPayablesSubtitle => 'Purchases and payables';

  @override
  String get totalPayable => 'Total payable';

  @override
  String get expenseSaved => 'Expense saved';

  @override
  String get addCategory => 'Add category';

  @override
  String get addBrand => 'Add brand';

  @override
  String get editCategory => 'Edit category';

  @override
  String get editBrand => 'Edit brand';

  @override
  String get categoryName => 'Category name';

  @override
  String get brandNameField => 'Brand name';

  @override
  String get inventoryScanBarcode => 'Scan barcode';

  @override
  String get inventoryShowAll => 'Show all';

  @override
  String get inventoryLowStockOnly => 'Low stock only';

  @override
  String get inventorySearchProducts => 'Search products…';

  @override
  String get inventoryAdjustStock => 'Adjust stock';

  @override
  String get debtsCustomerTab => 'Customer debts';

  @override
  String get debtsSupplierTab => 'Supplier payables';

  @override
  String get debtsFilterStatus => 'Filter status';

  @override
  String get debtsSearchHint => 'Search name, phone, invoice…';

  @override
  String get debtStatusActive => 'Active';

  @override
  String get debtStatusPartiallyPaid => 'Partially paid';

  @override
  String get debtStatusOverdue => 'Overdue';

  @override
  String get reportsToday => 'Today';

  @override
  String get reportsThisWeek => 'This week';

  @override
  String get reportsThisMonth => 'This month';

  @override
  String get reportsCustomRange => 'Custom';

  @override
  String get reportsRevenue => 'Revenue';

  @override
  String get reportsExpenses => 'Expenses';

  @override
  String get reportsNetProfit => 'Net profit';

  @override
  String get usersCreateUser => 'Create user';

  @override
  String get usersSearchHint => 'Search users…';

  @override
  String get usersNoUsers => 'No users yet';

  @override
  String get usersInviteStaff => 'Invite staff from your store owner account.';

  @override
  String get onboardingTitle => 'Set up your store';

  @override
  String get onboardingSubtitle => 'Currency, tax, and branding';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get registerStoreTitle => 'Create your store';

  @override
  String get registerStoreSubtitle => 'Start your KULMIS ERP trial';

  @override
  String get welcomeGetStarted => 'Get started';

  @override
  String get welcomeSignIn => 'Sign in';

  @override
  String get syncQueueTitle => 'Sync queue';

  @override
  String get syncQueueEmpty => 'Queue is empty';

  @override
  String get syncRetryAll => 'Retry all';

  @override
  String get productAdded => 'Product saved';

  @override
  String get productDeleted => 'Product deleted';

  @override
  String get lowStock => 'Low stock';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get inStock => 'In stock';

  @override
  String get allProducts => 'All products';

  @override
  String get activeOnly => 'Active only';

  @override
  String get archived => 'Archived';

  @override
  String l10nDevMissingBanner(String locale) {
    return 'Missing translations for $locale — see untranslated_messages.txt';
  }

  @override
  String get editProduct => 'Edit product';

  @override
  String get productNameRequired => 'Product name *';

  @override
  String get noBrand => 'No brand';

  @override
  String get brandLabel => 'Brand';

  @override
  String get secondaryNameOptional => 'Secondary name (optional)';

  @override
  String get barcodeLabel => 'Barcode';

  @override
  String get barcodeTypeLabel => 'Barcode type';

  @override
  String get barcodeTypeCode128 => 'CODE128';

  @override
  String get barcodeTypeEan13 => 'EAN-13';

  @override
  String get barcodeTypeQr => 'QR Code';

  @override
  String get productsCost => 'Cost';

  @override
  String get sellPriceRequired => 'Sell price *';

  @override
  String get minStockAlert => 'Min stock alert';

  @override
  String get printLabel => 'Print label';

  @override
  String get barcodeAlreadyInUse => 'Barcode already in use';

  @override
  String get productLimitReached => 'Product limit reached';

  @override
  String get productImageSaveFailed =>
      'Image could not be saved. Check Supabase storage (store-logos / product-images buckets).';

  @override
  String get noMatchingProducts => 'No matching products';

  @override
  String get noMatchingProductsSubtitle =>
      'Try a different search term or clear filters.';

  @override
  String get productsEmptySubtitle =>
      'Build your catalog with barcodes, prices, and stock levels.';

  @override
  String get filterByBrand => 'Filter by brand';

  @override
  String get allBrands => 'All brands';

  @override
  String get totalProducts => 'Total products';

  @override
  String get clearSearch => 'Clear search';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get searchProductsExtended => 'Search by name, barcode, or SKU…';

  @override
  String posPaymentAccountsError(String detail) {
    return 'Could not load payment accounts: $detail';
  }

  @override
  String get posCustomerRequired =>
      'Select or add a customer for partial/credit sales.';

  @override
  String get posInvalidPartialAmount =>
      'Enter a valid partial amount less than the total.';

  @override
  String get posSetupPaymentAccount =>
      'Set up a payment account in Accounting before partial sales.';

  @override
  String get posPaymentFull => 'Full';

  @override
  String get posPaymentPartial => 'Partial';

  @override
  String get posPaymentCredit => 'Credit';

  @override
  String get commonSelect => 'Select';

  @override
  String get posQuickAddShort => 'Quick add';

  @override
  String posInvoiceTotal(String amount) {
    return 'Invoice total: $amount';
  }

  @override
  String get posCustomerRequiredHint => 'Required to track remaining balance.';

  @override
  String posCustomerOptional(String name) {
    return 'Customer (optional): $name';
  }

  @override
  String get posNotesOptional => 'Notes (optional)';

  @override
  String get posAmountReceivedNow => 'Amount received now';

  @override
  String get posPartialAmountHint => 'e.g. 40.00';

  @override
  String posRemainingToDebt(String amount) {
    return 'Remaining $amount → customer debt';
  }

  @override
  String posCreditNoPaymentNow(String amount) {
    return 'No payment now. Entire $amount → Accounts Receivable.';
  }

  @override
  String get posReceivePaymentInto => 'Receive payment into';

  @override
  String get posPaymentAccount => 'Payment account';

  @override
  String get posSetupAccountsPartial =>
      'Set up payment accounts in Accounting before partial sales.';

  @override
  String get posNoAccountsCash =>
      'No payment accounts — sale will complete as cash.';

  @override
  String get posSplitAcrossAccounts => 'Split across accounts';

  @override
  String get posNeedTwoAccounts =>
      'Need at least two payment accounts for a split.';

  @override
  String get posSplitPayment => 'Split payment';

  @override
  String posTotalDue(String amount) {
    return 'Total due: $amount';
  }

  @override
  String get posCompleteOnCredit => 'Complete on credit';

  @override
  String get posCompletePartialSale => 'Complete partial sale';

  @override
  String get reportsPickDateRange => 'Pick date range';

  @override
  String get reportsRangeLabel => 'Report range';

  @override
  String get reportsSummary => 'Summary';

  @override
  String get reportsCogs => 'COGS';

  @override
  String get reportsSalesCount => 'Sales count';

  @override
  String get reportsExportPdf => 'Export PDF';

  @override
  String get reportsExportCsv => 'Export CSV';

  @override
  String get reportsShareCsvText => 'KULMIS ERP report (CSV)';

  @override
  String reportsSaleItems(int count, String id) {
    return 'Items: $count • $id';
  }

  @override
  String reportsLineItemDetail(int qty, String unit, String cost) {
    return 'x$qty @ $unit (cost $cost)';
  }

  @override
  String get debtsFilterStatusTooltip => 'Filter status';

  @override
  String get debtCustomerReceivable => 'Customer receivable';

  @override
  String get debtSupplierPayable => 'Supplier payable';

  @override
  String get deleteCategoryTitle => 'Delete category?';

  @override
  String get deleteBrandTitle => 'Delete brand?';

  @override
  String removeItemConfirm(String name) {
    return 'Remove \"$name\"?';
  }

  @override
  String get categorySaved => 'Category saved';

  @override
  String get brandSaved => 'Brand saved';

  @override
  String get expenseName => 'Expense name';

  @override
  String get expenseCategory => 'Category';

  @override
  String get expenseAmount => 'Amount';

  @override
  String get paidFromAccount => 'Paid from account';

  @override
  String get expenseCategoryMisc => 'Miscellaneous';

  @override
  String get posScanBarcodeSearch => 'Scan barcode or search products (F1)';

  @override
  String get posAddToCartTooltip => 'Add to cart';

  @override
  String get posScanCameraTooltip => 'Scan barcode (camera)';

  @override
  String posCartMobile(int count, String total) {
    return 'Cart ($count) • $total';
  }

  @override
  String get posScanOrTapProducts => 'Scan or tap products';

  @override
  String get posSellingPrice => 'Selling price';

  @override
  String posCatalogPrice(String price) {
    return 'Catalog: $price';
  }

  @override
  String get posDiscountAmount => 'Discount amount';

  @override
  String get posTaxInclSuffix => ' (incl.)';

  @override
  String get posHeldSaleLabel => 'Held sale';

  @override
  String inventoryKpiError(String detail) {
    return 'KPI error: $detail';
  }

  @override
  String get inventoryUpdated => 'Inventory updated';

  @override
  String inventoryAdjustTitle(String name) {
    return 'Adjust: $name';
  }

  @override
  String inventoryCurrentQty(int qty) {
    return 'Current quantity: $qty';
  }

  @override
  String get inventoryChangeDelta => 'Change (+/-)';

  @override
  String get inventoryReason => 'Reason';

  @override
  String get inventoryStockValueCost => 'Stock value (cost)';

  @override
  String inventoryBarcodeLine(String barcode, int qty) {
    return 'Barcode: $barcode • Qty $qty';
  }

  @override
  String inventoryQtyPill(int qty) {
    return 'Qty $qty';
  }

  @override
  String inventoryCostPill(String amount) {
    return 'Cost $amount';
  }

  @override
  String inventorySellPill(String amount) {
    return 'Sell $amount';
  }

  @override
  String inventoryProfitPill(String amount) {
    return 'Profit $amount';
  }

  @override
  String get inventoryNoMatchingSubtitle =>
      'Try scanning a barcode or changing your search/filter.';

  @override
  String get inventoryReasonDamaged => 'Damaged goods';

  @override
  String get inventoryReasonExpired => 'Expired goods';

  @override
  String get inventoryReasonTheft => 'Theft / shrinkage';

  @override
  String get inventoryReasonReturn => 'Supplier return';

  @override
  String get inventoryReasonCount => 'Stock count correction';

  @override
  String get inventoryReasonInitial => 'Initial stock entry';

  @override
  String debtBalanceDue(String amount) {
    return 'Balance due: $amount';
  }

  @override
  String get debtPaymentAmount => 'Payment amount';

  @override
  String get debtSelectPaymentAccount => 'Select a payment account';

  @override
  String get debtNoWallets => 'No wallets — seed accounting first.';

  @override
  String debtPaymentExceeds(String amount) {
    return 'Cannot exceed $amount';
  }

  @override
  String get debtPaymentRecorded => 'Payment recorded successfully';

  @override
  String debtPaymentRemainingSync(String amount) {
    return 'Remaining $amount • Saved locally, syncing in background';
  }

  @override
  String get rememberMe => 'Remember me';

  @override
  String get rememberMeSubtitle => 'Stay signed in on this device';

  @override
  String get signingIn => 'Signing in…';

  @override
  String get newToInventraX => 'New to KULMIS ERP?';

  @override
  String get registerYourStore => 'Register your store';

  @override
  String get backToWelcome => 'Back to welcome';

  @override
  String get authSupabaseSecured =>
      'Secured with Supabase Auth and tenant isolation.';

  @override
  String get authOfflineMode => 'Offline mode — configure .env for cloud sync.';

  @override
  String get welcomeSubtitle =>
      'Run your store with confidence. Register in minutes or sign in to continue.';

  @override
  String get welcomeTagline =>
      'Multi-tenant SaaS for modern retail. Secure, fast, and built for scale.';

  @override
  String get featureCloudSync => 'Cloud sync';

  @override
  String get featureOfflinePos => 'Offline POS';

  @override
  String get featureRlsIsolation => 'RLS isolation';

  @override
  String get featureBarcodeReady => 'Barcode ready';

  @override
  String get registerStepBusiness => 'Business';

  @override
  String get registerStepOwner => 'Owner';

  @override
  String get registerStepReview => 'Review';

  @override
  String get creatingStore => 'Creating your store…';

  @override
  String get tellUsBusiness => 'Tell us about your business';

  @override
  String get businessType => 'Business type';

  @override
  String get country => 'Country';

  @override
  String get taxNumberOptional => 'Tax number (optional)';

  @override
  String get ownerAccountTitle => 'Owner account — you will be Store Owner';

  @override
  String get fullName => 'Full name *';

  @override
  String get confirmPassword => 'Confirm password *';

  @override
  String get passwordHint => 'Min 8 chars, uppercase, lowercase, and a number.';

  @override
  String get reviewCreateStore => 'Review and create your store';

  @override
  String get freeTrial14Day => '14-day Free Trial';

  @override
  String get storeOwnerPermissions => 'Store Owner role with full permissions';

  @override
  String get alreadyHaveAccountSignIn => 'Already have an account? Sign in';

  @override
  String get storeNameRequired => 'Store name is required';

  @override
  String get ownerNameRequired => 'Owner name is required';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get registrationFailed => 'Registration failed. Please try again.';

  @override
  String get reviewLabelStore => 'Store';

  @override
  String get reviewLabelType => 'Type';

  @override
  String get reviewLabelLocation => 'Location';

  @override
  String get reviewLabelOwner => 'Owner';

  @override
  String get onboardingStoreSetup => 'Store setup';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingBusinessInfo => 'Business info';

  @override
  String get onboardingBusinessSubtitle => 'Tell us about your store';

  @override
  String get onboardingLocalization => 'Localization';

  @override
  String get onboardingLocalizationSubtitle => 'Currency and tax settings';

  @override
  String get onboardingBranding => 'Branding';

  @override
  String get onboardingBrandingSubtitle =>
      'Receipt header and logo (logo upload via Supabase storage later)';

  @override
  String get onboardingChoosePlan => 'Choose your plan';

  @override
  String get onboardingPlanSubtitle => '14-day free trial starts automatically';

  @override
  String get receiptHeaderText => 'Receipt header text';

  @override
  String get phoneRequired => 'Phone *';

  @override
  String get addressRequired => 'Address *';

  @override
  String get purchaseCompleteTitle => 'Complete purchase';

  @override
  String purchaseTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String get purchaseSelectPayAccount => 'Select which account to pay from';

  @override
  String get purchaseSaveOnCredit => 'Save on credit';

  @override
  String get purchaseSavePurchase => 'Save purchase';

  @override
  String purchaseCouldNotLoadAccounts(String detail) {
    return 'Could not load accounts: $detail';
  }

  @override
  String get purchaseAmountPaidNow => 'Amount paid now';

  @override
  String purchaseRemainingToDebt(String amount) {
    return 'Remaining $amount → supplier debt';
  }

  @override
  String purchaseCreditNoPayment(String amount) {
    return 'No payment now. Full $amount goes to Accounts Payable.';
  }

  @override
  String get purchasePayFromAccount => 'Pay from account';

  @override
  String get purchaseSetupAccountsFirst =>
      'Set up payment accounts in Accounting first.';

  @override
  String purchaseAddedProduct(String name) {
    return 'Added $name';
  }

  @override
  String get quickAddSupplier => 'Quick add supplier';

  @override
  String purchaseUsingSupplier(String name) {
    return 'Using existing supplier: $name';
  }

  @override
  String get purchaseSelectSupplierFirst => 'Select or add a supplier first';

  @override
  String get purchaseNotSavedCancelled => 'Purchase not saved — cancelled';

  @override
  String purchaseCouldNotSave(String detail) {
    return 'Could not save purchase: $detail';
  }

  @override
  String purchaseSavedSummary(String total, String status) {
    return 'Purchase saved • $total • $status';
  }

  @override
  String get navSupplier => 'Supplier';

  @override
  String get purchaseLookUp => 'Look up';

  @override
  String purchaseInStockLine(int qty, String cost, String sell) {
    return 'In stock: $qty • Last cost: $cost • Sell: $sell';
  }

  @override
  String get purchasePrice => 'Purchase price';

  @override
  String get newSellPriceOptional => 'New sell price (optional)';

  @override
  String get invoiceOptional => 'Invoice # (optional)';

  @override
  String get purchaseCart => 'Purchase cart';

  @override
  String get purchaseCartEmpty =>
      'Scan or look up products.\nExisting items show stock and prices.';

  @override
  String purchaseStockLine(int stock, int add) {
    return 'Stock $stock → +$add';
  }

  @override
  String purchaseMargin(String percent) {
    return 'Margin $percent%';
  }

  @override
  String get completePurchase => 'Complete purchase';

  @override
  String get saving => 'Saving…';

  @override
  String get selectOrAddSupplier => 'Select or add supplier';

  @override
  String get purchaseDetailTitle => 'Purchase detail';

  @override
  String get purchaseNotFound => 'Purchase not found';

  @override
  String purchaseInvoiceLine(String number) {
    return 'Invoice: $number';
  }

  @override
  String get lineItems => 'Line items';

  @override
  String get acctMonthToDate => 'Month to date';

  @override
  String get acctFinancialOverview => 'Financial overview';

  @override
  String acctRevenueLine(String amount) {
    return 'Revenue $amount';
  }

  @override
  String get acctAfterCogsExpenses => 'After COGS & expenses';

  @override
  String get acctCashWallets => 'Cash & wallets';

  @override
  String get acctAllPaymentAccounts => 'All payment accounts';

  @override
  String get acctReceivable => 'Receivable';

  @override
  String get acctCustomerCredit => 'Customer credit';

  @override
  String get acctPayable => 'Payable';

  @override
  String get acctSupplierBalances => 'Supplier balances';

  @override
  String get acctTrialBalance => 'Trial balance';

  @override
  String get acctBalanceSheet => 'Balance sheet';

  @override
  String get acctJournals => 'Journals';

  @override
  String acctChartError(String detail) {
    return 'Chart error: $detail';
  }

  @override
  String get posCatalogLoadError =>
      'Could not load products. Pull to refresh or check filters.';

  @override
  String get posNoProductsMatch => 'No products match your search';

  @override
  String get viewGrid => 'Grid';

  @override
  String get viewList => 'List';

  @override
  String productCountLabel(int count) {
    return '$count products';
  }

  @override
  String get tagOut => 'Out';

  @override
  String get tagLow => 'Low';

  @override
  String get barcodeProductNotFound => 'Product not found';

  @override
  String barcodeNoMatch(String code) {
    return 'No product matches barcode:\n$code';
  }

  @override
  String get manualEntry => 'Manual entry';

  @override
  String get retryScan => 'Retry scan';

  @override
  String get barcodeNoBarcode => 'Product has no barcode';

  @override
  String get barcodeLabelTitle => 'Barcode label';

  @override
  String barcodeGenerated(String code) {
    return 'Generated: $code';
  }

  @override
  String get purchasePriceRequired => 'Purchase price *';

  @override
  String get registerCreateStore => 'Create store';

  @override
  String get storeNameField => 'Store name *';

  @override
  String get invalidPassword => 'Invalid password';

  @override
  String get authNoProfileHint =>
      'Your Auth account exists but has no store profile. Run supabase/scripts/setup_super_admin.sql in Supabase SQL Editor, or use Register your store once with this email.';

  @override
  String get barcodeDirectSale => 'Direct sale';

  @override
  String get barcodeAddNewProduct => 'Add new product';

  @override
  String get acctNavSectionBooks => 'Books';

  @override
  String get acctNavSectionCash => 'Cash';

  @override
  String get acctNavSectionReports => 'Reports';

  @override
  String get acctNavOverview => 'Overview';

  @override
  String get acctNavChartOfAccounts => 'Chart of accounts';

  @override
  String get acctNavGeneralLedger => 'General ledger';

  @override
  String get acctNavDeposits => 'Deposits & withdrawals';

  @override
  String get acctNavPaymentAccounts => 'Payment accounts';

  @override
  String get acctNavProfitLoss => 'Profit & loss';

  @override
  String get acctNavCashFlow => 'Cash flow';

  @override
  String get acctNetProfit => 'Net profit';

  @override
  String get acctRevenueLabel => 'Revenue';

  @override
  String get acctExpensesLabel => 'Expenses';

  @override
  String get acctProfitLossShort => 'P&L';

  @override
  String get acctRevenueVsExpenses => 'Revenue vs expenses';

  @override
  String get acctLast6Months => 'Last 6 months';

  @override
  String get acctNoActivityYet => 'No activity yet';

  @override
  String get acctNoActivityHint => 'Complete sales and expenses to see trends';

  @override
  String get acctBooksAtGlance => 'Books at a glance';

  @override
  String get acctDoubleEntry => 'Double-entry';

  @override
  String get acctStatusActive => 'Active';

  @override
  String get acctCashPosition => 'Cash position';

  @override
  String get acctOutstandingAr => 'Outstanding AR';

  @override
  String get acctOutstandingAp => 'Outstanding AP';

  @override
  String get purchasePaid => 'Paid';

  @override
  String get purchaseOutstanding => 'Outstanding';

  @override
  String get unknownSupplier => 'Unknown supplier';

  @override
  String get purchaseSelectPaymentAccount => 'Select a payment account';

  @override
  String get onboardingFinishSetup => 'Finish setup';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingPlanFreeTrialDesc => '14 days — full POS & inventory';

  @override
  String get onboardingPlanBilledMonthly =>
      'Billed monthly when billing is enabled';

  @override
  String get onboardingTaxRateOptional => 'Tax rate % (optional)';

  @override
  String get onboardingPlanStarter => 'Starter';

  @override
  String get onboardingPlanBusiness => 'Business';

  @override
  String get onboardingPlanFreeTrialName => 'Free Trial';

  @override
  String get posAddMore => 'Add more';

  @override
  String posProfitLine(String amount) {
    return 'Profit $amount';
  }

  @override
  String get posOutOfStock => 'Out of stock';

  @override
  String get posLowStock => 'Low stock';

  @override
  String posQtyInCart(int qty) {
    return '$qty in cart';
  }

  @override
  String posSellLine(String amount) {
    return 'Sell $amount';
  }

  @override
  String posCostStockLine(String cost, int qty) {
    return 'Cost $cost • Stock $qty';
  }

  @override
  String get barcodeScanTitle => 'Scan barcode';

  @override
  String get acctNewJournalEntry => 'New journal entry';

  @override
  String get acctManualJournalEntry => 'Manual journal entry';

  @override
  String get acctManualJournalSubtitle =>
      'Debits must equal credits — used for adjustments';

  @override
  String get acctBalancedEntryRequired => 'Balanced entry required';

  @override
  String get acctEntryDetails => 'Entry details';

  @override
  String get acctEntryDate => 'Entry date';

  @override
  String get acctPostEntry => 'Post entry';

  @override
  String get acctFillRequiredFields => 'Fill all required fields';

  @override
  String get acctJournalPosted => 'Journal posted';

  @override
  String get acctSelectAccountTitle => 'Select an account';

  @override
  String get acctSelectAccountSubtitle =>
      'Choose an account to view its ledger activity';

  @override
  String get acctNoLedgerActivity => 'No activity';

  @override
  String acctYearToDateAsOf(String date) {
    return 'Year to date · As of $date';
  }

  @override
  String acctAssetsLiabilitiesEquity(String date) {
    return 'Assets, liabilities & equity · As of $date';
  }

  @override
  String get acctAssetsEquals => 'Assets = Liabilities + Equity';

  @override
  String get acctAssets => 'Assets';

  @override
  String get acctLiabilities => 'Liabilities';

  @override
  String get acctEquity => 'Equity';

  @override
  String acctIncomeStatementPeriod(String period) {
    return 'Income statement · $period';
  }

  @override
  String get acctCogs => 'Cost of goods sold';

  @override
  String get acctGrossProfit => 'Gross profit';

  @override
  String acctSimplifiedViewPeriod(String period) {
    return 'Simplified view · $period';
  }

  @override
  String get acctNetMovement => 'Net movement';

  @override
  String get acctOperatingActivities => 'Operating activities';

  @override
  String get acctNoJournalEntries => 'No journal entries yet';

  @override
  String get acctCreateManualEntry => 'Create manual entry';

  @override
  String acctPostedEntriesCount(int count) {
    return '$count posted entries (last 12 months)';
  }

  @override
  String get acctNewEntry => 'New entry';

  @override
  String get acctNoPaymentAccountsTitle => 'No payment accounts';

  @override
  String get acctPaymentAccountsAutoCreated =>
      'Accounts are created automatically when you sign in';

  @override
  String get acctAddAccount => 'Add account';

  @override
  String get acctDeleteDeactivate => 'Delete (deactivate)';

  @override
  String get acctDeleteDeactivateHint =>
      'Hides this account. Not allowed if already used.';

  @override
  String get acctRestoreAccount => 'Restore account';

  @override
  String get acctDeleteAccountTitle => 'Delete account?';

  @override
  String acctAccountUpdated(String name) {
    return 'Updated: $name';
  }

  @override
  String get acctAddAccountDialogTitle => 'Add account';

  @override
  String get acctAccountTypeAsset => 'Asset';

  @override
  String get acctAccountTypeLiability => 'Liability';

  @override
  String get acctAccountTypeEquity => 'Equity';

  @override
  String get acctAccountTypeRevenue => 'Revenue';

  @override
  String get acctAccountTypeExpense => 'Expense';

  @override
  String get acctCreateButton => 'Create';

  @override
  String get acctAccountCreated => 'Account created';

  @override
  String get acctCurrentBalance => 'Current balance';

  @override
  String get acctActivityLast6Months => 'Activity (last 6 months)';

  @override
  String get acctCannotDeleteWithBalance =>
      'Cannot delete: this account has a balance or transactions.';

  @override
  String get acctAccountNotFound => 'Account not found';

  @override
  String get acctTapAccountHint =>
      'Tap any account to view charts and activity';

  @override
  String get acctOwnerCashMovements => 'Owner cash movements';

  @override
  String get acctOwnerCashSubtitle =>
      'Record money the owner puts into or takes out of the business';

  @override
  String get acctDeposit => 'Deposit';

  @override
  String get acctWithdrawal => 'Withdrawal';

  @override
  String get acctTransactionDetails => 'Transaction details';

  @override
  String get acctNoPaymentAccountsConfigured =>
      'No payment accounts configured.';

  @override
  String get acctEnterValidAmount => 'Enter a valid amount';

  @override
  String acctExportFailed(String detail) {
    return 'Export failed: $detail';
  }

  @override
  String get acctExportPdf => 'Export PDF';

  @override
  String get acctBooksBalanced => 'Books balanced';

  @override
  String get acctOutOfBalance => 'Out of balance';

  @override
  String get acctDebitTotal => 'Total debits';

  @override
  String get acctCreditTotal => 'Total credits';

  @override
  String get acctEditPaymentAccount => 'Edit payment account';

  @override
  String get acctAddPaymentAccount => 'Add payment account';

  @override
  String get acctPaymentAccountName => 'Wallet name';

  @override
  String get acctPaymentAccountType => 'Wallet type';

  @override
  String get acctSetAsDefault => 'Set as default payment';

  @override
  String get acctDefaultPaymentHint =>
      'Used automatically at checkout when no wallet is selected';

  @override
  String get acctPaymentAccountSaved => 'Payment account saved';

  @override
  String get acctWalletTypeCash => 'Cash';

  @override
  String get acctWalletTypeBank => 'Bank';

  @override
  String get acctWalletTypeMobile => 'Mobile money';

  @override
  String get acctTapToEditWallet => 'Tap a wallet to edit';

  @override
  String acctPurchaseSavedAccountingFailed(String detail) {
    return 'Purchase saved but accounting entry failed: $detail';
  }

  @override
  String get platformCommandCenter => 'SaaS command center';

  @override
  String get platformNavOverview => 'Overview';

  @override
  String get platformNavBusiness => 'Business';

  @override
  String get platformNavOperations => 'Operations';

  @override
  String get platformNavDashboard => 'Dashboard';

  @override
  String get platformNavGlobalSearch => 'Global search';

  @override
  String get platformNavAllStores => 'All stores';

  @override
  String get platformNavBilling => 'Billing';

  @override
  String get platformNavRevenue => 'Revenue';

  @override
  String get platformNavPlans => 'Plans';

  @override
  String get platformNavStorage => 'Storage';

  @override
  String get platformNavAlerts => 'Alerts';

  @override
  String get platformNavAudit => 'Audit log';

  @override
  String get platformNavHealth => 'System health';

  @override
  String get platformStoreApp => 'Store app';

  @override
  String get platformSuperAdmin => 'Super admin';

  @override
  String get platformAllStoresTitle => 'All stores';

  @override
  String get platformAllStoresSubtitle =>
      'Search, filter, and manage every tenant on the platform';

  @override
  String get platformGlobalSearchTitle => 'Global search';

  @override
  String get platformAlertsTitle => 'Alerts';

  @override
  String get platformAlertsSubtitle =>
      'Expired subscriptions, trials ending, and storage warnings';

  @override
  String get platformStorageTitle => 'Storage';

  @override
  String get platformStorageSubtitle =>
      'Platform-wide file usage and top consuming stores';

  @override
  String get platformTotalStorage => 'Total platform storage';

  @override
  String get platformTotalStorageSubtitle =>
      'Product images, logos, and attachments';

  @override
  String get platformTopStorageConsumers => 'Top storage consumers';

  @override
  String platformImagesCount(int count) {
    return '$count images';
  }

  @override
  String get platformAuditTitle => 'Audit log';

  @override
  String get platformAuditSubtitle =>
      'Super admin actions: impersonation, billing, suspensions';

  @override
  String get platformBillingTitle => 'Billing & subscriptions';

  @override
  String get platformBillingSubtitle =>
      'Manage plan status, trials, and renewals per store';

  @override
  String get platformViewStore => 'View store';

  @override
  String get platformSetActive => 'Set active';

  @override
  String get platformExtendTrial14d => 'Extend trial 14d';

  @override
  String get platformSuspend => 'Suspend';

  @override
  String platformStoreUpdated(String name) {
    return 'Updated $name';
  }

  @override
  String get platformRevenueTitle => 'Revenue';

  @override
  String get platformRevenueSubtitle =>
      'MRR, ARR, and plan contribution across the platform';

  @override
  String get platformMrrByPlan => 'MRR by plan';

  @override
  String get platformPlanBreakdown => 'Plan breakdown';

  @override
  String platformStoresCount(int count) {
    return '$count stores';
  }

  @override
  String get platformStoreGrowth12m => 'Store growth (12 months)';

  @override
  String get platformSubscriptionsByPlan => 'Subscriptions by plan';

  @override
  String get platformTopStorageUsage => 'Top storage usage';

  @override
  String get platformRecentStores => 'Recent stores';

  @override
  String get platformTotalStores => 'Total stores';

  @override
  String get platformTrialStores => 'Trial';

  @override
  String get platformExpiredStores => 'Expired';

  @override
  String get platformMrr => 'MRR';

  @override
  String get platformPaidStores => 'Paid stores';

  @override
  String get platformStoreNotFound => 'Store not found';

  @override
  String get platformOpenStoreImpersonate => 'Open store (impersonate)';

  @override
  String get platformBusinessAnalytics => 'Business analytics';

  @override
  String get platformSubscriptionControl => 'Subscription control';

  @override
  String platformSetPlan(String name) {
    return 'Set $name';
  }

  @override
  String get platformActivate => 'Activate';

  @override
  String get platformStoreInfo => 'Store info';

  @override
  String get platformExitImpersonation => 'Exit';

  @override
  String get platformPlansTitle => 'Subscription plans';

  @override
  String get platformPlansSubtitle =>
      'Product, user, and storage limits per tier';

  @override
  String get platformNewPlan => 'New plan';

  @override
  String platformHealthUnavailable(String detail) {
    return 'Health unavailable: $detail';
  }

  @override
  String get platformPendingSync => 'Pending sync';

  @override
  String get platformFailedPushes => 'Failed pushes';

  @override
  String get platformProductsSessionStore => 'Products (session store)';

  @override
  String get platformOpenFullHealth => 'Open full system health page';

  @override
  String get platformInventoryValue => 'Inventory value';

  @override
  String acctChartAccountsSubtitle(int count) {
    return '$count accounts · Add your own accounts and deactivate unused ones';
  }

  @override
  String get acctShowInactive => 'Show inactive';

  @override
  String get acctHideInactive => 'Hide inactive';

  @override
  String get acctSystemBadge => 'System';

  @override
  String get acctDeleteAccountBody =>
      'This will deactivate the account (it will be hidden). Accounts with a balance or journal activity cannot be deleted.';

  @override
  String get acctBalancedEntryBannerSubtitle =>
      'Total debit amount will be mirrored as credit on the second account';

  @override
  String get acctTypeSectionAsset => 'Assets';

  @override
  String get acctTypeSectionLiability => 'Liabilities';

  @override
  String get acctTypeSectionEquity => 'Equity';

  @override
  String get acctTypeSectionRevenue => 'Revenue';

  @override
  String get acctTypeSectionExpense => 'Expenses';

  @override
  String get acctAccountCode => 'Account code';

  @override
  String get acctAccountNameLabel => 'Account name';

  @override
  String get acctAccountTypeLabel => 'Account type';

  @override
  String get acctOpeningBalanceOptional => 'Opening balance (optional)';

  @override
  String get acctDescription => 'Description';

  @override
  String get acctDebitAccount => 'Debit account';

  @override
  String get acctCreditAccount => 'Credit account';

  @override
  String get acctAmount => 'Amount';

  @override
  String get acctNotesOptional => 'Notes (optional)';

  @override
  String get acctDepositEntry => 'Deposit entry';

  @override
  String get acctWithdrawalEntry => 'Withdrawal entry';

  @override
  String get acctDepositBannerSubtitle => 'Debit Cash · Credit Owner Capital';

  @override
  String get acctWithdrawalBannerSubtitle =>
      'Debit Owner Drawings · Credit Cash';

  @override
  String get acctWalletAccount => 'Wallet / account';

  @override
  String get acctPostDeposit => 'Post deposit';

  @override
  String get acctPostWithdrawal => 'Post withdrawal';

  @override
  String get acctDepositPosted => 'Deposit posted';

  @override
  String get acctWithdrawalPosted => 'Withdrawal posted';

  @override
  String acctErrorDetail(String detail) {
    return 'Error: $detail';
  }

  @override
  String get platformSearchHint => 'Stores, owners, emails, plans…';

  @override
  String get platformSearchMinChars => 'Type at least 2 characters';

  @override
  String platformSearchStoresSection(int count) {
    return 'Stores ($count)';
  }

  @override
  String platformSearchPlansSection(int count) {
    return 'Plans ($count)';
  }

  @override
  String get platformSearchNoStores => 'No stores matched';

  @override
  String get platformSearchNoPlans => 'No plans matched';

  @override
  String get platformSystemHealthTitle => 'System health';

  @override
  String get platformEdit => 'Edit';

  @override
  String platformErrorDetail(String detail) {
    return 'Error: $detail';
  }

  @override
  String get platformFilterAll => 'All';

  @override
  String get platformFilterActive => 'Active';

  @override
  String get platformFilterTrial => 'Trial';

  @override
  String get platformFilterExpired => 'Expired';

  @override
  String get platformFilterSuspended => 'Suspended';

  @override
  String get platformNoStoresMatchFilter => 'No stores match this filter';

  @override
  String get platformCreatePlan => 'Create plan';

  @override
  String get platformEditPlan => 'Edit plan';

  @override
  String get platformPlanIdSlug => 'Plan ID (slug)';

  @override
  String get platformPlanNameLabel => 'Name';

  @override
  String get platformPlanMonthlyPrice => 'Monthly price (USD)';

  @override
  String get platformPlanProductLimit => 'Product limit (empty = unlimited)';

  @override
  String get platformPlanUserLimit => 'User limit';

  @override
  String get platformProductsMetric => 'Products';

  @override
  String get platformSalesMetric => 'Sales';

  @override
  String get platformPurchasesMetric => 'Purchases';

  @override
  String get platformRevenueMetric => 'Revenue';

  @override
  String get platformExpensesMetric => 'Expenses';

  @override
  String get platformCustomersMetric => 'Customers';

  @override
  String get platformSuppliersMetric => 'Suppliers';

  @override
  String get platformUsersMetric => 'Users';

  @override
  String get platformDebtsMetric => 'Debts';

  @override
  String get platformStorageSection => 'Storage';

  @override
  String get platformOwnerLabel => 'Owner';

  @override
  String get platformPhoneLabel => 'Phone';

  @override
  String get platformAddressLabel => 'Address';

  @override
  String get platformCountryLabel => 'Country';

  @override
  String get platformPlanLabel => 'Plan';

  @override
  String get platformCreatedLabel => 'Created';

  @override
  String get authBrandTagline => 'Enterprise Resource Planning';

  @override
  String get authWelcomeBack => 'Welcome';

  @override
  String get authWelcomeBackHighlight => 'back!';

  @override
  String get authWelcomeMessage =>
      'Sign in to your account and manage your business smarter, faster and easier.';

  @override
  String get authSignInTo => 'Sign in to';

  @override
  String get authEnterCredentials =>
      'Enter your credentials to access your account';

  @override
  String get authEmailAddress => 'Email address';

  @override
  String get authEmailHint => 'Enter your email';

  @override
  String get authPasswordHint => 'Enter your password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authOrContinueWith => 'or continue with';

  @override
  String authNewToBrand(String brandName) {
    return 'New to $brandName?';
  }

  @override
  String get authCreateAccount => 'Create an account';

  @override
  String get authFeatureSecureTitle => 'Secure & Reliable';

  @override
  String get authFeatureSecureDesc =>
      'Bank-level security for your business data';

  @override
  String get authFeatureFastTitle => 'Fast & Efficient';

  @override
  String get authFeatureFastDesc =>
      'Optimized performance for daily operations';

  @override
  String get authFeatureAnalyticsTitle => 'Smart Analytics';

  @override
  String get authFeatureAnalyticsDesc =>
      'Real-time insights for better decisions';

  @override
  String get authFeatureCloudTitle => 'Cloud Sync';

  @override
  String get authFeatureCloudDesc => 'Access your data anytime, anywhere';

  @override
  String get authLanguage => 'Language';

  @override
  String authSocialComingSoon(String provider) {
    return '$provider sign-in coming soon';
  }

  @override
  String get authForgotPasswordComingSoon => 'Password reset coming soon';

  @override
  String get authStoreNameHint => 'Enter your store name';

  @override
  String get authBusinessTypeHint => 'e.g. Retail, Wholesale';

  @override
  String get authCountryHint => 'e.g. Ghana';

  @override
  String get authCurrencyHint => 'e.g. GHS';

  @override
  String get authAddressHint => 'Street, city, region';

  @override
  String get authFullNameHint => 'Enter your full name';

  @override
  String get authPhoneHint => 'Enter phone number';

  @override
  String get authConfirmPasswordHint => 'Re-enter your password';

  @override
  String get invoiceTitle => 'Invoice';

  @override
  String get invoiceNumber => 'Invoice #';

  @override
  String get invoiceDate => 'Invoice date';

  @override
  String get invoiceDueDate => 'Due date';

  @override
  String get invoiceStatus => 'Status';

  @override
  String get invoicePaymentStatus => 'Payment';

  @override
  String get invoiceBillTo => 'Bill to';

  @override
  String get invoiceProduct => 'Product';

  @override
  String get invoiceSku => 'SKU / Barcode';

  @override
  String get invoiceQty => 'Qty';

  @override
  String get invoiceUnitPrice => 'Unit price';

  @override
  String get invoiceDiscount => 'Discount';

  @override
  String get invoiceTax => 'Tax';

  @override
  String get invoiceLineTotal => 'Total';

  @override
  String get invoiceSubtotal => 'Subtotal';

  @override
  String get invoicePaid => 'Paid';

  @override
  String get invoiceRemaining => 'Balance due';

  @override
  String get invoiceGrandTotal => 'Grand total';

  @override
  String get invoiceThankYou => 'Thank you for your business.';

  @override
  String get invoiceWalkIn => 'Walk-in customer';

  @override
  String get invoicePrint => 'Print';

  @override
  String get invoiceSharePdf => 'Share PDF';

  @override
  String get invoiceViewA4 => 'View A4 invoice';

  @override
  String get invoiceOpenThermal => 'Thermal receipt';

  @override
  String subscriptionTrialEndsIn(int days) {
    return 'Free trial ends in $days days';
  }

  @override
  String subscriptionExpiresIn(int days) {
    return 'Your subscription expires in $days days';
  }

  @override
  String get subscriptionUpgradeNow => 'Upgrade now';

  @override
  String get subscriptionRenewNow => 'Renew now';

  @override
  String get billingTitle => 'Billing & Subscription';

  @override
  String get billingSubtitle => 'Manage your plan and payment history';

  @override
  String get billingRenewPlan => 'Renew plan';

  @override
  String get billingUpgrade => 'Upgrade';

  @override
  String get billingBuySms => 'Buy SMS';

  @override
  String get billingPaymentFailed => 'Payment failed';

  @override
  String get billingUnavailableOffline => 'Billing unavailable offline';

  @override
  String get billingViewAllPackages => 'View all packages';

  @override
  String get billingChoosePlanBelow =>
      'Choose a plan below to renew or upgrade';

  @override
  String billingSubscribeTo(String plan) {
    return 'Subscribe to $plan';
  }

  @override
  String get billingPerMonth => '/ month';

  @override
  String get billingSmsBalanceLabel => 'SMS balance';

  @override
  String get billingCycleLabel => 'Billing';

  @override
  String billingRemainingSms(int count) {
    return 'Remaining SMS: $count';
  }

  @override
  String get billingNoTransactions => 'No transactions yet';

  @override
  String get billingPaymentHistory => 'Payment history';

  @override
  String get billingUpgradePlan => 'Upgrade plan';

  @override
  String get billingSmsMarketplace => 'SMS marketplace';

  @override
  String get billingChoosePlan => 'Choose plan';

  @override
  String get subscriptionRenewSubscription => 'Renew Subscription';

  @override
  String get subscriptionUpgradePlan => 'Upgrade Plan';

  @override
  String get subscriptionAccountSettings => 'Account settings';

  @override
  String get waafiPhoneLabel => 'Waafi mobile number';

  @override
  String get waafiPhoneHint => '061… or 25261…';

  @override
  String get waafiInstructions =>
      'Enter your Waafi mobile number. A payment request will be sent to your phone — enter your PIN to confirm.';

  @override
  String get waafiSendPayment => 'PAY KTS';

  @override
  String get waafiSendingRequest => 'Sending payment request…';

  @override
  String get waafiWaitingConfirmation => 'Waiting for Waafi confirmation…';

  @override
  String get waafiProcessingPayment => 'Processing payment…';

  @override
  String waafiPaymentSentTo(String phone) {
    return 'A payment request was sent to:\n$phone';
  }

  @override
  String get waafiEnterPin =>
      'Please enter your PIN on your phone.\nThis may take a few seconds.';

  @override
  String get waafiCancelPayment => 'Cancel payment';

  @override
  String get waafiPaymentSuccess => 'Payment successful';

  @override
  String waafiWalletBalance(int balance) {
    return 'Wallet balance: $balance SMS';
  }

  @override
  String get waafiPaymentTimedOut => 'Payment timed out';

  @override
  String get waafiPaymentCancelled => 'Payment cancelled';

  @override
  String get waafiPaymentNotCompleted => 'Payment not completed';

  @override
  String get waafiPaymentFailed => 'Payment failed';

  @override
  String get waafiNoPinConfirmation => 'No PIN confirmation received.';

  @override
  String get waafiPaymentCancelledDefault => 'Payment was cancelled.';

  @override
  String get waafiTryAgain => 'Try again';

  @override
  String get waafiSendingRequestStatus => 'Sending payment request to Waafi…';

  @override
  String get smsDashboardTitle => 'SMS Dashboard';

  @override
  String get smsBuyPackage => 'Buy SMS package';

  @override
  String get smsSendReminder => 'Send debt reminder';

  @override
  String get smsEditTemplates => 'Edit templates';

  @override
  String get smsTemplatesTitle => 'Templates';

  @override
  String get smsLogsTitle => 'SMS logs';

  @override
  String get smsRemindersTitle => 'Reminders';

  @override
  String get smsQueued => 'SMS queued — sending shortly';

  @override
  String get smsCouldNotQueue => 'Could not queue SMS';

  @override
  String get smsTemplateSaved => 'Template saved';

  @override
  String get smsBuyPackagesTitle => 'Buy packages';

  @override
  String get smsBuyWithWaafi => 'PAY KTS';

  @override
  String get smsSend => 'Send SMS';

  @override
  String smsToPhone(String phone) {
    return 'To: $phone';
  }

  @override
  String smsEditTemplate(String name) {
    return 'Edit $name';
  }

  @override
  String get smsReminders3Days => '3 days before due';

  @override
  String get smsReminders1Day => '1 day before due';

  @override
  String get smsRemindersOnDue => 'On due date';

  @override
  String get smsRemindersOverdue => 'Overdue reminders';

  @override
  String get smsDailyCap => 'Daily send cap';

  @override
  String get smsDailyCapTitle => 'Daily SMS cap';

  @override
  String get smsBuyPackageButton => 'Buy package';

  @override
  String get invoiceCompact => 'Compact';

  @override
  String get invoiceDetailed => 'Detailed';

  @override
  String invoiceStatusBadge(String status) {
    return 'Status: $status';
  }

  @override
  String invoicePaymentBadge(String status) {
    return 'Payment: $status';
  }

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get smsScheduledReminders => 'Scheduled reminders';

  @override
  String get smsScheduledRemindersSubtitle =>
      'Automated debt reminders based on due dates';

  @override
  String get smsAutomatedReminders => 'Automated reminders';

  @override
  String get smsSendOnDueDates => 'Send SMS on due dates';

  @override
  String smsPerDay(int count) {
    return '$count SMS per day';
  }

  @override
  String get smsMaxPerDay => 'Max SMS per day';

  @override
  String get smsReminderHistory => 'Reminder history';

  @override
  String get smsNoRemindersYet => 'No reminders sent yet';

  @override
  String get smsReminderTypeThreeDays => '3 days before due';

  @override
  String get smsReminderTypeOneDay => '1 day before due';

  @override
  String get smsReminderTypeDueDate => 'Due date reminder';

  @override
  String get smsReminderTypeOverdue => 'Overdue reminder';

  @override
  String get smsLogsSubtitle => 'Delivery history for your store';

  @override
  String get smsNoSmsSentYet => 'No SMS sent yet';

  @override
  String get smsTemplatesReminderTitle => 'Reminder templates';

  @override
  String get smsTemplatesVariables =>
      'Template variables: customer_name, store_name, amount, invoice_number, due_date, payment_link';

  @override
  String get smsNoTemplatesYet =>
      'No templates yet — they are created when your SMS wallet is set up.';

  @override
  String get smsTemplateHint =>
      'Use amount, store_name, and other variables in double curly braces';

  @override
  String get smsBuyPackagesSubtitle =>
      'Purchase SMS credits via Waafi Pay — EVC, Zaad, Sahal, WAAFI';

  @override
  String smsCloudBalance(int count) {
    return 'Cloud balance: $count SMS';
  }

  @override
  String get smsNoPackagesAvailable =>
      'No packages available. Contact platform admin.';

  @override
  String get healthTitle => 'System health';

  @override
  String get healthRefreshMetrics => 'Refresh metrics';

  @override
  String get healthRealtime => 'Realtime';

  @override
  String get healthSync => 'Sync';

  @override
  String get healthQueue => 'Queue';

  @override
  String healthQueueRetries(int count) {
    return '$count with retries';
  }

  @override
  String get healthNetwork => 'Network';

  @override
  String get healthOnline => 'Online';

  @override
  String get healthOffline => 'Offline';

  @override
  String get healthSyncTimeline => 'Sync timeline';

  @override
  String get healthLastPull => 'Last pull';

  @override
  String get healthLastPush => 'Last push';

  @override
  String get healthLastSuccess => 'Last successful sync';

  @override
  String get healthLastError => 'Last error';

  @override
  String get healthCloudConfigured => 'Cloud configured';

  @override
  String get healthYes => 'Yes';

  @override
  String get healthNo => 'No';

  @override
  String get healthBackgroundScheduler => 'Background scheduler';

  @override
  String get healthRunning => 'Running';

  @override
  String get healthInterval => 'Interval';

  @override
  String get healthLastCycle => 'Last cycle';

  @override
  String get healthInProgress => 'In progress';

  @override
  String get healthLocalDatabase => 'Local database';

  @override
  String get healthCachedProducts => 'Cached products';

  @override
  String get healthDbFileSize => 'DB file size';

  @override
  String get healthDbFileSizeWeb => 'N/A (web)';

  @override
  String healthDbFileSizeMb(String size) {
    return '$size MB';
  }

  @override
  String get healthQueueMaxRetries => 'Queue at max retries';

  @override
  String get healthQueueInspector => 'Queue inspector';

  @override
  String get healthOpenFullQueue => 'Open full queue';

  @override
  String get healthQueueEmpty => 'Queue is empty';

  @override
  String get healthRecoveryActions => 'Recovery actions';

  @override
  String get healthRecoverySubtitle =>
      'Use when support needs to recover sync without blocking POS.';

  @override
  String get healthRetryFailedSync => 'Retry failed sync';

  @override
  String get healthForceFullSync => 'Force full sync';

  @override
  String get healthClearHydrationCache => 'Clear hydration cache';

  @override
  String get healthRebuildIndexes => 'Rebuild local indexes';

  @override
  String get healthQaValidation => 'QA validation';

  @override
  String get healthRealtimeEventLog => 'Realtime event log';

  @override
  String get healthAllOperational => 'All systems operational';

  @override
  String get healthSyncInProgress => 'Sync in progress';

  @override
  String get healthAttentionNeeded => 'Attention needed';

  @override
  String get healthOfflineLocalMode => 'Offline — local mode';

  @override
  String get healthBadgeHealthy => 'Healthy';

  @override
  String get healthBadgeActive => 'Active';

  @override
  String get healthBadgeReview => 'Review';

  @override
  String get healthBadgeOffline => 'Offline';

  @override
  String get healthBadgeIdle => 'Idle';

  @override
  String healthQueuedRetryingRealtime(
    int queued,
    int retrying,
    String realtime,
  ) {
    return '$queued queued · $retrying retrying · Realtime $realtime';
  }

  @override
  String get healthOfflineSalesStored =>
      'Sales and inventory updates are stored on this device.';

  @override
  String get healthRetryingFailedSync => 'Retrying failed sync items';

  @override
  String get healthFullSyncCompleted => 'Full sync completed';

  @override
  String get healthHydrationCleared =>
      'Hydration cache cleared — next sync will pull fresh data';

  @override
  String get healthIndexesRebuilt => 'Local indexes rebuilt';

  @override
  String healthErrorDetail(String detail) {
    return 'Error: $detail';
  }

  @override
  String get healthRealtimeConnected => 'connected';

  @override
  String get healthRealtimeReconnecting => 'reconnecting';

  @override
  String get healthRealtimeDisconnected => 'disconnected';

  @override
  String get healthRealtimeFailed => 'failed';

  @override
  String healthSecondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String get aiRiskNegativeProfit => 'Negative profit';

  @override
  String aiRiskNegativeProfitMsg(String pct) {
    return 'This month profit is below zero. Review expenses ($pct% of sales) and margins.';
  }

  @override
  String get aiRiskThinMargin => 'Thin profit margin';

  @override
  String aiRiskThinMarginMsg(String pct) {
    return 'Profit margin is $pct%. Consider pricing or cost control.';
  }

  @override
  String get aiRiskSalesDeclining => 'Sales declining';

  @override
  String aiRiskSalesDecliningMsg(String pct) {
    return 'Last 7 days sales are $pct% vs the previous 7 days.';
  }

  @override
  String get aiRiskHighExpense => 'High expense ratio';

  @override
  String aiRiskHighExpenseMsg(String pct) {
    return 'Expenses are $pct% of revenue this month.';
  }

  @override
  String get aiRiskLowStock => 'Low stock alerts';

  @override
  String aiRiskLowStockMsg(int count) {
    return '$count product(s) at or below minimum stock.';
  }

  @override
  String get aiRiskSlowMoving => 'Slow-moving inventory';

  @override
  String aiRiskSlowMovingMsg(int count) {
    return '$count products had no sales in the last 30 days but still hold stock.';
  }

  @override
  String get aiRiskHighDebt => 'High customer debt';

  @override
  String get aiRiskHighDebtMsg =>
      'Outstanding customer debt exceeds this month\'s sales.';

  @override
  String get aiRiskOverdueDebts => 'Overdue debts';

  @override
  String aiRiskOverdueDebtsMsg(int count) {
    return '$count debt(s) are past due — follow up collections.';
  }

  @override
  String get aiRiskOutOfStock => 'Out of stock';

  @override
  String aiRiskOutOfStockMsg(int count) {
    return '$count SKU(s) are out of stock.';
  }

  @override
  String get platformSmsPackagesTitle => 'SMS Packages';

  @override
  String get platformSmsPackagesSubtitle =>
      'Marketplace catalog — stores purchase via Waafi Pay';

  @override
  String get platformNewPackage => 'New package';

  @override
  String get platformCreateSmsPackage => 'Create SMS package';

  @override
  String get platformEditSmsPackage => 'Edit package';

  @override
  String get platformSmsPackageId => 'ID slug';

  @override
  String get platformSmsPackageName => 'Name';

  @override
  String get platformSmsPackageCount => 'SMS count';

  @override
  String get platformSmsPackagePrice => 'Price (USD)';

  @override
  String get platformStoreSubscriptionsTitle => 'Store Subscriptions';

  @override
  String get platformStoreSubscriptionsSubtitle =>
      'All tenant subscriptions across KULMIS ERP';

  @override
  String get platformStoreLabel => 'Store';

  @override
  String get platformTrial => 'Trial';

  @override
  String get platformPaid => 'Paid';

  @override
  String get platformSmsWalletsTitle => 'Store SMS Wallets';

  @override
  String get platformSmsWalletsSubtitle =>
      'Cloud SMS credit balances per store';

  @override
  String platformSmsUsedPurchased(int used, int purchased) {
    return 'Used: $used • Purchased: $purchased';
  }

  @override
  String platformSmsRemaining(int count) {
    return '$count SMS';
  }

  @override
  String get platformTransactionsTitle => 'Payment Transactions';

  @override
  String get platformTransactionsSubtitle =>
      'Waafi and future gateway payments';

  @override
  String get platformPaymentGatewayTitle => 'Payment Gateway';

  @override
  String get platformPaymentGatewaySubtitle =>
      'Waafi Pay configuration — credentials via Supabase secrets';

  @override
  String get platformWaafiEnabled => 'Waafi Pay enabled';

  @override
  String get platformWaafiSandbox => 'Waafi sandbox mode';

  @override
  String get platformNoSettings => 'No settings';

  @override
  String get platformGatewaySecretsHelp =>
      'Set secrets via CLI:\nWAAFI_MERCHANT_UID, WAAFI_API_USER_ID, WAAFI_API_KEY\nWAAFI_SANDBOX=true, WAAFI_DEV_MODE=true (simulate payments)\nPAYMENT_WEBHOOK_SECRET';

  @override
  String get platformTrialSettingsTitle => 'Trial Settings';

  @override
  String get platformTrialSettingsSubtitle =>
      'Default free trial and grace period for new stores';

  @override
  String get platformDefaultTrialDays => 'Default trial days';

  @override
  String get platformGracePeriod => 'Grace period after expiry';

  @override
  String platformDaysCount(int count) {
    return '$count days';
  }

  @override
  String get platformTrialDaysTitle => 'Trial days';

  @override
  String get platformGracePeriodDaysTitle => 'Grace period days';

  @override
  String get platformDaysLabel => 'Days';

  @override
  String get platformRevenueAnalyticsTitle => 'Revenue Analytics';

  @override
  String get platformRevenueAnalyticsSubtitle =>
      'Collected revenue, MRR, trials, and SMS sales';

  @override
  String get platformTotalRevenue => 'Total revenue';

  @override
  String get platformSubscriptionRevenue => 'Subscription revenue';

  @override
  String get platformSmsRevenue => 'SMS revenue';

  @override
  String get platformMrrContracted => 'MRR (contracted)';

  @override
  String get platformActiveSubs => 'Active subs';

  @override
  String get platformTrialing => 'Trialing';

  @override
  String get platformTrialsExpiring7d => 'Trials expiring (7d)';

  @override
  String get platformFailedPayments30d => 'Failed payments (30d)';

  @override
  String get platformOtpTitle => 'OTP Infrastructure';

  @override
  String get platformOtpSubtitle =>
      'Central auth verification — multi-app branding, Hormuud delivery, rate limits';

  @override
  String get platformOtpSentToday => 'Sent today';

  @override
  String get platformOtpVerifiedToday => 'Verified today';

  @override
  String get platformOtpFailedToday => 'Failed today';

  @override
  String get platformOtpPending => 'Pending (active)';

  @override
  String get platformAppBranding => 'App branding';

  @override
  String get platformAppBrandingSubtitle =>
      'KULMIS ERP (kulmis-erp) — templates in otp_apps table. Add more apps for KULMIS PAY and other SaaS products.';

  @override
  String get platformRealtimeStatus => 'Realtime status';

  @override
  String get platformWebsocketHealth => 'Websocket health';

  @override
  String get platformFailedPayments24h => 'Failed payments (24h)';

  @override
  String get platformFailedSms24h => 'Failed SMS (24h)';

  @override
  String get platformEventLog => 'Event log';

  @override
  String get platformSearchButton => 'Search';

  @override
  String get platformStoresSearchHint => 'Store name, owner, email…';
}
