import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_so.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('so'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'InventraX ERP'**
  String get appTitle;

  /// No description provided for @brandName.
  ///
  /// In en, this message translates to:
  /// **'InventraX'**
  String get brandName;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navPos.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get navPos;

  /// No description provided for @navCustomSales.
  ///
  /// In en, this message translates to:
  /// **'Custom Sales'**
  String get navCustomSales;

  /// No description provided for @navDraftInvoices.
  ///
  /// In en, this message translates to:
  /// **'Draft Invoices'**
  String get navDraftInvoices;

  /// No description provided for @navSalesHistory.
  ///
  /// In en, this message translates to:
  /// **'Sales History'**
  String get navSalesHistory;

  /// No description provided for @navSales.
  ///
  /// In en, this message translates to:
  /// **'Sales History'**
  String get navSales;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navBrands.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get navBrands;

  /// No description provided for @navInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get navInventory;

  /// No description provided for @navPurchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get navPurchases;

  /// No description provided for @navAddPurchase.
  ///
  /// In en, this message translates to:
  /// **'Add Purchase'**
  String get navAddPurchase;

  /// No description provided for @navCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get navCustomers;

  /// No description provided for @navSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get navSuppliers;

  /// No description provided for @navDebts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get navDebts;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get navExpenses;

  /// No description provided for @navAccounting.
  ///
  /// In en, this message translates to:
  /// **'Accounting'**
  String get navAccounting;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navAiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get navAiInsights;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get navSync;

  /// No description provided for @navUserManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get navUserManagement;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navPurchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'Purchase history'**
  String get navPurchaseHistory;

  /// No description provided for @navReceiveStock.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get navReceiveStock;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSomali.
  ///
  /// In en, this message translates to:
  /// **'Somali'**
  String get languageSomali;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageEnglishNative.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishNative;

  /// No description provided for @languageSomaliNative.
  ///
  /// In en, this message translates to:
  /// **'Soomaali'**
  String get languageSomaliNative;

  /// No description provided for @languageArabicNative.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabicNative;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @localizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Localization'**
  String get localizationTitle;

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get saveSettings;

  /// No description provided for @savingSettings.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get savingSettings;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Store settings updated successfully'**
  String get settingsSaved;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get syncOffline;

  /// No description provided for @syncSyncing.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncSyncing;

  /// No description provided for @syncQueue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get syncQueue;

  /// No description provided for @syncLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get syncLive;

  /// No description provided for @syncConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get syncConnected;

  /// No description provided for @syncReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting'**
  String get syncReconnecting;

  /// No description provided for @syncOfflineMode.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE MODE'**
  String get syncOfflineMode;

  /// No description provided for @syncOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline mode — checkout and edits work locally. Changes sync when you\'re back online.'**
  String get syncOfflineBanner;

  /// No description provided for @syncQueueBanner.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change waiting to sync} other{{count} changes waiting to sync}}'**
  String syncQueueBanner(int count);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @metricSyncQueue.
  ///
  /// In en, this message translates to:
  /// **'Sync queue'**
  String get metricSyncQueue;

  /// No description provided for @openPos.
  ///
  /// In en, this message translates to:
  /// **'Open POS'**
  String get openPos;

  /// No description provided for @walkIn.
  ///
  /// In en, this message translates to:
  /// **'Walk-in'**
  String get walkIn;

  /// No description provided for @paymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentLabel;

  /// No description provided for @splitPayment.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get splitPayment;

  /// No description provided for @filterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterToday;

  /// No description provided for @filterWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get filterWeek;

  /// No description provided for @filterMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get filterMonth;

  /// No description provided for @filterCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get filterCustom;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @salesRangeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get salesRangeToday;

  /// No description provided for @salesRangeWeek.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get salesRangeWeek;

  /// No description provided for @salesRangeMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get salesRangeMonth;

  /// No description provided for @salesRangeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get salesRangeCustom;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get statusPartial;

  /// No description provided for @statusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get statusUnpaid;

  /// No description provided for @statusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get statusRefunded;

  /// No description provided for @statusVoided.
  ///
  /// In en, this message translates to:
  /// **'Voided'**
  String get statusVoided;

  /// No description provided for @netRevenue.
  ///
  /// In en, this message translates to:
  /// **'Net revenue'**
  String get netRevenue;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @unpaidCount.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaidCount;

  /// No description provided for @salesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Invoice, customer, barcode…'**
  String get salesSearchHint;

  /// No description provided for @noMatchingSales.
  ///
  /// In en, this message translates to:
  /// **'No matching sales'**
  String get noMatchingSales;

  /// No description provided for @noMatchingSalesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try another filter or record a sale from POS.'**
  String get noMatchingSalesSubtitle;

  /// No description provided for @colInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice #'**
  String get colInvoice;

  /// No description provided for @colCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get colCustomer;

  /// No description provided for @colStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get colStatus;

  /// No description provided for @colTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get colTotal;

  /// No description provided for @colPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get colPayment;

  /// No description provided for @colDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get colDate;

  /// No description provided for @colActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get colActions;

  /// No description provided for @voidSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Void sale?'**
  String get voidSaleTitle;

  /// No description provided for @voidSaleBody.
  ///
  /// In en, this message translates to:
  /// **'This restores stock and removes the sale from totals.'**
  String get voidSaleBody;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @voidAction.
  ///
  /// In en, this message translates to:
  /// **'Void'**
  String get voidAction;

  /// No description provided for @saleVoidedSnack.
  ///
  /// In en, this message translates to:
  /// **'Sale voided — stock restored'**
  String get saleVoidedSnack;

  /// No description provided for @partialRefundTitle.
  ///
  /// In en, this message translates to:
  /// **'Partial refund'**
  String get partialRefundTitle;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @refundAction.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refundAction;

  /// No description provided for @nothingToRefund.
  ///
  /// In en, this message translates to:
  /// **'Nothing left to refund'**
  String get nothingToRefund;

  /// No description provided for @refundedAmountSnack.
  ///
  /// In en, this message translates to:
  /// **'Refunded {amount} — stock restored'**
  String refundedAmountSnack(String amount);

  /// No description provided for @noItemsRefunded.
  ///
  /// In en, this message translates to:
  /// **'No items refunded'**
  String get noItemsRefunded;

  /// No description provided for @printAction.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get printAction;

  /// No description provided for @catalogAndPricing.
  ///
  /// In en, this message translates to:
  /// **'Catalog & pricing'**
  String get catalogAndPricing;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search name, SKU, barcode…'**
  String get searchProducts;

  /// No description provided for @searchCustomersHint.
  ///
  /// In en, this message translates to:
  /// **'Search name or phone…'**
  String get searchCustomersHint;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProducts;

  /// No description provided for @noProductsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first product or import from spreadsheet.'**
  String get noProductsSubtitle;

  /// No description provided for @noExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpenses;

  /// No description provided for @noExpensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track rent, utilities, and other operating costs.'**
  String get noExpensesSubtitle;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Low stock, debt reminders, and system alerts appear here.'**
  String get noNotificationsSubtitle;

  /// No description provided for @noCustomers.
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get noCustomers;

  /// No description provided for @noCustomersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add customers to track debt and sales history.'**
  String get noCustomersSubtitle;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add customer'**
  String get addCustomer;

  /// No description provided for @noSuppliers.
  ///
  /// In en, this message translates to:
  /// **'No suppliers yet'**
  String get noSuppliers;

  /// No description provided for @noSuppliersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add suppliers for purchases and payables.'**
  String get noSuppliersSubtitle;

  /// No description provided for @addSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add supplier'**
  String get addSupplier;

  /// No description provided for @noDebts.
  ///
  /// In en, this message translates to:
  /// **'No open debts'**
  String get noDebts;

  /// No description provided for @noDebtsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customer and supplier balances appear here.'**
  String get noDebtsSubtitle;

  /// No description provided for @noCustomerDebts.
  ///
  /// In en, this message translates to:
  /// **'No customer debts'**
  String get noCustomerDebts;

  /// No description provided for @noCustomerDebtsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Credit or partial POS sales appear here.'**
  String get noCustomerDebtsSubtitle;

  /// No description provided for @noSupplierPayables.
  ///
  /// In en, this message translates to:
  /// **'No supplier payables'**
  String get noSupplierPayables;

  /// No description provided for @noSupplierPayablesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Partial or credit purchases appear here.'**
  String get noSupplierPayablesSubtitle;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get recordPayment;

  /// No description provided for @noInventory.
  ///
  /// In en, this message translates to:
  /// **'No stock movements'**
  String get noInventory;

  /// No description provided for @noInventorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Purchases and adjustments update inventory here.'**
  String get noInventorySubtitle;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategories;

  /// No description provided for @noCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize products with categories.'**
  String get noCategoriesSubtitle;

  /// No description provided for @noBrands.
  ///
  /// In en, this message translates to:
  /// **'No brands yet'**
  String get noBrands;

  /// No description provided for @noBrandsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Group products by brand.'**
  String get noBrandsSubtitle;

  /// No description provided for @noPurchases.
  ///
  /// In en, this message translates to:
  /// **'No purchases yet'**
  String get noPurchases;

  /// No description provided for @noPurchasesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase from suppliers to get started.'**
  String get noPurchasesSubtitle;

  /// No description provided for @receiveStock.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get receiveStock;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage inventory, POS, and reports for your store.'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createStore.
  ///
  /// In en, this message translates to:
  /// **'Create a store'**
  String get createStore;

  /// No description provided for @reportsExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get reportsExport;

  /// No description provided for @reportsProfitLoss.
  ///
  /// In en, this message translates to:
  /// **'Profit & loss'**
  String get reportsProfitLoss;

  /// No description provided for @reportsSales.
  ///
  /// In en, this message translates to:
  /// **'Sales report'**
  String get reportsSales;

  /// No description provided for @posCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get posCart;

  /// No description provided for @posCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get posCheckout;

  /// No description provided for @posHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get posHold;

  /// No description provided for @posClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get posClear;

  /// No description provided for @posSearchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search or scan barcode…'**
  String get posSearchProducts;

  /// No description provided for @posEmptyCart.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get posEmptyCart;

  /// No description provided for @posEmptyCartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode or tap a product to start.'**
  String get posEmptyCartSubtitle;

  /// No description provided for @posTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get posTotal;

  /// No description provided for @posDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get posDiscount;

  /// No description provided for @posTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get posTax;

  /// No description provided for @posPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get posPay;

  /// No description provided for @posCompleteSale.
  ///
  /// In en, this message translates to:
  /// **'Complete sale'**
  String get posCompleteSale;

  /// No description provided for @accountingOverview.
  ///
  /// In en, this message translates to:
  /// **'Chart of accounts, journals, and financial reports'**
  String get accountingOverview;

  /// No description provided for @aiInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get aiInsightsTitle;

  /// No description provided for @aiPoweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by OpenAI'**
  String get aiPoweredBy;

  /// No description provided for @aiConfigureKey.
  ///
  /// In en, this message translates to:
  /// **'Offline rules + add OPENAI_API_KEY'**
  String get aiConfigureKey;

  /// No description provided for @aiClearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get aiClearChat;

  /// No description provided for @aiAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your business data…'**
  String get aiAnalyzing;

  /// No description provided for @aiEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about sales, profit, inventory, debts, or expenses.\nAnalytics are computed locally — only summaries go to OpenAI.'**
  String get aiEmptyHint;

  /// No description provided for @aiInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about sales, profit, stock, debts…'**
  String get aiInputHint;

  /// No description provided for @aiLiveAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Live analytics'**
  String get aiLiveAnalytics;

  /// No description provided for @aiWarnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get aiWarnings;

  /// No description provided for @aiRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get aiRecommendations;

  /// No description provided for @aiOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Opportunities'**
  String get aiOpportunities;

  /// No description provided for @aiMonthSummary.
  ///
  /// In en, this message translates to:
  /// **'Month sales {sales} • Profit {profit} • {alerts} alert(s)'**
  String aiMonthSummary(String sales, String profit, int alerts);

  /// No description provided for @aiPromptSalesSummary.
  ///
  /// In en, this message translates to:
  /// **'Give me this month sales and profit summary'**
  String get aiPromptSalesSummary;

  /// No description provided for @aiPromptCompareWeeks.
  ///
  /// In en, this message translates to:
  /// **'Compare last 7 days vs previous 7 days'**
  String get aiPromptCompareWeeks;

  /// No description provided for @aiPromptTopProducts.
  ///
  /// In en, this message translates to:
  /// **'Which products sell the most?'**
  String get aiPromptTopProducts;

  /// No description provided for @aiPromptRisks.
  ///
  /// In en, this message translates to:
  /// **'What are my biggest business risks?'**
  String get aiPromptRisks;

  /// No description provided for @aiPromptExpenses.
  ///
  /// In en, this message translates to:
  /// **'Analyze expenses and suggest cuts'**
  String get aiPromptExpenses;

  /// No description provided for @aiPromptDebts.
  ///
  /// In en, this message translates to:
  /// **'Who owes the most debt?'**
  String get aiPromptDebts;

  /// No description provided for @aiPromptSlowStock.
  ///
  /// In en, this message translates to:
  /// **'Which stock is slow-moving?'**
  String get aiPromptSlowStock;

  /// No description provided for @aiPromptForecast.
  ///
  /// In en, this message translates to:
  /// **'Forecast next month based on trends'**
  String get aiPromptForecast;

  /// No description provided for @aiRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Please wait a few seconds between AI requests.'**
  String get aiRateLimit;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach the server. Your changes are saved locally and will sync when you\'re back online.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'That took too long. Please try again — your local data is safe.'**
  String get errorTimeout;

  /// No description provided for @errorPermission.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission for this action. Ask your store admin if you need access.'**
  String get errorPermission;

  /// No description provided for @errorDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This record already exists. Check barcode, SKU, or name and try again.'**
  String get errorDuplicate;

  /// No description provided for @errorSync.
  ///
  /// In en, this message translates to:
  /// **'Unable to sync right now. Changes are queued and will retry automatically.'**
  String get errorSync;

  /// No description provided for @errorDatabase.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong saving locally. Please try again or contact support.'**
  String get errorDatabase;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorLoadAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Could not load analytics: {message}'**
  String errorLoadAnalytics(String message);

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get commonNoData;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get commonNoMatches;

  /// No description provided for @commonTryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search.'**
  String get commonTryDifferentSearch;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get commonChange;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get commonViewAll;

  /// No description provided for @commonErrorWithDetail.
  ///
  /// In en, this message translates to:
  /// **'Error: {detail}'**
  String commonErrorWithDetail(String detail);

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get commonName;

  /// No description provided for @commonPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get commonPhone;

  /// No description provided for @commonNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get commonNotes;

  /// No description provided for @commonQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get commonQuantity;

  /// No description provided for @commonPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get commonPrice;

  /// No description provided for @commonTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get commonTotal;

  /// No description provided for @commonSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get commonSubtotal;

  /// No description provided for @commonScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get commonScan;

  /// No description provided for @commonPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get commonPrint;

  /// No description provided for @commonExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get commonExport;

  /// No description provided for @commonImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get commonImport;

  /// No description provided for @commonFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get commonFilter;

  /// No description provided for @commonAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get commonAllStatuses;

  /// No description provided for @commonRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// No description provided for @commonOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get commonOptional;

  /// No description provided for @posDirectSale.
  ///
  /// In en, this message translates to:
  /// **'Direct sale'**
  String get posDirectSale;

  /// No description provided for @posAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get posAddToCart;

  /// No description provided for @posCheckoutError.
  ///
  /// In en, this message translates to:
  /// **'Checkout error: {detail}'**
  String posCheckoutError(String detail);

  /// No description provided for @posSaleComplete.
  ///
  /// In en, this message translates to:
  /// **'Sale complete'**
  String get posSaleComplete;

  /// No description provided for @posPrintReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print receipt'**
  String get posPrintReceipt;

  /// No description provided for @posHoldSale.
  ///
  /// In en, this message translates to:
  /// **'Hold sale'**
  String get posHoldSale;

  /// No description provided for @posSaleHeld.
  ///
  /// In en, this message translates to:
  /// **'Sale held — cart cleared'**
  String get posSaleHeld;

  /// No description provided for @posQuickAddCustomer.
  ///
  /// In en, this message translates to:
  /// **'Quick add customer'**
  String get posQuickAddCustomer;

  /// No description provided for @posNoCustomer.
  ///
  /// In en, this message translates to:
  /// **'No customer'**
  String get posNoCustomer;

  /// No description provided for @posNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get posNewCustomer;

  /// No description provided for @posNoHeldSales.
  ///
  /// In en, this message translates to:
  /// **'No held sales'**
  String get posNoHeldSales;

  /// No description provided for @posHeldSales.
  ///
  /// In en, this message translates to:
  /// **'Held sales'**
  String get posHeldSales;

  /// No description provided for @posProductAdded.
  ///
  /// In en, this message translates to:
  /// **'Product added'**
  String get posProductAdded;

  /// No description provided for @posEditPrice.
  ///
  /// In en, this message translates to:
  /// **'Edit price · {name}'**
  String posEditPrice(String name);

  /// No description provided for @posPriceOverrideDisabled.
  ///
  /// In en, this message translates to:
  /// **'Price override disabled in Settings'**
  String get posPriceOverrideDisabled;

  /// No description provided for @posOrderDiscount.
  ///
  /// In en, this message translates to:
  /// **'Order discount'**
  String get posOrderDiscount;

  /// No description provided for @posAddDiscount.
  ///
  /// In en, this message translates to:
  /// **'Add discount'**
  String get posAddDiscount;

  /// No description provided for @posCheckoutShortcut.
  ///
  /// In en, this message translates to:
  /// **'Checkout · F10'**
  String get posCheckoutShortcut;

  /// No description provided for @posQuickAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Quick add product'**
  String get posQuickAddProduct;

  /// No description provided for @posCartItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String posCartItems(int count);

  /// No description provided for @posChangeCustomer.
  ///
  /// In en, this message translates to:
  /// **'Change customer'**
  String get posChangeCustomer;

  /// No description provided for @posMobileCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get posMobileCart;

  /// No description provided for @posItemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get posItemName;

  /// No description provided for @posSaleCompletedSummary.
  ///
  /// In en, this message translates to:
  /// **'Sale completed ({summary})'**
  String posSaleCompletedSummary(String summary);

  /// No description provided for @posLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Label (optional)'**
  String get posLabelOptional;

  /// No description provided for @posLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Customer waiting'**
  String get posLabelHint;

  /// No description provided for @posHeldRestored.
  ///
  /// In en, this message translates to:
  /// **'Held sale restored'**
  String get posHeldRestored;

  /// No description provided for @posClearCartFirst.
  ///
  /// In en, this message translates to:
  /// **'Clear cart first to restore'**
  String get posClearCartFirst;

  /// No description provided for @dashboardWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get dashboardWelcome;

  /// No description provided for @dashboardTodaySales.
  ///
  /// In en, this message translates to:
  /// **'Today\'s sales'**
  String get dashboardTodaySales;

  /// No description provided for @dashboardMonthProfit.
  ///
  /// In en, this message translates to:
  /// **'Month profit'**
  String get dashboardMonthProfit;

  /// No description provided for @dashboardLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get dashboardLowStock;

  /// No description provided for @dashboardOpenPos.
  ///
  /// In en, this message translates to:
  /// **'Open POS'**
  String get dashboardOpenPos;

  /// No description provided for @dashboardNoSalesYet.
  ///
  /// In en, this message translates to:
  /// **'No sales yet — open POS to get started'**
  String get dashboardNoSalesYet;

  /// No description provided for @dashboardSalesLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Sales · last 7 days'**
  String get dashboardSalesLast7Days;

  /// No description provided for @dashboardDailyRevenue.
  ///
  /// In en, this message translates to:
  /// **'Daily revenue'**
  String get dashboardDailyRevenue;

  /// No description provided for @dashboardChartError.
  ///
  /// In en, this message translates to:
  /// **'Chart error: {detail}'**
  String dashboardChartError(String detail);

  /// No description provided for @dashboardNoSalesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No sales recorded yet'**
  String get dashboardNoSalesRecorded;

  /// No description provided for @dashboardLowStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Low stock alerts'**
  String get dashboardLowStockAlerts;

  /// No description provided for @dashboardQtyAlert.
  ///
  /// In en, this message translates to:
  /// **'Qty {qty} / alert {alert}'**
  String dashboardQtyAlert(int qty, int alert);

  /// No description provided for @dashboardTodaySalesDot.
  ///
  /// In en, this message translates to:
  /// **'Today\'s sales · {amount}'**
  String dashboardTodaySalesDot(String amount);

  /// No description provided for @dashboardMonthlySales.
  ///
  /// In en, this message translates to:
  /// **'Monthly sales'**
  String get dashboardMonthlySales;

  /// No description provided for @dashboardTodayExpenses.
  ///
  /// In en, this message translates to:
  /// **'Today\'s expenses'**
  String get dashboardTodayExpenses;

  /// No description provided for @dashboardMonthlyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Monthly expenses'**
  String get dashboardMonthlyExpenses;

  /// No description provided for @dashboardRecentSales.
  ///
  /// In en, this message translates to:
  /// **'Recent sales'**
  String get dashboardRecentSales;

  /// No description provided for @dashboardAllStockGood.
  ///
  /// In en, this message translates to:
  /// **'All stock levels look good'**
  String get dashboardAllStockGood;

  /// No description provided for @dashboardYourStore.
  ///
  /// In en, this message translates to:
  /// **'Your store'**
  String get dashboardYourStore;

  /// No description provided for @settingsSystemHealth.
  ///
  /// In en, this message translates to:
  /// **'System health'**
  String get settingsSystemHealth;

  /// No description provided for @settingsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsEmail;

  /// No description provided for @settingsTaxNumber.
  ///
  /// In en, this message translates to:
  /// **'Tax number'**
  String get settingsTaxNumber;

  /// No description provided for @planFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Free Trial'**
  String get planFreeTrial;

  /// No description provided for @settingsPosFeedback.
  ///
  /// In en, this message translates to:
  /// **'POS feedback'**
  String get settingsPosFeedback;

  /// No description provided for @settingsSoundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get settingsSoundEffects;

  /// No description provided for @settingsScanCues.
  ///
  /// In en, this message translates to:
  /// **'Scan and checkout cues'**
  String get settingsScanCues;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get settingsHaptics;

  /// No description provided for @settingsPlatformCenter.
  ///
  /// In en, this message translates to:
  /// **'Platform command center'**
  String get settingsPlatformCenter;

  /// No description provided for @settingsPlatformSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stores, plans, revenue, SaaS analytics'**
  String get settingsPlatformSubtitle;

  /// No description provided for @settingsUserMgmt.
  ///
  /// In en, this message translates to:
  /// **'User management'**
  String get settingsUserMgmt;

  /// No description provided for @settingsUserMgmtSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Staff, roles, and permissions'**
  String get settingsUserMgmtSubtitle;

  /// No description provided for @settingsHealthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync, realtime, queue & diagnostics'**
  String get settingsHealthSubtitle;

  /// No description provided for @settingsQaValidation.
  ///
  /// In en, this message translates to:
  /// **'QA validation'**
  String get settingsQaValidation;

  /// No description provided for @settingsQaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automated checks & pre-launch checklist'**
  String get settingsQaSubtitle;

  /// No description provided for @settingsStoreBranding.
  ///
  /// In en, this message translates to:
  /// **'Store branding'**
  String get settingsStoreBranding;

  /// No description provided for @settingsBrandingHint.
  ///
  /// In en, this message translates to:
  /// **'Logo appears on receipts, invoices, and shared debt links.'**
  String get settingsBrandingHint;

  /// No description provided for @settingsStoreName.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get settingsStoreName;

  /// No description provided for @settingsPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get settingsPhone;

  /// No description provided for @settingsAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get settingsAddress;

  /// No description provided for @settingsTaxRate.
  ///
  /// In en, this message translates to:
  /// **'Tax rate %'**
  String get settingsTaxRate;

  /// No description provided for @settingsReceiptHeader.
  ///
  /// In en, this message translates to:
  /// **'Receipt header'**
  String get settingsReceiptHeader;

  /// No description provided for @settingsInvoiceFooter.
  ///
  /// In en, this message translates to:
  /// **'Invoice footer text'**
  String get settingsInvoiceFooter;

  /// No description provided for @settingsTaxInclusiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Tax-inclusive prices'**
  String get settingsTaxInclusiveTitle;

  /// No description provided for @settingsTaxInclusiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prices already include tax (POS extracts tax for display)'**
  String get settingsTaxInclusiveSubtitle;

  /// No description provided for @settingsPosPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'POS permissions'**
  String get settingsPosPermissionsTitle;

  /// No description provided for @settingsAllowPriceOverride.
  ///
  /// In en, this message translates to:
  /// **'Allow cashier price override'**
  String get settingsAllowPriceOverride;

  /// No description provided for @settingsAllowPriceOverrideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When off, cart prices cannot be edited at checkout'**
  String get settingsAllowPriceOverrideSubtitle;

  /// No description provided for @settingsAutoPrintReceipt.
  ///
  /// In en, this message translates to:
  /// **'Auto-print receipt after sale'**
  String get settingsAutoPrintReceipt;

  /// No description provided for @settingsAutoPrintSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Skips the print prompt at checkout'**
  String get settingsAutoPrintSubtitle;

  /// No description provided for @settingsSubscriptionPlan.
  ///
  /// In en, this message translates to:
  /// **'Subscription plan'**
  String get settingsSubscriptionPlan;

  /// No description provided for @settingsAuditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get settingsAuditLog;

  /// No description provided for @settingsNoAudit.
  ///
  /// In en, this message translates to:
  /// **'No audit entries yet.'**
  String get settingsNoAudit;

  /// No description provided for @settingsExpenseSaved.
  ///
  /// In en, this message translates to:
  /// **'Expense saved'**
  String get settingsExpenseSaved;

  /// No description provided for @settingsLogoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Logo upload failed. Run supabase db push for storage buckets, then try again.'**
  String get settingsLogoUploadFailed;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please try again.'**
  String get signInFailed;

  /// No description provided for @customerDirectory.
  ///
  /// In en, this message translates to:
  /// **'Customer directory'**
  String get customerDirectory;

  /// No description provided for @customerReceivablesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Credit sales and receivables'**
  String get customerReceivablesSubtitle;

  /// No description provided for @totalReceivable.
  ///
  /// In en, this message translates to:
  /// **'Total receivable'**
  String get totalReceivable;

  /// No description provided for @supplierDirectory.
  ///
  /// In en, this message translates to:
  /// **'Supplier directory'**
  String get supplierDirectory;

  /// No description provided for @supplierPayablesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Purchases and payables'**
  String get supplierPayablesSubtitle;

  /// No description provided for @totalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total payable'**
  String get totalPayable;

  /// No description provided for @expenseSaved.
  ///
  /// In en, this message translates to:
  /// **'Expense saved'**
  String get expenseSaved;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @addBrand.
  ///
  /// In en, this message translates to:
  /// **'Add brand'**
  String get addBrand;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @editBrand.
  ///
  /// In en, this message translates to:
  /// **'Edit brand'**
  String get editBrand;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @brandNameField.
  ///
  /// In en, this message translates to:
  /// **'Brand name'**
  String get brandNameField;

  /// No description provided for @inventoryScanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get inventoryScanBarcode;

  /// No description provided for @inventoryShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get inventoryShowAll;

  /// No description provided for @inventoryLowStockOnly.
  ///
  /// In en, this message translates to:
  /// **'Low stock only'**
  String get inventoryLowStockOnly;

  /// No description provided for @inventorySearchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products…'**
  String get inventorySearchProducts;

  /// No description provided for @inventoryAdjustStock.
  ///
  /// In en, this message translates to:
  /// **'Adjust stock'**
  String get inventoryAdjustStock;

  /// No description provided for @debtsCustomerTab.
  ///
  /// In en, this message translates to:
  /// **'Customer debts'**
  String get debtsCustomerTab;

  /// No description provided for @debtsSupplierTab.
  ///
  /// In en, this message translates to:
  /// **'Supplier payables'**
  String get debtsSupplierTab;

  /// No description provided for @debtsFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter status'**
  String get debtsFilterStatus;

  /// No description provided for @debtsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search name, phone, invoice…'**
  String get debtsSearchHint;

  /// No description provided for @debtStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get debtStatusActive;

  /// No description provided for @debtStatusPartiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially paid'**
  String get debtStatusPartiallyPaid;

  /// No description provided for @debtStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get debtStatusOverdue;

  /// No description provided for @reportsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get reportsToday;

  /// No description provided for @reportsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get reportsThisWeek;

  /// No description provided for @reportsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get reportsThisMonth;

  /// No description provided for @reportsCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get reportsCustomRange;

  /// No description provided for @reportsRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get reportsRevenue;

  /// No description provided for @reportsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get reportsExpenses;

  /// No description provided for @reportsNetProfit.
  ///
  /// In en, this message translates to:
  /// **'Net profit'**
  String get reportsNetProfit;

  /// No description provided for @usersCreateUser.
  ///
  /// In en, this message translates to:
  /// **'Create user'**
  String get usersCreateUser;

  /// No description provided for @usersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search users…'**
  String get usersSearchHint;

  /// No description provided for @usersNoUsers.
  ///
  /// In en, this message translates to:
  /// **'No users yet'**
  String get usersNoUsers;

  /// No description provided for @usersInviteStaff.
  ///
  /// In en, this message translates to:
  /// **'Invite staff from your store owner account.'**
  String get usersInviteStaff;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your store'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Currency, tax, and branding'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @registerStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your store'**
  String get registerStoreTitle;

  /// No description provided for @registerStoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your InventraX trial'**
  String get registerStoreSubtitle;

  /// No description provided for @welcomeGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get welcomeGetStarted;

  /// No description provided for @welcomeSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get welcomeSignIn;

  /// No description provided for @syncQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync queue'**
  String get syncQueueTitle;

  /// No description provided for @syncQueueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Queue is empty'**
  String get syncQueueEmpty;

  /// No description provided for @syncRetryAll.
  ///
  /// In en, this message translates to:
  /// **'Retry all'**
  String get syncRetryAll;

  /// No description provided for @productAdded.
  ///
  /// In en, this message translates to:
  /// **'Product saved'**
  String get productAdded;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get productDeleted;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get lowStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStock;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All products'**
  String get allProducts;

  /// No description provided for @activeOnly.
  ///
  /// In en, this message translates to:
  /// **'Active only'**
  String get activeOnly;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @l10nDevMissingBanner.
  ///
  /// In en, this message translates to:
  /// **'Missing translations for {locale} — see untranslated_messages.txt'**
  String l10nDevMissingBanner(String locale);

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @productNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Product name *'**
  String get productNameRequired;

  /// No description provided for @noBrand.
  ///
  /// In en, this message translates to:
  /// **'No brand'**
  String get noBrand;

  /// No description provided for @brandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brandLabel;

  /// No description provided for @secondaryNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Secondary name (optional)'**
  String get secondaryNameOptional;

  /// No description provided for @barcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcodeLabel;

  /// No description provided for @barcodeTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode type'**
  String get barcodeTypeLabel;

  /// No description provided for @barcodeTypeCode128.
  ///
  /// In en, this message translates to:
  /// **'CODE128'**
  String get barcodeTypeCode128;

  /// No description provided for @barcodeTypeEan13.
  ///
  /// In en, this message translates to:
  /// **'EAN-13'**
  String get barcodeTypeEan13;

  /// No description provided for @barcodeTypeQr.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get barcodeTypeQr;

  /// No description provided for @productsCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get productsCost;

  /// No description provided for @sellPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Sell price *'**
  String get sellPriceRequired;

  /// No description provided for @minStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Min stock alert'**
  String get minStockAlert;

  /// No description provided for @printLabel.
  ///
  /// In en, this message translates to:
  /// **'Print label'**
  String get printLabel;

  /// No description provided for @barcodeAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'Barcode already in use'**
  String get barcodeAlreadyInUse;

  /// No description provided for @productLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Product limit reached'**
  String get productLimitReached;

  /// No description provided for @productImageSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Image could not be saved. Check Supabase storage (store-logos / product-images buckets).'**
  String get productImageSaveFailed;

  /// No description provided for @noMatchingProducts.
  ///
  /// In en, this message translates to:
  /// **'No matching products'**
  String get noMatchingProducts;

  /// No description provided for @noMatchingProductsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term or clear filters.'**
  String get noMatchingProductsSubtitle;

  /// No description provided for @productsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build your catalog with barcodes, prices, and stock levels.'**
  String get productsEmptySubtitle;

  /// No description provided for @filterByBrand.
  ///
  /// In en, this message translates to:
  /// **'Filter by brand'**
  String get filterByBrand;

  /// No description provided for @allBrands.
  ///
  /// In en, this message translates to:
  /// **'All brands'**
  String get allBrands;

  /// No description provided for @totalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total products'**
  String get totalProducts;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @searchResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String searchResultCount(int count);

  /// No description provided for @searchProductsExtended.
  ///
  /// In en, this message translates to:
  /// **'Search by name, barcode, or SKU…'**
  String get searchProductsExtended;

  /// No description provided for @posPaymentAccountsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load payment accounts: {detail}'**
  String posPaymentAccountsError(String detail);

  /// No description provided for @posCustomerRequired.
  ///
  /// In en, this message translates to:
  /// **'Select or add a customer for partial/credit sales.'**
  String get posCustomerRequired;

  /// No description provided for @posInvalidPartialAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid partial amount less than the total.'**
  String get posInvalidPartialAmount;

  /// No description provided for @posSetupPaymentAccount.
  ///
  /// In en, this message translates to:
  /// **'Set up a payment account in Accounting before partial sales.'**
  String get posSetupPaymentAccount;

  /// No description provided for @posPaymentFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get posPaymentFull;

  /// No description provided for @posPaymentPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get posPaymentPartial;

  /// No description provided for @posPaymentCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get posPaymentCredit;

  /// No description provided for @commonSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get commonSelect;

  /// No description provided for @posQuickAddShort.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get posQuickAddShort;

  /// No description provided for @posInvoiceTotal.
  ///
  /// In en, this message translates to:
  /// **'Invoice total: {amount}'**
  String posInvoiceTotal(String amount);

  /// No description provided for @posCustomerRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Required to track remaining balance.'**
  String get posCustomerRequiredHint;

  /// No description provided for @posCustomerOptional.
  ///
  /// In en, this message translates to:
  /// **'Customer (optional): {name}'**
  String posCustomerOptional(String name);

  /// No description provided for @posNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get posNotesOptional;

  /// No description provided for @posAmountReceivedNow.
  ///
  /// In en, this message translates to:
  /// **'Amount received now'**
  String get posAmountReceivedNow;

  /// No description provided for @posPartialAmountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 40.00'**
  String get posPartialAmountHint;

  /// No description provided for @posRemainingToDebt.
  ///
  /// In en, this message translates to:
  /// **'Remaining {amount} → customer debt'**
  String posRemainingToDebt(String amount);

  /// No description provided for @posCreditNoPaymentNow.
  ///
  /// In en, this message translates to:
  /// **'No payment now. Entire {amount} → Accounts Receivable.'**
  String posCreditNoPaymentNow(String amount);

  /// No description provided for @posReceivePaymentInto.
  ///
  /// In en, this message translates to:
  /// **'Receive payment into'**
  String get posReceivePaymentInto;

  /// No description provided for @posPaymentAccount.
  ///
  /// In en, this message translates to:
  /// **'Payment account'**
  String get posPaymentAccount;

  /// No description provided for @posSetupAccountsPartial.
  ///
  /// In en, this message translates to:
  /// **'Set up payment accounts in Accounting before partial sales.'**
  String get posSetupAccountsPartial;

  /// No description provided for @posNoAccountsCash.
  ///
  /// In en, this message translates to:
  /// **'No payment accounts — sale will complete as cash.'**
  String get posNoAccountsCash;

  /// No description provided for @posSplitAcrossAccounts.
  ///
  /// In en, this message translates to:
  /// **'Split across accounts'**
  String get posSplitAcrossAccounts;

  /// No description provided for @posNeedTwoAccounts.
  ///
  /// In en, this message translates to:
  /// **'Need at least two payment accounts for a split.'**
  String get posNeedTwoAccounts;

  /// No description provided for @posSplitPayment.
  ///
  /// In en, this message translates to:
  /// **'Split payment'**
  String get posSplitPayment;

  /// No description provided for @posTotalDue.
  ///
  /// In en, this message translates to:
  /// **'Total due: {amount}'**
  String posTotalDue(String amount);

  /// No description provided for @posCompleteOnCredit.
  ///
  /// In en, this message translates to:
  /// **'Complete on credit'**
  String get posCompleteOnCredit;

  /// No description provided for @posCompletePartialSale.
  ///
  /// In en, this message translates to:
  /// **'Complete partial sale'**
  String get posCompletePartialSale;

  /// No description provided for @reportsPickDateRange.
  ///
  /// In en, this message translates to:
  /// **'Pick date range'**
  String get reportsPickDateRange;

  /// No description provided for @reportsRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Report range'**
  String get reportsRangeLabel;

  /// No description provided for @reportsSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get reportsSummary;

  /// No description provided for @reportsCogs.
  ///
  /// In en, this message translates to:
  /// **'COGS'**
  String get reportsCogs;

  /// No description provided for @reportsSalesCount.
  ///
  /// In en, this message translates to:
  /// **'Sales count'**
  String get reportsSalesCount;

  /// No description provided for @reportsExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get reportsExportPdf;

  /// No description provided for @reportsExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get reportsExportCsv;

  /// No description provided for @reportsShareCsvText.
  ///
  /// In en, this message translates to:
  /// **'InventraX report (CSV)'**
  String get reportsShareCsvText;

  /// No description provided for @reportsSaleItems.
  ///
  /// In en, this message translates to:
  /// **'Items: {count} • {id}'**
  String reportsSaleItems(int count, String id);

  /// No description provided for @reportsLineItemDetail.
  ///
  /// In en, this message translates to:
  /// **'x{qty} @ {unit} (cost {cost})'**
  String reportsLineItemDetail(int qty, String unit, String cost);

  /// No description provided for @debtsFilterStatusTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter status'**
  String get debtsFilterStatusTooltip;

  /// No description provided for @debtCustomerReceivable.
  ///
  /// In en, this message translates to:
  /// **'Customer receivable'**
  String get debtCustomerReceivable;

  /// No description provided for @debtSupplierPayable.
  ///
  /// In en, this message translates to:
  /// **'Supplier payable'**
  String get debtSupplierPayable;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteBrandTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete brand?'**
  String get deleteBrandTitle;

  /// No description provided for @removeItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\"?'**
  String removeItemConfirm(String name);

  /// No description provided for @categorySaved.
  ///
  /// In en, this message translates to:
  /// **'Category saved'**
  String get categorySaved;

  /// No description provided for @brandSaved.
  ///
  /// In en, this message translates to:
  /// **'Brand saved'**
  String get brandSaved;

  /// No description provided for @expenseName.
  ///
  /// In en, this message translates to:
  /// **'Expense name'**
  String get expenseName;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCategory;

  /// No description provided for @expenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseAmount;

  /// No description provided for @paidFromAccount.
  ///
  /// In en, this message translates to:
  /// **'Paid from account'**
  String get paidFromAccount;

  /// No description provided for @expenseCategoryMisc.
  ///
  /// In en, this message translates to:
  /// **'Miscellaneous'**
  String get expenseCategoryMisc;

  /// No description provided for @posScanBarcodeSearch.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode or search products (F1)'**
  String get posScanBarcodeSearch;

  /// No description provided for @posAddToCartTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get posAddToCartTooltip;

  /// No description provided for @posScanCameraTooltip.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode (camera)'**
  String get posScanCameraTooltip;

  /// No description provided for @posCartMobile.
  ///
  /// In en, this message translates to:
  /// **'Cart ({count}) • {total}'**
  String posCartMobile(int count, String total);

  /// No description provided for @posScanOrTapProducts.
  ///
  /// In en, this message translates to:
  /// **'Scan or tap products'**
  String get posScanOrTapProducts;

  /// No description provided for @posSellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling price'**
  String get posSellingPrice;

  /// No description provided for @posCatalogPrice.
  ///
  /// In en, this message translates to:
  /// **'Catalog: {price}'**
  String posCatalogPrice(String price);

  /// No description provided for @posDiscountAmount.
  ///
  /// In en, this message translates to:
  /// **'Discount amount'**
  String get posDiscountAmount;

  /// No description provided for @posTaxInclSuffix.
  ///
  /// In en, this message translates to:
  /// **' (incl.)'**
  String get posTaxInclSuffix;

  /// No description provided for @posHeldSaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Held sale'**
  String get posHeldSaleLabel;

  /// No description provided for @inventoryKpiError.
  ///
  /// In en, this message translates to:
  /// **'KPI error: {detail}'**
  String inventoryKpiError(String detail);

  /// No description provided for @inventoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Inventory updated'**
  String get inventoryUpdated;

  /// No description provided for @inventoryAdjustTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust: {name}'**
  String inventoryAdjustTitle(String name);

  /// No description provided for @inventoryCurrentQty.
  ///
  /// In en, this message translates to:
  /// **'Current quantity: {qty}'**
  String inventoryCurrentQty(int qty);

  /// No description provided for @inventoryChangeDelta.
  ///
  /// In en, this message translates to:
  /// **'Change (+/-)'**
  String get inventoryChangeDelta;

  /// No description provided for @inventoryReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get inventoryReason;

  /// No description provided for @inventoryStockValueCost.
  ///
  /// In en, this message translates to:
  /// **'Stock value (cost)'**
  String get inventoryStockValueCost;

  /// No description provided for @inventoryBarcodeLine.
  ///
  /// In en, this message translates to:
  /// **'Barcode: {barcode} • Qty {qty}'**
  String inventoryBarcodeLine(String barcode, int qty);

  /// No description provided for @inventoryQtyPill.
  ///
  /// In en, this message translates to:
  /// **'Qty {qty}'**
  String inventoryQtyPill(int qty);

  /// No description provided for @inventoryCostPill.
  ///
  /// In en, this message translates to:
  /// **'Cost {amount}'**
  String inventoryCostPill(String amount);

  /// No description provided for @inventorySellPill.
  ///
  /// In en, this message translates to:
  /// **'Sell {amount}'**
  String inventorySellPill(String amount);

  /// No description provided for @inventoryProfitPill.
  ///
  /// In en, this message translates to:
  /// **'Profit {amount}'**
  String inventoryProfitPill(String amount);

  /// No description provided for @inventoryNoMatchingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try scanning a barcode or changing your search/filter.'**
  String get inventoryNoMatchingSubtitle;

  /// No description provided for @inventoryReasonDamaged.
  ///
  /// In en, this message translates to:
  /// **'Damaged goods'**
  String get inventoryReasonDamaged;

  /// No description provided for @inventoryReasonExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired goods'**
  String get inventoryReasonExpired;

  /// No description provided for @inventoryReasonTheft.
  ///
  /// In en, this message translates to:
  /// **'Theft / shrinkage'**
  String get inventoryReasonTheft;

  /// No description provided for @inventoryReasonReturn.
  ///
  /// In en, this message translates to:
  /// **'Supplier return'**
  String get inventoryReasonReturn;

  /// No description provided for @inventoryReasonCount.
  ///
  /// In en, this message translates to:
  /// **'Stock count correction'**
  String get inventoryReasonCount;

  /// No description provided for @inventoryReasonInitial.
  ///
  /// In en, this message translates to:
  /// **'Initial stock entry'**
  String get inventoryReasonInitial;

  /// No description provided for @debtBalanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance due: {amount}'**
  String debtBalanceDue(String amount);

  /// No description provided for @debtPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Payment amount'**
  String get debtPaymentAmount;

  /// No description provided for @debtSelectPaymentAccount.
  ///
  /// In en, this message translates to:
  /// **'Select a payment account'**
  String get debtSelectPaymentAccount;

  /// No description provided for @debtNoWallets.
  ///
  /// In en, this message translates to:
  /// **'No wallets — seed accounting first.'**
  String get debtNoWallets;

  /// No description provided for @debtPaymentExceeds.
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed {amount}'**
  String debtPaymentExceeds(String amount);

  /// No description provided for @debtPaymentRecorded.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded successfully'**
  String get debtPaymentRecorded;

  /// No description provided for @debtPaymentRemainingSync.
  ///
  /// In en, this message translates to:
  /// **'Remaining {amount} • Saved locally, syncing in background'**
  String debtPaymentRemainingSync(String amount);

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @rememberMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay signed in on this device'**
  String get rememberMeSubtitle;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get signingIn;

  /// No description provided for @newToInventraX.
  ///
  /// In en, this message translates to:
  /// **'New to InventraX?'**
  String get newToInventraX;

  /// No description provided for @registerYourStore.
  ///
  /// In en, this message translates to:
  /// **'Register your store'**
  String get registerYourStore;

  /// No description provided for @backToWelcome.
  ///
  /// In en, this message translates to:
  /// **'Back to welcome'**
  String get backToWelcome;

  /// No description provided for @authSupabaseSecured.
  ///
  /// In en, this message translates to:
  /// **'Secured with Supabase Auth and tenant isolation.'**
  String get authSupabaseSecured;

  /// No description provided for @authOfflineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline mode — configure .env for cloud sync.'**
  String get authOfflineMode;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Run your store with confidence. Register in minutes or sign in to continue.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Multi-tenant SaaS for modern retail. Secure, fast, and built for scale.'**
  String get welcomeTagline;

  /// No description provided for @featureCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync'**
  String get featureCloudSync;

  /// No description provided for @featureOfflinePos.
  ///
  /// In en, this message translates to:
  /// **'Offline POS'**
  String get featureOfflinePos;

  /// No description provided for @featureRlsIsolation.
  ///
  /// In en, this message translates to:
  /// **'RLS isolation'**
  String get featureRlsIsolation;

  /// No description provided for @featureBarcodeReady.
  ///
  /// In en, this message translates to:
  /// **'Barcode ready'**
  String get featureBarcodeReady;

  /// No description provided for @registerStepBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get registerStepBusiness;

  /// No description provided for @registerStepOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get registerStepOwner;

  /// No description provided for @registerStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get registerStepReview;

  /// No description provided for @creatingStore.
  ///
  /// In en, this message translates to:
  /// **'Creating your store…'**
  String get creatingStore;

  /// No description provided for @tellUsBusiness.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your business'**
  String get tellUsBusiness;

  /// No description provided for @businessType.
  ///
  /// In en, this message translates to:
  /// **'Business type'**
  String get businessType;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @taxNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Tax number (optional)'**
  String get taxNumberOptional;

  /// No description provided for @ownerAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Owner account — you will be Store Owner'**
  String get ownerAccountTitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name *'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password *'**
  String get confirmPassword;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Min 8 chars, uppercase, lowercase, and a number.'**
  String get passwordHint;

  /// No description provided for @reviewCreateStore.
  ///
  /// In en, this message translates to:
  /// **'Review and create your store'**
  String get reviewCreateStore;

  /// No description provided for @freeTrial14Day.
  ///
  /// In en, this message translates to:
  /// **'14-day Free Trial'**
  String get freeTrial14Day;

  /// No description provided for @storeOwnerPermissions.
  ///
  /// In en, this message translates to:
  /// **'Store Owner role with full permissions'**
  String get storeOwnerPermissions;

  /// No description provided for @alreadyHaveAccountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccountSignIn;

  /// No description provided for @storeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Store name is required'**
  String get storeNameRequired;

  /// No description provided for @ownerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Owner name is required'**
  String get ownerNameRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationFailed;

  /// No description provided for @reviewLabelStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get reviewLabelStore;

  /// No description provided for @reviewLabelType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get reviewLabelType;

  /// No description provided for @reviewLabelLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get reviewLabelLocation;

  /// No description provided for @reviewLabelOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get reviewLabelOwner;

  /// No description provided for @onboardingStoreSetup.
  ///
  /// In en, this message translates to:
  /// **'Store setup'**
  String get onboardingStoreSetup;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingBusinessInfo.
  ///
  /// In en, this message translates to:
  /// **'Business info'**
  String get onboardingBusinessInfo;

  /// No description provided for @onboardingBusinessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your store'**
  String get onboardingBusinessSubtitle;

  /// No description provided for @onboardingLocalization.
  ///
  /// In en, this message translates to:
  /// **'Localization'**
  String get onboardingLocalization;

  /// No description provided for @onboardingLocalizationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Currency and tax settings'**
  String get onboardingLocalizationSubtitle;

  /// No description provided for @onboardingBranding.
  ///
  /// In en, this message translates to:
  /// **'Branding'**
  String get onboardingBranding;

  /// No description provided for @onboardingBrandingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt header and logo (logo upload via Supabase storage later)'**
  String get onboardingBrandingSubtitle;

  /// No description provided for @onboardingChoosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get onboardingChoosePlan;

  /// No description provided for @onboardingPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'14-day free trial starts automatically'**
  String get onboardingPlanSubtitle;

  /// No description provided for @receiptHeaderText.
  ///
  /// In en, this message translates to:
  /// **'Receipt header text'**
  String get receiptHeaderText;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone *'**
  String get phoneRequired;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address *'**
  String get addressRequired;

  /// No description provided for @purchaseCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete purchase'**
  String get purchaseCompleteTitle;

  /// No description provided for @purchaseTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String purchaseTotal(String amount);

  /// No description provided for @purchaseSelectPayAccount.
  ///
  /// In en, this message translates to:
  /// **'Select which account to pay from'**
  String get purchaseSelectPayAccount;

  /// No description provided for @purchaseSaveOnCredit.
  ///
  /// In en, this message translates to:
  /// **'Save on credit'**
  String get purchaseSaveOnCredit;

  /// No description provided for @purchaseSavePurchase.
  ///
  /// In en, this message translates to:
  /// **'Save purchase'**
  String get purchaseSavePurchase;

  /// No description provided for @purchaseCouldNotLoadAccounts.
  ///
  /// In en, this message translates to:
  /// **'Could not load accounts: {detail}'**
  String purchaseCouldNotLoadAccounts(String detail);

  /// No description provided for @purchaseAmountPaidNow.
  ///
  /// In en, this message translates to:
  /// **'Amount paid now'**
  String get purchaseAmountPaidNow;

  /// No description provided for @purchaseRemainingToDebt.
  ///
  /// In en, this message translates to:
  /// **'Remaining {amount} → supplier debt'**
  String purchaseRemainingToDebt(String amount);

  /// No description provided for @purchaseCreditNoPayment.
  ///
  /// In en, this message translates to:
  /// **'No payment now. Full {amount} goes to Accounts Payable.'**
  String purchaseCreditNoPayment(String amount);

  /// No description provided for @purchasePayFromAccount.
  ///
  /// In en, this message translates to:
  /// **'Pay from account'**
  String get purchasePayFromAccount;

  /// No description provided for @purchaseSetupAccountsFirst.
  ///
  /// In en, this message translates to:
  /// **'Set up payment accounts in Accounting first.'**
  String get purchaseSetupAccountsFirst;

  /// No description provided for @purchaseAddedProduct.
  ///
  /// In en, this message translates to:
  /// **'Added {name}'**
  String purchaseAddedProduct(String name);

  /// No description provided for @quickAddSupplier.
  ///
  /// In en, this message translates to:
  /// **'Quick add supplier'**
  String get quickAddSupplier;

  /// No description provided for @purchaseUsingSupplier.
  ///
  /// In en, this message translates to:
  /// **'Using existing supplier: {name}'**
  String purchaseUsingSupplier(String name);

  /// No description provided for @purchaseSelectSupplierFirst.
  ///
  /// In en, this message translates to:
  /// **'Select or add a supplier first'**
  String get purchaseSelectSupplierFirst;

  /// No description provided for @purchaseNotSavedCancelled.
  ///
  /// In en, this message translates to:
  /// **'Purchase not saved — cancelled'**
  String get purchaseNotSavedCancelled;

  /// No description provided for @purchaseCouldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save purchase: {detail}'**
  String purchaseCouldNotSave(String detail);

  /// No description provided for @purchaseSavedSummary.
  ///
  /// In en, this message translates to:
  /// **'Purchase saved • {total} • {status}'**
  String purchaseSavedSummary(String total, String status);

  /// No description provided for @navSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get navSupplier;

  /// No description provided for @purchaseLookUp.
  ///
  /// In en, this message translates to:
  /// **'Look up'**
  String get purchaseLookUp;

  /// No description provided for @purchaseInStockLine.
  ///
  /// In en, this message translates to:
  /// **'In stock: {qty} • Last cost: {cost} • Sell: {sell}'**
  String purchaseInStockLine(int qty, String cost, String sell);

  /// No description provided for @purchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Purchase price'**
  String get purchasePrice;

  /// No description provided for @newSellPriceOptional.
  ///
  /// In en, this message translates to:
  /// **'New sell price (optional)'**
  String get newSellPriceOptional;

  /// No description provided for @invoiceOptional.
  ///
  /// In en, this message translates to:
  /// **'Invoice # (optional)'**
  String get invoiceOptional;

  /// No description provided for @purchaseCart.
  ///
  /// In en, this message translates to:
  /// **'Purchase cart'**
  String get purchaseCart;

  /// No description provided for @purchaseCartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Scan or look up products.\nExisting items show stock and prices.'**
  String get purchaseCartEmpty;

  /// No description provided for @purchaseStockLine.
  ///
  /// In en, this message translates to:
  /// **'Stock {stock} → +{add}'**
  String purchaseStockLine(int stock, int add);

  /// No description provided for @purchaseMargin.
  ///
  /// In en, this message translates to:
  /// **'Margin {percent}%'**
  String purchaseMargin(String percent);

  /// No description provided for @completePurchase.
  ///
  /// In en, this message translates to:
  /// **'Complete purchase'**
  String get completePurchase;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @selectOrAddSupplier.
  ///
  /// In en, this message translates to:
  /// **'Select or add supplier'**
  String get selectOrAddSupplier;

  /// No description provided for @purchaseDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase detail'**
  String get purchaseDetailTitle;

  /// No description provided for @purchaseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Purchase not found'**
  String get purchaseNotFound;

  /// No description provided for @purchaseInvoiceLine.
  ///
  /// In en, this message translates to:
  /// **'Invoice: {number}'**
  String purchaseInvoiceLine(String number);

  /// No description provided for @lineItems.
  ///
  /// In en, this message translates to:
  /// **'Line items'**
  String get lineItems;

  /// No description provided for @acctMonthToDate.
  ///
  /// In en, this message translates to:
  /// **'Month to date'**
  String get acctMonthToDate;

  /// No description provided for @acctFinancialOverview.
  ///
  /// In en, this message translates to:
  /// **'Financial overview'**
  String get acctFinancialOverview;

  /// No description provided for @acctRevenueLine.
  ///
  /// In en, this message translates to:
  /// **'Revenue {amount}'**
  String acctRevenueLine(String amount);

  /// No description provided for @acctAfterCogsExpenses.
  ///
  /// In en, this message translates to:
  /// **'After COGS & expenses'**
  String get acctAfterCogsExpenses;

  /// No description provided for @acctCashWallets.
  ///
  /// In en, this message translates to:
  /// **'Cash & wallets'**
  String get acctCashWallets;

  /// No description provided for @acctAllPaymentAccounts.
  ///
  /// In en, this message translates to:
  /// **'All payment accounts'**
  String get acctAllPaymentAccounts;

  /// No description provided for @acctReceivable.
  ///
  /// In en, this message translates to:
  /// **'Receivable'**
  String get acctReceivable;

  /// No description provided for @acctCustomerCredit.
  ///
  /// In en, this message translates to:
  /// **'Customer credit'**
  String get acctCustomerCredit;

  /// No description provided for @acctPayable.
  ///
  /// In en, this message translates to:
  /// **'Payable'**
  String get acctPayable;

  /// No description provided for @acctSupplierBalances.
  ///
  /// In en, this message translates to:
  /// **'Supplier balances'**
  String get acctSupplierBalances;

  /// No description provided for @acctTrialBalance.
  ///
  /// In en, this message translates to:
  /// **'Trial balance'**
  String get acctTrialBalance;

  /// No description provided for @acctBalanceSheet.
  ///
  /// In en, this message translates to:
  /// **'Balance sheet'**
  String get acctBalanceSheet;

  /// No description provided for @acctJournals.
  ///
  /// In en, this message translates to:
  /// **'Journals'**
  String get acctJournals;

  /// No description provided for @acctChartError.
  ///
  /// In en, this message translates to:
  /// **'Chart error: {detail}'**
  String acctChartError(String detail);

  /// No description provided for @posCatalogLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load products. Pull to refresh or check filters.'**
  String get posCatalogLoadError;

  /// No description provided for @posNoProductsMatch.
  ///
  /// In en, this message translates to:
  /// **'No products match your search'**
  String get posNoProductsMatch;

  /// No description provided for @viewGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get viewGrid;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get viewList;

  /// No description provided for @productCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String productCountLabel(int count);

  /// No description provided for @tagOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get tagOut;

  /// No description provided for @tagLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get tagLow;

  /// No description provided for @barcodeProductNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get barcodeProductNotFound;

  /// No description provided for @barcodeNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No product matches barcode:\n{code}'**
  String barcodeNoMatch(String code);

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual entry'**
  String get manualEntry;

  /// No description provided for @retryScan.
  ///
  /// In en, this message translates to:
  /// **'Retry scan'**
  String get retryScan;

  /// No description provided for @barcodeNoBarcode.
  ///
  /// In en, this message translates to:
  /// **'Product has no barcode'**
  String get barcodeNoBarcode;

  /// No description provided for @barcodeLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Barcode label'**
  String get barcodeLabelTitle;

  /// No description provided for @barcodeGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated: {code}'**
  String barcodeGenerated(String code);

  /// No description provided for @purchasePriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Purchase price *'**
  String get purchasePriceRequired;

  /// No description provided for @registerCreateStore.
  ///
  /// In en, this message translates to:
  /// **'Create store'**
  String get registerCreateStore;

  /// No description provided for @storeNameField.
  ///
  /// In en, this message translates to:
  /// **'Store name *'**
  String get storeNameField;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid password'**
  String get invalidPassword;

  /// No description provided for @authNoProfileHint.
  ///
  /// In en, this message translates to:
  /// **'Your Auth account exists but has no store profile. Run supabase/scripts/setup_super_admin.sql in Supabase SQL Editor, or use Register your store once with this email.'**
  String get authNoProfileHint;

  /// No description provided for @barcodeDirectSale.
  ///
  /// In en, this message translates to:
  /// **'Direct sale'**
  String get barcodeDirectSale;

  /// No description provided for @barcodeAddNewProduct.
  ///
  /// In en, this message translates to:
  /// **'Add new product'**
  String get barcodeAddNewProduct;

  /// No description provided for @acctNavSectionBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get acctNavSectionBooks;

  /// No description provided for @acctNavSectionCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get acctNavSectionCash;

  /// No description provided for @acctNavSectionReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get acctNavSectionReports;

  /// No description provided for @acctNavOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get acctNavOverview;

  /// No description provided for @acctNavChartOfAccounts.
  ///
  /// In en, this message translates to:
  /// **'Chart of accounts'**
  String get acctNavChartOfAccounts;

  /// No description provided for @acctNavGeneralLedger.
  ///
  /// In en, this message translates to:
  /// **'General ledger'**
  String get acctNavGeneralLedger;

  /// No description provided for @acctNavDeposits.
  ///
  /// In en, this message translates to:
  /// **'Deposits & withdrawals'**
  String get acctNavDeposits;

  /// No description provided for @acctNavPaymentAccounts.
  ///
  /// In en, this message translates to:
  /// **'Payment accounts'**
  String get acctNavPaymentAccounts;

  /// No description provided for @acctNavProfitLoss.
  ///
  /// In en, this message translates to:
  /// **'Profit & loss'**
  String get acctNavProfitLoss;

  /// No description provided for @acctNavCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Cash flow'**
  String get acctNavCashFlow;

  /// No description provided for @acctNetProfit.
  ///
  /// In en, this message translates to:
  /// **'Net profit'**
  String get acctNetProfit;

  /// No description provided for @acctRevenueLabel.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get acctRevenueLabel;

  /// No description provided for @acctExpensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get acctExpensesLabel;

  /// No description provided for @acctProfitLossShort.
  ///
  /// In en, this message translates to:
  /// **'P&L'**
  String get acctProfitLossShort;

  /// No description provided for @acctRevenueVsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Revenue vs expenses'**
  String get acctRevenueVsExpenses;

  /// No description provided for @acctLast6Months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get acctLast6Months;

  /// No description provided for @acctNoActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get acctNoActivityYet;

  /// No description provided for @acctNoActivityHint.
  ///
  /// In en, this message translates to:
  /// **'Complete sales and expenses to see trends'**
  String get acctNoActivityHint;

  /// No description provided for @acctBooksAtGlance.
  ///
  /// In en, this message translates to:
  /// **'Books at a glance'**
  String get acctBooksAtGlance;

  /// No description provided for @acctDoubleEntry.
  ///
  /// In en, this message translates to:
  /// **'Double-entry'**
  String get acctDoubleEntry;

  /// No description provided for @acctStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get acctStatusActive;

  /// No description provided for @acctCashPosition.
  ///
  /// In en, this message translates to:
  /// **'Cash position'**
  String get acctCashPosition;

  /// No description provided for @acctOutstandingAr.
  ///
  /// In en, this message translates to:
  /// **'Outstanding AR'**
  String get acctOutstandingAr;

  /// No description provided for @acctOutstandingAp.
  ///
  /// In en, this message translates to:
  /// **'Outstanding AP'**
  String get acctOutstandingAp;

  /// No description provided for @purchasePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get purchasePaid;

  /// No description provided for @purchaseOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get purchaseOutstanding;

  /// No description provided for @unknownSupplier.
  ///
  /// In en, this message translates to:
  /// **'Unknown supplier'**
  String get unknownSupplier;

  /// No description provided for @purchaseSelectPaymentAccount.
  ///
  /// In en, this message translates to:
  /// **'Select a payment account'**
  String get purchaseSelectPaymentAccount;

  /// No description provided for @onboardingFinishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get onboardingFinishSetup;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingPlanFreeTrialDesc.
  ///
  /// In en, this message translates to:
  /// **'14 days — full POS & inventory'**
  String get onboardingPlanFreeTrialDesc;

  /// No description provided for @onboardingPlanBilledMonthly.
  ///
  /// In en, this message translates to:
  /// **'Billed monthly when billing is enabled'**
  String get onboardingPlanBilledMonthly;

  /// No description provided for @onboardingTaxRateOptional.
  ///
  /// In en, this message translates to:
  /// **'Tax rate % (optional)'**
  String get onboardingTaxRateOptional;

  /// No description provided for @onboardingPlanStarter.
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get onboardingPlanStarter;

  /// No description provided for @onboardingPlanBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get onboardingPlanBusiness;

  /// No description provided for @onboardingPlanFreeTrialName.
  ///
  /// In en, this message translates to:
  /// **'Free Trial'**
  String get onboardingPlanFreeTrialName;

  /// No description provided for @posAddMore.
  ///
  /// In en, this message translates to:
  /// **'Add more'**
  String get posAddMore;

  /// No description provided for @posProfitLine.
  ///
  /// In en, this message translates to:
  /// **'Profit {amount}'**
  String posProfitLine(String amount);

  /// No description provided for @posOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get posOutOfStock;

  /// No description provided for @posLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get posLowStock;

  /// No description provided for @posQtyInCart.
  ///
  /// In en, this message translates to:
  /// **'{qty} in cart'**
  String posQtyInCart(int qty);

  /// No description provided for @posSellLine.
  ///
  /// In en, this message translates to:
  /// **'Sell {amount}'**
  String posSellLine(String amount);

  /// No description provided for @posCostStockLine.
  ///
  /// In en, this message translates to:
  /// **'Cost {cost} • Stock {qty}'**
  String posCostStockLine(String cost, int qty);

  /// No description provided for @barcodeScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get barcodeScanTitle;

  /// No description provided for @acctNewJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'New journal entry'**
  String get acctNewJournalEntry;

  /// No description provided for @acctManualJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual journal entry'**
  String get acctManualJournalEntry;

  /// No description provided for @acctManualJournalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Debits must equal credits — used for adjustments'**
  String get acctManualJournalSubtitle;

  /// No description provided for @acctBalancedEntryRequired.
  ///
  /// In en, this message translates to:
  /// **'Balanced entry required'**
  String get acctBalancedEntryRequired;

  /// No description provided for @acctEntryDetails.
  ///
  /// In en, this message translates to:
  /// **'Entry details'**
  String get acctEntryDetails;

  /// No description provided for @acctEntryDate.
  ///
  /// In en, this message translates to:
  /// **'Entry date'**
  String get acctEntryDate;

  /// No description provided for @acctPostEntry.
  ///
  /// In en, this message translates to:
  /// **'Post entry'**
  String get acctPostEntry;

  /// No description provided for @acctFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Fill all required fields'**
  String get acctFillRequiredFields;

  /// No description provided for @acctJournalPosted.
  ///
  /// In en, this message translates to:
  /// **'Journal posted'**
  String get acctJournalPosted;

  /// No description provided for @acctSelectAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Select an account'**
  String get acctSelectAccountTitle;

  /// No description provided for @acctSelectAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an account to view its ledger activity'**
  String get acctSelectAccountSubtitle;

  /// No description provided for @acctNoLedgerActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity'**
  String get acctNoLedgerActivity;

  /// No description provided for @acctYearToDateAsOf.
  ///
  /// In en, this message translates to:
  /// **'Year to date · As of {date}'**
  String acctYearToDateAsOf(String date);

  /// No description provided for @acctAssetsLiabilitiesEquity.
  ///
  /// In en, this message translates to:
  /// **'Assets, liabilities & equity · As of {date}'**
  String acctAssetsLiabilitiesEquity(String date);

  /// No description provided for @acctAssetsEquals.
  ///
  /// In en, this message translates to:
  /// **'Assets = Liabilities + Equity'**
  String get acctAssetsEquals;

  /// No description provided for @acctAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get acctAssets;

  /// No description provided for @acctLiabilities.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get acctLiabilities;

  /// No description provided for @acctEquity.
  ///
  /// In en, this message translates to:
  /// **'Equity'**
  String get acctEquity;

  /// No description provided for @acctIncomeStatementPeriod.
  ///
  /// In en, this message translates to:
  /// **'Income statement · {period}'**
  String acctIncomeStatementPeriod(String period);

  /// No description provided for @acctCogs.
  ///
  /// In en, this message translates to:
  /// **'Cost of goods sold'**
  String get acctCogs;

  /// No description provided for @acctGrossProfit.
  ///
  /// In en, this message translates to:
  /// **'Gross profit'**
  String get acctGrossProfit;

  /// No description provided for @acctSimplifiedViewPeriod.
  ///
  /// In en, this message translates to:
  /// **'Simplified view · {period}'**
  String acctSimplifiedViewPeriod(String period);

  /// No description provided for @acctNetMovement.
  ///
  /// In en, this message translates to:
  /// **'Net movement'**
  String get acctNetMovement;

  /// No description provided for @acctOperatingActivities.
  ///
  /// In en, this message translates to:
  /// **'Operating activities'**
  String get acctOperatingActivities;

  /// No description provided for @acctNoJournalEntries.
  ///
  /// In en, this message translates to:
  /// **'No journal entries yet'**
  String get acctNoJournalEntries;

  /// No description provided for @acctCreateManualEntry.
  ///
  /// In en, this message translates to:
  /// **'Create manual entry'**
  String get acctCreateManualEntry;

  /// No description provided for @acctPostedEntriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} posted entries (last 12 months)'**
  String acctPostedEntriesCount(int count);

  /// No description provided for @acctNewEntry.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get acctNewEntry;

  /// No description provided for @acctNoPaymentAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'No payment accounts'**
  String get acctNoPaymentAccountsTitle;

  /// No description provided for @acctPaymentAccountsAutoCreated.
  ///
  /// In en, this message translates to:
  /// **'Accounts are created automatically when you sign in'**
  String get acctPaymentAccountsAutoCreated;

  /// No description provided for @acctAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get acctAddAccount;

  /// No description provided for @acctDeleteDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Delete (deactivate)'**
  String get acctDeleteDeactivate;

  /// No description provided for @acctDeleteDeactivateHint.
  ///
  /// In en, this message translates to:
  /// **'Hides this account. Not allowed if already used.'**
  String get acctDeleteDeactivateHint;

  /// No description provided for @acctRestoreAccount.
  ///
  /// In en, this message translates to:
  /// **'Restore account'**
  String get acctRestoreAccount;

  /// No description provided for @acctDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get acctDeleteAccountTitle;

  /// No description provided for @acctAccountUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated: {name}'**
  String acctAccountUpdated(String name);

  /// No description provided for @acctAddAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get acctAddAccountDialogTitle;

  /// No description provided for @acctAccountTypeAsset.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get acctAccountTypeAsset;

  /// No description provided for @acctAccountTypeLiability.
  ///
  /// In en, this message translates to:
  /// **'Liability'**
  String get acctAccountTypeLiability;

  /// No description provided for @acctAccountTypeEquity.
  ///
  /// In en, this message translates to:
  /// **'Equity'**
  String get acctAccountTypeEquity;

  /// No description provided for @acctAccountTypeRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get acctAccountTypeRevenue;

  /// No description provided for @acctAccountTypeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get acctAccountTypeExpense;

  /// No description provided for @acctCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get acctCreateButton;

  /// No description provided for @acctAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get acctAccountCreated;

  /// No description provided for @acctCurrentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get acctCurrentBalance;

  /// No description provided for @acctActivityLast6Months.
  ///
  /// In en, this message translates to:
  /// **'Activity (last 6 months)'**
  String get acctActivityLast6Months;

  /// No description provided for @acctCannotDeleteWithBalance.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete: this account has a balance or transactions.'**
  String get acctCannotDeleteWithBalance;

  /// No description provided for @acctAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found'**
  String get acctAccountNotFound;

  /// No description provided for @acctTapAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Tap any account to view charts and activity'**
  String get acctTapAccountHint;

  /// No description provided for @acctOwnerCashMovements.
  ///
  /// In en, this message translates to:
  /// **'Owner cash movements'**
  String get acctOwnerCashMovements;

  /// No description provided for @acctOwnerCashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record money the owner puts into or takes out of the business'**
  String get acctOwnerCashSubtitle;

  /// No description provided for @acctDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get acctDeposit;

  /// No description provided for @acctWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get acctWithdrawal;

  /// No description provided for @acctTransactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction details'**
  String get acctTransactionDetails;

  /// No description provided for @acctNoPaymentAccountsConfigured.
  ///
  /// In en, this message translates to:
  /// **'No payment accounts configured.'**
  String get acctNoPaymentAccountsConfigured;

  /// No description provided for @acctEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get acctEnterValidAmount;

  /// No description provided for @acctExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {detail}'**
  String acctExportFailed(String detail);

  /// No description provided for @acctExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get acctExportPdf;

  /// No description provided for @acctBooksBalanced.
  ///
  /// In en, this message translates to:
  /// **'Books balanced'**
  String get acctBooksBalanced;

  /// No description provided for @acctOutOfBalance.
  ///
  /// In en, this message translates to:
  /// **'Out of balance'**
  String get acctOutOfBalance;

  /// No description provided for @acctDebitTotal.
  ///
  /// In en, this message translates to:
  /// **'Total debits'**
  String get acctDebitTotal;

  /// No description provided for @acctCreditTotal.
  ///
  /// In en, this message translates to:
  /// **'Total credits'**
  String get acctCreditTotal;

  /// No description provided for @acctEditPaymentAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit payment account'**
  String get acctEditPaymentAccount;

  /// No description provided for @acctAddPaymentAccount.
  ///
  /// In en, this message translates to:
  /// **'Add payment account'**
  String get acctAddPaymentAccount;

  /// No description provided for @acctPaymentAccountName.
  ///
  /// In en, this message translates to:
  /// **'Wallet name'**
  String get acctPaymentAccountName;

  /// No description provided for @acctPaymentAccountType.
  ///
  /// In en, this message translates to:
  /// **'Wallet type'**
  String get acctPaymentAccountType;

  /// No description provided for @acctSetAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default payment'**
  String get acctSetAsDefault;

  /// No description provided for @acctDefaultPaymentHint.
  ///
  /// In en, this message translates to:
  /// **'Used automatically at checkout when no wallet is selected'**
  String get acctDefaultPaymentHint;

  /// No description provided for @acctPaymentAccountSaved.
  ///
  /// In en, this message translates to:
  /// **'Payment account saved'**
  String get acctPaymentAccountSaved;

  /// No description provided for @acctWalletTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get acctWalletTypeCash;

  /// No description provided for @acctWalletTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get acctWalletTypeBank;

  /// No description provided for @acctWalletTypeMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile money'**
  String get acctWalletTypeMobile;

  /// No description provided for @acctTapToEditWallet.
  ///
  /// In en, this message translates to:
  /// **'Tap a wallet to edit'**
  String get acctTapToEditWallet;

  /// No description provided for @acctPurchaseSavedAccountingFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase saved but accounting entry failed: {detail}'**
  String acctPurchaseSavedAccountingFailed(String detail);

  /// No description provided for @platformCommandCenter.
  ///
  /// In en, this message translates to:
  /// **'SaaS command center'**
  String get platformCommandCenter;

  /// No description provided for @platformNavOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get platformNavOverview;

  /// No description provided for @platformNavBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get platformNavBusiness;

  /// No description provided for @platformNavOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get platformNavOperations;

  /// No description provided for @platformNavDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get platformNavDashboard;

  /// No description provided for @platformNavGlobalSearch.
  ///
  /// In en, this message translates to:
  /// **'Global search'**
  String get platformNavGlobalSearch;

  /// No description provided for @platformNavAllStores.
  ///
  /// In en, this message translates to:
  /// **'All stores'**
  String get platformNavAllStores;

  /// No description provided for @platformNavBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get platformNavBilling;

  /// No description provided for @platformNavRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get platformNavRevenue;

  /// No description provided for @platformNavPlans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get platformNavPlans;

  /// No description provided for @platformNavStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get platformNavStorage;

  /// No description provided for @platformNavAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get platformNavAlerts;

  /// No description provided for @platformNavAudit.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get platformNavAudit;

  /// No description provided for @platformNavHealth.
  ///
  /// In en, this message translates to:
  /// **'System health'**
  String get platformNavHealth;

  /// No description provided for @platformStoreApp.
  ///
  /// In en, this message translates to:
  /// **'Store app'**
  String get platformStoreApp;

  /// No description provided for @platformSuperAdmin.
  ///
  /// In en, this message translates to:
  /// **'Super admin'**
  String get platformSuperAdmin;

  /// No description provided for @platformAllStoresTitle.
  ///
  /// In en, this message translates to:
  /// **'All stores'**
  String get platformAllStoresTitle;

  /// No description provided for @platformAllStoresSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search, filter, and manage every tenant on the platform'**
  String get platformAllStoresSubtitle;

  /// No description provided for @platformGlobalSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Global search'**
  String get platformGlobalSearchTitle;

  /// No description provided for @platformAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get platformAlertsTitle;

  /// No description provided for @platformAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Expired subscriptions, trials ending, and storage warnings'**
  String get platformAlertsSubtitle;

  /// No description provided for @platformStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get platformStorageTitle;

  /// No description provided for @platformStorageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Platform-wide file usage and top consuming stores'**
  String get platformStorageSubtitle;

  /// No description provided for @platformTotalStorage.
  ///
  /// In en, this message translates to:
  /// **'Total platform storage'**
  String get platformTotalStorage;

  /// No description provided for @platformTotalStorageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Product images, logos, and attachments'**
  String get platformTotalStorageSubtitle;

  /// No description provided for @platformTopStorageConsumers.
  ///
  /// In en, this message translates to:
  /// **'Top storage consumers'**
  String get platformTopStorageConsumers;

  /// No description provided for @platformImagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} images'**
  String platformImagesCount(int count);

  /// No description provided for @platformAuditTitle.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get platformAuditTitle;

  /// No description provided for @platformAuditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Super admin actions: impersonation, billing, suspensions'**
  String get platformAuditSubtitle;

  /// No description provided for @platformBillingTitle.
  ///
  /// In en, this message translates to:
  /// **'Billing & subscriptions'**
  String get platformBillingTitle;

  /// No description provided for @platformBillingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage plan status, trials, and renewals per store'**
  String get platformBillingSubtitle;

  /// No description provided for @platformViewStore.
  ///
  /// In en, this message translates to:
  /// **'View store'**
  String get platformViewStore;

  /// No description provided for @platformSetActive.
  ///
  /// In en, this message translates to:
  /// **'Set active'**
  String get platformSetActive;

  /// No description provided for @platformExtendTrial14d.
  ///
  /// In en, this message translates to:
  /// **'Extend trial 14d'**
  String get platformExtendTrial14d;

  /// No description provided for @platformSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get platformSuspend;

  /// No description provided for @platformStoreUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {name}'**
  String platformStoreUpdated(String name);

  /// No description provided for @platformRevenueTitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get platformRevenueTitle;

  /// No description provided for @platformRevenueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'MRR, ARR, and plan contribution across the platform'**
  String get platformRevenueSubtitle;

  /// No description provided for @platformMrrByPlan.
  ///
  /// In en, this message translates to:
  /// **'MRR by plan'**
  String get platformMrrByPlan;

  /// No description provided for @platformPlanBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Plan breakdown'**
  String get platformPlanBreakdown;

  /// No description provided for @platformStoresCount.
  ///
  /// In en, this message translates to:
  /// **'{count} stores'**
  String platformStoresCount(int count);

  /// No description provided for @platformStoreGrowth12m.
  ///
  /// In en, this message translates to:
  /// **'Store growth (12 months)'**
  String get platformStoreGrowth12m;

  /// No description provided for @platformSubscriptionsByPlan.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions by plan'**
  String get platformSubscriptionsByPlan;

  /// No description provided for @platformTopStorageUsage.
  ///
  /// In en, this message translates to:
  /// **'Top storage usage'**
  String get platformTopStorageUsage;

  /// No description provided for @platformRecentStores.
  ///
  /// In en, this message translates to:
  /// **'Recent stores'**
  String get platformRecentStores;

  /// No description provided for @platformTotalStores.
  ///
  /// In en, this message translates to:
  /// **'Total stores'**
  String get platformTotalStores;

  /// No description provided for @platformTrialStores.
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get platformTrialStores;

  /// No description provided for @platformExpiredStores.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get platformExpiredStores;

  /// No description provided for @platformMrr.
  ///
  /// In en, this message translates to:
  /// **'MRR'**
  String get platformMrr;

  /// No description provided for @platformPaidStores.
  ///
  /// In en, this message translates to:
  /// **'Paid stores'**
  String get platformPaidStores;

  /// No description provided for @platformStoreNotFound.
  ///
  /// In en, this message translates to:
  /// **'Store not found'**
  String get platformStoreNotFound;

  /// No description provided for @platformOpenStoreImpersonate.
  ///
  /// In en, this message translates to:
  /// **'Open store (impersonate)'**
  String get platformOpenStoreImpersonate;

  /// No description provided for @platformBusinessAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Business analytics'**
  String get platformBusinessAnalytics;

  /// No description provided for @platformSubscriptionControl.
  ///
  /// In en, this message translates to:
  /// **'Subscription control'**
  String get platformSubscriptionControl;

  /// No description provided for @platformSetPlan.
  ///
  /// In en, this message translates to:
  /// **'Set {name}'**
  String platformSetPlan(String name);

  /// No description provided for @platformActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get platformActivate;

  /// No description provided for @platformStoreInfo.
  ///
  /// In en, this message translates to:
  /// **'Store info'**
  String get platformStoreInfo;

  /// No description provided for @platformExitImpersonation.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get platformExitImpersonation;

  /// No description provided for @platformPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription plans'**
  String get platformPlansTitle;

  /// No description provided for @platformPlansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Product, user, and storage limits per tier'**
  String get platformPlansSubtitle;

  /// No description provided for @platformNewPlan.
  ///
  /// In en, this message translates to:
  /// **'New plan'**
  String get platformNewPlan;

  /// No description provided for @platformHealthUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Health unavailable: {detail}'**
  String platformHealthUnavailable(String detail);

  /// No description provided for @platformPendingSync.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get platformPendingSync;

  /// No description provided for @platformFailedPushes.
  ///
  /// In en, this message translates to:
  /// **'Failed pushes'**
  String get platformFailedPushes;

  /// No description provided for @platformProductsSessionStore.
  ///
  /// In en, this message translates to:
  /// **'Products (session store)'**
  String get platformProductsSessionStore;

  /// No description provided for @platformOpenFullHealth.
  ///
  /// In en, this message translates to:
  /// **'Open full system health page'**
  String get platformOpenFullHealth;

  /// No description provided for @platformInventoryValue.
  ///
  /// In en, this message translates to:
  /// **'Inventory value'**
  String get platformInventoryValue;

  /// No description provided for @acctChartAccountsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} accounts · Add your own accounts and deactivate unused ones'**
  String acctChartAccountsSubtitle(int count);

  /// No description provided for @acctShowInactive.
  ///
  /// In en, this message translates to:
  /// **'Show inactive'**
  String get acctShowInactive;

  /// No description provided for @acctHideInactive.
  ///
  /// In en, this message translates to:
  /// **'Hide inactive'**
  String get acctHideInactive;

  /// No description provided for @acctSystemBadge.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get acctSystemBadge;

  /// No description provided for @acctDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This will deactivate the account (it will be hidden). Accounts with a balance or journal activity cannot be deleted.'**
  String get acctDeleteAccountBody;

  /// No description provided for @acctBalancedEntryBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Total debit amount will be mirrored as credit on the second account'**
  String get acctBalancedEntryBannerSubtitle;

  /// No description provided for @acctTypeSectionAsset.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get acctTypeSectionAsset;

  /// No description provided for @acctTypeSectionLiability.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get acctTypeSectionLiability;

  /// No description provided for @acctTypeSectionEquity.
  ///
  /// In en, this message translates to:
  /// **'Equity'**
  String get acctTypeSectionEquity;

  /// No description provided for @acctTypeSectionRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get acctTypeSectionRevenue;

  /// No description provided for @acctTypeSectionExpense.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get acctTypeSectionExpense;

  /// No description provided for @acctAccountCode.
  ///
  /// In en, this message translates to:
  /// **'Account code'**
  String get acctAccountCode;

  /// No description provided for @acctAccountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get acctAccountNameLabel;

  /// No description provided for @acctAccountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get acctAccountTypeLabel;

  /// No description provided for @acctOpeningBalanceOptional.
  ///
  /// In en, this message translates to:
  /// **'Opening balance (optional)'**
  String get acctOpeningBalanceOptional;

  /// No description provided for @acctDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get acctDescription;

  /// No description provided for @acctDebitAccount.
  ///
  /// In en, this message translates to:
  /// **'Debit account'**
  String get acctDebitAccount;

  /// No description provided for @acctCreditAccount.
  ///
  /// In en, this message translates to:
  /// **'Credit account'**
  String get acctCreditAccount;

  /// No description provided for @acctAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get acctAmount;

  /// No description provided for @acctNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get acctNotesOptional;

  /// No description provided for @acctDepositEntry.
  ///
  /// In en, this message translates to:
  /// **'Deposit entry'**
  String get acctDepositEntry;

  /// No description provided for @acctWithdrawalEntry.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal entry'**
  String get acctWithdrawalEntry;

  /// No description provided for @acctDepositBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Debit Cash · Credit Owner Capital'**
  String get acctDepositBannerSubtitle;

  /// No description provided for @acctWithdrawalBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Debit Owner Drawings · Credit Cash'**
  String get acctWithdrawalBannerSubtitle;

  /// No description provided for @acctWalletAccount.
  ///
  /// In en, this message translates to:
  /// **'Wallet / account'**
  String get acctWalletAccount;

  /// No description provided for @acctPostDeposit.
  ///
  /// In en, this message translates to:
  /// **'Post deposit'**
  String get acctPostDeposit;

  /// No description provided for @acctPostWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Post withdrawal'**
  String get acctPostWithdrawal;

  /// No description provided for @acctDepositPosted.
  ///
  /// In en, this message translates to:
  /// **'Deposit posted'**
  String get acctDepositPosted;

  /// No description provided for @acctWithdrawalPosted.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal posted'**
  String get acctWithdrawalPosted;

  /// No description provided for @acctErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'Error: {detail}'**
  String acctErrorDetail(String detail);

  /// No description provided for @platformSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Stores, owners, emails, plans…'**
  String get platformSearchHint;

  /// No description provided for @platformSearchMinChars.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters'**
  String get platformSearchMinChars;

  /// No description provided for @platformSearchStoresSection.
  ///
  /// In en, this message translates to:
  /// **'Stores ({count})'**
  String platformSearchStoresSection(int count);

  /// No description provided for @platformSearchPlansSection.
  ///
  /// In en, this message translates to:
  /// **'Plans ({count})'**
  String platformSearchPlansSection(int count);

  /// No description provided for @platformSearchNoStores.
  ///
  /// In en, this message translates to:
  /// **'No stores matched'**
  String get platformSearchNoStores;

  /// No description provided for @platformSearchNoPlans.
  ///
  /// In en, this message translates to:
  /// **'No plans matched'**
  String get platformSearchNoPlans;

  /// No description provided for @platformSystemHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'System health'**
  String get platformSystemHealthTitle;

  /// No description provided for @platformEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get platformEdit;

  /// No description provided for @platformErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'Error: {detail}'**
  String platformErrorDetail(String detail);

  /// No description provided for @platformFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get platformFilterAll;

  /// No description provided for @platformFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get platformFilterActive;

  /// No description provided for @platformFilterTrial.
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get platformFilterTrial;

  /// No description provided for @platformFilterExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get platformFilterExpired;

  /// No description provided for @platformFilterSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get platformFilterSuspended;

  /// No description provided for @platformNoStoresMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No stores match this filter'**
  String get platformNoStoresMatchFilter;

  /// No description provided for @platformCreatePlan.
  ///
  /// In en, this message translates to:
  /// **'Create plan'**
  String get platformCreatePlan;

  /// No description provided for @platformEditPlan.
  ///
  /// In en, this message translates to:
  /// **'Edit plan'**
  String get platformEditPlan;

  /// No description provided for @platformPlanIdSlug.
  ///
  /// In en, this message translates to:
  /// **'Plan ID (slug)'**
  String get platformPlanIdSlug;

  /// No description provided for @platformPlanNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get platformPlanNameLabel;

  /// No description provided for @platformPlanMonthlyPrice.
  ///
  /// In en, this message translates to:
  /// **'Monthly price (USD)'**
  String get platformPlanMonthlyPrice;

  /// No description provided for @platformPlanProductLimit.
  ///
  /// In en, this message translates to:
  /// **'Product limit (empty = unlimited)'**
  String get platformPlanProductLimit;

  /// No description provided for @platformPlanUserLimit.
  ///
  /// In en, this message translates to:
  /// **'User limit'**
  String get platformPlanUserLimit;

  /// No description provided for @platformProductsMetric.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get platformProductsMetric;

  /// No description provided for @platformSalesMetric.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get platformSalesMetric;

  /// No description provided for @platformPurchasesMetric.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get platformPurchasesMetric;

  /// No description provided for @platformRevenueMetric.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get platformRevenueMetric;

  /// No description provided for @platformExpensesMetric.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get platformExpensesMetric;

  /// No description provided for @platformCustomersMetric.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get platformCustomersMetric;

  /// No description provided for @platformSuppliersMetric.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get platformSuppliersMetric;

  /// No description provided for @platformUsersMetric.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get platformUsersMetric;

  /// No description provided for @platformDebtsMetric.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get platformDebtsMetric;

  /// No description provided for @platformStorageSection.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get platformStorageSection;

  /// No description provided for @platformOwnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get platformOwnerLabel;

  /// No description provided for @platformPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get platformPhoneLabel;

  /// No description provided for @platformAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get platformAddressLabel;

  /// No description provided for @platformCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get platformCountryLabel;

  /// No description provided for @platformPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get platformPlanLabel;

  /// No description provided for @platformCreatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get platformCreatedLabel;

  /// No description provided for @authBrandTagline.
  ///
  /// In en, this message translates to:
  /// **'Enterprise Resource Planning'**
  String get authBrandTagline;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get authWelcomeBack;

  /// No description provided for @authWelcomeBackHighlight.
  ///
  /// In en, this message translates to:
  /// **'back!'**
  String get authWelcomeBackHighlight;

  /// No description provided for @authWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account and manage your business smarter, faster and easier.'**
  String get authWelcomeMessage;

  /// No description provided for @authSignInTo.
  ///
  /// In en, this message translates to:
  /// **'Sign in to'**
  String get authSignInTo;

  /// No description provided for @authEnterCredentials.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to access your account'**
  String get authEnterCredentials;

  /// No description provided for @authEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get authEmailAddress;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEmailHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get authOrContinueWith;

  /// No description provided for @authNewToBrand.
  ///
  /// In en, this message translates to:
  /// **'New to {brandName}?'**
  String authNewToBrand(String brandName);

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authCreateAccount;

  /// No description provided for @authFeatureSecureTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure & Reliable'**
  String get authFeatureSecureTitle;

  /// No description provided for @authFeatureSecureDesc.
  ///
  /// In en, this message translates to:
  /// **'Bank-level security for your business data'**
  String get authFeatureSecureDesc;

  /// No description provided for @authFeatureFastTitle.
  ///
  /// In en, this message translates to:
  /// **'Fast & Efficient'**
  String get authFeatureFastTitle;

  /// No description provided for @authFeatureFastDesc.
  ///
  /// In en, this message translates to:
  /// **'Optimized performance for daily operations'**
  String get authFeatureFastDesc;

  /// No description provided for @authFeatureAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Analytics'**
  String get authFeatureAnalyticsTitle;

  /// No description provided for @authFeatureAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Real-time insights for better decisions'**
  String get authFeatureAnalyticsDesc;

  /// No description provided for @authFeatureCloudTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get authFeatureCloudTitle;

  /// No description provided for @authFeatureCloudDesc.
  ///
  /// In en, this message translates to:
  /// **'Access your data anytime, anywhere'**
  String get authFeatureCloudDesc;

  /// No description provided for @authLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get authLanguage;

  /// No description provided for @authSocialComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{provider} sign-in coming soon'**
  String authSocialComingSoon(String provider);

  /// No description provided for @authForgotPasswordComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Password reset coming soon'**
  String get authForgotPasswordComingSoon;

  /// No description provided for @authStoreNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your store name'**
  String get authStoreNameHint;

  /// No description provided for @authBusinessTypeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Retail, Wholesale'**
  String get authBusinessTypeHint;

  /// No description provided for @authCountryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ghana'**
  String get authCountryHint;

  /// No description provided for @authCurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. GHS'**
  String get authCurrencyHint;

  /// No description provided for @authAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, city, region'**
  String get authAddressHint;

  /// No description provided for @authFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get authFullNameHint;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get authPhoneHint;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get authConfirmPasswordHint;

  /// No description provided for @invoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoiceTitle;

  /// No description provided for @invoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice #'**
  String get invoiceNumber;

  /// No description provided for @invoiceDate.
  ///
  /// In en, this message translates to:
  /// **'Invoice date'**
  String get invoiceDate;

  /// No description provided for @invoiceDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get invoiceDueDate;

  /// No description provided for @invoiceStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get invoiceStatus;

  /// No description provided for @invoicePaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get invoicePaymentStatus;

  /// No description provided for @invoiceBillTo.
  ///
  /// In en, this message translates to:
  /// **'Bill to'**
  String get invoiceBillTo;

  /// No description provided for @invoiceProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get invoiceProduct;

  /// No description provided for @invoiceSku.
  ///
  /// In en, this message translates to:
  /// **'SKU / Barcode'**
  String get invoiceSku;

  /// No description provided for @invoiceQty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get invoiceQty;

  /// No description provided for @invoiceUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get invoiceUnitPrice;

  /// No description provided for @invoiceDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get invoiceDiscount;

  /// No description provided for @invoiceTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get invoiceTax;

  /// No description provided for @invoiceLineTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get invoiceLineTotal;

  /// No description provided for @invoiceSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get invoiceSubtotal;

  /// No description provided for @invoicePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invoicePaid;

  /// No description provided for @invoiceRemaining.
  ///
  /// In en, this message translates to:
  /// **'Balance due'**
  String get invoiceRemaining;

  /// No description provided for @invoiceGrandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand total'**
  String get invoiceGrandTotal;

  /// No description provided for @invoiceThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your business.'**
  String get invoiceThankYou;

  /// No description provided for @invoiceWalkIn.
  ///
  /// In en, this message translates to:
  /// **'Walk-in customer'**
  String get invoiceWalkIn;

  /// No description provided for @invoicePrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get invoicePrint;

  /// No description provided for @invoiceSharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get invoiceSharePdf;

  /// No description provided for @invoiceViewA4.
  ///
  /// In en, this message translates to:
  /// **'View A4 invoice'**
  String get invoiceViewA4;

  /// No description provided for @invoiceOpenThermal.
  ///
  /// In en, this message translates to:
  /// **'Thermal receipt'**
  String get invoiceOpenThermal;

  /// No description provided for @subscriptionTrialEndsIn.
  ///
  /// In en, this message translates to:
  /// **'Free trial ends in {days} days'**
  String subscriptionTrialEndsIn(int days);

  /// No description provided for @subscriptionExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Your subscription expires in {days} days'**
  String subscriptionExpiresIn(int days);

  /// No description provided for @subscriptionUpgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade now'**
  String get subscriptionUpgradeNow;

  /// No description provided for @subscriptionRenewNow.
  ///
  /// In en, this message translates to:
  /// **'Renew now'**
  String get subscriptionRenewNow;

  /// No description provided for @billingTitle.
  ///
  /// In en, this message translates to:
  /// **'Billing & Subscription'**
  String get billingTitle;

  /// No description provided for @billingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your plan and payment history'**
  String get billingSubtitle;

  /// No description provided for @billingRenewPlan.
  ///
  /// In en, this message translates to:
  /// **'Renew plan'**
  String get billingRenewPlan;

  /// No description provided for @billingUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get billingUpgrade;

  /// No description provided for @billingBuySms.
  ///
  /// In en, this message translates to:
  /// **'Buy SMS'**
  String get billingBuySms;

  /// No description provided for @billingPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get billingPaymentFailed;

  /// No description provided for @billingUnavailableOffline.
  ///
  /// In en, this message translates to:
  /// **'Billing unavailable offline'**
  String get billingUnavailableOffline;

  /// No description provided for @billingViewAllPackages.
  ///
  /// In en, this message translates to:
  /// **'View all packages'**
  String get billingViewAllPackages;

  /// No description provided for @billingChoosePlanBelow.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan below to renew or upgrade'**
  String get billingChoosePlanBelow;

  /// No description provided for @billingSubscribeTo.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to {plan}'**
  String billingSubscribeTo(String plan);

  /// No description provided for @billingPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get billingPerMonth;

  /// No description provided for @billingSmsBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'SMS balance'**
  String get billingSmsBalanceLabel;

  /// No description provided for @billingCycleLabel.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get billingCycleLabel;

  /// No description provided for @billingRemainingSms.
  ///
  /// In en, this message translates to:
  /// **'Remaining SMS: {count}'**
  String billingRemainingSms(int count);

  /// No description provided for @billingNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get billingNoTransactions;

  /// No description provided for @billingPaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get billingPaymentHistory;

  /// No description provided for @billingUpgradePlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade plan'**
  String get billingUpgradePlan;

  /// No description provided for @billingSmsMarketplace.
  ///
  /// In en, this message translates to:
  /// **'SMS marketplace'**
  String get billingSmsMarketplace;

  /// No description provided for @billingChoosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose plan'**
  String get billingChoosePlan;

  /// No description provided for @subscriptionRenewSubscription.
  ///
  /// In en, this message translates to:
  /// **'Renew Subscription'**
  String get subscriptionRenewSubscription;

  /// No description provided for @subscriptionUpgradePlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get subscriptionUpgradePlan;

  /// No description provided for @subscriptionAccountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get subscriptionAccountSettings;

  /// No description provided for @waafiPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Waafi mobile number'**
  String get waafiPhoneLabel;

  /// No description provided for @waafiPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'061… or 25261…'**
  String get waafiPhoneHint;

  /// No description provided for @waafiInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your Waafi mobile number. A payment request will be sent to your phone — enter your PIN to confirm.'**
  String get waafiInstructions;

  /// No description provided for @waafiSendPayment.
  ///
  /// In en, this message translates to:
  /// **'PAY KTS'**
  String get waafiSendPayment;

  /// No description provided for @waafiSendingRequest.
  ///
  /// In en, this message translates to:
  /// **'Sending payment request…'**
  String get waafiSendingRequest;

  /// No description provided for @waafiWaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Waafi confirmation…'**
  String get waafiWaitingConfirmation;

  /// No description provided for @waafiProcessingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing payment…'**
  String get waafiProcessingPayment;

  /// No description provided for @waafiPaymentSentTo.
  ///
  /// In en, this message translates to:
  /// **'A payment request was sent to:\n{phone}'**
  String waafiPaymentSentTo(String phone);

  /// No description provided for @waafiEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Please enter your PIN on your phone.\nThis may take a few seconds.'**
  String get waafiEnterPin;

  /// No description provided for @waafiCancelPayment.
  ///
  /// In en, this message translates to:
  /// **'Cancel payment'**
  String get waafiCancelPayment;

  /// No description provided for @waafiPaymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get waafiPaymentSuccess;

  /// No description provided for @waafiWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet balance: {balance} SMS'**
  String waafiWalletBalance(int balance);

  /// No description provided for @waafiPaymentTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Payment timed out'**
  String get waafiPaymentTimedOut;

  /// No description provided for @waafiPaymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled'**
  String get waafiPaymentCancelled;

  /// No description provided for @waafiPaymentNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Payment not completed'**
  String get waafiPaymentNotCompleted;

  /// No description provided for @waafiPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get waafiPaymentFailed;

  /// No description provided for @waafiNoPinConfirmation.
  ///
  /// In en, this message translates to:
  /// **'No PIN confirmation received.'**
  String get waafiNoPinConfirmation;

  /// No description provided for @waafiPaymentCancelledDefault.
  ///
  /// In en, this message translates to:
  /// **'Payment was cancelled.'**
  String get waafiPaymentCancelledDefault;

  /// No description provided for @waafiTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get waafiTryAgain;

  /// No description provided for @waafiSendingRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Sending payment request to Waafi…'**
  String get waafiSendingRequestStatus;

  /// No description provided for @smsDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'SMS Dashboard'**
  String get smsDashboardTitle;

  /// No description provided for @smsBuyPackage.
  ///
  /// In en, this message translates to:
  /// **'Buy SMS package'**
  String get smsBuyPackage;

  /// No description provided for @smsSendReminder.
  ///
  /// In en, this message translates to:
  /// **'Send debt reminder'**
  String get smsSendReminder;

  /// No description provided for @smsEditTemplates.
  ///
  /// In en, this message translates to:
  /// **'Edit templates'**
  String get smsEditTemplates;

  /// No description provided for @smsTemplatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get smsTemplatesTitle;

  /// No description provided for @smsLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'SMS logs'**
  String get smsLogsTitle;

  /// No description provided for @smsRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get smsRemindersTitle;

  /// No description provided for @smsQueued.
  ///
  /// In en, this message translates to:
  /// **'SMS queued — sending shortly'**
  String get smsQueued;

  /// No description provided for @smsCouldNotQueue.
  ///
  /// In en, this message translates to:
  /// **'Could not queue SMS'**
  String get smsCouldNotQueue;

  /// No description provided for @smsTemplateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get smsTemplateSaved;

  /// No description provided for @smsBuyPackagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy packages'**
  String get smsBuyPackagesTitle;

  /// No description provided for @smsBuyWithWaafi.
  ///
  /// In en, this message translates to:
  /// **'PAY KTS'**
  String get smsBuyWithWaafi;

  /// No description provided for @smsSend.
  ///
  /// In en, this message translates to:
  /// **'Send SMS'**
  String get smsSend;

  /// No description provided for @smsToPhone.
  ///
  /// In en, this message translates to:
  /// **'To: {phone}'**
  String smsToPhone(String phone);

  /// No description provided for @smsEditTemplate.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String smsEditTemplate(String name);

  /// No description provided for @smsReminders3Days.
  ///
  /// In en, this message translates to:
  /// **'3 days before due'**
  String get smsReminders3Days;

  /// No description provided for @smsReminders1Day.
  ///
  /// In en, this message translates to:
  /// **'1 day before due'**
  String get smsReminders1Day;

  /// No description provided for @smsRemindersOnDue.
  ///
  /// In en, this message translates to:
  /// **'On due date'**
  String get smsRemindersOnDue;

  /// No description provided for @smsRemindersOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue reminders'**
  String get smsRemindersOverdue;

  /// No description provided for @smsDailyCap.
  ///
  /// In en, this message translates to:
  /// **'Daily send cap'**
  String get smsDailyCap;

  /// No description provided for @smsDailyCapTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily SMS cap'**
  String get smsDailyCapTitle;

  /// No description provided for @smsBuyPackageButton.
  ///
  /// In en, this message translates to:
  /// **'Buy package'**
  String get smsBuyPackageButton;

  /// No description provided for @invoiceCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get invoiceCompact;

  /// No description provided for @invoiceDetailed.
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get invoiceDetailed;

  /// No description provided for @invoiceStatusBadge.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String invoiceStatusBadge(String status);

  /// No description provided for @invoicePaymentBadge.
  ///
  /// In en, this message translates to:
  /// **'Payment: {status}'**
  String invoicePaymentBadge(String status);

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @smsScheduledReminders.
  ///
  /// In en, this message translates to:
  /// **'Scheduled reminders'**
  String get smsScheduledReminders;

  /// No description provided for @smsScheduledRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automated debt reminders based on due dates'**
  String get smsScheduledRemindersSubtitle;

  /// No description provided for @smsAutomatedReminders.
  ///
  /// In en, this message translates to:
  /// **'Automated reminders'**
  String get smsAutomatedReminders;

  /// No description provided for @smsSendOnDueDates.
  ///
  /// In en, this message translates to:
  /// **'Send SMS on due dates'**
  String get smsSendOnDueDates;

  /// No description provided for @smsPerDay.
  ///
  /// In en, this message translates to:
  /// **'{count} SMS per day'**
  String smsPerDay(int count);

  /// No description provided for @smsMaxPerDay.
  ///
  /// In en, this message translates to:
  /// **'Max SMS per day'**
  String get smsMaxPerDay;

  /// No description provided for @smsReminderHistory.
  ///
  /// In en, this message translates to:
  /// **'Reminder history'**
  String get smsReminderHistory;

  /// No description provided for @smsNoRemindersYet.
  ///
  /// In en, this message translates to:
  /// **'No reminders sent yet'**
  String get smsNoRemindersYet;

  /// No description provided for @smsReminderTypeThreeDays.
  ///
  /// In en, this message translates to:
  /// **'3 days before due'**
  String get smsReminderTypeThreeDays;

  /// No description provided for @smsReminderTypeOneDay.
  ///
  /// In en, this message translates to:
  /// **'1 day before due'**
  String get smsReminderTypeOneDay;

  /// No description provided for @smsReminderTypeDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date reminder'**
  String get smsReminderTypeDueDate;

  /// No description provided for @smsReminderTypeOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue reminder'**
  String get smsReminderTypeOverdue;

  /// No description provided for @smsLogsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery history for your store'**
  String get smsLogsSubtitle;

  /// No description provided for @smsNoSmsSentYet.
  ///
  /// In en, this message translates to:
  /// **'No SMS sent yet'**
  String get smsNoSmsSentYet;

  /// No description provided for @smsTemplatesReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder templates'**
  String get smsTemplatesReminderTitle;

  /// No description provided for @smsTemplatesVariables.
  ///
  /// In en, this message translates to:
  /// **'Template variables: customer_name, store_name, amount, invoice_number, due_date, payment_link'**
  String get smsTemplatesVariables;

  /// No description provided for @smsNoTemplatesYet.
  ///
  /// In en, this message translates to:
  /// **'No templates yet — they are created when your SMS wallet is set up.'**
  String get smsNoTemplatesYet;

  /// No description provided for @smsTemplateHint.
  ///
  /// In en, this message translates to:
  /// **'Use amount, store_name, and other variables in double curly braces'**
  String get smsTemplateHint;

  /// No description provided for @smsBuyPackagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase SMS credits via Waafi Pay — EVC, Zaad, Sahal, WAAFI'**
  String get smsBuyPackagesSubtitle;

  /// No description provided for @smsCloudBalance.
  ///
  /// In en, this message translates to:
  /// **'Cloud balance: {count} SMS'**
  String smsCloudBalance(int count);

  /// No description provided for @smsNoPackagesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No packages available. Contact platform admin.'**
  String get smsNoPackagesAvailable;

  /// No description provided for @healthTitle.
  ///
  /// In en, this message translates to:
  /// **'System health'**
  String get healthTitle;

  /// No description provided for @healthRefreshMetrics.
  ///
  /// In en, this message translates to:
  /// **'Refresh metrics'**
  String get healthRefreshMetrics;

  /// No description provided for @healthRealtime.
  ///
  /// In en, this message translates to:
  /// **'Realtime'**
  String get healthRealtime;

  /// No description provided for @healthSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get healthSync;

  /// No description provided for @healthQueue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get healthQueue;

  /// No description provided for @healthQueueRetries.
  ///
  /// In en, this message translates to:
  /// **'{count} with retries'**
  String healthQueueRetries(int count);

  /// No description provided for @healthNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get healthNetwork;

  /// No description provided for @healthOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get healthOnline;

  /// No description provided for @healthOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get healthOffline;

  /// No description provided for @healthSyncTimeline.
  ///
  /// In en, this message translates to:
  /// **'Sync timeline'**
  String get healthSyncTimeline;

  /// No description provided for @healthLastPull.
  ///
  /// In en, this message translates to:
  /// **'Last pull'**
  String get healthLastPull;

  /// No description provided for @healthLastPush.
  ///
  /// In en, this message translates to:
  /// **'Last push'**
  String get healthLastPush;

  /// No description provided for @healthLastSuccess.
  ///
  /// In en, this message translates to:
  /// **'Last successful sync'**
  String get healthLastSuccess;

  /// No description provided for @healthLastError.
  ///
  /// In en, this message translates to:
  /// **'Last error'**
  String get healthLastError;

  /// No description provided for @healthCloudConfigured.
  ///
  /// In en, this message translates to:
  /// **'Cloud configured'**
  String get healthCloudConfigured;

  /// No description provided for @healthYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get healthYes;

  /// No description provided for @healthNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get healthNo;

  /// No description provided for @healthBackgroundScheduler.
  ///
  /// In en, this message translates to:
  /// **'Background scheduler'**
  String get healthBackgroundScheduler;

  /// No description provided for @healthRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get healthRunning;

  /// No description provided for @healthInterval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get healthInterval;

  /// No description provided for @healthLastCycle.
  ///
  /// In en, this message translates to:
  /// **'Last cycle'**
  String get healthLastCycle;

  /// No description provided for @healthInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get healthInProgress;

  /// No description provided for @healthLocalDatabase.
  ///
  /// In en, this message translates to:
  /// **'Local database'**
  String get healthLocalDatabase;

  /// No description provided for @healthCachedProducts.
  ///
  /// In en, this message translates to:
  /// **'Cached products'**
  String get healthCachedProducts;

  /// No description provided for @healthDbFileSize.
  ///
  /// In en, this message translates to:
  /// **'DB file size'**
  String get healthDbFileSize;

  /// No description provided for @healthDbFileSizeWeb.
  ///
  /// In en, this message translates to:
  /// **'N/A (web)'**
  String get healthDbFileSizeWeb;

  /// No description provided for @healthDbFileSizeMb.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String healthDbFileSizeMb(String size);

  /// No description provided for @healthQueueMaxRetries.
  ///
  /// In en, this message translates to:
  /// **'Queue at max retries'**
  String get healthQueueMaxRetries;

  /// No description provided for @healthQueueInspector.
  ///
  /// In en, this message translates to:
  /// **'Queue inspector'**
  String get healthQueueInspector;

  /// No description provided for @healthOpenFullQueue.
  ///
  /// In en, this message translates to:
  /// **'Open full queue'**
  String get healthOpenFullQueue;

  /// No description provided for @healthQueueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Queue is empty'**
  String get healthQueueEmpty;

  /// No description provided for @healthRecoveryActions.
  ///
  /// In en, this message translates to:
  /// **'Recovery actions'**
  String get healthRecoveryActions;

  /// No description provided for @healthRecoverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use when support needs to recover sync without blocking POS.'**
  String get healthRecoverySubtitle;

  /// No description provided for @healthRetryFailedSync.
  ///
  /// In en, this message translates to:
  /// **'Retry failed sync'**
  String get healthRetryFailedSync;

  /// No description provided for @healthForceFullSync.
  ///
  /// In en, this message translates to:
  /// **'Force full sync'**
  String get healthForceFullSync;

  /// No description provided for @healthClearHydrationCache.
  ///
  /// In en, this message translates to:
  /// **'Clear hydration cache'**
  String get healthClearHydrationCache;

  /// No description provided for @healthRebuildIndexes.
  ///
  /// In en, this message translates to:
  /// **'Rebuild local indexes'**
  String get healthRebuildIndexes;

  /// No description provided for @healthQaValidation.
  ///
  /// In en, this message translates to:
  /// **'QA validation'**
  String get healthQaValidation;

  /// No description provided for @healthRealtimeEventLog.
  ///
  /// In en, this message translates to:
  /// **'Realtime event log'**
  String get healthRealtimeEventLog;

  /// No description provided for @healthAllOperational.
  ///
  /// In en, this message translates to:
  /// **'All systems operational'**
  String get healthAllOperational;

  /// No description provided for @healthSyncInProgress.
  ///
  /// In en, this message translates to:
  /// **'Sync in progress'**
  String get healthSyncInProgress;

  /// No description provided for @healthAttentionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Attention needed'**
  String get healthAttentionNeeded;

  /// No description provided for @healthOfflineLocalMode.
  ///
  /// In en, this message translates to:
  /// **'Offline — local mode'**
  String get healthOfflineLocalMode;

  /// No description provided for @healthBadgeHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthBadgeHealthy;

  /// No description provided for @healthBadgeActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get healthBadgeActive;

  /// No description provided for @healthBadgeReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get healthBadgeReview;

  /// No description provided for @healthBadgeOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get healthBadgeOffline;

  /// No description provided for @healthBadgeIdle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get healthBadgeIdle;

  /// No description provided for @healthQueuedRetryingRealtime.
  ///
  /// In en, this message translates to:
  /// **'{queued} queued · {retrying} retrying · Realtime {realtime}'**
  String healthQueuedRetryingRealtime(
    int queued,
    int retrying,
    String realtime,
  );

  /// No description provided for @healthOfflineSalesStored.
  ///
  /// In en, this message translates to:
  /// **'Sales and inventory updates are stored on this device.'**
  String get healthOfflineSalesStored;

  /// No description provided for @healthRetryingFailedSync.
  ///
  /// In en, this message translates to:
  /// **'Retrying failed sync items'**
  String get healthRetryingFailedSync;

  /// No description provided for @healthFullSyncCompleted.
  ///
  /// In en, this message translates to:
  /// **'Full sync completed'**
  String get healthFullSyncCompleted;

  /// No description provided for @healthHydrationCleared.
  ///
  /// In en, this message translates to:
  /// **'Hydration cache cleared — next sync will pull fresh data'**
  String get healthHydrationCleared;

  /// No description provided for @healthIndexesRebuilt.
  ///
  /// In en, this message translates to:
  /// **'Local indexes rebuilt'**
  String get healthIndexesRebuilt;

  /// No description provided for @healthErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'Error: {detail}'**
  String healthErrorDetail(String detail);

  /// No description provided for @healthRealtimeConnected.
  ///
  /// In en, this message translates to:
  /// **'connected'**
  String get healthRealtimeConnected;

  /// No description provided for @healthRealtimeReconnecting.
  ///
  /// In en, this message translates to:
  /// **'reconnecting'**
  String get healthRealtimeReconnecting;

  /// No description provided for @healthRealtimeDisconnected.
  ///
  /// In en, this message translates to:
  /// **'disconnected'**
  String get healthRealtimeDisconnected;

  /// No description provided for @healthRealtimeFailed.
  ///
  /// In en, this message translates to:
  /// **'failed'**
  String get healthRealtimeFailed;

  /// No description provided for @healthSecondsShort.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String healthSecondsShort(int seconds);

  /// No description provided for @aiRiskNegativeProfit.
  ///
  /// In en, this message translates to:
  /// **'Negative profit'**
  String get aiRiskNegativeProfit;

  /// No description provided for @aiRiskNegativeProfitMsg.
  ///
  /// In en, this message translates to:
  /// **'This month profit is below zero. Review expenses ({pct}% of sales) and margins.'**
  String aiRiskNegativeProfitMsg(String pct);

  /// No description provided for @aiRiskThinMargin.
  ///
  /// In en, this message translates to:
  /// **'Thin profit margin'**
  String get aiRiskThinMargin;

  /// No description provided for @aiRiskThinMarginMsg.
  ///
  /// In en, this message translates to:
  /// **'Profit margin is {pct}%. Consider pricing or cost control.'**
  String aiRiskThinMarginMsg(String pct);

  /// No description provided for @aiRiskSalesDeclining.
  ///
  /// In en, this message translates to:
  /// **'Sales declining'**
  String get aiRiskSalesDeclining;

  /// No description provided for @aiRiskSalesDecliningMsg.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days sales are {pct}% vs the previous 7 days.'**
  String aiRiskSalesDecliningMsg(String pct);

  /// No description provided for @aiRiskHighExpense.
  ///
  /// In en, this message translates to:
  /// **'High expense ratio'**
  String get aiRiskHighExpense;

  /// No description provided for @aiRiskHighExpenseMsg.
  ///
  /// In en, this message translates to:
  /// **'Expenses are {pct}% of revenue this month.'**
  String aiRiskHighExpenseMsg(String pct);

  /// No description provided for @aiRiskLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock alerts'**
  String get aiRiskLowStock;

  /// No description provided for @aiRiskLowStockMsg.
  ///
  /// In en, this message translates to:
  /// **'{count} product(s) at or below minimum stock.'**
  String aiRiskLowStockMsg(int count);

  /// No description provided for @aiRiskSlowMoving.
  ///
  /// In en, this message translates to:
  /// **'Slow-moving inventory'**
  String get aiRiskSlowMoving;

  /// No description provided for @aiRiskSlowMovingMsg.
  ///
  /// In en, this message translates to:
  /// **'{count} products had no sales in the last 30 days but still hold stock.'**
  String aiRiskSlowMovingMsg(int count);

  /// No description provided for @aiRiskHighDebt.
  ///
  /// In en, this message translates to:
  /// **'High customer debt'**
  String get aiRiskHighDebt;

  /// No description provided for @aiRiskHighDebtMsg.
  ///
  /// In en, this message translates to:
  /// **'Outstanding customer debt exceeds this month\'s sales.'**
  String get aiRiskHighDebtMsg;

  /// No description provided for @aiRiskOverdueDebts.
  ///
  /// In en, this message translates to:
  /// **'Overdue debts'**
  String get aiRiskOverdueDebts;

  /// No description provided for @aiRiskOverdueDebtsMsg.
  ///
  /// In en, this message translates to:
  /// **'{count} debt(s) are past due — follow up collections.'**
  String aiRiskOverdueDebtsMsg(int count);

  /// No description provided for @aiRiskOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get aiRiskOutOfStock;

  /// No description provided for @aiRiskOutOfStockMsg.
  ///
  /// In en, this message translates to:
  /// **'{count} SKU(s) are out of stock.'**
  String aiRiskOutOfStockMsg(int count);

  /// No description provided for @platformSmsPackagesTitle.
  ///
  /// In en, this message translates to:
  /// **'SMS Packages'**
  String get platformSmsPackagesTitle;

  /// No description provided for @platformSmsPackagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Marketplace catalog — stores purchase via Waafi Pay'**
  String get platformSmsPackagesSubtitle;

  /// No description provided for @platformNewPackage.
  ///
  /// In en, this message translates to:
  /// **'New package'**
  String get platformNewPackage;

  /// No description provided for @platformCreateSmsPackage.
  ///
  /// In en, this message translates to:
  /// **'Create SMS package'**
  String get platformCreateSmsPackage;

  /// No description provided for @platformEditSmsPackage.
  ///
  /// In en, this message translates to:
  /// **'Edit package'**
  String get platformEditSmsPackage;

  /// No description provided for @platformSmsPackageId.
  ///
  /// In en, this message translates to:
  /// **'ID slug'**
  String get platformSmsPackageId;

  /// No description provided for @platformSmsPackageName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get platformSmsPackageName;

  /// No description provided for @platformSmsPackageCount.
  ///
  /// In en, this message translates to:
  /// **'SMS count'**
  String get platformSmsPackageCount;

  /// No description provided for @platformSmsPackagePrice.
  ///
  /// In en, this message translates to:
  /// **'Price (USD)'**
  String get platformSmsPackagePrice;

  /// No description provided for @platformStoreSubscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Store Subscriptions'**
  String get platformStoreSubscriptionsTitle;

  /// No description provided for @platformStoreSubscriptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All tenant subscriptions across KULMIS ERP'**
  String get platformStoreSubscriptionsSubtitle;

  /// No description provided for @platformStoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get platformStoreLabel;

  /// No description provided for @platformTrial.
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get platformTrial;

  /// No description provided for @platformPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get platformPaid;

  /// No description provided for @platformSmsWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'Store SMS Wallets'**
  String get platformSmsWalletsTitle;

  /// No description provided for @platformSmsWalletsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud SMS credit balances per store'**
  String get platformSmsWalletsSubtitle;

  /// No description provided for @platformSmsUsedPurchased.
  ///
  /// In en, this message translates to:
  /// **'Used: {used} • Purchased: {purchased}'**
  String platformSmsUsedPurchased(int used, int purchased);

  /// No description provided for @platformSmsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} SMS'**
  String platformSmsRemaining(int count);

  /// No description provided for @platformTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Transactions'**
  String get platformTransactionsTitle;

  /// No description provided for @platformTransactionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Waafi and future gateway payments'**
  String get platformTransactionsSubtitle;

  /// No description provided for @platformPaymentGatewayTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Gateway'**
  String get platformPaymentGatewayTitle;

  /// No description provided for @platformPaymentGatewaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Waafi Pay configuration — credentials via Supabase secrets'**
  String get platformPaymentGatewaySubtitle;

  /// No description provided for @platformWaafiEnabled.
  ///
  /// In en, this message translates to:
  /// **'Waafi Pay enabled'**
  String get platformWaafiEnabled;

  /// No description provided for @platformWaafiSandbox.
  ///
  /// In en, this message translates to:
  /// **'Waafi sandbox mode'**
  String get platformWaafiSandbox;

  /// No description provided for @platformNoSettings.
  ///
  /// In en, this message translates to:
  /// **'No settings'**
  String get platformNoSettings;

  /// No description provided for @platformGatewaySecretsHelp.
  ///
  /// In en, this message translates to:
  /// **'Set secrets via CLI:\nWAAFI_MERCHANT_UID, WAAFI_API_USER_ID, WAAFI_API_KEY\nWAAFI_SANDBOX=true, WAAFI_DEV_MODE=true (simulate payments)\nPAYMENT_WEBHOOK_SECRET'**
  String get platformGatewaySecretsHelp;

  /// No description provided for @platformTrialSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trial Settings'**
  String get platformTrialSettingsTitle;

  /// No description provided for @platformTrialSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Default free trial and grace period for new stores'**
  String get platformTrialSettingsSubtitle;

  /// No description provided for @platformDefaultTrialDays.
  ///
  /// In en, this message translates to:
  /// **'Default trial days'**
  String get platformDefaultTrialDays;

  /// No description provided for @platformGracePeriod.
  ///
  /// In en, this message translates to:
  /// **'Grace period after expiry'**
  String get platformGracePeriod;

  /// No description provided for @platformDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String platformDaysCount(int count);

  /// No description provided for @platformTrialDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Trial days'**
  String get platformTrialDaysTitle;

  /// No description provided for @platformGracePeriodDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Grace period days'**
  String get platformGracePeriodDaysTitle;

  /// No description provided for @platformDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get platformDaysLabel;

  /// No description provided for @platformRevenueAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue Analytics'**
  String get platformRevenueAnalyticsTitle;

  /// No description provided for @platformRevenueAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Collected revenue, MRR, trials, and SMS sales'**
  String get platformRevenueAnalyticsSubtitle;

  /// No description provided for @platformTotalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total revenue'**
  String get platformTotalRevenue;

  /// No description provided for @platformSubscriptionRevenue.
  ///
  /// In en, this message translates to:
  /// **'Subscription revenue'**
  String get platformSubscriptionRevenue;

  /// No description provided for @platformSmsRevenue.
  ///
  /// In en, this message translates to:
  /// **'SMS revenue'**
  String get platformSmsRevenue;

  /// No description provided for @platformMrrContracted.
  ///
  /// In en, this message translates to:
  /// **'MRR (contracted)'**
  String get platformMrrContracted;

  /// No description provided for @platformActiveSubs.
  ///
  /// In en, this message translates to:
  /// **'Active subs'**
  String get platformActiveSubs;

  /// No description provided for @platformTrialing.
  ///
  /// In en, this message translates to:
  /// **'Trialing'**
  String get platformTrialing;

  /// No description provided for @platformTrialsExpiring7d.
  ///
  /// In en, this message translates to:
  /// **'Trials expiring (7d)'**
  String get platformTrialsExpiring7d;

  /// No description provided for @platformFailedPayments30d.
  ///
  /// In en, this message translates to:
  /// **'Failed payments (30d)'**
  String get platformFailedPayments30d;

  /// No description provided for @platformOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'OTP Infrastructure'**
  String get platformOtpTitle;

  /// No description provided for @platformOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Central auth verification — multi-app branding, Hormuud delivery, rate limits'**
  String get platformOtpSubtitle;

  /// No description provided for @platformOtpSentToday.
  ///
  /// In en, this message translates to:
  /// **'Sent today'**
  String get platformOtpSentToday;

  /// No description provided for @platformOtpVerifiedToday.
  ///
  /// In en, this message translates to:
  /// **'Verified today'**
  String get platformOtpVerifiedToday;

  /// No description provided for @platformOtpFailedToday.
  ///
  /// In en, this message translates to:
  /// **'Failed today'**
  String get platformOtpFailedToday;

  /// No description provided for @platformOtpPending.
  ///
  /// In en, this message translates to:
  /// **'Pending (active)'**
  String get platformOtpPending;

  /// No description provided for @platformAppBranding.
  ///
  /// In en, this message translates to:
  /// **'App branding'**
  String get platformAppBranding;

  /// No description provided for @platformAppBrandingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'KULMIS ERP (kulmis-erp) — templates in otp_apps table. Add more apps for KULMIS PAY and other SaaS products.'**
  String get platformAppBrandingSubtitle;

  /// No description provided for @platformRealtimeStatus.
  ///
  /// In en, this message translates to:
  /// **'Realtime status'**
  String get platformRealtimeStatus;

  /// No description provided for @platformWebsocketHealth.
  ///
  /// In en, this message translates to:
  /// **'Websocket health'**
  String get platformWebsocketHealth;

  /// No description provided for @platformFailedPayments24h.
  ///
  /// In en, this message translates to:
  /// **'Failed payments (24h)'**
  String get platformFailedPayments24h;

  /// No description provided for @platformFailedSms24h.
  ///
  /// In en, this message translates to:
  /// **'Failed SMS (24h)'**
  String get platformFailedSms24h;

  /// No description provided for @platformEventLog.
  ///
  /// In en, this message translates to:
  /// **'Event log'**
  String get platformEventLog;

  /// No description provided for @platformSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get platformSearchButton;

  /// No description provided for @platformStoresSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Store name, owner, email…'**
  String get platformStoresSearchHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'so'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'so':
      return AppLocalizationsSo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
