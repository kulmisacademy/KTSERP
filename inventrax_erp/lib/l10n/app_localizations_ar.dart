// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'KULMIS ERP';

  @override
  String get brandName => 'KULMIS ERP';

  @override
  String get navDashboard => 'لوحة التحكم';

  @override
  String get navPos => 'نقطة البيع';

  @override
  String get navCustomSales => 'مبيعات مخصصة';

  @override
  String get navDraftInvoices => 'مسودات الفواتير';

  @override
  String get navSalesHistory => 'سجل المبيعات';

  @override
  String get navSales => 'سجل المبيعات';

  @override
  String get navProducts => 'المنتجات';

  @override
  String get navCategories => 'الفئات';

  @override
  String get navBrands => 'العلامات';

  @override
  String get navInventory => 'المخزون';

  @override
  String get navPurchases => 'المشتريات';

  @override
  String get navAddPurchase => 'إضافة شراء';

  @override
  String get navCustomers => 'العملاء';

  @override
  String get navSuppliers => 'الموردون';

  @override
  String get navDebts => 'الديون';

  @override
  String get navExpenses => 'المصروفات';

  @override
  String get navAccounting => 'المحاسبة';

  @override
  String get navReports => 'التقارير';

  @override
  String get navAiInsights => 'رؤى الذكاء الاصطناعي';

  @override
  String get navNotifications => 'الإشعارات';

  @override
  String get navSync => 'المزامنة';

  @override
  String get navUserManagement => 'إدارة المستخدمين';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navPurchaseHistory => 'سجل المشتريات';

  @override
  String get navReceiveStock => 'شراء';

  @override
  String get languageTitle => 'اللغة';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageSomali => 'الصومالية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglishNative => 'English';

  @override
  String get languageSomaliNative => 'Soomaali';

  @override
  String get languageArabicNative => 'العربية';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get appearanceTitle => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get localizationTitle => 'التوطين';

  @override
  String get currencyLabel => 'العملة';

  @override
  String get saveSettings => 'حفظ الإعدادات';

  @override
  String get savingSettings => 'جارٍ الحفظ…';

  @override
  String get settingsSaved => 'تم حفظ الإعدادات';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get notSignedIn => 'غير مسجل الدخول';

  @override
  String get syncOffline => 'غير متصل';

  @override
  String get syncSyncing => 'مزامنة';

  @override
  String get syncQueue => 'قائمة';

  @override
  String get syncLive => 'مباشر';

  @override
  String get syncConnected => 'متصل';

  @override
  String get syncReconnecting => 'إعادة الاتصال';

  @override
  String get syncOfflineMode => 'وضع عدم الاتصال';

  @override
  String get syncOfflineBanner =>
      'وضع عدم الاتصال — البيع والتعديلات تعمل محلياً. ستتم المزامنة عند عودة الاتصال.';

  @override
  String syncQueueBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تغييرات بانتظار المزامنة',
      one: 'تغيير واحد بانتظار المزامنة',
    );
    return '$_temp0';
  }

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get details => 'التفاصيل';

  @override
  String get metricSyncQueue => 'قائمة المزامنة';

  @override
  String get openPos => 'فتح نقطة البيع';

  @override
  String get walkIn => 'زائر';

  @override
  String get paymentLabel => 'الدفع';

  @override
  String get splitPayment => 'مقسم';

  @override
  String get filterToday => 'اليوم';

  @override
  String get filterWeek => 'أسبوع';

  @override
  String get filterMonth => 'شهر';

  @override
  String get filterCustom => 'مخصص';

  @override
  String get filterAll => 'الكل';

  @override
  String get salesRangeToday => 'اليوم';

  @override
  String get salesRangeWeek => 'آخر 7 أيام';

  @override
  String get salesRangeMonth => 'هذا الشهر';

  @override
  String get salesRangeCustom => 'نطاق مخصص';

  @override
  String get statusPaid => 'مدفوع';

  @override
  String get statusPartial => 'جزئي';

  @override
  String get statusUnpaid => 'غير مدفوع';

  @override
  String get statusRefunded => 'مسترد';

  @override
  String get statusVoided => 'ملغى';

  @override
  String get netRevenue => 'صافي الإيرادات';

  @override
  String get transactions => 'المعاملات';

  @override
  String get unpaidCount => 'غير مدفوع';

  @override
  String get salesSearchHint => 'فاتورة، عميل، باركود…';

  @override
  String get noMatchingSales => 'لا توجد مبيعات مطابقة';

  @override
  String get noMatchingSalesSubtitle =>
      'جرّب فلتراً آخر أو سجّل بيعاً من نقطة البيع.';

  @override
  String get colInvoice => 'رقم الفاتورة';

  @override
  String get colCustomer => 'العميل';

  @override
  String get colStatus => 'الحالة';

  @override
  String get colTotal => 'الإجمالي';

  @override
  String get colPayment => 'الدفع';

  @override
  String get colDate => 'التاريخ';

  @override
  String get colActions => 'إجراءات';

  @override
  String get voidSaleTitle => 'إلغاء البيع؟';

  @override
  String get voidSaleBody => 'يستعيد المخزون ويزيل البيع من الإجماليات.';

  @override
  String get reason => 'السبب';

  @override
  String get voidAction => 'إلغاء';

  @override
  String get saleVoidedSnack => 'تم إلغاء البيع — استُعيد المخزون';

  @override
  String get partialRefundTitle => 'استرداد جزئي';

  @override
  String get qty => 'الكمية';

  @override
  String get refundAction => 'استرداد';

  @override
  String get nothingToRefund => 'لا يوجد ما يُسترد';

  @override
  String refundedAmountSnack(String amount) {
    return 'تم استرداد $amount — استُعيد المخزون';
  }

  @override
  String get noItemsRefunded => 'لم يُسترد أي صنف';

  @override
  String get printAction => 'طباعة';

  @override
  String get catalogAndPricing => 'الكتالوج والتسعير';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get searchProducts => 'بحث بالاسم، SKU، باركود…';

  @override
  String get searchCustomersHint => 'بحث بالاسم أو الهاتف…';

  @override
  String get noProducts => 'لا توجد منتجات بعد';

  @override
  String get noProductsSubtitle => 'أضف أول منتج أو استورد من جدول.';

  @override
  String get noExpenses => 'لا توجد مصروفات بعد';

  @override
  String get noExpensesSubtitle => 'تتبع الإيجار والمرافق وتكاليف التشغيل.';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get noNotifications => 'لا إشعارات';

  @override
  String get noNotificationsSubtitle =>
      'تنبيهات المخزون والديون والنظام تظهر هنا.';

  @override
  String get noCustomers => 'لا عملاء بعد';

  @override
  String get noCustomersSubtitle => 'أضف عملاء لتتبع الديون وسجل المبيعات.';

  @override
  String get addCustomer => 'إضافة عميل';

  @override
  String get noSuppliers => 'لا موردين بعد';

  @override
  String get noSuppliersSubtitle => 'أضف موردين للمشتريات والذمم.';

  @override
  String get addSupplier => 'إضافة مورد';

  @override
  String get noDebts => 'لا ديون مفتوحة';

  @override
  String get noDebtsSubtitle => 'أرصدة العملاء والموردين تظهر هنا.';

  @override
  String get noCustomerDebts => 'لا ديون عملاء';

  @override
  String get noCustomerDebtsSubtitle =>
      'مبيعات الآجل أو الجزئية من نقطة البيع تظهر هنا.';

  @override
  String get noSupplierPayables => 'لا ذمم موردين';

  @override
  String get noSupplierPayablesSubtitle =>
      'المشتريات الآجلة أو الجزئية تظهر هنا.';

  @override
  String get recordPayment => 'تسجيل دفعة';

  @override
  String get noInventory => 'لا حركات مخزون';

  @override
  String get noInventorySubtitle => 'المشتريات والتعديلات تحدّث المخزون هنا.';

  @override
  String get noCategories => 'لا فئات بعد';

  @override
  String get noCategoriesSubtitle => 'نظّم المنتجات بالفئات.';

  @override
  String get noBrands => 'لا علامات بعد';

  @override
  String get noBrandsSubtitle => 'جمّع المنتجات حسب العلامة.';

  @override
  String get noPurchases => 'لا مشتريات بعد';

  @override
  String get noPurchasesSubtitle => 'اشترِ من الموردين للبدء.';

  @override
  String get receiveStock => 'شراء';

  @override
  String get loginTitle => 'مرحباً بعودتك';

  @override
  String get loginSubtitle =>
      'سجّل الدخول لإدارة المخزون ونقطة البيع والتقارير.';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get createStore => 'إنشاء متجر';

  @override
  String get reportsExport => 'تصدير';

  @override
  String get reportsProfitLoss => 'الأرباح والخسائر';

  @override
  String get reportsSales => 'تقرير المبيعات';

  @override
  String get posCart => 'السلة';

  @override
  String get posCheckout => 'الدفع';

  @override
  String get posHold => 'تعليق';

  @override
  String get posClear => 'مسح';

  @override
  String get posSearchProducts => 'بحث أو مسح باركود…';

  @override
  String get posEmptyCart => 'السلة فارغة';

  @override
  String get posEmptyCartSubtitle => 'امسح باركوداً أو اختر منتجاً للبدء.';

  @override
  String get posTotal => 'الإجمالي';

  @override
  String get posDiscount => 'خصم';

  @override
  String get posTax => 'ضريبة';

  @override
  String get posPay => 'ادفع';

  @override
  String get posCompleteSale => 'إتمام البيع';

  @override
  String get accountingOverview => 'دليل الحسابات والقيود والتقارير المالية';

  @override
  String get aiInsightsTitle => 'رؤى الذكاء الاصطناعي';

  @override
  String get aiPoweredBy => 'مدعوم من OpenAI';

  @override
  String get aiConfigureKey => 'قواعد دون اتصال + أضف OPENAI_API_KEY';

  @override
  String get aiClearChat => 'مسح المحادثة';

  @override
  String get aiAnalyzing => 'جارٍ تحليل بيانات عملك…';

  @override
  String get aiEmptyHint =>
      'اسأل عن المبيعات أو الربح أو المخزون أو الديون أو المصروفات.\nيتم التحليل محلياً — الملخصات فقط تُرسل إلى OpenAI.';

  @override
  String get aiInputHint => 'اسأل عن المبيعات أو الربح أو المخزون أو الديون…';

  @override
  String get aiLiveAnalytics => 'تحليلات مباشرة';

  @override
  String get aiWarnings => 'تحذيرات';

  @override
  String get aiRecommendations => 'توصيات';

  @override
  String get aiOpportunities => 'فرص';

  @override
  String aiMonthSummary(String sales, String profit, int alerts) {
    return 'مبيعات الشهر $sales • الربح $profit • $alerts تنبيه';
  }

  @override
  String get aiPromptSalesSummary => 'أعطني ملخص مبيعات وربح هذا الشهر';

  @override
  String get aiPromptCompareWeeks => 'قارن آخر 7 أيام مع الـ 7 السابقة';

  @override
  String get aiPromptTopProducts => 'ما أكثر المنتجات مبيعاً؟';

  @override
  String get aiPromptRisks => 'ما أكبر مخاطر عملي؟';

  @override
  String get aiPromptExpenses => 'حلل المصروفات واقترح تخفيضات';

  @override
  String get aiPromptDebts => 'من يدين بأكبر مبلغ؟';

  @override
  String get aiPromptSlowStock => 'أي مخزون بطيء الحركة؟';

  @override
  String get aiPromptForecast => 'توقع الشهر القادم بناءً على الاتجاهات';

  @override
  String get aiRateLimit =>
      'يرجى الانتظار بضع ثوانٍ بين طلبات الذكاء الاصطناعي.';

  @override
  String get errorNetwork =>
      'تعذر الوصول إلى الخادم. تم حفظ تغييراتك محلياً وستُزامَن عند عودة الاتصال.';

  @override
  String get errorTimeout =>
      'استغرق ذلك وقتاً طويلاً. حاول مرة أخرى — بياناتك المحلية آمنة.';

  @override
  String get errorPermission =>
      'ليس لديك إذن لهذا الإجراء. اطلب من مدير المتجر إذا لزم الأمر.';

  @override
  String get errorDuplicate =>
      'هذا السجل موجود مسبقاً. تحقق من الباركود أو SKU أو الاسم.';

  @override
  String get errorSync =>
      'تعذرت المزامنة الآن. التغييرات في قائمة الانتظار وستُعاد المحاولة تلقائياً.';

  @override
  String get errorDatabase =>
      'حدث خطأ في الحفظ المحلي. حاول مرة أخرى أو اتصل بالدعم.';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String errorLoadAnalytics(String message) {
    return 'تعذر تحميل التحليلات: $message';
  }

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonLoading => 'جارٍ التحميل…';

  @override
  String get commonNoData => 'لا توجد بيانات بعد';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonRefresh => 'تحديث';

  @override
  String get commonAdd => 'إضافة';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonNoMatches => 'لا توجد نتائج';

  @override
  String get commonTryDifferentSearch => 'جرّب بحثاً مختلفاً.';

  @override
  String get commonDone => 'تم';

  @override
  String get commonApply => 'تطبيق';

  @override
  String get commonChange => 'تغيير';

  @override
  String get commonViewAll => 'عرض الكل';

  @override
  String commonErrorWithDetail(String detail) {
    return 'خطأ: $detail';
  }

  @override
  String get commonYes => 'نعم';

  @override
  String get commonNo => 'لا';

  @override
  String get commonName => 'الاسم';

  @override
  String get commonPhone => 'الهاتف';

  @override
  String get commonNotes => 'ملاحظات';

  @override
  String get commonQuantity => 'الكمية';

  @override
  String get commonPrice => 'السعر';

  @override
  String get commonTotal => 'الإجمالي';

  @override
  String get commonSubtotal => 'المجموع الفرعي';

  @override
  String get commonScan => 'مسح';

  @override
  String get commonPrint => 'طباعة';

  @override
  String get commonExport => 'تصدير';

  @override
  String get commonImport => 'استيراد';

  @override
  String get commonFilter => 'تصفية';

  @override
  String get commonAllStatuses => 'كل الحالات';

  @override
  String get commonRequired => 'مطلوب';

  @override
  String get commonOptional => 'اختياري';

  @override
  String get posDirectSale => 'بيع مباشر';

  @override
  String get posAddToCart => 'أضف إلى السلة';

  @override
  String posCheckoutError(String detail) {
    return 'خطأ في الدفع: $detail';
  }

  @override
  String get posSaleComplete => 'اكتمل البيع';

  @override
  String get posPrintReceipt => 'طباعة الإيصال';

  @override
  String get posHoldSale => 'تعليق البيع';

  @override
  String get posSaleHeld => 'تم تعليق البيع — تم مسح السلة';

  @override
  String get posQuickAddCustomer => 'إضافة عميل سريعة';

  @override
  String get posNoCustomer => 'بدون عميل';

  @override
  String get posNewCustomer => 'عميل جديد';

  @override
  String get posNoHeldSales => 'لا مبيعات معلقة';

  @override
  String get posHeldSales => 'مبيعات معلقة';

  @override
  String get posProductAdded => 'تمت إضافة المنتج';

  @override
  String posEditPrice(String name) {
    return 'تعديل السعر · $name';
  }

  @override
  String get posPriceOverrideDisabled => 'تعديل السعر معطّل في الإعدادات';

  @override
  String get posOrderDiscount => 'خصم الطلب';

  @override
  String get posAddDiscount => 'إضافة خصم';

  @override
  String get posCheckoutShortcut => 'الدفع · F10';

  @override
  String get posQuickAddProduct => 'إضافة منتج سريعة';

  @override
  String posCartItems(int count) {
    return '$count أصناف';
  }

  @override
  String get posChangeCustomer => 'تغيير العميل';

  @override
  String get posMobileCart => 'السلة';

  @override
  String get posItemName => 'اسم الصنف';

  @override
  String posSaleCompletedSummary(String summary) {
    return 'اكتمل البيع ($summary)';
  }

  @override
  String get posLabelOptional => 'تسمية (اختياري)';

  @override
  String get posLabelHint => 'مثال: عميل في الانتظار';

  @override
  String get posHeldRestored => 'تم استعادة البيع المعلق';

  @override
  String get posClearCartFirst => 'أفرغ السلة أولاً للاستعادة';

  @override
  String get dashboardWelcome => 'مرحباً بعودتك';

  @override
  String get dashboardTodaySales => 'مبيعات اليوم';

  @override
  String get dashboardMonthProfit => 'ربح الشهر';

  @override
  String get dashboardLowStock => 'مخزون منخفض';

  @override
  String get dashboardOpenPos => 'فتح نقطة البيع';

  @override
  String get dashboardNoSalesYet => 'لا مبيعات بعد — افتح نقطة البيع للبدء';

  @override
  String get dashboardSalesLast7Days => 'المبيعات · 7 أيام';

  @override
  String get dashboardDailyRevenue => 'الإيراد اليومي';

  @override
  String dashboardChartError(String detail) {
    return 'خطأ في الرسم: $detail';
  }

  @override
  String get dashboardNoSalesRecorded => 'لم تُسجّل مبيعات بعد';

  @override
  String get dashboardLowStockAlerts => 'تنبيهات مخزون منخفض';

  @override
  String dashboardQtyAlert(int qty, int alert) {
    return 'كم $qty / تنبيه $alert';
  }

  @override
  String dashboardTodaySalesDot(String amount) {
    return 'مبيعات اليوم · $amount';
  }

  @override
  String get dashboardMonthlySales => 'مبيعات الشهر';

  @override
  String get dashboardTodayExpenses => 'مصروفات اليوم';

  @override
  String get dashboardMonthlyExpenses => 'مصروفات الشهر';

  @override
  String get dashboardRecentSales => 'مبيعات حديثة';

  @override
  String get dashboardAllStockGood => 'مستويات المخزون جيدة';

  @override
  String get dashboardYourStore => 'متجرك';

  @override
  String get settingsSystemHealth => 'صحة النظام';

  @override
  String get settingsEmail => 'البريد الإلكتروني';

  @override
  String get settingsTaxNumber => 'الرقم الضريبي';

  @override
  String get planFreeTrial => 'تجربة مجانية';

  @override
  String get settingsPosFeedback => 'تغذية راجعة نقطة البيع';

  @override
  String get settingsSoundEffects => 'مؤثرات صوتية';

  @override
  String get settingsScanCues => 'إشارات المسح والدفع';

  @override
  String get settingsHaptics => 'اهتزاز';

  @override
  String get settingsPlatformCenter => 'مركز التحكم بالمنصة';

  @override
  String get settingsPlatformSubtitle => 'المتاجر والخطط وإيرادات SaaS';

  @override
  String get settingsUserMgmt => 'إدارة المستخدمين';

  @override
  String get settingsUserMgmtSubtitle => 'الموظفون والأدوار والصلاحيات';

  @override
  String get settingsHealthSubtitle => 'المزامنة والوقت الفعلي والقائمة';

  @override
  String get settingsQaValidation => 'تحقق QA';

  @override
  String get settingsQaSubtitle => 'فحوصات آلية وقائمة ما قبل الإطلاق';

  @override
  String get settingsStoreBranding => 'هوية المتجر';

  @override
  String get settingsBrandingHint =>
      'الشعار يظهر على الإيصالات والفواتير وروابط الديون.';

  @override
  String get settingsStoreName => 'اسم المتجر';

  @override
  String get settingsPhone => 'الهاتف';

  @override
  String get settingsAddress => 'العنوان';

  @override
  String get settingsTaxRate => 'نسبة الضريبة %';

  @override
  String get settingsReceiptHeader => 'ترويسة الإيصال';

  @override
  String get settingsInvoiceFooter => 'نص تذييل الفاتورة';

  @override
  String get settingsTaxInclusiveTitle => 'أسعار شاملة الضريبة';

  @override
  String get settingsTaxInclusiveSubtitle => 'الأسعار تشمل الضريبة مسبقاً';

  @override
  String get settingsPosPermissionsTitle => 'صلاحيات نقطة البيع';

  @override
  String get settingsAllowPriceOverride => 'السماح بتعديل السعر';

  @override
  String get settingsAllowPriceOverrideSubtitle =>
      'عند الإيقاف لا يمكن تعديل الأسعار عند الدفع';

  @override
  String get settingsAutoPrintReceipt => 'طباعة إيصال تلقائياً';

  @override
  String get settingsAutoPrintSubtitle => 'تخطي مطالبة الطباعة';

  @override
  String get settingsSubscriptionPlan => 'خطة الاشتراك';

  @override
  String get settingsAuditLog => 'سجل التدقيق';

  @override
  String get settingsNoAudit => 'لا سجلات تدقيق بعد.';

  @override
  String get settingsExpenseSaved => 'تم حفظ المصروف';

  @override
  String get settingsLogoUploadFailed =>
      'فشل رفع الشعار. نفّذ supabase db push.';

  @override
  String get signInFailed => 'فشل تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get customerDirectory => 'دليل العملاء';

  @override
  String get customerReceivablesSubtitle => 'مبيعات الآجل والمستحقات';

  @override
  String get totalReceivable => 'إجمالي المستحق';

  @override
  String get supplierDirectory => 'دليل الموردين';

  @override
  String get supplierPayablesSubtitle => 'المشتريات والذمم';

  @override
  String get totalPayable => 'إجمالي المستحق الدفع';

  @override
  String get expenseSaved => 'تم حفظ المصروف';

  @override
  String get addCategory => 'إضافة فئة';

  @override
  String get addBrand => 'إضافة علامة';

  @override
  String get editCategory => 'تعديل فئة';

  @override
  String get editBrand => 'تعديل علامة';

  @override
  String get categoryName => 'اسم الفئة';

  @override
  String get brandNameField => 'اسم العلامة';

  @override
  String get inventoryScanBarcode => 'مسح باركود';

  @override
  String get inventoryShowAll => 'عرض الكل';

  @override
  String get inventoryLowStockOnly => 'مخزون منخفض فقط';

  @override
  String get inventorySearchProducts => 'بحث المنتجات…';

  @override
  String get inventoryAdjustStock => 'تعديل المخزون';

  @override
  String get debtsCustomerTab => 'ديون العملاء';

  @override
  String get debtsSupplierTab => 'ذمم الموردين';

  @override
  String get debtsFilterStatus => 'تصفية الحالة';

  @override
  String get debtsSearchHint => 'بحث اسم، هاتف، فاتورة…';

  @override
  String get debtStatusActive => 'نشط';

  @override
  String get debtStatusPartiallyPaid => 'مدفوع جزئياً';

  @override
  String get debtStatusOverdue => 'متأخر';

  @override
  String get reportsToday => 'اليوم';

  @override
  String get reportsThisWeek => 'هذا الأسبوع';

  @override
  String get reportsThisMonth => 'هذا الشهر';

  @override
  String get reportsCustomRange => 'مخصص';

  @override
  String get reportsRevenue => 'الإيرادات';

  @override
  String get reportsExpenses => 'المصروفات';

  @override
  String get reportsNetProfit => 'صافي الربح';

  @override
  String get usersCreateUser => 'إنشاء مستخدم';

  @override
  String get usersSearchHint => 'بحث المستخدمين…';

  @override
  String get usersNoUsers => 'لا مستخدمين بعد';

  @override
  String get usersInviteStaff => 'ادعُ الموظفين من حساب مالك المتجر.';

  @override
  String get onboardingTitle => 'إعداد متجرك';

  @override
  String get onboardingSubtitle => 'العملة والضريبة والهوية';

  @override
  String get onboardingContinue => 'متابعة';

  @override
  String get registerStoreTitle => 'إنشاء متجرك';

  @override
  String get registerStoreSubtitle => 'ابدأ تجربة KULMIS ERP';

  @override
  String get welcomeGetStarted => 'ابدأ';

  @override
  String get welcomeSignIn => 'تسجيل الدخول';

  @override
  String get syncQueueTitle => 'قائمة المزامنة';

  @override
  String get syncQueueEmpty => 'القائمة فارغة';

  @override
  String get syncRetryAll => 'إعادة المحاولة للكل';

  @override
  String get productAdded => 'تم حفظ المنتج';

  @override
  String get productDeleted => 'تم حذف المنتج';

  @override
  String get lowStock => 'مخزون منخفض';

  @override
  String get outOfStock => 'نفد المخزون';

  @override
  String get inStock => 'متوفر';

  @override
  String get allProducts => 'كل المنتجات';

  @override
  String get activeOnly => 'النشط فقط';

  @override
  String get archived => 'مؤرشف';

  @override
  String l10nDevMissingBanner(String locale) {
    return 'ترجمات ناقصة لـ $locale — راجع untranslated_messages.txt';
  }

  @override
  String get editProduct => 'تعديل منتج';

  @override
  String get productNameRequired => 'اسم المنتج *';

  @override
  String get noBrand => 'بدون علامة';

  @override
  String get brandLabel => 'العلامة';

  @override
  String get secondaryNameOptional => 'اسم ثانوي (اختياري)';

  @override
  String get barcodeLabel => 'الباركود';

  @override
  String get barcodeTypeLabel => 'نوع الباركود';

  @override
  String get barcodeTypeCode128 => 'CODE128';

  @override
  String get barcodeTypeEan13 => 'EAN-13';

  @override
  String get barcodeTypeQr => 'رمز QR';

  @override
  String get productsCost => 'التكلفة';

  @override
  String get sellPriceRequired => 'سعر البيع *';

  @override
  String get minStockAlert => 'تنبيه الحد الأدنى';

  @override
  String get printLabel => 'طباعة الملصق';

  @override
  String get barcodeAlreadyInUse => 'الباركود مستخدم مسبقاً';

  @override
  String get productLimitReached => 'تم بلوغ حد المنتجات';

  @override
  String get productImageSaveFailed =>
      'تعذر حفظ الصورة. تحقق من تخزين Supabase.';

  @override
  String get noMatchingProducts => 'لا منتجات مطابقة';

  @override
  String get noMatchingProductsSubtitle =>
      'جرّب بحثاً مختلفاً أو امسح الفلاتر.';

  @override
  String get productsEmptySubtitle =>
      'أنشئ كتالوجك بالباركود والأسعار والمخزون.';

  @override
  String get filterByBrand => 'تصفية حسب العلامة';

  @override
  String get allBrands => 'كل العلامات';

  @override
  String get totalProducts => 'إجمالي المنتجات';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتائج',
      one: 'نتيجة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get searchProductsExtended => 'بحث بالاسم أو الباركود أو SKU…';

  @override
  String posPaymentAccountsError(String detail) {
    return 'تعذر تحميل حسابات الدفع: $detail';
  }

  @override
  String get posCustomerRequired => 'اختر أو أضف عميلاً للبيع الجزئي/الآجل.';

  @override
  String get posInvalidPartialAmount =>
      'أدخل مبلغاً جزئياً صالحاً أقل من الإجمالي.';

  @override
  String get posSetupPaymentAccount =>
      'أعد حساب دفع في المحاسبة قبل البيع الجزئي.';

  @override
  String get posPaymentFull => 'كامل';

  @override
  String get posPaymentPartial => 'جزئي';

  @override
  String get posPaymentCredit => 'آجل';

  @override
  String get commonSelect => 'اختيار';

  @override
  String get posQuickAddShort => 'إضافة سريعة';

  @override
  String posInvoiceTotal(String amount) {
    return 'إجمالي الفاتورة: $amount';
  }

  @override
  String get posCustomerRequiredHint => 'مطلوب لتتبع الرصيد المتبقي.';

  @override
  String posCustomerOptional(String name) {
    return 'العميل (اختياري): $name';
  }

  @override
  String get posNotesOptional => 'ملاحظات (اختياري)';

  @override
  String get posAmountReceivedNow => 'المبلغ المستلم الآن';

  @override
  String get posPartialAmountHint => 'مثال 40.00';

  @override
  String posRemainingToDebt(String amount) {
    return 'المتبقي $amount → دين العميل';
  }

  @override
  String posCreditNoPaymentNow(String amount) {
    return 'لا دفع الآن. $amount بالكامل → الذمم المدينة.';
  }

  @override
  String get posReceivePaymentInto => 'استلام الدفع في';

  @override
  String get posPaymentAccount => 'حساب الدفع';

  @override
  String get posSetupAccountsPartial =>
      'أعد حسابات الدفع في المحاسبة قبل البيع الجزئي.';

  @override
  String get posNoAccountsCash => 'لا حسابات دفع — يُكتمل البيع نقداً.';

  @override
  String get posSplitAcrossAccounts => 'تقسيم على الحسابات';

  @override
  String get posNeedTwoAccounts => 'يلزم حسابان دفع على الأقل للتقسيم.';

  @override
  String get posSplitPayment => 'دفع مقسّم';

  @override
  String posTotalDue(String amount) {
    return 'المستحق: $amount';
  }

  @override
  String get posCompleteOnCredit => 'إتمام بالآجل';

  @override
  String get posCompletePartialSale => 'إتمام بيع جزئي';

  @override
  String get reportsPickDateRange => 'اختر نطاق التاريخ';

  @override
  String get reportsRangeLabel => 'نطاق التقرير';

  @override
  String get reportsSummary => 'الملخص';

  @override
  String get reportsCogs => 'تكلفة البضاعة';

  @override
  String get reportsSalesCount => 'عدد المبيعات';

  @override
  String get reportsExportPdf => 'تصدير PDF';

  @override
  String get reportsExportCsv => 'تصدير CSV';

  @override
  String get reportsShareCsvText => 'تقرير KULMIS ERP (CSV)';

  @override
  String reportsSaleItems(int count, String id) {
    return 'أصناف: $count • $id';
  }

  @override
  String reportsLineItemDetail(int qty, String unit, String cost) {
    return '×$qty @ $unit (تكلفة $cost)';
  }

  @override
  String get debtsFilterStatusTooltip => 'تصفية الحالة';

  @override
  String get debtCustomerReceivable => 'ذمم العملاء';

  @override
  String get debtSupplierPayable => 'ذمم الموردين';

  @override
  String get deleteCategoryTitle => 'حذف الفئة؟';

  @override
  String get deleteBrandTitle => 'حذف العلامة؟';

  @override
  String removeItemConfirm(String name) {
    return 'إزالة \"$name\"؟';
  }

  @override
  String get categorySaved => 'تم حفظ الفئة';

  @override
  String get brandSaved => 'تم حفظ العلامة';

  @override
  String get expenseName => 'اسم المصروف';

  @override
  String get expenseCategory => 'الفئة';

  @override
  String get expenseAmount => 'المبلغ';

  @override
  String get paidFromAccount => 'مدفوع من الحساب';

  @override
  String get expenseCategoryMisc => 'متنوع';

  @override
  String get posScanBarcodeSearch => 'مسح باركود أو بحث المنتجات (F1)';

  @override
  String get posAddToCartTooltip => 'أضف إلى السلة';

  @override
  String get posScanCameraTooltip => 'مسح بالكاميرا';

  @override
  String posCartMobile(int count, String total) {
    return 'السلة ($count) • $total';
  }

  @override
  String get posScanOrTapProducts => 'امسح أو اضغط على المنتجات';

  @override
  String get posSellingPrice => 'سعر البيع';

  @override
  String posCatalogPrice(String price) {
    return 'الكتالوج: $price';
  }

  @override
  String get posDiscountAmount => 'مبلغ الخصم';

  @override
  String get posTaxInclSuffix => ' (شامل)';

  @override
  String get posHeldSaleLabel => 'بيع معلق';

  @override
  String inventoryKpiError(String detail) {
    return 'خطأ KPI: $detail';
  }

  @override
  String get inventoryUpdated => 'تم تحديث المخزون';

  @override
  String inventoryAdjustTitle(String name) {
    return 'تعديل: $name';
  }

  @override
  String inventoryCurrentQty(int qty) {
    return 'الكمية الحالية: $qty';
  }

  @override
  String get inventoryChangeDelta => 'التغيير (+/-)';

  @override
  String get inventoryReason => 'السبب';

  @override
  String get inventoryStockValueCost => 'قيمة المخزون (تكلفة)';

  @override
  String inventoryBarcodeLine(String barcode, int qty) {
    return 'باركود: $barcode • كم $qty';
  }

  @override
  String inventoryQtyPill(int qty) {
    return 'كم $qty';
  }

  @override
  String inventoryCostPill(String amount) {
    return 'تكلفة $amount';
  }

  @override
  String inventorySellPill(String amount) {
    return 'بيع $amount';
  }

  @override
  String inventoryProfitPill(String amount) {
    return 'ربح $amount';
  }

  @override
  String get inventoryNoMatchingSubtitle =>
      'جرّب مسح باركود أو تغيير البحث/الفلتر.';

  @override
  String get inventoryReasonDamaged => 'بضائع تالفة';

  @override
  String get inventoryReasonExpired => 'بضائع منتهية';

  @override
  String get inventoryReasonTheft => 'سرقة / انكماش';

  @override
  String get inventoryReasonReturn => 'إرجاع للمورد';

  @override
  String get inventoryReasonCount => 'تصحيح جرد المخزون';

  @override
  String get inventoryReasonInitial => 'إدخال مخزون أولي';

  @override
  String debtBalanceDue(String amount) {
    return 'الرصيد المستحق: $amount';
  }

  @override
  String get debtPaymentAmount => 'مبلغ الدفع';

  @override
  String get debtSelectPaymentAccount => 'اختر حساب الدفع';

  @override
  String get debtNoWallets => 'لا محافظ — أنشئ المحاسبة أولاً.';

  @override
  String debtPaymentExceeds(String amount) {
    return 'لا يمكن تجاوز $amount';
  }

  @override
  String get debtPaymentRecorded => 'تم تسجيل الدفع بنجاح';

  @override
  String debtPaymentRemainingSync(String amount) {
    return 'المتبقي $amount • محفوظ محلياً، المزامنة جارية';
  }

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get rememberMeSubtitle => 'البقاء مسجلاً على هذا الجهاز';

  @override
  String get signingIn => 'جاري تسجيل الدخول…';

  @override
  String get newToInventraX => 'جديد في KULMIS ERP؟';

  @override
  String get registerYourStore => 'سجّل متجرك';

  @override
  String get backToWelcome => 'العودة للترحيب';

  @override
  String get authSupabaseSecured => 'مؤمّن بـ Supabase Auth وعزل المستأجرين.';

  @override
  String get authOfflineMode => 'وضع عدم الاتصال — اضبط .env للمزامنة.';

  @override
  String get welcomeSubtitle =>
      'أدِر متجرك بثقة. سجّل خلال دقائق أو سجّل الدخول.';

  @override
  String get welcomeTagline => 'SaaS متعدد المستأجرين للتجزئة الحديثة.';

  @override
  String get featureCloudSync => 'مزامنة سحابية';

  @override
  String get featureOfflinePos => 'نقطة بيع دون اتصال';

  @override
  String get featureRlsIsolation => 'عزل RLS';

  @override
  String get featureBarcodeReady => 'جاهز للباركود';

  @override
  String get registerStepBusiness => 'العمل';

  @override
  String get registerStepOwner => 'المالك';

  @override
  String get registerStepReview => 'مراجعة';

  @override
  String get creatingStore => 'جاري إنشاء المتجر…';

  @override
  String get tellUsBusiness => 'أخبرنا عن عملك';

  @override
  String get businessType => 'نوع النشاط';

  @override
  String get country => 'البلد';

  @override
  String get taxNumberOptional => 'الرقم الضريبي (اختياري)';

  @override
  String get ownerAccountTitle => 'حساب المالك — ستكون مالك المتجر';

  @override
  String get fullName => 'الاسم الكامل *';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور *';

  @override
  String get passwordHint => '8 أحرف على الأقل، كبيرة وصغيرة ورقم.';

  @override
  String get reviewCreateStore => 'راجع وأنشئ متجرك';

  @override
  String get freeTrial14Day => 'تجربة مجانية 14 يوماً';

  @override
  String get storeOwnerPermissions => 'دور مالك المتجر بصلاحيات كاملة';

  @override
  String get alreadyHaveAccountSignIn => 'لديك حساب؟ سجّل الدخول';

  @override
  String get storeNameRequired => 'اسم المتجر مطلوب';

  @override
  String get ownerNameRequired => 'اسم المالك مطلوب';

  @override
  String get emailRequired => 'البريد مطلوب';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get registrationFailed => 'فشل التسجيل. حاول مرة أخرى.';

  @override
  String get reviewLabelStore => 'المتجر';

  @override
  String get reviewLabelType => 'النوع';

  @override
  String get reviewLabelLocation => 'الموقع';

  @override
  String get reviewLabelOwner => 'المالك';

  @override
  String get onboardingStoreSetup => 'إعداد المتجر';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingBusinessInfo => 'معلومات العمل';

  @override
  String get onboardingBusinessSubtitle => 'أخبرنا عن متجرك';

  @override
  String get onboardingLocalization => 'التوطين';

  @override
  String get onboardingLocalizationSubtitle => 'العملة والضريبة';

  @override
  String get onboardingBranding => 'الهوية';

  @override
  String get onboardingBrandingSubtitle => 'ترويسة الإيصال والشعار';

  @override
  String get onboardingChoosePlan => 'اختر الخطة';

  @override
  String get onboardingPlanSubtitle => 'تبدأ تجربة 14 يوماً تلقائياً';

  @override
  String get receiptHeaderText => 'نص ترويسة الإيصال';

  @override
  String get phoneRequired => 'الهاتف *';

  @override
  String get addressRequired => 'العنوان *';

  @override
  String get purchaseCompleteTitle => 'إتمام الشراء';

  @override
  String purchaseTotal(String amount) {
    return 'الإجمالي: $amount';
  }

  @override
  String get purchaseSelectPayAccount => 'اختر حساب الدفع';

  @override
  String get purchaseSaveOnCredit => 'حفظ بالآجل';

  @override
  String get purchaseSavePurchase => 'حفظ الشراء';

  @override
  String purchaseCouldNotLoadAccounts(String detail) {
    return 'تعذر تحميل الحسابات: $detail';
  }

  @override
  String get purchaseAmountPaidNow => 'المبلغ المدفوع الآن';

  @override
  String purchaseRemainingToDebt(String amount) {
    return 'المتبقي $amount → دين المورد';
  }

  @override
  String purchaseCreditNoPayment(String amount) {
    return 'لا دفع الآن. $amount بالكامل → الذمم الدائنة.';
  }

  @override
  String get purchasePayFromAccount => 'الدفع من حساب';

  @override
  String get purchaseSetupAccountsFirst =>
      'أعد حسابات الدفع في المحاسبة أولاً.';

  @override
  String purchaseAddedProduct(String name) {
    return 'تمت إضافة $name';
  }

  @override
  String get quickAddSupplier => 'إضافة مورد سريعة';

  @override
  String purchaseUsingSupplier(String name) {
    return 'مورد موجود: $name';
  }

  @override
  String get purchaseSelectSupplierFirst => 'اختر أو أضف مورداً أولاً';

  @override
  String get purchaseNotSavedCancelled => 'لم يُحفظ الشراء — أُلغي';

  @override
  String purchaseCouldNotSave(String detail) {
    return 'تعذر حفظ الشراء: $detail';
  }

  @override
  String purchaseSavedSummary(String total, String status) {
    return 'تم حفظ الشراء • $total • $status';
  }

  @override
  String get navSupplier => 'المورد';

  @override
  String get purchaseLookUp => 'بحث';

  @override
  String purchaseInStockLine(int qty, String cost, String sell) {
    return 'متوفر: $qty • تكلفة: $cost • بيع: $sell';
  }

  @override
  String get purchasePrice => 'سعر الشراء';

  @override
  String get newSellPriceOptional => 'سعر بيع جديد (اختياري)';

  @override
  String get invoiceOptional => 'رقم الفاتورة (اختياري)';

  @override
  String get purchaseCart => 'سلة الشراء';

  @override
  String get purchaseCartEmpty =>
      'امسح أو ابحث عن المنتجات.\nالعناصر الحالية تعرض المخزون والأسعار.';

  @override
  String purchaseStockLine(int stock, int add) {
    return 'مخزون $stock → +$add';
  }

  @override
  String purchaseMargin(String percent) {
    return 'هامش $percent%';
  }

  @override
  String get completePurchase => 'إتمام الشراء';

  @override
  String get saving => 'جاري الحفظ…';

  @override
  String get selectOrAddSupplier => 'اختر أو أضف مورداً';

  @override
  String get purchaseDetailTitle => 'تفاصيل الشراء';

  @override
  String get purchaseNotFound => 'الشراء غير موجود';

  @override
  String purchaseInvoiceLine(String number) {
    return 'فاتورة: $number';
  }

  @override
  String get lineItems => 'البنود';

  @override
  String get acctMonthToDate => 'من بداية الشهر';

  @override
  String get acctFinancialOverview => 'نظرة مالية';

  @override
  String acctRevenueLine(String amount) {
    return 'الإيرادات $amount';
  }

  @override
  String get acctAfterCogsExpenses => 'بعد COGS والمصروفات';

  @override
  String get acctCashWallets => 'النقد والمحافظ';

  @override
  String get acctAllPaymentAccounts => 'كل حسابات الدفع';

  @override
  String get acctReceivable => 'المدينون';

  @override
  String get acctCustomerCredit => 'ائتمان العملاء';

  @override
  String get acctPayable => 'الدائنون';

  @override
  String get acctSupplierBalances => 'أرصدة الموردين';

  @override
  String get acctTrialBalance => 'ميزان المراجعة';

  @override
  String get acctBalanceSheet => 'الميزانية';

  @override
  String get acctJournals => 'اليوميات';

  @override
  String acctChartError(String detail) {
    return 'خطأ الرسم: $detail';
  }

  @override
  String get posCatalogLoadError => 'تعذر تحميل المنتجات.';

  @override
  String get posNoProductsMatch => 'لا منتجات مطابقة';

  @override
  String get viewGrid => 'شبكة';

  @override
  String get viewList => 'قائمة';

  @override
  String productCountLabel(int count) {
    return '$count منتجات';
  }

  @override
  String get tagOut => 'نفد';

  @override
  String get tagLow => 'منخفض';

  @override
  String get barcodeProductNotFound => 'المنتج غير موجود';

  @override
  String barcodeNoMatch(String code) {
    return 'لا منتج لهذا الباركود:\n$code';
  }

  @override
  String get manualEntry => 'إدخال يدوي';

  @override
  String get retryScan => 'إعادة المسح';

  @override
  String get barcodeNoBarcode => 'المنتج بلا باركود';

  @override
  String get barcodeLabelTitle => 'ملصق الباركود';

  @override
  String barcodeGenerated(String code) {
    return 'تم التوليد: $code';
  }

  @override
  String get purchasePriceRequired => 'سعر الشراء *';

  @override
  String get registerCreateStore => 'إنشاء المتجر';

  @override
  String get storeNameField => 'اسم المتجر *';

  @override
  String get invalidPassword => 'كلمة مرور غير صالحة';

  @override
  String get authNoProfileHint =>
      'حساب Auth موجود لكن لا يوجد ملف متجر. نفّذ supabase/scripts/setup_super_admin.sql أو سجّل متجرك مرة بهذا البريد.';

  @override
  String get barcodeDirectSale => 'بيع مباشر';

  @override
  String get barcodeAddNewProduct => 'إضافة منتج جديد';

  @override
  String get acctNavSectionBooks => 'الدفاتر';

  @override
  String get acctNavSectionCash => 'النقد';

  @override
  String get acctNavSectionReports => 'التقارير';

  @override
  String get acctNavOverview => 'نظرة عامة';

  @override
  String get acctNavChartOfAccounts => 'دليل الحسابات';

  @override
  String get acctNavGeneralLedger => 'الأستاذ العام';

  @override
  String get acctNavDeposits => 'إيداعات وسحوبات';

  @override
  String get acctNavPaymentAccounts => 'حسابات الدفع';

  @override
  String get acctNavProfitLoss => 'الأرباح والخسائر';

  @override
  String get acctNavCashFlow => 'التدفق النقدي';

  @override
  String get acctNetProfit => 'صافي الربح';

  @override
  String get acctRevenueLabel => 'الإيرادات';

  @override
  String get acctExpensesLabel => 'المصروفات';

  @override
  String get acctProfitLossShort => 'أرباح وخسائر';

  @override
  String get acctRevenueVsExpenses => 'الإيرادات مقابل المصروفات';

  @override
  String get acctLast6Months => 'آخر 6 أشهر';

  @override
  String get acctNoActivityYet => 'لا نشاط بعد';

  @override
  String get acctNoActivityHint => 'أكمل المبيعات والمصروفات لرؤية الاتجاهات';

  @override
  String get acctBooksAtGlance => 'الدفاتر بلمحة';

  @override
  String get acctDoubleEntry => 'قيد مزدوج';

  @override
  String get acctStatusActive => 'نشط';

  @override
  String get acctCashPosition => 'الوضع النقدي';

  @override
  String get acctOutstandingAr => 'مدينون مفتوح';

  @override
  String get acctOutstandingAp => 'دائنون مفتوح';

  @override
  String get purchasePaid => 'مدفوع';

  @override
  String get purchaseOutstanding => 'متبقي';

  @override
  String get unknownSupplier => 'مورد غير معروف';

  @override
  String get purchaseSelectPaymentAccount => 'اختر حساب الدفع';

  @override
  String get onboardingFinishSetup => 'إنهاء الإعداد';

  @override
  String get onboardingBack => 'رجوع';

  @override
  String get onboardingPlanFreeTrialDesc => '14 يوماً — نقطة بيع ومخزون كامل';

  @override
  String get onboardingPlanBilledMonthly => 'فوترة شهرية عند تفعيل الفوترة';

  @override
  String get onboardingTaxRateOptional => 'نسبة الضريبة % (اختياري)';

  @override
  String get onboardingPlanStarter => 'مبتدئ';

  @override
  String get onboardingPlanBusiness => 'أعمال';

  @override
  String get onboardingPlanFreeTrialName => 'تجربة مجانية';

  @override
  String get posAddMore => 'إضافة المزيد';

  @override
  String posProfitLine(String amount) {
    return 'ربح $amount';
  }

  @override
  String get posOutOfStock => 'نفد المخزون';

  @override
  String get posLowStock => 'مخزون منخفض';

  @override
  String posQtyInCart(int qty) {
    return '$qty في السلة';
  }

  @override
  String posSellLine(String amount) {
    return 'بيع $amount';
  }

  @override
  String posCostStockLine(String cost, int qty) {
    return 'تكلفة $cost • مخزون $qty';
  }

  @override
  String get barcodeScanTitle => 'مسح الباركود';

  @override
  String get acctNewJournalEntry => 'قيد يومية جديد';

  @override
  String get acctManualJournalEntry => 'قيد يدوي';

  @override
  String get acctManualJournalSubtitle =>
      'يجب أن تتساوى المدين والدائن — للتسويات';

  @override
  String get acctBalancedEntryRequired => 'قيد متوازن مطلوب';

  @override
  String get acctEntryDetails => 'تفاصيل القيد';

  @override
  String get acctEntryDate => 'تاريخ القيد';

  @override
  String get acctPostEntry => 'ترحيل القيد';

  @override
  String get acctFillRequiredFields => 'املأ جميع الحقول المطلوبة';

  @override
  String get acctJournalPosted => 'تم ترحيل اليومية';

  @override
  String get acctSelectAccountTitle => 'اختر حساباً';

  @override
  String get acctSelectAccountSubtitle => 'اختر حساباً لعرض حركته';

  @override
  String get acctNoLedgerActivity => 'لا نشاط';

  @override
  String acctYearToDateAsOf(String date) {
    return 'من بداية السنة · حتى $date';
  }

  @override
  String acctAssetsLiabilitiesEquity(String date) {
    return 'أصول وخصوم وحقوق · حتى $date';
  }

  @override
  String get acctAssetsEquals => 'الأصول = الخصوم + حقوق الملكية';

  @override
  String get acctAssets => 'الأصول';

  @override
  String get acctLiabilities => 'الخصوم';

  @override
  String get acctEquity => 'حقوق الملكية';

  @override
  String acctIncomeStatementPeriod(String period) {
    return 'قائمة الدخل · $period';
  }

  @override
  String get acctCogs => 'تكلفة البضاعة المباعة';

  @override
  String get acctGrossProfit => 'إجمالي الربح';

  @override
  String acctSimplifiedViewPeriod(String period) {
    return 'عرض مبسط · $period';
  }

  @override
  String get acctNetMovement => 'صافي الحركة';

  @override
  String get acctOperatingActivities => 'الأنشطة التشغيلية';

  @override
  String get acctNoJournalEntries => 'لا قيود يومية بعد';

  @override
  String get acctCreateManualEntry => 'إنشاء قيد يدوي';

  @override
  String acctPostedEntriesCount(int count) {
    return '$count قيد مرحّل (آخر 12 شهراً)';
  }

  @override
  String get acctNewEntry => 'قيد جديد';

  @override
  String get acctNoPaymentAccountsTitle => 'لا حسابات دفع';

  @override
  String get acctPaymentAccountsAutoCreated =>
      'تُنشأ الحسابات تلقائياً عند تسجيل الدخول';

  @override
  String get acctAddAccount => 'إضافة حساب';

  @override
  String get acctDeleteDeactivate => 'حذف (تعطيل)';

  @override
  String get acctDeleteDeactivateHint =>
      'يخفي الحساب. غير مسموح إن وُجد استخدام.';

  @override
  String get acctRestoreAccount => 'استعادة الحساب';

  @override
  String get acctDeleteAccountTitle => 'حذف الحساب؟';

  @override
  String acctAccountUpdated(String name) {
    return 'تم التحديث: $name';
  }

  @override
  String get acctAddAccountDialogTitle => 'إضافة حساب';

  @override
  String get acctAccountTypeAsset => 'أصل';

  @override
  String get acctAccountTypeLiability => 'خصم';

  @override
  String get acctAccountTypeEquity => 'حقوق ملكية';

  @override
  String get acctAccountTypeRevenue => 'إيراد';

  @override
  String get acctAccountTypeExpense => 'مصروف';

  @override
  String get acctCreateButton => 'إنشاء';

  @override
  String get acctAccountCreated => 'تم إنشاء الحساب';

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
  String get acctOwnerCashMovements => 'حركات نقد المالك';

  @override
  String get acctOwnerCashSubtitle =>
      'سجّل الأموال التي يضعها المالك في العمل أو يسحبها منه';

  @override
  String get acctDeposit => 'إيداع';

  @override
  String get acctWithdrawal => 'سحب';

  @override
  String get acctTransactionDetails => 'تفاصيل المعاملة';

  @override
  String get acctNoPaymentAccountsConfigured => 'لا حسابات دفع مُعدّة.';

  @override
  String get acctEnterValidAmount => 'أدخل مبلغاً صالحاً';

  @override
  String acctExportFailed(String detail) {
    return 'فشل التصدير: $detail';
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
    return 'تم حفظ الشراء لكن فشل القيد المحاسبي: $detail';
  }

  @override
  String get platformCommandCenter => 'مركز قيادة SaaS';

  @override
  String get platformNavOverview => 'نظرة عامة';

  @override
  String get platformNavBusiness => 'الأعمال';

  @override
  String get platformNavOperations => 'العمليات';

  @override
  String get platformNavDashboard => 'لوحة التحكم';

  @override
  String get platformNavGlobalSearch => 'بحث عام';

  @override
  String get platformNavAllStores => 'كل المتاجر';

  @override
  String get platformNavBilling => 'الفوترة';

  @override
  String get platformNavRevenue => 'الإيرادات';

  @override
  String get platformNavPlans => 'الخطط';

  @override
  String get platformNavStorage => 'التخزين';

  @override
  String get platformNavAlerts => 'التنبيهات';

  @override
  String get platformNavAudit => 'سجل التدقيق';

  @override
  String get platformNavHealth => 'صحة النظام';

  @override
  String get platformStoreApp => 'تطبيق المتجر';

  @override
  String get platformSuperAdmin => 'مشرف عام';

  @override
  String get platformAllStoresTitle => 'كل المتاجر';

  @override
  String get platformAllStoresSubtitle => 'بحث وتصفية وإدارة كل المستأجرين';

  @override
  String get platformGlobalSearchTitle => 'بحث عام';

  @override
  String get platformAlertsTitle => 'التنبيهات';

  @override
  String get platformAlertsSubtitle =>
      'اشتراكات منتهية وتجارب وتحذيرات التخزين';

  @override
  String get platformStorageTitle => 'التخزين';

  @override
  String get platformStorageSubtitle => 'استخدام الملفات على مستوى المنصة';

  @override
  String get platformTotalStorage => 'إجمالي تخزين المنصة';

  @override
  String get platformTotalStorageSubtitle => 'صور المنتجات والشعارات والمرفقات';

  @override
  String get platformTopStorageConsumers => 'أعلى مستهلكي التخزين';

  @override
  String platformImagesCount(int count) {
    return '$count صور';
  }

  @override
  String get platformAuditTitle => 'سجل التدقيق';

  @override
  String get platformAuditSubtitle => 'إجراءات المشرف: انتحال، فوترة، تعليق';

  @override
  String get platformBillingTitle => 'الفوترة والاشتراكات';

  @override
  String get platformBillingSubtitle =>
      'إدارة الخطة والتجربة والتجديد لكل متجر';

  @override
  String get platformViewStore => 'عرض المتجر';

  @override
  String get platformSetActive => 'تعيين نشط';

  @override
  String get platformExtendTrial14d => 'تمديد التجربة 14 يوماً';

  @override
  String get platformSuspend => 'تعليق';

  @override
  String platformStoreUpdated(String name) {
    return 'تم تحديث $name';
  }

  @override
  String get platformRevenueTitle => 'الإيرادات';

  @override
  String get platformRevenueSubtitle => 'MRR وARR ومساهمة الخطط';

  @override
  String get platformMrrByPlan => 'MRR حسب الخطة';

  @override
  String get platformPlanBreakdown => 'تفصيل الخطط';

  @override
  String platformStoresCount(int count) {
    return '$count متاجر';
  }

  @override
  String get platformStoreGrowth12m => 'نمو المتاجر (12 شهراً)';

  @override
  String get platformSubscriptionsByPlan => 'الاشتراكات حسب الخطة';

  @override
  String get platformTopStorageUsage => 'أعلى استخدام تخزين';

  @override
  String get platformRecentStores => 'متاجر حديثة';

  @override
  String get platformTotalStores => 'إجمالي المتاجر';

  @override
  String get platformTrialStores => 'تجربة';

  @override
  String get platformExpiredStores => 'منتهي';

  @override
  String get platformMrr => 'MRR';

  @override
  String get platformPaidStores => 'متاجر مدفوعة';

  @override
  String get platformStoreNotFound => 'المتجر غير موجود';

  @override
  String get platformOpenStoreImpersonate => 'فتح المتجر (انتحال)';

  @override
  String get platformBusinessAnalytics => 'تحليلات الأعمال';

  @override
  String get platformSubscriptionControl => 'التحكم بالاشتراك';

  @override
  String platformSetPlan(String name) {
    return 'تعيين $name';
  }

  @override
  String get platformActivate => 'تفعيل';

  @override
  String get platformStoreInfo => 'معلومات المتجر';

  @override
  String get platformExitImpersonation => 'خروج';

  @override
  String get platformPlansTitle => 'خطط الاشتراك';

  @override
  String get platformPlansSubtitle => 'حدود المنتجات والمستخدمين والتخزين';

  @override
  String get platformNewPlan => 'خطة جديدة';

  @override
  String platformHealthUnavailable(String detail) {
    return 'الصحة غير متاحة: $detail';
  }

  @override
  String get platformPendingSync => 'مزامنة معلّقة';

  @override
  String get platformFailedPushes => 'دفع فاشل';

  @override
  String get platformProductsSessionStore => 'المنتجات (متجر الجلسة)';

  @override
  String get platformOpenFullHealth => 'فتح صفحة صحة النظام الكاملة';

  @override
  String get platformInventoryValue => 'قيمة المخزون';

  @override
  String acctChartAccountsSubtitle(int count) {
    return '$count حساب · أضف حساباتك وأوقف غير المستخدمة';
  }

  @override
  String get acctShowInactive => 'إظهار غير النشطة';

  @override
  String get acctHideInactive => 'إخفاء غير النشطة';

  @override
  String get acctSystemBadge => 'نظام';

  @override
  String get acctDeleteAccountBody =>
      'سيؤدي هذا إلى إيقاف الحساب (سيُخفى). لا يمكن حذف حسابات النظام أو المستخدمة في القيود.';

  @override
  String get acctBalancedEntryBannerSubtitle =>
      'يُسجَّل مبلغ المدين كدائن في الحساب الثاني';

  @override
  String get acctTypeSectionAsset => 'الأصول';

  @override
  String get acctTypeSectionLiability => 'الخصوم';

  @override
  String get acctTypeSectionEquity => 'حقوق الملكية';

  @override
  String get acctTypeSectionRevenue => 'الإيرادات';

  @override
  String get acctTypeSectionExpense => 'المصروفات';

  @override
  String get acctAccountCode => 'رمز الحساب';

  @override
  String get acctAccountNameLabel => 'اسم الحساب';

  @override
  String get acctAccountTypeLabel => 'نوع الحساب';

  @override
  String get acctOpeningBalanceOptional => 'الرصيد الافتتاحي (اختياري)';

  @override
  String get acctDescription => 'الوصف';

  @override
  String get acctDebitAccount => 'حساب المدين';

  @override
  String get acctCreditAccount => 'حساب الدائن';

  @override
  String get acctAmount => 'المبلغ';

  @override
  String get acctNotesOptional => 'ملاحظات (اختياري)';

  @override
  String get acctDepositEntry => 'قيد إيداع';

  @override
  String get acctWithdrawalEntry => 'قيد سحب';

  @override
  String get acctDepositBannerSubtitle => 'مدين النقد · دائن رأس المال';

  @override
  String get acctWithdrawalBannerSubtitle => 'مدين المسحوبات · دائن النقد';

  @override
  String get acctWalletAccount => 'المحفظة / الحساب';

  @override
  String get acctPostDeposit => 'ترحيل الإيداع';

  @override
  String get acctPostWithdrawal => 'ترحيل السحب';

  @override
  String get acctDepositPosted => 'تم ترحيل الإيداع';

  @override
  String get acctWithdrawalPosted => 'تم ترحيل السحب';

  @override
  String acctErrorDetail(String detail) {
    return 'خطأ: $detail';
  }

  @override
  String get platformSearchHint => 'متاجر، ملاك، بريد، خطط…';

  @override
  String get platformSearchMinChars => 'اكتب حرفين على الأقل';

  @override
  String platformSearchStoresSection(int count) {
    return 'متاجر ($count)';
  }

  @override
  String platformSearchPlansSection(int count) {
    return 'خطط ($count)';
  }

  @override
  String get platformSearchNoStores => 'لا متاجر مطابقة';

  @override
  String get platformSearchNoPlans => 'لا خطط مطابقة';

  @override
  String get platformSystemHealthTitle => 'صحة النظام';

  @override
  String get platformEdit => 'تعديل';

  @override
  String platformErrorDetail(String detail) {
    return 'خطأ: $detail';
  }

  @override
  String get platformFilterAll => 'الكل';

  @override
  String get platformFilterActive => 'نشط';

  @override
  String get platformFilterTrial => 'تجربة';

  @override
  String get platformFilterExpired => 'منتهي';

  @override
  String get platformFilterSuspended => 'موقوف';

  @override
  String get platformNoStoresMatchFilter => 'لا متاجر تطابق هذا الفلتر';

  @override
  String get platformCreatePlan => 'إنشاء خطة';

  @override
  String get platformEditPlan => 'تعديل الخطة';

  @override
  String get platformPlanIdSlug => 'معرّف الخطة (slug)';

  @override
  String get platformPlanNameLabel => 'الاسم';

  @override
  String get platformPlanMonthlyPrice => 'السعر الشهري (USD)';

  @override
  String get platformPlanProductLimit => 'حد المنتجات (فارغ = غير محدود)';

  @override
  String get platformPlanUserLimit => 'حد المستخدمين';

  @override
  String get platformProductsMetric => 'منتجات';

  @override
  String get platformSalesMetric => 'مبيعات';

  @override
  String get platformPurchasesMetric => 'مشتريات';

  @override
  String get platformRevenueMetric => 'إيرادات';

  @override
  String get platformExpensesMetric => 'مصروفات';

  @override
  String get platformCustomersMetric => 'عملاء';

  @override
  String get platformSuppliersMetric => 'موردون';

  @override
  String get platformUsersMetric => 'مستخدمون';

  @override
  String get platformDebtsMetric => 'ديون';

  @override
  String get platformStorageSection => 'التخزين';

  @override
  String get platformOwnerLabel => 'المالك';

  @override
  String get platformPhoneLabel => 'الهاتف';

  @override
  String get platformAddressLabel => 'العنوان';

  @override
  String get platformCountryLabel => 'البلد';

  @override
  String get platformPlanLabel => 'الخطة';

  @override
  String get platformCreatedLabel => 'تاريخ الإنشاء';

  @override
  String get authBrandTagline => 'تخطيط موارد المؤسسات';

  @override
  String get authWelcomeBack => 'مرحباً';

  @override
  String get authWelcomeBackHighlight => 'بعودتك!';

  @override
  String get authWelcomeMessage =>
      'سجّل الدخول إلى حسابك وأدِر أعمالك بذكاء وسرعة وسهولة.';

  @override
  String get authSignInTo => 'تسجيل الدخول إلى';

  @override
  String get authEnterCredentials => 'أدخل بيانات الاعتماد للوصول إلى حسابك';

  @override
  String get authEmailAddress => 'البريد الإلكتروني';

  @override
  String get authEmailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get authPasswordHint => 'أدخل كلمة المرور';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authOrContinueWith => 'أو تابع باستخدام';

  @override
  String authNewToBrand(String brandName) {
    return 'جديد في $brandName؟';
  }

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authFeatureSecureTitle => 'آمن وموثوق';

  @override
  String get authFeatureSecureDesc => 'أمان بمستوى البنوك لبيانات عملك';

  @override
  String get authFeatureFastTitle => 'سريع وفعّال';

  @override
  String get authFeatureFastDesc => 'أداء محسّن للعمليات اليومية';

  @override
  String get authFeatureAnalyticsTitle => 'تحليلات ذكية';

  @override
  String get authFeatureAnalyticsDesc => 'رؤى فورية لقرارات أفضل';

  @override
  String get authFeatureCloudTitle => 'مزامنة سحابية';

  @override
  String get authFeatureCloudDesc => 'الوصول إلى بياناتك في أي وقت ومكان';

  @override
  String get authLanguage => 'اللغة';

  @override
  String authSocialComingSoon(String provider) {
    return 'تسجيل الدخول عبر $provider قريباً';
  }

  @override
  String get authForgotPasswordComingSoon => 'إعادة تعيين كلمة المرور قريباً';

  @override
  String get authStoreNameHint => 'أدخل اسم المتجر';

  @override
  String get authBusinessTypeHint => 'مثال: تجزئة، جملة';

  @override
  String get authCountryHint => 'مثال: غانا';

  @override
  String get authCurrencyHint => 'مثال: GHS';

  @override
  String get authAddressHint => 'الشارع، المدينة، المنطقة';

  @override
  String get authFullNameHint => 'أدخل اسمك الكامل';

  @override
  String get authPhoneHint => 'أدخل رقم الهاتف';

  @override
  String get authConfirmPasswordHint => 'أعد إدخال كلمة المرور';

  @override
  String get invoiceTitle => 'فاتورة';

  @override
  String get invoiceNumber => 'فاتورة #';

  @override
  String get invoiceDate => 'تاريخ الفاتورة';

  @override
  String get invoiceDueDate => 'تاريخ الاستحقاق';

  @override
  String get invoiceStatus => 'الحالة';

  @override
  String get invoicePaymentStatus => 'الدفع';

  @override
  String get invoiceBillTo => 'فاتورة إلى';

  @override
  String get invoiceProduct => 'المنتج';

  @override
  String get invoiceSku => 'الباركود';

  @override
  String get invoiceQty => 'الكمية';

  @override
  String get invoiceUnitPrice => 'سعر الوحدة';

  @override
  String get invoiceDiscount => 'الخصم';

  @override
  String get invoiceTax => 'الضريبة';

  @override
  String get invoiceLineTotal => 'الإجمالي';

  @override
  String get invoiceSubtotal => 'المجموع الفرعي';

  @override
  String get invoicePaid => 'المدفوع';

  @override
  String get invoiceRemaining => 'المتبقي';

  @override
  String get invoiceGrandTotal => 'الإجمالي الكلي';

  @override
  String get invoiceThankYou => 'شكراً لتعاملكم معنا.';

  @override
  String get invoiceWalkIn => 'عميل مباشر';

  @override
  String get invoicePrint => 'طباعة';

  @override
  String get invoiceSharePdf => 'مشاركة PDF';

  @override
  String get invoiceViewA4 => 'عرض فاتورة A4';

  @override
  String get invoiceOpenThermal => 'إيصال حراري';

  @override
  String subscriptionTrialEndsIn(int days) {
    return 'تنتهي الفترة التجريبية خلال $days أيام';
  }

  @override
  String subscriptionExpiresIn(int days) {
    return 'ينتهي اشتراكك خلال $days أيام';
  }

  @override
  String get subscriptionUpgradeNow => 'ترقية الآن';

  @override
  String get subscriptionRenewNow => 'تجديد الآن';

  @override
  String get billingTitle => 'الفوترة والاشتراك';

  @override
  String get billingSubtitle => 'إدارة الخطة وسجل المدفوعات';

  @override
  String get billingRenewPlan => 'تجديد الخطة';

  @override
  String get billingUpgrade => 'ترقية';

  @override
  String get billingBuySms => 'شراء SMS';

  @override
  String get billingPaymentFailed => 'فشل الدفع';

  @override
  String get billingUnavailableOffline => 'الفوترة غير متاحة دون اتصال';

  @override
  String get billingViewAllPackages => 'عرض جميع الباقات';

  @override
  String get billingChoosePlanBelow => 'اختر خطة أدناه للتجديد أو الترقية';

  @override
  String billingSubscribeTo(String plan) {
    return 'اشترك في $plan';
  }

  @override
  String get billingPerMonth => '/ شهر';

  @override
  String get billingSmsBalanceLabel => 'رصيد SMS';

  @override
  String get billingCycleLabel => 'الفوترة';

  @override
  String billingRemainingSms(int count) {
    return 'SMS المتبقي: $count';
  }

  @override
  String get billingNoTransactions => 'لا توجد معاملات بعد';

  @override
  String get billingPaymentHistory => 'سجل المدفوعات';

  @override
  String get billingUpgradePlan => 'ترقية الخطة';

  @override
  String get billingSmsMarketplace => 'سوق SMS';

  @override
  String get billingChoosePlan => 'اختر خطة';

  @override
  String get subscriptionRenewSubscription => 'تجديد الاشتراك';

  @override
  String get subscriptionUpgradePlan => 'ترقية الخطة';

  @override
  String get subscriptionAccountSettings => 'إعدادات الحساب';

  @override
  String get waafiPhoneLabel => 'رقم Waafi';

  @override
  String get waafiPhoneHint => '061… أو 25261…';

  @override
  String get waafiInstructions =>
      'أدخل رقم Waafi. سيتم إرسال طلب دفع إلى هاتفك — أدخل رقم PIN للتأكيد.';

  @override
  String get waafiSendPayment => 'PAY KTS';

  @override
  String get waafiSendingRequest => 'جارٍ إرسال طلب الدفع…';

  @override
  String get waafiWaitingConfirmation => 'في انتظار تأكيد Waafi…';

  @override
  String get waafiProcessingPayment => 'جارٍ معالجة الدفع…';

  @override
  String waafiPaymentSentTo(String phone) {
    return 'تم إرسال طلب الدفع إلى:\n$phone';
  }

  @override
  String get waafiEnterPin =>
      'يرجى إدخال PIN على هاتفك.\nقد يستغرق ذلك بضع ثوانٍ.';

  @override
  String get waafiCancelPayment => 'إلغاء الدفع';

  @override
  String get waafiPaymentSuccess => 'تم الدفع بنجاح';

  @override
  String waafiWalletBalance(int balance) {
    return 'رصيد المحفظة: $balance SMS';
  }

  @override
  String get waafiPaymentTimedOut => 'انتهت مهلة الدفع';

  @override
  String get waafiPaymentCancelled => 'تم إلغاء الدفع';

  @override
  String get waafiPaymentNotCompleted => 'لم يكتمل الدفع';

  @override
  String get waafiPaymentFailed => 'فشل الدفع';

  @override
  String get waafiNoPinConfirmation => 'لم يتم تأكيد PIN.';

  @override
  String get waafiPaymentCancelledDefault => 'تم إلغاء الدفع.';

  @override
  String get waafiTryAgain => 'حاول مرة أخرى';

  @override
  String get waafiSendingRequestStatus => 'جارٍ إرسال طلب Waafi…';

  @override
  String get smsDashboardTitle => 'لوحة SMS';

  @override
  String get smsBuyPackage => 'شراء باقة SMS';

  @override
  String get smsSendReminder => 'إرسال تذكير دين';

  @override
  String get smsEditTemplates => 'تعديل القوالب';

  @override
  String get smsTemplatesTitle => 'القوالب';

  @override
  String get smsLogsTitle => 'سجل SMS';

  @override
  String get smsRemindersTitle => 'التذكيرات';

  @override
  String get smsQueued => 'تم إضافة SMS للطابور — سيتم الإرسال قريباً';

  @override
  String get smsCouldNotQueue => 'تعذر إضافة SMS للطابور';

  @override
  String get smsTemplateSaved => 'تم حفظ القالب';

  @override
  String get smsBuyPackagesTitle => 'شراء الباقات';

  @override
  String get smsBuyWithWaafi => 'PAY KTS';

  @override
  String get smsSend => 'إرسال SMS';

  @override
  String smsToPhone(String phone) {
    return 'إلى: $phone';
  }

  @override
  String smsEditTemplate(String name) {
    return 'تعديل $name';
  }

  @override
  String get smsReminders3Days => 'قبل 3 أيام من الاستحقاق';

  @override
  String get smsReminders1Day => 'قبل يوم من الاستحقاق';

  @override
  String get smsRemindersOnDue => 'في تاريخ الاستحقاق';

  @override
  String get smsRemindersOverdue => 'تذكيرات المتأخرين';

  @override
  String get smsDailyCap => 'الحد اليومي';

  @override
  String get smsDailyCapTitle => 'حد SMS اليومي';

  @override
  String get smsBuyPackageButton => 'شراء باقة';

  @override
  String get invoiceCompact => 'مختصر';

  @override
  String get invoiceDetailed => 'مفصل';

  @override
  String invoiceStatusBadge(String status) {
    return 'الحالة: $status';
  }

  @override
  String invoicePaymentBadge(String status) {
    return 'الدفع: $status';
  }

  @override
  String get commonTryAgain => 'حاول مرة أخرى';

  @override
  String get smsScheduledReminders => 'التذكيرات المجدولة';

  @override
  String get smsScheduledRemindersSubtitle =>
      'تذكيرات ديون تلقائية حسب تواريخ الاستحقاق';

  @override
  String get smsAutomatedReminders => 'تذكيرات تلقائية';

  @override
  String get smsSendOnDueDates => 'إرسال SMS في تواريخ الاستحقاق';

  @override
  String smsPerDay(int count) {
    return '$count SMS يومياً';
  }

  @override
  String get smsMaxPerDay => 'الحد الأقصى لـ SMS يومياً';

  @override
  String get smsReminderHistory => 'سجل التذكيرات';

  @override
  String get smsNoRemindersYet => 'لم يُرسل أي تذكير بعد';

  @override
  String get smsReminderTypeThreeDays => 'قبل 3 أيام من الاستحقاق';

  @override
  String get smsReminderTypeOneDay => 'قبل يوم من الاستحقاق';

  @override
  String get smsReminderTypeDueDate => 'تذكير تاريخ الاستحقاق';

  @override
  String get smsReminderTypeOverdue => 'تذكير متأخر';

  @override
  String get smsLogsSubtitle => 'سجل التسليم لمتجرك';

  @override
  String get smsNoSmsSentYet => 'لم يُرسل أي SMS بعد';

  @override
  String get smsTemplatesReminderTitle => 'قوالب التذكير';

  @override
  String get smsTemplatesVariables =>
      'متغيرات القالب: customer_name, store_name, amount, invoice_number, due_date, payment_link';

  @override
  String get smsNoTemplatesYet =>
      'لا توجد قوالب بعد — تُنشأ عند إعداد محفظة SMS.';

  @override
  String get smsTemplateHint =>
      'استخدم amount و store_name ومتغيرات أخرى بين أقواس معقوفة مزدوجة';

  @override
  String get smsBuyPackagesSubtitle =>
      'شراء رصيد SMS عبر Waafi Pay — EVC, Zaad, Sahal, WAAFI';

  @override
  String smsCloudBalance(int count) {
    return 'الرصيد السحابي: $count SMS';
  }

  @override
  String get smsNoPackagesAvailable => 'لا توجد باقات. تواصل مع مسؤول المنصة.';

  @override
  String get healthTitle => 'صحة النظام';

  @override
  String get healthRefreshMetrics => 'تحديث المقاييس';

  @override
  String get healthRealtime => 'الوقت الفعلي';

  @override
  String get healthSync => 'المزامنة';

  @override
  String get healthQueue => 'الطابور';

  @override
  String healthQueueRetries(int count) {
    return '$count مع إعادة المحاولة';
  }

  @override
  String get healthNetwork => 'الشبكة';

  @override
  String get healthOnline => 'متصل';

  @override
  String get healthOffline => 'غير متصل';

  @override
  String get healthSyncTimeline => 'جدول المزامنة';

  @override
  String get healthLastPull => 'آخر سحب';

  @override
  String get healthLastPush => 'آخر دفع';

  @override
  String get healthLastSuccess => 'آخر مزامنة ناجحة';

  @override
  String get healthLastError => 'آخر خطأ';

  @override
  String get healthCloudConfigured => 'السحابة مُعدّة';

  @override
  String get healthYes => 'نعم';

  @override
  String get healthNo => 'لا';

  @override
  String get healthBackgroundScheduler => 'المجدول الخلفي';

  @override
  String get healthRunning => 'يعمل';

  @override
  String get healthInterval => 'الفترة';

  @override
  String get healthLastCycle => 'آخر دورة';

  @override
  String get healthInProgress => 'قيد التنفيذ';

  @override
  String get healthLocalDatabase => 'قاعدة البيانات المحلية';

  @override
  String get healthCachedProducts => 'المنتجات المخزنة';

  @override
  String get healthDbFileSize => 'حجم ملف DB';

  @override
  String get healthDbFileSizeWeb => 'غير متاح (ويب)';

  @override
  String healthDbFileSizeMb(String size) {
    return '$size ميجابايت';
  }

  @override
  String get healthQueueMaxRetries => 'طابور بأقصى محاولات';

  @override
  String get healthQueueInspector => 'مفتش الطابور';

  @override
  String get healthOpenFullQueue => 'فتح الطابور الكامل';

  @override
  String get healthQueueEmpty => 'الطابور فارغ';

  @override
  String get healthRecoveryActions => 'إجراءات الاستعادة';

  @override
  String get healthRecoverySubtitle =>
      'استخدم عندما يحتاج الدعم لاستعادة المزامنة دون إيقاف نقطة البيع.';

  @override
  String get healthRetryFailedSync => 'إعادة محاولة المزامنة الفاشلة';

  @override
  String get healthForceFullSync => 'فرض مزامنة كاملة';

  @override
  String get healthClearHydrationCache => 'مسح ذاكرة التخزين المؤقت';

  @override
  String get healthRebuildIndexes => 'إعادة بناء الفهارس المحلية';

  @override
  String get healthQaValidation => 'التحقق من الجودة';

  @override
  String get healthRealtimeEventLog => 'سجل أحداث الوقت الفعلي';

  @override
  String get healthAllOperational => 'جميع الأنظمة تعمل';

  @override
  String get healthSyncInProgress => 'المزامنة قيد التنفيذ';

  @override
  String get healthAttentionNeeded => 'يحتاج انتباه';

  @override
  String get healthOfflineLocalMode => 'غير متصل — الوضع المحلي';

  @override
  String get healthBadgeHealthy => 'سليم';

  @override
  String get healthBadgeActive => 'نشط';

  @override
  String get healthBadgeReview => 'مراجعة';

  @override
  String get healthBadgeOffline => 'غير متصل';

  @override
  String get healthBadgeIdle => 'خامل';

  @override
  String healthQueuedRetryingRealtime(
    int queued,
    int retrying,
    String realtime,
  ) {
    return '$queued في الطابور · $retrying إعادة محاولة · الوقت الفعلي $realtime';
  }

  @override
  String get healthOfflineSalesStored =>
      'المبيعات وتحديثات المخزون تُخزن على هذا الجهاز.';

  @override
  String get healthRetryingFailedSync => 'إعادة محاولة عناصر المزامنة الفاشلة';

  @override
  String get healthFullSyncCompleted => 'اكتملت المزامنة الكاملة';

  @override
  String get healthHydrationCleared =>
      'تم مسح ذاكرة التخزين — المزامنة التالية ستسحب بيانات جديدة';

  @override
  String get healthIndexesRebuilt => 'أُعيد بناء الفهارس المحلية';

  @override
  String healthErrorDetail(String detail) {
    return 'خطأ: $detail';
  }

  @override
  String get healthRealtimeConnected => 'متصل';

  @override
  String get healthRealtimeReconnecting => 'إعادة الاتصال';

  @override
  String get healthRealtimeDisconnected => 'منقطع';

  @override
  String get healthRealtimeFailed => 'فشل';

  @override
  String healthSecondsShort(int seconds) {
    return '$secondsث';
  }

  @override
  String get aiRiskNegativeProfit => 'ربح سلبي';

  @override
  String aiRiskNegativeProfitMsg(String pct) {
    return 'ربح هذا الشهر أقل من الصفر. راجع المصروفات ($pct% من المبيعات) والهوامش.';
  }

  @override
  String get aiRiskThinMargin => 'هامش ربح ضعيف';

  @override
  String aiRiskThinMarginMsg(String pct) {
    return 'هامش الربح $pct%. فكّر في التسعير أو ضبط التكاليف.';
  }

  @override
  String get aiRiskSalesDeclining => 'انخفاض المبيعات';

  @override
  String aiRiskSalesDecliningMsg(String pct) {
    return 'مبيعات آخر 7 أيام $pct% مقارنة بالـ 7 أيام السابقة.';
  }

  @override
  String get aiRiskHighExpense => 'نسبة مصروفات مرتفعة';

  @override
  String aiRiskHighExpenseMsg(String pct) {
    return 'المصروفات $pct% من الإيرادات هذا الشهر.';
  }

  @override
  String get aiRiskLowStock => 'تنبيهات مخزون منخفض';

  @override
  String aiRiskLowStockMsg(int count) {
    return '$count منتج(ات) عند أو دون الحد الأدنى للمخزون.';
  }

  @override
  String get aiRiskSlowMoving => 'مخزون بطيء الحركة';

  @override
  String aiRiskSlowMovingMsg(int count) {
    return '$count منتجات لم تُبَع خلال 30 يوماً ولا تزال في المخزون.';
  }

  @override
  String get aiRiskHighDebt => 'ديون عملاء مرتفعة';

  @override
  String get aiRiskHighDebtMsg =>
      'ديون العملاء المستحقة تتجاوز مبيعات هذا الشهر.';

  @override
  String get aiRiskOverdueDebts => 'ديون متأخرة';

  @override
  String aiRiskOverdueDebtsMsg(int count) {
    return '$count دين(ديون) متأخرة — تابع التحصيل.';
  }

  @override
  String get aiRiskOutOfStock => 'نفاد المخزون';

  @override
  String aiRiskOutOfStockMsg(int count) {
    return '$count SKU نفد مخزونها.';
  }

  @override
  String get platformSmsPackagesTitle => 'باقات SMS';

  @override
  String get platformSmsPackagesSubtitle =>
      'كتالوج السوق — المتاجر تشتري عبر Waafi Pay';

  @override
  String get platformNewPackage => 'باقة جديدة';

  @override
  String get platformCreateSmsPackage => 'إنشاء باقة SMS';

  @override
  String get platformEditSmsPackage => 'تعديل الباقة';

  @override
  String get platformSmsPackageId => 'معرف (slug)';

  @override
  String get platformSmsPackageName => 'الاسم';

  @override
  String get platformSmsPackageCount => 'عدد SMS';

  @override
  String get platformSmsPackagePrice => 'السعر (USD)';

  @override
  String get platformStoreSubscriptionsTitle => 'اشتراكات المتاجر';

  @override
  String get platformStoreSubscriptionsSubtitle =>
      'جميع اشتراكات المستأجرين في KULMIS ERP';

  @override
  String get platformStoreLabel => 'متجر';

  @override
  String get platformTrial => 'تجريبي';

  @override
  String get platformPaid => 'مدفوع';

  @override
  String get platformSmsWalletsTitle => 'محافظ SMS للمتاجر';

  @override
  String get platformSmsWalletsSubtitle => 'أرصدة SMS السحابية لكل متجر';

  @override
  String platformSmsUsedPurchased(int used, int purchased) {
    return 'مستخدم: $used • مشترى: $purchased';
  }

  @override
  String platformSmsRemaining(int count) {
    return '$count SMS';
  }

  @override
  String get platformTransactionsTitle => 'معاملات الدفع';

  @override
  String get platformTransactionsSubtitle => 'Waafi وبوابات الدفع المستقبلية';

  @override
  String get platformPaymentGatewayTitle => 'بوابة الدفع';

  @override
  String get platformPaymentGatewaySubtitle =>
      'إعداد Waafi Pay — بيانات الاعتماد عبر Supabase secrets';

  @override
  String get platformWaafiEnabled => 'Waafi Pay مفعّل';

  @override
  String get platformWaafiSandbox => 'وضع Waafi التجريبي';

  @override
  String get platformNoSettings => 'لا توجد إعدادات';

  @override
  String get platformGatewaySecretsHelp =>
      'اضبط الأسرار عبر CLI:\nWAAFI_MERCHANT_UID, WAAFI_API_USER_ID, WAAFI_API_KEY\nWAAFI_SANDBOX=true, WAAFI_DEV_MODE=true\nPAYMENT_WEBHOOK_SECRET';

  @override
  String get platformTrialSettingsTitle => 'إعدادات التجربة';

  @override
  String get platformTrialSettingsSubtitle =>
      'التجربة المجانية وفترة السماح للمتاجر الجديدة';

  @override
  String get platformDefaultTrialDays => 'أيام التجربة الافتراضية';

  @override
  String get platformGracePeriod => 'فترة السماح بعد الانتهاء';

  @override
  String platformDaysCount(int count) {
    return '$count أيام';
  }

  @override
  String get platformTrialDaysTitle => 'أيام التجربة';

  @override
  String get platformGracePeriodDaysTitle => 'أيام فترة السماح';

  @override
  String get platformDaysLabel => 'أيام';

  @override
  String get platformRevenueAnalyticsTitle => 'تحليلات الإيرادات';

  @override
  String get platformRevenueAnalyticsSubtitle =>
      'الإيرادات المحصلة، MRR، التجارب، ومبيعات SMS';

  @override
  String get platformTotalRevenue => 'إجمالي الإيرادات';

  @override
  String get platformSubscriptionRevenue => 'إيرادات الاشتراك';

  @override
  String get platformSmsRevenue => 'إيرادات SMS';

  @override
  String get platformMrrContracted => 'MRR (تعاقدي)';

  @override
  String get platformActiveSubs => 'اشتراكات نشطة';

  @override
  String get platformTrialing => 'تجريبية';

  @override
  String get platformTrialsExpiring7d => 'تجارب تنتهي (7 أيام)';

  @override
  String get platformFailedPayments30d => 'مدفوعات فاشلة (30 يوم)';

  @override
  String get platformOtpTitle => 'بنية OTP';

  @override
  String get platformOtpSubtitle =>
      'التحقق المركزي — علامات متعددة، Hormuud، حدود المعدل';

  @override
  String get platformOtpSentToday => 'أُرسل اليوم';

  @override
  String get platformOtpVerifiedToday => 'تم التحقق اليوم';

  @override
  String get platformOtpFailedToday => 'فشل اليوم';

  @override
  String get platformOtpPending => 'معلق (نشط)';

  @override
  String get platformAppBranding => 'علامة التطبيق';

  @override
  String get platformAppBrandingSubtitle =>
      'KULMIS ERP (kulmis-erp) — قوالب في otp_apps. أضف تطبيقات لـ KULMIS PAY ومنتجات أخرى.';

  @override
  String get platformRealtimeStatus => 'حالة الوقت الفعلي';

  @override
  String get platformWebsocketHealth => 'صحة WebSocket';

  @override
  String get platformFailedPayments24h => 'مدفوعات فاشلة (24 ساعة)';

  @override
  String get platformFailedSms24h => 'SMS فاشل (24 ساعة)';

  @override
  String get platformEventLog => 'سجل الأحداث';

  @override
  String get platformSearchButton => 'بحث';

  @override
  String get platformStoresSearchHint => 'اسم المتجر، المالك، البريد…';
}
