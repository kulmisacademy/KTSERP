// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Somali (`so`).
class AppLocalizationsSo extends AppLocalizations {
  AppLocalizationsSo([String locale = 'so']) : super(locale);

  @override
  String get appTitle => 'InventraX ERP';

  @override
  String get brandName => 'InventraX';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navPos => 'POS';

  @override
  String get navCustomSales => 'Iib Gaar ah';

  @override
  String get navDraftInvoices => 'Qoraallada Invoice';

  @override
  String get navSalesHistory => 'Taariikhda Iibka';

  @override
  String get navSales => 'Taariikhda Iibka';

  @override
  String get navProducts => 'Alaabta';

  @override
  String get navCategories => 'Qaybaha';

  @override
  String get navBrands => 'Summadaha';

  @override
  String get navInventory => 'Kaydka';

  @override
  String get navPurchases => 'Iibsashada';

  @override
  String get navAddPurchase => 'Ku dar iibsasho';

  @override
  String get navCustomers => 'Macaamiisha';

  @override
  String get navSuppliers => 'Alaab-bixiyeyaasha';

  @override
  String get navDebts => 'Deymaha';

  @override
  String get navExpenses => 'Kharashyada';

  @override
  String get navAccounting => 'Xisaabaadka';

  @override
  String get navReports => 'Warbixinnada';

  @override
  String get navAiInsights => 'AI Falanqayn';

  @override
  String get navNotifications => 'Ogeysiisyada';

  @override
  String get navSync => 'Isku-xirka';

  @override
  String get navUserManagement => 'Maamulka Isticmaalayaasha';

  @override
  String get navSettings => 'Dejinta';

  @override
  String get navPurchaseHistory => 'Taariikhda iibsashada';

  @override
  String get navReceiveStock => 'Iibso';

  @override
  String get languageTitle => 'Luqadda';

  @override
  String get languageEnglish => 'Ingiriisi';

  @override
  String get languageSomali => 'Soomaali';

  @override
  String get languageArabic => 'Carabi';

  @override
  String get languageEnglishNative => 'English';

  @override
  String get languageSomaliNative => 'Soomaali';

  @override
  String get languageArabicNative => 'العربية';

  @override
  String get settingsTitle => 'Dejinta';

  @override
  String get appearanceTitle => 'Muuqaalka';

  @override
  String get themeSystem => 'Nidaamka';

  @override
  String get themeLight => 'Iftiin';

  @override
  String get themeDark => 'Madow';

  @override
  String get localizationTitle => 'Dejinta goobta';

  @override
  String get currencyLabel => 'Lacagta';

  @override
  String get saveSettings => 'Kaydi dejinta';

  @override
  String get savingSettings => 'Kaydinaya…';

  @override
  String get settingsSaved => 'Dejinta waa la kaydiyay';

  @override
  String get signOut => 'Ka bax';

  @override
  String get notSignedIn => 'Lama soo gelin';

  @override
  String get syncOffline => 'Offline';

  @override
  String get syncSyncing => 'Isku-xir';

  @override
  String get syncQueue => 'Safka';

  @override
  String get syncLive => 'Toos';

  @override
  String get syncConnected => 'Ku xiran';

  @override
  String get syncReconnecting => 'Dib u xir';

  @override
  String get syncOfflineMode => 'HABKA OFFLINE';

  @override
  String get syncOfflineBanner =>
      'Habka offline — iibka iyo wax-ka-beddelka waxay ku shaqeeyaan gudaha. Isbeddelada ayaa isku xiraya markaad dib online noqoto.';

  @override
  String syncQueueBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count isbeddel ayaa sugaya isku-xirka',
      one: '1 isbeddel ayaa sugaya isku-xirka',
    );
    return '$_temp0';
  }

  @override
  String get retry => 'Isku day';

  @override
  String get details => 'Faahfaahin';

  @override
  String get metricSyncQueue => 'Safka isku-xirka';

  @override
  String get openPos => 'Fur POS';

  @override
  String get walkIn => 'Soo galitaan';

  @override
  String get paymentLabel => 'Lacag bixin';

  @override
  String get splitPayment => 'Qaybsan';

  @override
  String get filterToday => 'Maanta';

  @override
  String get filterWeek => 'Toddobaad';

  @override
  String get filterMonth => 'Bishii';

  @override
  String get filterCustom => 'Gaar ah';

  @override
  String get filterAll => 'Dhammaan';

  @override
  String get salesRangeToday => 'Maanta';

  @override
  String get salesRangeWeek => '7 maalmood ee u dambeeyay';

  @override
  String get salesRangeMonth => 'Bishan';

  @override
  String get salesRangeCustom => 'Muddo gaar ah';

  @override
  String get statusPaid => 'La bixiyay';

  @override
  String get statusPartial => 'Qayb';

  @override
  String get statusUnpaid => 'Aan la bixin';

  @override
  String get statusRefunded => 'Lacag celin';

  @override
  String get statusVoided => 'La baajiyay';

  @override
  String get netRevenue => 'Dakhliga nadiifka ah';

  @override
  String get transactions => 'Macaamillo';

  @override
  String get unpaidCount => 'Aan la bixin';

  @override
  String get salesSearchHint => 'Qaansheegta, macmiil, barcode…';

  @override
  String get noMatchingSales => 'Iib la mid ah ma jiro';

  @override
  String get noMatchingSalesSubtitle =>
      'Isku day shaandhe kale ama iib ka diiwaangeli POS.';

  @override
  String get colInvoice => 'Qaansheegta #';

  @override
  String get colCustomer => 'Macmiil';

  @override
  String get colStatus => 'Xaalad';

  @override
  String get colTotal => 'Wadarta';

  @override
  String get colPayment => 'Lacag bixin';

  @override
  String get colDate => 'Taariikh';

  @override
  String get colActions => 'Ficillo';

  @override
  String get voidSaleTitle => 'Baaji iibka?';

  @override
  String get voidSaleBody =>
      'Tani waxay soo celisaa kaydka waxayna ka saartaa iibka wadarta.';

  @override
  String get reason => 'Sabab';

  @override
  String get voidAction => 'Baaji';

  @override
  String get saleVoidedSnack =>
      'Iibka waa la baajiyay — kaydka waa la soo celiyay';

  @override
  String get partialRefundTitle => 'Lacag celin qayb ah';

  @override
  String get qty => 'Tirada';

  @override
  String get refundAction => 'Lacag celin';

  @override
  String get nothingToRefund => 'Wax lacag celin ah ma harin';

  @override
  String refundedAmountSnack(String amount) {
    return 'Lacag celin $amount — kaydka waa la soo celiyay';
  }

  @override
  String get noItemsRefunded => 'Wax alaab ah lama celin';

  @override
  String get printAction => 'Daabac';

  @override
  String get catalogAndPricing => 'Buugga & qiimaha';

  @override
  String get addProduct => 'Ku dar alaab';

  @override
  String get searchProducts => 'Raadi magac, SKU, barcode…';

  @override
  String get searchCustomersHint => 'Raadi magac ama telefoon…';

  @override
  String get noProducts => 'Weli alaab ma jirto';

  @override
  String get noProductsSubtitle =>
      'Ku dar alaabtaada ugu horreysa ama soo daji spreadsheet.';

  @override
  String get noExpenses => 'Weli kharash ma jiro';

  @override
  String get noExpensesSubtitle =>
      'La soco kirada, korontada, iyo kharashyada kale.';

  @override
  String get addExpense => 'Ku dar kharash';

  @override
  String get noNotifications => 'Ogeysiis ma jiro';

  @override
  String get noNotificationsSubtitle =>
      'Kayd hoose, deyn, iyo digniino halkan ayaa ka muuqda.';

  @override
  String get noCustomers => 'Weli macmiil ma jiro';

  @override
  String get noCustomersSubtitle =>
      'Ku dar macaamiisha si aad ula socoto deynta iyo iibka.';

  @override
  String get addCustomer => 'Ku dar macmiil';

  @override
  String get noSuppliers => 'Weli alaab-bixiye ma jiro';

  @override
  String get noSuppliersSubtitle => 'Ku dar alaab-bixiyeyaasha iibsashada.';

  @override
  String get addSupplier => 'Ku dar alaab-bixiye';

  @override
  String get noDebts => 'Deyn furan ma jiro';

  @override
  String get noDebtsSubtitle =>
      'Deynta macmiilka iyo alaab-bixiyaha halkan ayaa ka muuqda.';

  @override
  String get noCustomerDebts => 'Deyn macmiil ma jiro';

  @override
  String get noCustomerDebtsSubtitle =>
      'Iibka deyn ama qayb ah POS halkan ayaa ka muuqda.';

  @override
  String get noSupplierPayables => 'Lacag alaab-bixiye ma jirto';

  @override
  String get noSupplierPayablesSubtitle =>
      'Iibsashada deyn ama qayb ah halkan ayaa ka muuqda.';

  @override
  String get recordPayment => 'Diiwaangeli lacag bixin';

  @override
  String get noInventory => 'Dhaqdhaqaaq kayd ma jiro';

  @override
  String get noInventorySubtitle =>
      'Iibsashada iyo hagaajinta ayaa cusboonaysiisa kaydka.';

  @override
  String get noCategories => 'Weli qayb ma jirto';

  @override
  String get noCategoriesSubtitle => 'U habee alaabta qaybaha.';

  @override
  String get noBrands => 'Weli summad ma jirto';

  @override
  String get noBrandsSubtitle => 'U kala saar alaabta summadaha.';

  @override
  String get noPurchases => 'Weli iibsasho ma jirto';

  @override
  String get noPurchasesSubtitle =>
      'Ka iibso alaab-bixiyeyaasha si aad u bilowdo.';

  @override
  String get receiveStock => 'Iibso';

  @override
  String get loginTitle => 'Ku soo dhawoow';

  @override
  String get loginSubtitle =>
      'Soo gal si aad u maamusho kaydka, POS, iyo warbixinnada dukaankaaga.';

  @override
  String get email => 'Iimayl';

  @override
  String get password => 'Furaha sirta';

  @override
  String get signIn => 'Soo gal';

  @override
  String get createStore => 'Abuur dukaan';

  @override
  String get reportsExport => 'Dhoofi';

  @override
  String get reportsProfitLoss => 'Faa\'iido & khasaaro';

  @override
  String get reportsSales => 'Warbixin iibka';

  @override
  String get posCart => 'Gaadhifardood';

  @override
  String get posCheckout => 'Bixinta';

  @override
  String get posHold => 'Haysasho';

  @override
  String get posClear => 'Nadiifi';

  @override
  String get posSearchProducts => 'Raadi ama scan barcode…';

  @override
  String get posEmptyCart => 'Gaadhifardoodku waa madhan';

  @override
  String get posEmptyCartSubtitle =>
      'Scan barcode ama taabo alaab si aad u bilowdo.';

  @override
  String get posTotal => 'Wadarta';

  @override
  String get posDiscount => 'Qiimo dhimis';

  @override
  String get posTax => 'Canshuur';

  @override
  String get posPay => 'Bixi';

  @override
  String get posCompleteSale => 'Dhammaystir iibka';

  @override
  String get accountingOverview =>
      'Shaxda xisaabaadka, joornaalada, iyo warbixinnada maaliyadeed';

  @override
  String get aiInsightsTitle => 'AI Falanqayn';

  @override
  String get aiPoweredBy => 'Waxaa ku shaqeeya OpenAI';

  @override
  String get aiConfigureKey => 'Xeerarka offline + ku dar OPENAI_API_KEY';

  @override
  String get aiClearChat => 'Nadiifi sheekada';

  @override
  String get aiAnalyzing => 'Waxaan falanqaynayaa xogta ganacsigaaga…';

  @override
  String get aiEmptyHint =>
      'Weydii wax kasta oo ku saabsan iibka, faa\'iidada, kaydka, deymaha, ama kharashyada.\nFalanqaynta waxaa lagu sameeyaa gudaha — kooban oo keliya ayaa u tagaya OpenAI.';

  @override
  String get aiInputHint => 'Weydii iibka, faa\'iidada, kaydka, deymaha…';

  @override
  String get aiLiveAnalytics => 'Falanqayn toos ah';

  @override
  String get aiWarnings => 'Digniino';

  @override
  String get aiRecommendations => 'Talooyin';

  @override
  String get aiOpportunities => 'Fursado';

  @override
  String aiMonthSummary(String sales, String profit, int alerts) {
    return 'Iibka bisha $sales • Faa\'iido $profit • $alerts digniin';
  }

  @override
  String get aiPromptSalesSummary => 'Soo koob iibka iyo faa\'iidada bishan';

  @override
  String get aiPromptCompareWeeks =>
      'Is barbar dhig 7 maalmood ee u dambeeyay iyo 7 ka horreeyay';

  @override
  String get aiPromptTopProducts => 'Alaabtee ayaa ugu iib badan?';

  @override
  String get aiPromptRisks =>
      'Waa maxay khataraha ugu waaweyn ee ganacsigayga?';

  @override
  String get aiPromptExpenses => 'Falanqee kharashyada oo soo jeedi jarid';

  @override
  String get aiPromptDebts => 'Yaa ugu badan deyn bixinta?';

  @override
  String get aiPromptSlowStock => 'Kaydee ayaa si gaabis ah u iibinaysa?';

  @override
  String get aiPromptForecast =>
      'Saadaali bisha soo socota iyadoo lagu salaynayo isbeddellada';

  @override
  String get aiRateLimit =>
      'Fadlan sug dhowr ilbiriqsi inta u dhaxaysa codsiyada AI.';

  @override
  String get errorNetwork =>
      'Lama gaari karo serverka. Isbeddeladaada waxaa lagu kaydiyay gudaha waxayna isku xirayaan markaad dib online noqoto.';

  @override
  String get errorTimeout =>
      'Waqti aad buu u qaatay. Fadlan isku day mar kale — xogtaada gudaha waa ammaan.';

  @override
  String get errorPermission =>
      'Ma haysatid ogolaanshaha ficilkan. Weydii maamulaha dukaanka haddii aad u baahan tahay.';

  @override
  String get errorDuplicate =>
      'Diiwaankan hore ayuu u jiray. Hubi barcode, SKU, ama magaca oo isku day.';

  @override
  String get errorSync =>
      'Hadda lama isku xirin karo. Isbeddelada waxaa lagu safay oo si toos ah ayaa loo isku dayi doonaa.';

  @override
  String get errorDatabase =>
      'Waxbaa khaldamay kaydinta gudaha. Fadlan isku day mar kale ama la xiriir taageerada.';

  @override
  String get errorGeneric => 'Waxbaa khaldamay. Fadlan isku day mar kale.';

  @override
  String errorLoadAnalytics(String message) {
    return 'Lama soo rarin falanqaynta: $message';
  }

  @override
  String get commonSave => 'Kaydi';

  @override
  String get commonCancel => 'Jooji';

  @override
  String get commonLoading => 'Soo raraya…';

  @override
  String get commonNoData => 'Weli xog ma jirto';

  @override
  String get commonSearch => 'Raadi';

  @override
  String get commonRefresh => 'Cusbooneysii';

  @override
  String get commonAdd => 'Ku dar';

  @override
  String get commonEdit => 'Wax ka beddel';

  @override
  String get commonDelete => 'Tirtir';

  @override
  String get commonClose => 'Xir';

  @override
  String get commonConfirm => 'Xaqiiji';

  @override
  String get commonNoMatches => 'Wax la mid ah ma jiro';

  @override
  String get commonTryDifferentSearch => 'Isku day raadin kale.';

  @override
  String get commonDone => 'Dhammaystir';

  @override
  String get commonApply => 'Codso';

  @override
  String get commonChange => 'Beddel';

  @override
  String get commonViewAll => 'Arag dhammaan';

  @override
  String commonErrorWithDetail(String detail) {
    return 'Qalad: $detail';
  }

  @override
  String get commonYes => 'Haa';

  @override
  String get commonNo => 'Maya';

  @override
  String get commonName => 'Magac';

  @override
  String get commonPhone => 'Telefoon';

  @override
  String get commonNotes => 'Qoraallo';

  @override
  String get commonQuantity => 'Tirada';

  @override
  String get commonPrice => 'Qiimo';

  @override
  String get commonTotal => 'Wadarta';

  @override
  String get commonSubtotal => 'Hoosaadka';

  @override
  String get commonScan => 'Scan';

  @override
  String get commonPrint => 'Daabac';

  @override
  String get commonExport => 'Dhoofi';

  @override
  String get commonImport => 'Soo deji';

  @override
  String get commonFilter => 'Shaandhee';

  @override
  String get commonAllStatuses => 'Dhammaan xaaladaha';

  @override
  String get commonRequired => 'Waajib';

  @override
  String get commonOptional => 'Ikhtiyaari';

  @override
  String get posDirectSale => 'Iib toos ah';

  @override
  String get posAddToCart => 'Ku dar gaadhifardoodka';

  @override
  String posCheckoutError(String detail) {
    return 'Qalad bixinta: $detail';
  }

  @override
  String get posSaleComplete => 'Iibka waa dhammaaday';

  @override
  String get posPrintReceipt => 'Daabac rasiidka';

  @override
  String get posHoldSale => 'Hays iibka';

  @override
  String get posSaleHeld =>
      'Iibka waa la hayay — gaadhifardoodka waa la nadiifiyay';

  @override
  String get posQuickAddCustomer => 'Ku dar macmiil degdeg ah';

  @override
  String get posNoCustomer => 'Macmiil ma jiro';

  @override
  String get posNewCustomer => 'Macmiil cusub';

  @override
  String get posNoHeldSales => 'Iib la hayay ma jiro';

  @override
  String get posHeldSales => 'Iib la hayay';

  @override
  String get posProductAdded => 'Alaabta waa la daray';

  @override
  String posEditPrice(String name) {
    return 'Wax ka beddel qiimaha · $name';
  }

  @override
  String get posPriceOverrideDisabled =>
      'Beddelka qiimaha waa la xiray Dejinta';

  @override
  String get posOrderDiscount => 'Qiimo dhimis dalab';

  @override
  String get posAddDiscount => 'Ku dar qiimo dhimis';

  @override
  String get posCheckoutShortcut => 'Bixi · F10';

  @override
  String get posQuickAddProduct => 'Ku dar alaab degdeg ah';

  @override
  String posCartItems(int count) {
    return '$count alaab';
  }

  @override
  String get posChangeCustomer => 'Beddel macmiilka';

  @override
  String get posMobileCart => 'Gaadhifardood';

  @override
  String get posItemName => 'Magaca shayga';

  @override
  String posSaleCompletedSummary(String summary) {
    return 'Iibka waa dhammaaday ($summary)';
  }

  @override
  String get posLabelOptional => 'Calaamad (ikhtiyaari)';

  @override
  String get posLabelHint => 'tusaale Macmiil sugaya';

  @override
  String get posHeldRestored => 'Iibka la haystay waa la soo celiyay';

  @override
  String get posClearCartFirst =>
      'Marka hore nadiifi gaadhiga si aad u soo celiso';

  @override
  String get dashboardWelcome => 'Ku soo dhawoow';

  @override
  String get dashboardTodaySales => 'Iibka maanta';

  @override
  String get dashboardMonthProfit => 'Faa\'iidada bisha';

  @override
  String get dashboardLowStock => 'Kayd hoose';

  @override
  String get dashboardOpenPos => 'Fur POS';

  @override
  String get dashboardNoSalesYet =>
      'Weli iib ma jiro — fur POS si aad u bilowdo';

  @override
  String get dashboardSalesLast7Days => 'Iibka · 7 maalmood';

  @override
  String get dashboardDailyRevenue => 'Dakhliga maalinlaha';

  @override
  String dashboardChartError(String detail) {
    return 'Qalad shaxda: $detail';
  }

  @override
  String get dashboardNoSalesRecorded => 'Weli iib lama diiwaangelin';

  @override
  String get dashboardLowStockAlerts => 'Digniino kayd hoose';

  @override
  String dashboardQtyAlert(int qty, int alert) {
    return 'Tir $qty / digniin $alert';
  }

  @override
  String dashboardTodaySalesDot(String amount) {
    return 'Iibka maanta · $amount';
  }

  @override
  String get dashboardMonthlySales => 'Iibka bishii';

  @override
  String get dashboardTodayExpenses => 'Kharashka maanta';

  @override
  String get dashboardMonthlyExpenses => 'Kharashka bishii';

  @override
  String get dashboardRecentSales => 'Iibyo dhowaan';

  @override
  String get dashboardAllStockGood => 'Heerarka kaydka waa wanaagsan yihiin';

  @override
  String get dashboardYourStore => 'Dukaankaaga';

  @override
  String get settingsSystemHealth => 'Caafimaadka nidaamka';

  @override
  String get settingsEmail => 'Iimaylka';

  @override
  String get settingsTaxNumber => 'Lambarka canshuurta';

  @override
  String get planFreeTrial => 'Tijaabo bilaash';

  @override
  String get settingsPosFeedback => 'Jawaab celinta POS';

  @override
  String get settingsSoundEffects => 'Codadka';

  @override
  String get settingsScanCues => 'Scan iyo calaamadaha bixinta';

  @override
  String get settingsHaptics => 'Gariirka';

  @override
  String get settingsPlatformCenter => 'Xarunta amarada platform';

  @override
  String get settingsPlatformSubtitle =>
      'Dukaamada, qorshayaasha, dakhliga SaaS';

  @override
  String get settingsUserMgmt => 'Maamulka isticmaalayaasha';

  @override
  String get settingsUserMgmtSubtitle => 'Shaqaalaha, doorarka, ogolaanshaha';

  @override
  String get settingsHealthSubtitle => 'Isku-xirka, toos, safka';

  @override
  String get settingsQaValidation => 'Xaqiijinta QA';

  @override
  String get settingsQaSubtitle => 'Hubinta otomaatiga ah & liiska bilowga';

  @override
  String get settingsStoreBranding => 'Summadda dukaanka';

  @override
  String get settingsBrandingHint =>
      'Summadu waxay ku muuqataa rasiidka, qaansheegyada, iyo deynta.';

  @override
  String get settingsStoreName => 'Magaca dukaanka';

  @override
  String get settingsPhone => 'Telefoon';

  @override
  String get settingsAddress => 'Cinwaan';

  @override
  String get settingsTaxRate => 'Heerka canshuurta %';

  @override
  String get settingsReceiptHeader => 'Madaxa rasiidka';

  @override
  String get settingsInvoiceFooter => 'Qoraalka hoose ee qaansheegta';

  @override
  String get settingsTaxInclusiveTitle => 'Qiimaha canshuur ku jirto';

  @override
  String get settingsTaxInclusiveSubtitle =>
      'Qiimuhu waxay hore ugu jiraan canshuurta';

  @override
  String get settingsPosPermissionsTitle => 'Ogolaanshaha POS';

  @override
  String get settingsAllowPriceOverride => 'U oggolow beddelka qiimaha';

  @override
  String get settingsAllowPriceOverrideSubtitle =>
      'Marka la xiro, qiimaha lama beddeli karo bixinta';

  @override
  String get settingsAutoPrintReceipt => 'Si toos ah u daabac rasiidka';

  @override
  String get settingsAutoPrintSubtitle => 'Ka bood su\'aasha daabacaadda';

  @override
  String get settingsSubscriptionPlan => 'Qorshaha rukunka';

  @override
  String get settingsAuditLog => 'Diiwaanka hubinta';

  @override
  String get settingsNoAudit => 'Weli diiwaan hubin ma jiro.';

  @override
  String get settingsExpenseSaved => 'Kharashka waa la kaydiyay';

  @override
  String get settingsLogoUploadFailed =>
      'Soo dejinta summada way fashilantay. Ordi supabase db push.';

  @override
  String get signInFailed => 'Soo gelitaanku wuu fashilmay. Isku day mar kale.';

  @override
  String get customerDirectory => 'Buugga macaamiisha';

  @override
  String get customerReceivablesSubtitle => 'Iibka deyn iyo lacag la sugayo';

  @override
  String get totalReceivable => 'Wadarta la sugayo';

  @override
  String get supplierDirectory => 'Buugga alaab-bixiyeyaasha';

  @override
  String get supplierPayablesSubtitle => 'Iibsashada iyo lacag bixinta';

  @override
  String get totalPayable => 'Wadarta la bixinayo';

  @override
  String get expenseSaved => 'Kharashka waa la kaydiyay';

  @override
  String get addCategory => 'Ku dar qayb';

  @override
  String get addBrand => 'Ku dar summad';

  @override
  String get editCategory => 'Wax ka beddel qayb';

  @override
  String get editBrand => 'Wax ka beddel summad';

  @override
  String get categoryName => 'Magaca qaybta';

  @override
  String get brandNameField => 'Magaca summadda';

  @override
  String get inventoryScanBarcode => 'Scan barcode';

  @override
  String get inventoryShowAll => 'Muuji dhammaan';

  @override
  String get inventoryLowStockOnly => 'Kayd hoose oo keliya';

  @override
  String get inventorySearchProducts => 'Raadi alaabta…';

  @override
  String get inventoryAdjustStock => 'Hagaaji kaydka';

  @override
  String get debtsCustomerTab => 'Deynta macmiilka';

  @override
  String get debtsSupplierTab => 'Lacagta alaab-bixiyaha';

  @override
  String get debtsFilterStatus => 'Shaandhee xaalad';

  @override
  String get debtsSearchHint => 'Raadi magac, telefoon, qaansheeg…';

  @override
  String get debtStatusActive => 'Firfircoon';

  @override
  String get debtStatusPartiallyPaid => 'Qayb la bixiyay';

  @override
  String get debtStatusOverdue => 'Dib u dhac';

  @override
  String get reportsToday => 'Maanta';

  @override
  String get reportsThisWeek => 'Toddobaadkan';

  @override
  String get reportsThisMonth => 'Bishan';

  @override
  String get reportsCustomRange => 'Gaar ah';

  @override
  String get reportsRevenue => 'Dakhliga';

  @override
  String get reportsExpenses => 'Kharashyada';

  @override
  String get reportsNetProfit => 'Faa\'iidada nadiifka';

  @override
  String get usersCreateUser => 'Abuur isticmaale';

  @override
  String get usersSearchHint => 'Raadi isticmaalayaasha…';

  @override
  String get usersNoUsers => 'Weli isticmaale ma jiro';

  @override
  String get usersInviteStaff =>
      'Ku casuum shaqaalaha xisaabta milkiilaha dukaanka.';

  @override
  String get onboardingTitle => 'Deji dukaankaaga';

  @override
  String get onboardingSubtitle => 'Lacagta, canshuurta, summadda';

  @override
  String get onboardingContinue => 'Sii wad';

  @override
  String get registerStoreTitle => 'Abuur dukaankaaga';

  @override
  String get registerStoreSubtitle => 'Bilow tijaabada InventraX';

  @override
  String get welcomeGetStarted => 'Bilow';

  @override
  String get welcomeSignIn => 'Soo gal';

  @override
  String get syncQueueTitle => 'Safka isku-xirka';

  @override
  String get syncQueueEmpty => 'Safka waa madhan';

  @override
  String get syncRetryAll => 'Isku day dhammaan';

  @override
  String get productAdded => 'Alaabta waa la kaydiyay';

  @override
  String get productDeleted => 'Alaabta waa la tirtiray';

  @override
  String get lowStock => 'Kayd hoose';

  @override
  String get outOfStock => 'Kayd ma jiro';

  @override
  String get inStock => 'Kayd jira';

  @override
  String get allProducts => 'Dhammaan alaabta';

  @override
  String get activeOnly => 'Firfircoon oo keliya';

  @override
  String get archived => 'La kaydiyay';

  @override
  String l10nDevMissingBanner(String locale) {
    return 'Turjumaad maqan $locale — eeg untranslated_messages.txt';
  }

  @override
  String get editProduct => 'Wax ka beddel alaab';

  @override
  String get productNameRequired => 'Magaca alaabta *';

  @override
  String get noBrand => 'Summad la\'aan';

  @override
  String get brandLabel => 'Summad';

  @override
  String get secondaryNameOptional => 'Magac labaad (ikhtiyaari)';

  @override
  String get barcodeLabel => 'Barcode';

  @override
  String get barcodeTypeLabel => 'Nooca barcode';

  @override
  String get barcodeTypeCode128 => 'CODE128';

  @override
  String get barcodeTypeEan13 => 'EAN-13';

  @override
  String get barcodeTypeQr => 'QR Code';

  @override
  String get productsCost => 'Qiimaha iibsiga';

  @override
  String get sellPriceRequired => 'Qiimaha iibka *';

  @override
  String get minStockAlert => 'Digniinta kaydka yar';

  @override
  String get printLabel => 'Daabac summada';

  @override
  String get barcodeAlreadyInUse => 'Barcode hore ayaa la isticmaalay';

  @override
  String get productLimitReached => 'Xadka alaabta waa la gaaray';

  @override
  String get productImageSaveFailed =>
      'Sawirka lama kaydin. Hubi kaydinta Supabase.';

  @override
  String get noMatchingProducts => 'Alaab la mid ah ma jiro';

  @override
  String get noMatchingProductsSubtitle =>
      'Isku day raadin kale ama nadiifi shaandhada.';

  @override
  String get productsEmptySubtitle =>
      'Dhiso buuggaaga barcode, qiimo, iyo kayd.';

  @override
  String get filterByBrand => 'Shaandhee summad';

  @override
  String get allBrands => 'Dhammaan summadaha';

  @override
  String get totalProducts => 'Wadarta alaabta';

  @override
  String get clearSearch => 'Nadiifi raadinta';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count natiijo',
      one: '1 natiijo',
    );
    return '$_temp0';
  }

  @override
  String get searchProductsExtended => 'Raadi magac, barcode, ama SKU…';

  @override
  String posPaymentAccountsError(String detail) {
    return 'Lama soo rarin xisaabaadka lacag bixinta: $detail';
  }

  @override
  String get posCustomerRequired =>
      'Dooro ama ku dar macmiil iibka qaybta/deynta.';

  @override
  String get posInvalidPartialAmount => 'Geli qadar sax ah oo ka yar wadarta.';

  @override
  String get posSetupPaymentAccount =>
      'Samee xisaab lacag bixineed Accounting ka hor iibka qaybta.';

  @override
  String get posPaymentFull => 'Buuxa';

  @override
  String get posPaymentPartial => 'Qayb';

  @override
  String get posPaymentCredit => 'Deyn';

  @override
  String get commonSelect => 'Dooro';

  @override
  String get posQuickAddShort => 'Ku dar degdeg';

  @override
  String posInvoiceTotal(String amount) {
    return 'Wadarta qaansheegta: $amount';
  }

  @override
  String get posCustomerRequiredHint =>
      'Loo baahan yahay si loo raaco hadhaaga.';

  @override
  String posCustomerOptional(String name) {
    return 'Macmiil (ikhtiyaari): $name';
  }

  @override
  String get posNotesOptional => 'Qoraallo (ikhtiyaari)';

  @override
  String get posAmountReceivedNow => 'Lacagta hadda la helay';

  @override
  String get posPartialAmountHint => 'tusaale 40.00';

  @override
  String posRemainingToDebt(String amount) {
    return 'Hadhaaga $amount → deynta macmiilka';
  }

  @override
  String posCreditNoPaymentNow(String amount) {
    return 'Lacag ma jirto hadda. $amount oo dhan → Accounts Receivable.';
  }

  @override
  String get posReceivePaymentInto => 'Hel lacagta gudaha';

  @override
  String get posPaymentAccount => 'Xisaabta lacag bixinta';

  @override
  String get posSetupAccountsPartial =>
      'Samee xisaabaadka Accounting ka hor iibka qaybta.';

  @override
  String get posNoAccountsCash =>
      'Xisaabaad ma jiraan — iibku wuxuu noqonayaa lacag caddaan.';

  @override
  String get posSplitAcrossAccounts => 'U qaybi xisaabaadka';

  @override
  String get posNeedTwoAccounts =>
      'Ugu yaraan laba xisaab ayaa loo baahan yahay qaybinta.';

  @override
  String get posSplitPayment => 'Lacag bixin qaybsan';

  @override
  String posTotalDue(String amount) {
    return 'Wadarta la bixinayo: $amount';
  }

  @override
  String get posCompleteOnCredit => 'Dhammaystir deyn ahaan';

  @override
  String get posCompletePartialSale => 'Dhammaystir iibka qaybta';

  @override
  String get reportsPickDateRange => 'Dooro taariikhda';

  @override
  String get reportsRangeLabel => 'Muddada warbixinta';

  @override
  String get reportsSummary => 'Kooban';

  @override
  String get reportsCogs => 'Qiimaha alaabta la iibiyay';

  @override
  String get reportsSalesCount => 'Tirada iibka';

  @override
  String get reportsExportPdf => 'Dhoofinta PDF';

  @override
  String get reportsExportCsv => 'Dhoofinta CSV';

  @override
  String get reportsShareCsvText => 'Warbixinta InventraX (CSV)';

  @override
  String reportsSaleItems(int count, String id) {
    return 'Alaab: $count • $id';
  }

  @override
  String reportsLineItemDetail(int qty, String unit, String cost) {
    return 'x$qty @ $unit (qiimo $cost)';
  }

  @override
  String get debtsFilterStatusTooltip => 'Shaandhee xaaladda';

  @override
  String get debtCustomerReceivable => 'Deynta macmiilka';

  @override
  String get debtSupplierPayable => 'Deynta alaab-qeybiyaha';

  @override
  String get deleteCategoryTitle => 'Tirtir qaybta?';

  @override
  String get deleteBrandTitle => 'Tirtir summadda?';

  @override
  String removeItemConfirm(String name) {
    return 'Ka saar \"$name\"?';
  }

  @override
  String get categorySaved => 'Qaybta waa la kaydiyay';

  @override
  String get brandSaved => 'Summadda waa la kaydiyay';

  @override
  String get expenseName => 'Magaca kharashka';

  @override
  String get expenseCategory => 'Qaybta';

  @override
  String get expenseAmount => 'Qadarka';

  @override
  String get paidFromAccount => 'Laga bixiyay xisaabta';

  @override
  String get expenseCategoryMisc => 'Kala duwan';

  @override
  String get posScanBarcodeSearch => 'Scan barcode ama raadi alaab (F1)';

  @override
  String get posAddToCartTooltip => 'Ku dar gaadhiga';

  @override
  String get posScanCameraTooltip => 'Scan barcode (kamarad)';

  @override
  String posCartMobile(int count, String total) {
    return 'Gaadhi ($count) • $total';
  }

  @override
  String get posScanOrTapProducts => 'Scan ama taabo alaab';

  @override
  String get posSellingPrice => 'Qiimaha iibka';

  @override
  String posCatalogPrice(String price) {
    return 'Buugga: $price';
  }

  @override
  String get posDiscountAmount => 'Qadarka dhimista';

  @override
  String get posTaxInclSuffix => ' (ku jira)';

  @override
  String get posHeldSaleLabel => 'Iib la haysto';

  @override
  String inventoryKpiError(String detail) {
    return 'KPI qalad: $detail';
  }

  @override
  String get inventoryUpdated => 'Kaydka waa la cusbooneysiiyay';

  @override
  String inventoryAdjustTitle(String name) {
    return 'Hagaaji: $name';
  }

  @override
  String inventoryCurrentQty(int qty) {
    return 'Tirada hadda: $qty';
  }

  @override
  String get inventoryChangeDelta => 'Isbeddel (+/-)';

  @override
  String get inventoryReason => 'Sabab';

  @override
  String get inventoryStockValueCost => 'Qiimaha kaydka (kharash)';

  @override
  String inventoryBarcodeLine(String barcode, int qty) {
    return 'Barcode: $barcode • Tir $qty';
  }

  @override
  String inventoryQtyPill(int qty) {
    return 'Tir $qty';
  }

  @override
  String inventoryCostPill(String amount) {
    return 'Kharash $amount';
  }

  @override
  String inventorySellPill(String amount) {
    return 'Iib $amount';
  }

  @override
  String inventoryProfitPill(String amount) {
    return 'Faa\'iido $amount';
  }

  @override
  String get inventoryNoMatchingSubtitle =>
      'Isku day scan barcode ama beddel raadinta/shaandhada.';

  @override
  String get inventoryReasonDamaged => 'Alaab burburtay';

  @override
  String get inventoryReasonExpired => 'Alaab dhacday';

  @override
  String get inventoryReasonTheft => 'Xatooyo / dhimista';

  @override
  String get inventoryReasonReturn => 'Soo celin alaab-qeybiye';

  @override
  String get inventoryReasonCount => 'Hagaajinta tirinta kaydka';

  @override
  String get inventoryReasonInitial => 'Gelitaanka kaydka bilowga';

  @override
  String debtBalanceDue(String amount) {
    return 'Hadhaaga: $amount';
  }

  @override
  String get debtPaymentAmount => 'Qadarka lacag bixinta';

  @override
  String get debtSelectPaymentAccount => 'Dooro xisaabta lacag bixinta';

  @override
  String get debtNoWallets => 'Jeeb ma jiraan — marka hore seed accounting.';

  @override
  String debtPaymentExceeds(String amount) {
    return 'Ma dhaafi karo $amount';
  }

  @override
  String get debtPaymentRecorded => 'Lacag bixintu waa la diiwaangeliyay';

  @override
  String debtPaymentRemainingSync(String amount) {
    return 'Hadhaaga $amount • Kayd gudaha, sync socda';
  }

  @override
  String get rememberMe => 'I xasuuso';

  @override
  String get rememberMeSubtitle => 'Ku sii joog qalabkan';

  @override
  String get signingIn => 'Soo galaya…';

  @override
  String get newToInventraX => 'Cusub InventraX?';

  @override
  String get registerYourStore => 'Diiwaangeli dukaankaaga';

  @override
  String get backToWelcome => 'Ku noqo soo dhaweynta';

  @override
  String get authSupabaseSecured =>
      'Amniga Supabase Auth iyo go\'doominta tenant.';

  @override
  String get authOfflineMode =>
      'Habka offline — habee .env si aad u sync gareyso.';

  @override
  String get welcomeSubtitle =>
      'Maamul dukaankaaga si kalsooni leh. Diiwaangeli daqiiqado gudahood ama soo gal.';

  @override
  String get welcomeTagline => 'SaaS multi-tenant tafaariiq casri ah.';

  @override
  String get featureCloudSync => 'Cloud sync';

  @override
  String get featureOfflinePos => 'POS offline';

  @override
  String get featureRlsIsolation => 'RLS go\'doomin';

  @override
  String get featureBarcodeReady => 'Barcode diyaar';

  @override
  String get registerStepBusiness => 'Ganacsiga';

  @override
  String get registerStepOwner => 'Milkiilaha';

  @override
  String get registerStepReview => 'Dib u eeg';

  @override
  String get creatingStore => 'Abuuritaanka dukaanka…';

  @override
  String get tellUsBusiness => 'Noo sheeg ganacsigaaga';

  @override
  String get businessType => 'Nooca ganacsiga';

  @override
  String get country => 'Waddanka';

  @override
  String get taxNumberOptional => 'Lambarka canshuurta (ikhtiyaari)';

  @override
  String get ownerAccountTitle =>
      'Akoonka milkiilaha — waxaad noqon doontaa Store Owner';

  @override
  String get fullName => 'Magaca buuxa *';

  @override
  String get confirmPassword => 'Xaqiiji erayga sirta *';

  @override
  String get passwordHint => 'Ugu yaraan 8 xaraf, weyn, yar, iyo tiro.';

  @override
  String get reviewCreateStore => 'Dib u eeg oo abuur dukaanka';

  @override
  String get freeTrial14Day => 'Tijaabo 14 maalmood';

  @override
  String get storeOwnerPermissions => 'Doorka Store Owner oo buuxa';

  @override
  String get alreadyHaveAccountSignIn => 'Hore u leedahay akoon? Soo gal';

  @override
  String get storeNameRequired => 'Magaca dukaanka waa loo baahan yahay';

  @override
  String get ownerNameRequired => 'Magaca milkiilaha waa loo baahan yahay';

  @override
  String get emailRequired => 'Iimaylka waa loo baahan yahay';

  @override
  String get passwordsDoNotMatch => 'Erayada sirta isma laha';

  @override
  String get registrationFailed => 'Diiwaangelintu way fashilantay.';

  @override
  String get reviewLabelStore => 'Dukaan';

  @override
  String get reviewLabelType => 'Nooc';

  @override
  String get reviewLabelLocation => 'Goob';

  @override
  String get reviewLabelOwner => 'Milkiile';

  @override
  String get onboardingStoreSetup => 'Dejinta dukaanka';

  @override
  String get onboardingSkip => 'Ka bood';

  @override
  String get onboardingBusinessInfo => 'Macluumaadka ganacsiga';

  @override
  String get onboardingBusinessSubtitle => 'Noo sheeg dukaankaaga';

  @override
  String get onboardingLocalization => 'Dejinta luqadda';

  @override
  String get onboardingLocalizationSubtitle => 'Lacagta iyo canshuurta';

  @override
  String get onboardingBranding => 'Summadaynta';

  @override
  String get onboardingBrandingSubtitle => 'Troska rasiidka iyo summadda';

  @override
  String get onboardingChoosePlan => 'Dooro qorshaha';

  @override
  String get onboardingPlanSubtitle => 'Tijaabo 14 maalmood si toos ah';

  @override
  String get receiptHeaderText => 'Qoraalka troska rasiidka';

  @override
  String get phoneRequired => 'Telefoonka *';

  @override
  String get addressRequired => 'Cinwaanka *';

  @override
  String get purchaseCompleteTitle => 'Dhammaystir iibsiga';

  @override
  String purchaseTotal(String amount) {
    return 'Wadarta: $amount';
  }

  @override
  String get purchaseSelectPayAccount => 'Dooro xisaabta lacag bixinta';

  @override
  String get purchaseSaveOnCredit => 'Kaydi deyn ahaan';

  @override
  String get purchaseSavePurchase => 'Kaydi iibsiga';

  @override
  String purchaseCouldNotLoadAccounts(String detail) {
    return 'Lama soo rarin xisaabaadka: $detail';
  }

  @override
  String get purchaseAmountPaidNow => 'Lacagta la bixiyay hadda';

  @override
  String purchaseRemainingToDebt(String amount) {
    return 'Hadhaaga $amount → deynta alaab-qeybiyaha';
  }

  @override
  String purchaseCreditNoPayment(String amount) {
    return 'Lacag ma jirto. $amount oo dhan → Accounts Payable.';
  }

  @override
  String get purchasePayFromAccount => 'Ka bixi xisaabta';

  @override
  String get purchaseSetupAccountsFirst =>
      'Marka hore samee xisaabaadka Accounting.';

  @override
  String purchaseAddedProduct(String name) {
    return 'Waxaa lagu daray $name';
  }

  @override
  String get quickAddSupplier => 'Ku dar alaab-qeybiye degdeg';

  @override
  String purchaseUsingSupplier(String name) {
    return 'Isticmaal alaab-qeybiyaha: $name';
  }

  @override
  String get purchaseSelectSupplierFirst =>
      'Dooro ama ku dar alaab-qeybiye marka hore';

  @override
  String get purchaseNotSavedCancelled => 'Iibka lama kaydin — waa la joojiyay';

  @override
  String purchaseCouldNotSave(String detail) {
    return 'Lama kaydin iibka: $detail';
  }

  @override
  String purchaseSavedSummary(String total, String status) {
    return 'Iibka waa la kaydiyay • $total • $status';
  }

  @override
  String get navSupplier => 'Alaab-qeybiye';

  @override
  String get purchaseLookUp => 'Raadi';

  @override
  String purchaseInStockLine(int qty, String cost, String sell) {
    return 'Kayd: $qty • Kharash: $cost • Iib: $sell';
  }

  @override
  String get purchasePrice => 'Qiimaha iibsiga';

  @override
  String get newSellPriceOptional => 'Qiimaha iibka cusub (ikhtiyaari)';

  @override
  String get invoiceOptional => 'Qaansheeg # (ikhtiyaari)';

  @override
  String get purchaseCart => 'Gaadhiga iibsiga';

  @override
  String get purchaseCartEmpty =>
      'Scan ama raadi alaab.\nAlaabta jirta waxay muujinaysaa kaydka iyo qiimaha.';

  @override
  String purchaseStockLine(int stock, int add) {
    return 'Kayd $stock → +$add';
  }

  @override
  String purchaseMargin(String percent) {
    return 'Faa\'iido $percent%';
  }

  @override
  String get completePurchase => 'Dhammaystir iibsiga';

  @override
  String get saving => 'Kaydinaya…';

  @override
  String get selectOrAddSupplier => 'Dooro ama ku dar alaab-qeybiye';

  @override
  String get purchaseDetailTitle => 'Faahfaahinta iibsiga';

  @override
  String get purchaseNotFound => 'Iibka lama helin';

  @override
  String purchaseInvoiceLine(String number) {
    return 'Qaansheeg: $number';
  }

  @override
  String get lineItems => 'Qodobbada';

  @override
  String get acctMonthToDate => 'Bishii ilaa hadda';

  @override
  String get acctFinancialOverview => 'Dulmar dhaqaale';

  @override
  String acctRevenueLine(String amount) {
    return 'Dakhliga $amount';
  }

  @override
  String get acctAfterCogsExpenses => 'Ka dib COGS & kharashka';

  @override
  String get acctCashWallets => 'Lacag caddaan & jeebab';

  @override
  String get acctAllPaymentAccounts => 'Dhammaan xisaabaadka lacag bixinta';

  @override
  String get acctReceivable => 'Lacagta la sugayo';

  @override
  String get acctCustomerCredit => 'Deynta macmiilka';

  @override
  String get acctPayable => 'Lacagta la bixinayo';

  @override
  String get acctSupplierBalances => 'Hadhaaga alaab-qeybiyaha';

  @override
  String get acctTrialBalance => 'Dheelitirka tijaabada';

  @override
  String get acctBalanceSheet => 'Warqadda dheelitirka';

  @override
  String get acctJournals => 'Joornaalada';

  @override
  String acctChartError(String detail) {
    return 'Qaladka shaxda: $detail';
  }

  @override
  String get posCatalogLoadError => 'Lama soo rarin alaabta.';

  @override
  String get posNoProductsMatch => 'Alaab isma laha raadinta';

  @override
  String get viewGrid => 'Shabakad';

  @override
  String get viewList => 'Liis';

  @override
  String productCountLabel(int count) {
    return '$count alaab';
  }

  @override
  String get tagOut => 'Dham';

  @override
  String get tagLow => 'Yar';

  @override
  String get barcodeProductNotFound => 'Alaab lama helin';

  @override
  String barcodeNoMatch(String code) {
    return 'Barcode ma laha alaab:\n$code';
  }

  @override
  String get manualEntry => 'Geli gacanta';

  @override
  String get retryScan => 'Dib u scan';

  @override
  String get barcodeNoBarcode => 'Alaabtu barcode ma laha';

  @override
  String get barcodeLabelTitle => 'Summada barcode';

  @override
  String barcodeGenerated(String code) {
    return 'La sameeyay: $code';
  }

  @override
  String get purchasePriceRequired => 'Qiimaha iibsiga *';

  @override
  String get registerCreateStore => 'Abuur dukaan';

  @override
  String get storeNameField => 'Magaca dukaanka *';

  @override
  String get invalidPassword => 'Erayga sirta aan sax ahayn';

  @override
  String get authNoProfileHint =>
      'Akoonkaaga Auth waa jiraa laakiin profile dukaan ma laha. Oro supabase/scripts/setup_super_admin.sql, ama Diiwaangeli dukaanka hal mar iimaylkan.';

  @override
  String get barcodeDirectSale => 'Iib toos ah';

  @override
  String get barcodeAddNewProduct => 'Ku dar alaab cusub';

  @override
  String get acctNavSectionBooks => 'Buugaag';

  @override
  String get acctNavSectionCash => 'Lacag';

  @override
  String get acctNavSectionReports => 'Warbixinno';

  @override
  String get acctNavOverview => 'Dulmar';

  @override
  String get acctNavChartOfAccounts => 'Shaxda xisaabaadka';

  @override
  String get acctNavGeneralLedger => 'Buugga guud';

  @override
  String get acctNavDeposits => 'Dhigaal & bixid';

  @override
  String get acctNavPaymentAccounts => 'Xisaabaadka lacag bixinta';

  @override
  String get acctNavProfitLoss => 'Faa\'iido & khasaare';

  @override
  String get acctNavCashFlow => 'Socodka lacagta';

  @override
  String get acctNetProfit => 'Faa\'iidada nadiifka';

  @override
  String get acctRevenueLabel => 'Dakhliga';

  @override
  String get acctExpensesLabel => 'Kharashka';

  @override
  String get acctProfitLossShort => 'F&K';

  @override
  String get acctRevenueVsExpenses => 'Dakhliga vs kharashka';

  @override
  String get acctLast6Months => '6 bilood ee ugu dambeeyay';

  @override
  String get acctNoActivityYet => 'Weli wax dhaqdhaqaaq ah ma jiro';

  @override
  String get acctNoActivityHint =>
      'Dhammaystir iibka iyo kharashka si aad u aragto isbeddelka';

  @override
  String get acctBooksAtGlance => 'Buugaagta isha';

  @override
  String get acctDoubleEntry => 'Geli laba jibbaaran';

  @override
  String get acctStatusActive => 'Firfircoon';

  @override
  String get acctCashPosition => 'Booska lacagta';

  @override
  String get acctOutstandingAr => 'AR hadhay';

  @override
  String get acctOutstandingAp => 'AP hadhay';

  @override
  String get purchasePaid => 'La bixiyay';

  @override
  String get purchaseOutstanding => 'Hadhaaga';

  @override
  String get unknownSupplier => 'Alaab-qeybiye aan la aqoon';

  @override
  String get purchaseSelectPaymentAccount => 'Dooro xisaabta lacag bixinta';

  @override
  String get onboardingFinishSetup => 'Dhammaystir dejinta';

  @override
  String get onboardingBack => 'Dib';

  @override
  String get onboardingPlanFreeTrialDesc => '14 maalmood — POS & kayd buuxa';

  @override
  String get onboardingPlanBilledMonthly =>
      'Bil kasta marka lacag bixintu firfircoon tahay';

  @override
  String get onboardingTaxRateOptional => 'Heerka canshuurta % (ikhtiyaari)';

  @override
  String get onboardingPlanStarter => 'Bilow';

  @override
  String get onboardingPlanBusiness => 'Ganacsi';

  @override
  String get onboardingPlanFreeTrialName => 'Tijaabo bilaash';

  @override
  String get posAddMore => 'Ku dar dheeraad';

  @override
  String posProfitLine(String amount) {
    return 'Faa\'iido $amount';
  }

  @override
  String get posOutOfStock => 'Kayd ma jiro';

  @override
  String get posLowStock => 'Kayd yar';

  @override
  String posQtyInCart(int qty) {
    return '$qty gaadhiga';
  }

  @override
  String posSellLine(String amount) {
    return 'Iib $amount';
  }

  @override
  String posCostStockLine(String cost, int qty) {
    return 'Kharash $cost • Kayd $qty';
  }

  @override
  String get barcodeScanTitle => 'Scan barcode';

  @override
  String get acctNewJournalEntry => 'Geli joornaal cusub';

  @override
  String get acctManualJournalEntry => 'Geli joornaal gacanta';

  @override
  String get acctManualJournalSubtitle => 'Debit waa inuu la mid yahay credit';

  @override
  String get acctBalancedEntryRequired =>
      'Geli dheelitiran ayaa loo baahan yahay';

  @override
  String get acctEntryDetails => 'Faahfaahinta gelitaanka';

  @override
  String get acctEntryDate => 'Taariikhda gelitaanka';

  @override
  String get acctPostEntry => 'Daabac gelitaanka';

  @override
  String get acctFillRequiredFields =>
      'Buuxi dhammaan goobaha loo baahan yahay';

  @override
  String get acctJournalPosted => 'Joornaalka waa la daabacay';

  @override
  String get acctSelectAccountTitle => 'Dooro xisaab';

  @override
  String get acctSelectAccountSubtitle =>
      'Dooro xisaab si aad u aragto dhaqdhaqaaqa';

  @override
  String get acctNoLedgerActivity => 'Wax dhaqdhaqaaq ah ma jiro';

  @override
  String acctYearToDateAsOf(String date) {
    return 'Sannadka ilaa hadda · $date';
  }

  @override
  String acctAssetsLiabilitiesEquity(String date) {
    return 'Hantida, deynta & saamiga · $date';
  }

  @override
  String get acctAssetsEquals => 'Hantida = Deynta + Saamiga';

  @override
  String get acctAssets => 'Hantida';

  @override
  String get acctLiabilities => 'Deynta';

  @override
  String get acctEquity => 'Saamiga';

  @override
  String acctIncomeStatementPeriod(String period) {
    return 'Bayaanka dakhliga · $period';
  }

  @override
  String get acctCogs => 'Qiimaha alaabta la iibiyay';

  @override
  String get acctGrossProfit => 'Faa\'iidada guud';

  @override
  String acctSimplifiedViewPeriod(String period) {
    return 'Muuqaal fudud · $period';
  }

  @override
  String get acctNetMovement => 'Dhaqdhaqaaqa nadiifka';

  @override
  String get acctOperatingActivities => 'Hawlaha hawlgalka';

  @override
  String get acctNoJournalEntries => 'Weli gelitaan joornaal ma jiro';

  @override
  String get acctCreateManualEntry => 'Abuur gelitaan gacanta';

  @override
  String acctPostedEntriesCount(int count) {
    return '$count gelitaan (12 bilood)';
  }

  @override
  String get acctNewEntry => 'Geli cusub';

  @override
  String get acctNoPaymentAccountsTitle => 'Ma jiraan xisaabaad lacag bixin';

  @override
  String get acctPaymentAccountsAutoCreated =>
      'Xisaabaadka si toos ah ayaa loo abuuraa markaad soo gasho';

  @override
  String get acctAddAccount => 'Ku dar xisaab';

  @override
  String get acctDeleteDeactivate => 'Tirtir (jooji)';

  @override
  String get acctDeleteDeactivateHint =>
      'Qari xisaabtan. Lama oggolaan haddii la isticmaalay.';

  @override
  String get acctRestoreAccount => 'Soo celi xisaabta';

  @override
  String get acctDeleteAccountTitle => 'Tirtir xisaabta?';

  @override
  String acctAccountUpdated(String name) {
    return 'La cusbooneysiiyay: $name';
  }

  @override
  String get acctAddAccountDialogTitle => 'Ku dar xisaab';

  @override
  String get acctAccountTypeAsset => 'Hanti';

  @override
  String get acctAccountTypeLiability => 'Deyn';

  @override
  String get acctAccountTypeEquity => 'Saami';

  @override
  String get acctAccountTypeRevenue => 'Dakhli';

  @override
  String get acctAccountTypeExpense => 'Kharash';

  @override
  String get acctCreateButton => 'Abuur';

  @override
  String get acctAccountCreated => 'Xisaabta waa la abuuray';

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
  String get acctOwnerCashMovements => 'Dhaqdhaqaaqa lacagta milkiilaha';

  @override
  String get acctOwnerCashSubtitle =>
      'Diiwaangeli lacagta milkiiluhu ganacsiga ku shubo ama ka qaato';

  @override
  String get acctDeposit => 'Dhigaal';

  @override
  String get acctWithdrawal => 'Bixid';

  @override
  String get acctTransactionDetails => 'Faahfaahinta macaamilka';

  @override
  String get acctNoPaymentAccountsConfigured =>
      'Ma jiraan xisaabaad lacag bixin.';

  @override
  String get acctEnterValidAmount => 'Geli qadar sax ah';

  @override
  String acctExportFailed(String detail) {
    return 'Dhoofintu way fashilantay: $detail';
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
    return 'Iibka waa la kaydiyay laakiin xisaabtu way fashilantay: $detail';
  }

  @override
  String get platformCommandCenter => 'Xarunta amarka SaaS';

  @override
  String get platformNavOverview => 'Dulmar';

  @override
  String get platformNavBusiness => 'Ganacsi';

  @override
  String get platformNavOperations => 'Hawlgallo';

  @override
  String get platformNavDashboard => 'Dashboard';

  @override
  String get platformNavGlobalSearch => 'Raadinta guud';

  @override
  String get platformNavAllStores => 'Dhammaan dukaamada';

  @override
  String get platformNavBilling => 'Lacag bixinta';

  @override
  String get platformNavRevenue => 'Dakhliga';

  @override
  String get platformNavPlans => 'Qorshayaasha';

  @override
  String get platformNavStorage => 'Kaydinta';

  @override
  String get platformNavAlerts => 'Digniino';

  @override
  String get platformNavAudit => 'Diiwaanka hubinta';

  @override
  String get platformNavHealth => 'Caafimaadka nidaamka';

  @override
  String get platformStoreApp => 'App dukaanka';

  @override
  String get platformSuperAdmin => 'Super admin';

  @override
  String get platformAllStoresTitle => 'Dhammaan dukaamada';

  @override
  String get platformAllStoresSubtitle =>
      'Raadi, sifee, oo maamul tenant kasta';

  @override
  String get platformGlobalSearchTitle => 'Raadinta guud';

  @override
  String get platformAlertsTitle => 'Digniino';

  @override
  String get platformAlertsSubtitle =>
      'Isdiiwaangelin dhamaaday, tijaabo, kaydinta';

  @override
  String get platformStorageTitle => 'Kaydinta';

  @override
  String get platformStorageSubtitle => 'Isticmaalka faylasha ee platform';

  @override
  String get platformTotalStorage => 'Wadarta kaydinta platform';

  @override
  String get platformTotalStorageSubtitle =>
      'Sawirrada alaabta, astaamaha, lifaaqyada';

  @override
  String get platformTopStorageConsumers => 'Kuwa ugu badan kaydinta';

  @override
  String platformImagesCount(int count) {
    return '$count sawir';
  }

  @override
  String get platformAuditTitle => 'Diiwaanka hubinta';

  @override
  String get platformAuditSubtitle => 'Ficillada super admin';

  @override
  String get platformBillingTitle => 'Lacag bixinta & isdiiwaangelinta';

  @override
  String get platformBillingSubtitle =>
      'Maamul qorshaha, tijaabada, cusboonaysiinta';

  @override
  String get platformViewStore => 'Eeg dukaanka';

  @override
  String get platformSetActive => 'Ka dhig firfircoon';

  @override
  String get platformExtendTrial14d => 'Kordhi tijaabada 14 maalmood';

  @override
  String get platformSuspend => 'Hakad';

  @override
  String platformStoreUpdated(String name) {
    return 'La cusbooneysiiyay $name';
  }

  @override
  String get platformRevenueTitle => 'Dakhliga';

  @override
  String get platformRevenueSubtitle => 'MRR, ARR, iyo qaybinta qorshaha';

  @override
  String get platformMrrByPlan => 'MRR qorshe ahaan';

  @override
  String get platformPlanBreakdown => 'Qaybinta qorshaha';

  @override
  String platformStoresCount(int count) {
    return '$count dukaan';
  }

  @override
  String get platformStoreGrowth12m => 'Koritaanka dukaanka (12 bilood)';

  @override
  String get platformSubscriptionsByPlan => 'Isdiiwaangelinta qorshe ahaan';

  @override
  String get platformTopStorageUsage => 'Kaydinta ugu sarreysa';

  @override
  String get platformRecentStores => 'Dukaamada dhawaan';

  @override
  String get platformTotalStores => 'Wadarta dukaamada';

  @override
  String get platformTrialStores => 'Tijaabo';

  @override
  String get platformExpiredStores => 'Dhacay';

  @override
  String get platformMrr => 'MRR';

  @override
  String get platformPaidStores => 'Dukaamada la bixiyay';

  @override
  String get platformStoreNotFound => 'Dukaan lama helin';

  @override
  String get platformOpenStoreImpersonate => 'Fur dukaanka (impersonate)';

  @override
  String get platformBusinessAnalytics => 'Falanqaynta ganacsiga';

  @override
  String get platformSubscriptionControl => 'Xakamaynta isdiiwaangelinta';

  @override
  String platformSetPlan(String name) {
    return 'Deji $name';
  }

  @override
  String get platformActivate => 'Firfircooni';

  @override
  String get platformStoreInfo => 'Macluumaadka dukaanka';

  @override
  String get platformExitImpersonation => 'Ka bax';

  @override
  String get platformPlansTitle => 'Qorshayaasha isdiiwaangelinta';

  @override
  String get platformPlansSubtitle =>
      'Xadka alaabta, isticmaalayaasha, kaydinta';

  @override
  String get platformNewPlan => 'Qorshe cusub';

  @override
  String platformHealthUnavailable(String detail) {
    return 'Caafimaadka lama heli karo: $detail';
  }

  @override
  String get platformPendingSync => 'Sync sugaya';

  @override
  String get platformFailedPushes => 'Riixid fashilantay';

  @override
  String get platformProductsSessionStore => 'Alaabta (dukaanka fadhiga)';

  @override
  String get platformOpenFullHealth => 'Fur bogga caafimaadka buuxa';

  @override
  String get platformInventoryValue => 'Qiimaha kaydka';

  @override
  String acctChartAccountsSubtitle(int count) {
    return '$count xisaabaad · Ku dar xisaabaadkaaga oo dami kuwa aan la isticmaalin';
  }

  @override
  String get acctShowInactive => 'Muuji kuwa aan firfircoonayn';

  @override
  String get acctHideInactive => 'Qari kuwa aan firfircoonayn';

  @override
  String get acctSystemBadge => 'Nidaam';

  @override
  String get acctDeleteAccountBody =>
      'Tani waxay daminaysaa xisaabta (way qarsoomi doontaa). Xisaabaadka nidaamka ama kuwa loo isticmaalay joornaalada lama tirtiri karo.';

  @override
  String get acctBalancedEntryBannerSubtitle =>
      'Wadarta debetka waxaa loo celin doonaa kredithka xisaabta labaad';

  @override
  String get acctTypeSectionAsset => 'Hantida';

  @override
  String get acctTypeSectionLiability => 'Deymaha';

  @override
  String get acctTypeSectionEquity => 'Sinnaanta';

  @override
  String get acctTypeSectionRevenue => 'Dakhliga';

  @override
  String get acctTypeSectionExpense => 'Kharashka';

  @override
  String get acctAccountCode => 'Koodhka xisaabta';

  @override
  String get acctAccountNameLabel => 'Magaca xisaabta';

  @override
  String get acctAccountTypeLabel => 'Nooca xisaabta';

  @override
  String get acctOpeningBalanceOptional => 'Haraaga furitaanka (ikhtiyaari)';

  @override
  String get acctDescription => 'Sharaxaad';

  @override
  String get acctDebitAccount => 'Xisaabta debetka';

  @override
  String get acctCreditAccount => 'Xisaabta kredithka';

  @override
  String get acctAmount => 'Qadarka';

  @override
  String get acctNotesOptional => 'Qoraallo (ikhtiyaari)';

  @override
  String get acctDepositEntry => 'Geli dhigaalka';

  @override
  String get acctWithdrawalEntry => 'Geli bixinta';

  @override
  String get acctDepositBannerSubtitle => 'Debet Cash · Kredith Owner Capital';

  @override
  String get acctWithdrawalBannerSubtitle =>
      'Debet Owner Drawings · Kredith Cash';

  @override
  String get acctWalletAccount => 'Jeebka / xisaabta';

  @override
  String get acctPostDeposit => 'Dhig dhigaalka';

  @override
  String get acctPostWithdrawal => 'Dhig bixinta';

  @override
  String get acctDepositPosted => 'Dhigaalka waa la dhigay';

  @override
  String get acctWithdrawalPosted => 'Bixintu waa la dhigtay';

  @override
  String acctErrorDetail(String detail) {
    return 'Qalad: $detail';
  }

  @override
  String get platformSearchHint => 'Dukaamo, milkiile, iimayl, qorshayaal…';

  @override
  String get platformSearchMinChars => 'Qor ugu yaraan 2 xaraf';

  @override
  String platformSearchStoresSection(int count) {
    return 'Dukaamo ($count)';
  }

  @override
  String platformSearchPlansSection(int count) {
    return 'Qorshayaal ($count)';
  }

  @override
  String get platformSearchNoStores => 'Dukaan lama helin';

  @override
  String get platformSearchNoPlans => 'Qorshe lama helin';

  @override
  String get platformSystemHealthTitle => 'Caafimaadka nidaamka';

  @override
  String get platformEdit => 'Wax ka beddel';

  @override
  String platformErrorDetail(String detail) {
    return 'Qalad: $detail';
  }

  @override
  String get platformFilterAll => 'Dhammaan';

  @override
  String get platformFilterActive => 'Firfircoon';

  @override
  String get platformFilterTrial => 'Tijaabo';

  @override
  String get platformFilterExpired => 'Dhacay';

  @override
  String get platformFilterSuspended => 'Hakad';

  @override
  String get platformNoStoresMatchFilter => 'Dukaan kuma habboona sifeyntan';

  @override
  String get platformCreatePlan => 'Abuur qorshe';

  @override
  String get platformEditPlan => 'Wax ka beddel qorshe';

  @override
  String get platformPlanIdSlug => 'Aqoonsiga qorshaha (slug)';

  @override
  String get platformPlanNameLabel => 'Magac';

  @override
  String get platformPlanMonthlyPrice => 'Qiimaha bille (USD)';

  @override
  String get platformPlanProductLimit =>
      'Xadka alaabta (madhan = aan xad lahayn)';

  @override
  String get platformPlanUserLimit => 'Xadka isticmaalayaasha';

  @override
  String get platformProductsMetric => 'Alaab';

  @override
  String get platformSalesMetric => 'Iib';

  @override
  String get platformPurchasesMetric => 'Iibsasho';

  @override
  String get platformRevenueMetric => 'Dakhli';

  @override
  String get platformExpensesMetric => 'Kharash';

  @override
  String get platformCustomersMetric => 'Macaamiil';

  @override
  String get platformSuppliersMetric => 'Alaab bixiyeyaal';

  @override
  String get platformUsersMetric => 'Isticmaalayaal';

  @override
  String get platformDebtsMetric => 'Deymo';

  @override
  String get platformStorageSection => 'Kaydin';

  @override
  String get platformOwnerLabel => 'Milkiile';

  @override
  String get platformPhoneLabel => 'Telefoon';

  @override
  String get platformAddressLabel => 'Cinwaan';

  @override
  String get platformCountryLabel => 'Waddan';

  @override
  String get platformPlanLabel => 'Qorshe';

  @override
  String get platformCreatedLabel => 'La abuuray';

  @override
  String get authBrandTagline => 'Qorshaynta Khayraadka Ganacsiga';

  @override
  String get authWelcomeBack => 'Ku soo';

  @override
  String get authWelcomeBackHighlight => 'dhawoow!';

  @override
  String get authWelcomeMessage =>
      'Soo gal akoonkaaga oo maamul ganacsigaaga si caqli badan, degdeg ah, oo fudud.';

  @override
  String get authSignInTo => 'Soo gal';

  @override
  String get authEnterCredentials =>
      'Geli aqoonsigaaga si aad u gasho akoonkaaga';

  @override
  String get authEmailAddress => 'Cinwaanka emailka';

  @override
  String get authEmailHint => 'Geli emailkaaga';

  @override
  String get authPasswordHint => 'Geli erayga sirta ah';

  @override
  String get authForgotPassword => 'Ma illowday erayga sirta ah?';

  @override
  String get authOrContinueWith => 'ama sii wad';

  @override
  String authNewToBrand(String brandName) {
    return 'Cusub $brandName?';
  }

  @override
  String get authCreateAccount => 'Abuur akoon';

  @override
  String get authFeatureSecureTitle => 'Ammaan & Aamin';

  @override
  String get authFeatureSecureDesc => 'Ammaan heer bangi ah xogta ganacsigaaga';

  @override
  String get authFeatureFastTitle => 'Degdeg & Hufan';

  @override
  String get authFeatureFastDesc => 'Waxqabad hagaagsan hawlgallada maalinlaha';

  @override
  String get authFeatureAnalyticsTitle => 'Falanqayn Caqli leh';

  @override
  String get authFeatureAnalyticsDesc =>
      'Aragtiyo waqtiga dhabta ah go\'aamo wanaagsan';

  @override
  String get authFeatureCloudTitle => 'Cloud Sync';

  @override
  String get authFeatureCloudDesc => 'Hel xogtaada wakhti kasta, meel kasta';

  @override
  String get authLanguage => 'Luuqad';

  @override
  String authSocialComingSoon(String provider) {
    return 'Soo galitaanka $provider waa iman doonaa';
  }

  @override
  String get authForgotPasswordComingSoon =>
      'Dib u dejinta erayga sirta ah waa iman doontaa';

  @override
  String get authStoreNameHint => 'Geli magaca dukaankaaga';

  @override
  String get authBusinessTypeHint => 'tusaale Retail, Wholesale';

  @override
  String get authCountryHint => 'tusaale Ghana';

  @override
  String get authCurrencyHint => 'tusaale GHS';

  @override
  String get authAddressHint => 'Waddo, magaalo, gobol';

  @override
  String get authFullNameHint => 'Geli magacaaga oo buuxa';

  @override
  String get authPhoneHint => 'Geli lambarka taleefanka';

  @override
  String get authConfirmPasswordHint => 'Dib u geli erayga sirta ah';

  @override
  String get invoiceTitle => 'Invoice';

  @override
  String get invoiceNumber => 'Invoice #';

  @override
  String get invoiceDate => 'Taariikhda invoice';

  @override
  String get invoiceDueDate => 'Waqtiga la bixinayo';

  @override
  String get invoiceStatus => 'Xaalad';

  @override
  String get invoicePaymentStatus => 'Lacag bixin';

  @override
  String get invoiceBillTo => 'U dir';

  @override
  String get invoiceProduct => 'Alaab';

  @override
  String get invoiceSku => 'Barcode';

  @override
  String get invoiceQty => 'Tirada';

  @override
  String get invoiceUnitPrice => 'Qiimaha';

  @override
  String get invoiceDiscount => 'Qiimo dhimis';

  @override
  String get invoiceTax => 'Canshuur';

  @override
  String get invoiceLineTotal => 'Wadarta';

  @override
  String get invoiceSubtotal => 'Wadarta hoose';

  @override
  String get invoicePaid => 'La bixiyay';

  @override
  String get invoiceRemaining => 'Hadhaaga';

  @override
  String get invoiceGrandTotal => 'Wadarta guud';

  @override
  String get invoiceThankYou => 'Waad ku mahadsan tahay ganacsigaaga.';

  @override
  String get invoiceWalkIn => 'Macmiil toos ah';

  @override
  String get invoicePrint => 'Daabac';

  @override
  String get invoiceSharePdf => 'Wadaag PDF';

  @override
  String get invoiceViewA4 => 'Eeg invoice A4';

  @override
  String get invoiceOpenThermal => 'Rasiidka thermal';

  @override
  String subscriptionTrialEndsIn(int days) {
    return 'Tijaabada bilaashka ah waxay dhamaanaysaa $days maalmood';
  }

  @override
  String subscriptionExpiresIn(int days) {
    return 'Rukunkaagu wuxuu dhacayaa $days maalmood gudahood';
  }

  @override
  String get subscriptionUpgradeNow => 'Hadda cusboonaysii';

  @override
  String get subscriptionRenewNow => 'Hadda cusbooneysii';

  @override
  String get billingTitle => 'Biilasha & Rukunka';

  @override
  String get billingSubtitle =>
      'Maamul qorshahaaga iyo taariikhda lacag bixinta';

  @override
  String get billingRenewPlan => 'Cusbooneysii qorshaha';

  @override
  String get billingUpgrade => 'Kor u qaad';

  @override
  String get billingBuySms => 'Iibso SMS';

  @override
  String get billingPaymentFailed => 'Lacag bixintu way fashilantay';

  @override
  String get billingUnavailableOffline => 'Biilasha lama heli karo offline';

  @override
  String get billingViewAllPackages => 'Eeg dhammaan xirmooyinka';

  @override
  String get billingChoosePlanBelow =>
      'Dooro qorshe hoose si aad u cusbooneysiiso';

  @override
  String billingSubscribeTo(String plan) {
    return 'Iska qor $plan';
  }

  @override
  String get billingPerMonth => '/ bishii';

  @override
  String get billingSmsBalanceLabel => 'Hadhaaga SMS';

  @override
  String get billingCycleLabel => 'Biilasha';

  @override
  String billingRemainingSms(int count) {
    return 'SMS hadhay: $count';
  }

  @override
  String get billingNoTransactions => 'Weli ma jiraan lacag bixinno';

  @override
  String get billingPaymentHistory => 'Taariikhda lacag bixinta';

  @override
  String get billingUpgradePlan => 'Kor u qaad qorshaha';

  @override
  String get billingSmsMarketplace => 'Suuqa SMS';

  @override
  String get billingChoosePlan => 'Dooro qorshe';

  @override
  String get subscriptionRenewSubscription => 'Cusbooneysii rukunka';

  @override
  String get subscriptionUpgradePlan => 'Kor u qaad qorshaha';

  @override
  String get subscriptionAccountSettings => 'Dejinta akoonka';

  @override
  String get waafiPhoneLabel => 'Lambarka Waafi';

  @override
  String get waafiPhoneHint => '061… ama 25261…';

  @override
  String get waafiInstructions =>
      'Geli lambarka Waafi. Codsiga lacag bixinta ayaa telefoonkaaga loo diri doonaa — geli PIN-kaaga.';

  @override
  String get waafiSendPayment => 'PAY KTS';

  @override
  String get waafiSendingRequest => 'Diraya codsiga lacag bixinta…';

  @override
  String get waafiWaitingConfirmation => 'Sugaya xaqiijinta Waafi…';

  @override
  String get waafiProcessingPayment => 'Habeynaya lacag bixinta…';

  @override
  String waafiPaymentSentTo(String phone) {
    return 'Codsiga lacag bixinta waxaa loo diray:\n$phone';
  }

  @override
  String get waafiEnterPin =>
      'Fadlan geli PIN-kaaga telefoonka.\nWaxay qaadan kartaa dhowr ilbiriqsi.';

  @override
  String get waafiCancelPayment => 'Jooji lacag bixinta';

  @override
  String get waafiPaymentSuccess => 'Lacag bixintu waa guulaysatay';

  @override
  String waafiWalletBalance(int balance) {
    return 'Hadhaaga SMS: $balance';
  }

  @override
  String get waafiPaymentTimedOut => 'Waqtiga lacag bixintu wuu dhammaaday';

  @override
  String get waafiPaymentCancelled => 'Lacag bixinta waa la joojiyay';

  @override
  String get waafiPaymentNotCompleted => 'Lacag bixinta lama dhammaystirin';

  @override
  String get waafiPaymentFailed => 'Lacag bixintu way fashilantay';

  @override
  String get waafiNoPinConfirmation => 'PIN lama xaqiijin.';

  @override
  String get waafiPaymentCancelledDefault => 'Lacag bixinta waa la joojiyay.';

  @override
  String get waafiTryAgain => 'Isku day mar kale';

  @override
  String get waafiSendingRequestStatus => 'Diraya codsiga Waafi…';

  @override
  String get smsDashboardTitle => 'Dashboard-ka SMS';

  @override
  String get smsBuyPackage => 'Iibso xirmo SMS';

  @override
  String get smsSendReminder => 'Dir xusuusin deyn';

  @override
  String get smsEditTemplates => 'Wax ka beddel qaab-dhismeedka';

  @override
  String get smsTemplatesTitle => 'Qaab-dhismeedyada';

  @override
  String get smsLogsTitle => 'Diiwaanka SMS';

  @override
  String get smsRemindersTitle => 'Xusuusinno';

  @override
  String get smsQueued => 'SMS waa la safay — dhawaan waa la diri doonaa';

  @override
  String get smsCouldNotQueue => 'SMS lama safin karin';

  @override
  String get smsTemplateSaved => 'Qaab-dhismeedka waa la kaydiyay';

  @override
  String get smsBuyPackagesTitle => 'Iibso xirmooyin';

  @override
  String get smsBuyWithWaafi => 'PAY KTS';

  @override
  String get smsSend => 'Dir SMS';

  @override
  String smsToPhone(String phone) {
    return 'Ku: $phone';
  }

  @override
  String smsEditTemplate(String name) {
    return 'Wax ka beddel $name';
  }

  @override
  String get smsReminders3Days => '3 maalmood ka hor';

  @override
  String get smsReminders1Day => '1 maalin ka hor';

  @override
  String get smsRemindersOnDue => 'Maalinta ugu dambaysa';

  @override
  String get smsRemindersOverdue => 'Xusuusinno daahay';

  @override
  String get smsDailyCap => 'Xadka maalinlaha ah';

  @override
  String get smsDailyCapTitle => 'Xadka SMS maalinlaha ah';

  @override
  String get smsBuyPackageButton => 'Iibso xirmo';

  @override
  String get invoiceCompact => 'Kooban';

  @override
  String get invoiceDetailed => 'Faahfaahsan';

  @override
  String invoiceStatusBadge(String status) {
    return 'Xaalad: $status';
  }

  @override
  String invoicePaymentBadge(String status) {
    return 'Lacag bixinta: $status';
  }

  @override
  String get commonTryAgain => 'Isku day mar kale';

  @override
  String get smsScheduledReminders => 'Xusuusinno jadwal ah';

  @override
  String get smsScheduledRemindersSubtitle =>
      'Xusuusinno deyn oo otomaatig ah oo ku salaysan taariikhda';

  @override
  String get smsAutomatedReminders => 'Xusuusinno otomaatig ah';

  @override
  String get smsSendOnDueDates => 'Dir SMS taariikhda ugu dambaysa';

  @override
  String smsPerDay(int count) {
    return '$count SMS maalintii';
  }

  @override
  String get smsMaxPerDay => 'SMS ugu badan maalintii';

  @override
  String get smsReminderHistory => 'Taariikhda xusuusinta';

  @override
  String get smsNoRemindersYet => 'Weli xusuusin lama dirin';

  @override
  String get smsReminderTypeThreeDays => '3 maalmood ka hor';

  @override
  String get smsReminderTypeOneDay => '1 maalin ka hor';

  @override
  String get smsReminderTypeDueDate => 'Xusuusin taariikhda ugu dambaysa';

  @override
  String get smsReminderTypeOverdue => 'Xusuusin daahay';

  @override
  String get smsLogsSubtitle => 'Taariikhda gaarsiinta dukaankaaga';

  @override
  String get smsNoSmsSentYet => 'Weli SMS lama dirin';

  @override
  String get smsTemplatesReminderTitle => 'Qaab-dhismeedyada xusuusinta';

  @override
  String get smsTemplatesVariables =>
      'Doorsoomayaasha qaabka: customer_name, store_name, amount, invoice_number, due_date, payment_link';

  @override
  String get smsNoTemplatesYet =>
      'Weli qaab-dhismeed ma jiro — waxaa la abuuraa marka SMS wallet-kaagu diyaar noqdo.';

  @override
  String get smsTemplateHint =>
      'Isticmaal amount, store_name, iyo doorsoomayaal kale oo ku jira laba curly brace';

  @override
  String get smsBuyPackagesSubtitle =>
      'Iibso SMS credits Waafi Pay — EVC, Zaad, Sahal, WAAFI';

  @override
  String smsCloudBalance(int count) {
    return 'Hadhaaga cloud: $count SMS';
  }

  @override
  String get smsNoPackagesAvailable =>
      'Xirmooyin ma jiraan. La xiriir maamulka platform-ka.';

  @override
  String get healthTitle => 'Caafimaadka nidaamka';

  @override
  String get healthRefreshMetrics => 'Cusbooneysii cabbirada';

  @override
  String get healthRealtime => 'Waqtiga dhabta ah';

  @override
  String get healthSync => 'Isku-xirka';

  @override
  String get healthQueue => 'Safka';

  @override
  String healthQueueRetries(int count) {
    return '$count isku day';
  }

  @override
  String get healthNetwork => 'Shabakadda';

  @override
  String get healthOnline => 'Online';

  @override
  String get healthOffline => 'Offline';

  @override
  String get healthSyncTimeline => 'Jadwalka isku-xirka';

  @override
  String get healthLastPull => 'Soo-dejintii ugu dambaysay';

  @override
  String get healthLastPush => 'Diridii ugu dambaysay';

  @override
  String get healthLastSuccess => 'Isku-xirka guulaystay ee ugu dambeeyay';

  @override
  String get healthLastError => 'Khaladkii ugu dambeeyay';

  @override
  String get healthCloudConfigured => 'Cloud waa la habeeyay';

  @override
  String get healthYes => 'Haa';

  @override
  String get healthNo => 'Maya';

  @override
  String get healthBackgroundScheduler => 'Jadwalka asalka ah';

  @override
  String get healthRunning => 'Socda';

  @override
  String get healthInterval => 'Fogaanta';

  @override
  String get healthLastCycle => 'Wareegii ugu dambeeyay';

  @override
  String get healthInProgress => 'Waa socda';

  @override
  String get healthLocalDatabase => 'Database-ka maxalliga ah';

  @override
  String get healthCachedProducts => 'Alaabta kaydsan';

  @override
  String get healthDbFileSize => 'Cabbirka faylka DB';

  @override
  String get healthDbFileSizeWeb => 'N/A (web)';

  @override
  String healthDbFileSizeMb(String size) {
    return '$size MB';
  }

  @override
  String get healthQueueMaxRetries => 'Safka isku dayga ugu badan';

  @override
  String get healthQueueInspector => 'Kormeeraha safka';

  @override
  String get healthOpenFullQueue => 'Fur safka buuxa';

  @override
  String get healthQueueEmpty => 'Safku waa madhan';

  @override
  String get healthRecoveryActions => 'Tallaabooyinka soo kabashada';

  @override
  String get healthRecoverySubtitle =>
      'Isticmaal marka taageeradu u baahan tahay inay soo kabsato isku-xirka iyadoo POS aan la joojin.';

  @override
  String get healthRetryFailedSync => 'Isku day isku-xirka fashilmay';

  @override
  String get healthForceFullSync => 'Ku qasab isku-xir buuxa';

  @override
  String get healthClearHydrationCache => 'Nadiifi kaydka hydration';

  @override
  String get healthRebuildIndexes => 'Dib u dhiso index-yada maxalliga ah';

  @override
  String get healthQaValidation => 'Xaqiijinta QA';

  @override
  String get healthRealtimeEventLog =>
      'Diiwaanka dhacdooyinka waqtiga dhabta ah';

  @override
  String get healthAllOperational => 'Dhammaan nidaamyadu waa shaqeynayaan';

  @override
  String get healthSyncInProgress => 'Isku-xirku waa socdaa';

  @override
  String get healthAttentionNeeded => 'Fiiro gaar ah ayaa loo baahan yahay';

  @override
  String get healthOfflineLocalMode => 'Offline — hab maxalli ah';

  @override
  String get healthBadgeHealthy => 'Caafimaad qaba';

  @override
  String get healthBadgeActive => 'Firfircoon';

  @override
  String get healthBadgeReview => 'Dib u eegis';

  @override
  String get healthBadgeOffline => 'Offline';

  @override
  String get healthBadgeIdle => 'Aan shaqeyn';

  @override
  String healthQueuedRetryingRealtime(
    int queued,
    int retrying,
    String realtime,
  ) {
    return '$queued safka · $retrying isku day · Waqtiga dhabta ah $realtime';
  }

  @override
  String get healthOfflineSalesStored =>
      'Iibka iyo kaydka waxaa lagu kaydiyaa qalabkan.';

  @override
  String get healthRetryingFailedSync =>
      'Isku dayaya walxaha isku-xirka fashilmay';

  @override
  String get healthFullSyncCompleted => 'Isku-xirka buuxa waa dhammaaday';

  @override
  String get healthHydrationCleared =>
      'Kaydka hydration waa la nadiifiyay — isku-xirka xiga wuxuu soo dejin doonaa xog cusub';

  @override
  String get healthIndexesRebuilt =>
      'Index-yada maxalliga ah waa la dib u dhisay';

  @override
  String healthErrorDetail(String detail) {
    return 'Khalad: $detail';
  }

  @override
  String get healthRealtimeConnected => 'ku xiran';

  @override
  String get healthRealtimeReconnecting => 'dib u xiraya';

  @override
  String get healthRealtimeDisconnected => 'go\'an';

  @override
  String get healthRealtimeFailed => 'fashilmay';

  @override
  String healthSecondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String get aiRiskNegativeProfit => 'Faa\'iido taban';

  @override
  String aiRiskNegativeProfitMsg(String pct) {
    return 'Faa\'iidada bishan waa ka hooseysaa eber. Dib u eeg kharashyada ($pct% iibka) iyo faa\'iidada.';
  }

  @override
  String get aiRiskThinMargin => 'Faa\'iido yar';

  @override
  String aiRiskThinMarginMsg(String pct) {
    return 'Faa\'iidada waa $pct%. Ka fiirso qiimaha ama xakamaynta kharashka.';
  }

  @override
  String get aiRiskSalesDeclining => 'Iibku wuu hoos u dhacayaa';

  @override
  String aiRiskSalesDecliningMsg(String pct) {
    return 'Iibka 7 maalmood ee u dambeeyay waa $pct% marka la barbar dhigo 7 maalmood ee ka horreeyay.';
  }

  @override
  String get aiRiskHighExpense => 'Saamiga kharashka sare';

  @override
  String aiRiskHighExpenseMsg(String pct) {
    return 'Kharashyadu waa $pct% dakhliga bishan.';
  }

  @override
  String get aiRiskLowStock => 'Digniin kayd yar';

  @override
  String aiRiskLowStockMsg(int count) {
    return '$count alaab(o) ayaa gaadhay ama ka hooseeya kaydka ugu yar.';
  }

  @override
  String get aiRiskSlowMoving => 'Kayd si tartiib ah u socda';

  @override
  String aiRiskSlowMovingMsg(int count) {
    return '$count alaab ma iibin 30 maalmood ee u dambeeyay laakiin weli kayd bay leeyihiin.';
  }

  @override
  String get aiRiskHighDebt => 'Deyn macaamiil sare';

  @override
  String get aiRiskHighDebtMsg =>
      'Deynta macaamiisha way ka badan tahay iibka bishan.';

  @override
  String get aiRiskOverdueDebts => 'Deymo daahay';

  @override
  String aiRiskOverdueDebtsMsg(int count) {
    return '$count deyn(yo) ayaa daahay — raac ururinta.';
  }

  @override
  String get aiRiskOutOfStock => 'Kaydka wuu dhammaaday';

  @override
  String aiRiskOutOfStockMsg(int count) {
    return '$count SKU(yo) kaydkoodu wuu dhammaaday.';
  }

  @override
  String get platformSmsPackagesTitle => 'Xirmooyinka SMS';

  @override
  String get platformSmsPackagesSubtitle =>
      'Buugga suuqa — dukaamada waxay ku iibsadaan Waafi Pay';

  @override
  String get platformNewPackage => 'Xirmo cusub';

  @override
  String get platformCreateSmsPackage => 'Abuur xirmo SMS';

  @override
  String get platformEditSmsPackage => 'Wax ka beddel xirmada';

  @override
  String get platformSmsPackageId => 'Aqoonsiga (slug)';

  @override
  String get platformSmsPackageName => 'Magac';

  @override
  String get platformSmsPackageCount => 'Tirada SMS';

  @override
  String get platformSmsPackagePrice => 'Qiimaha (USD)';

  @override
  String get platformStoreSubscriptionsTitle => 'Rukunka Dukaamada';

  @override
  String get platformStoreSubscriptionsSubtitle =>
      'Dhammaan rukunka tenant-ka KULMIS ERP';

  @override
  String get platformStoreLabel => 'Dukaan';

  @override
  String get platformTrial => 'Tijaabo';

  @override
  String get platformPaid => 'La bixiyay';

  @override
  String get platformSmsWalletsTitle => 'SMS Wallets Dukaamada';

  @override
  String get platformSmsWalletsSubtitle => 'Hadhaaga SMS cloud dukaan kasta';

  @override
  String platformSmsUsedPurchased(int used, int purchased) {
    return 'La isticmaalay: $used • La iibsaday: $purchased';
  }

  @override
  String platformSmsRemaining(int count) {
    return '$count SMS';
  }

  @override
  String get platformTransactionsTitle => 'Lacag bixinnada';

  @override
  String get platformTransactionsSubtitle =>
      'Waafi iyo lacag bixinnada mustaqbalka';

  @override
  String get platformPaymentGatewayTitle => 'Albaabka Lacag bixinta';

  @override
  String get platformPaymentGatewaySubtitle =>
      'Habeynta Waafi Pay — aqoonsiyada Supabase secrets';

  @override
  String get platformWaafiEnabled => 'Waafi Pay waa furan';

  @override
  String get platformWaafiSandbox => 'Habka Waafi sandbox';

  @override
  String get platformNoSettings => 'Dejinta ma jirto';

  @override
  String get platformGatewaySecretsHelp =>
      'Deji secrets CLI:\nWAAFI_MERCHANT_UID, WAAFI_API_USER_ID, WAAFI_API_KEY\nWAAFI_SANDBOX=true, WAAFI_DEV_MODE=true\nPAYMENT_WEBHOOK_SECRET';

  @override
  String get platformTrialSettingsTitle => 'Dejinta Tijaabada';

  @override
  String get platformTrialSettingsSubtitle =>
      'Tijaabada bilaashka ah iyo muddada fasaxa dukaamada cusub';

  @override
  String get platformDefaultTrialDays => 'Maalmaha tijaabada ee caadiga ah';

  @override
  String get platformGracePeriod => 'Muddada fasaxa ka dib dhicitaanka';

  @override
  String platformDaysCount(int count) {
    return '$count maalmood';
  }

  @override
  String get platformTrialDaysTitle => 'Maalmaha tijaabada';

  @override
  String get platformGracePeriodDaysTitle => 'Maalmaha muddada fasaxa';

  @override
  String get platformDaysLabel => 'Maalmood';

  @override
  String get platformRevenueAnalyticsTitle => 'Falanqaynta Dakhliga';

  @override
  String get platformRevenueAnalyticsSubtitle =>
      'Dakhliga la ururiyay, MRR, tijaabooyin, iyo iibka SMS';

  @override
  String get platformTotalRevenue => 'Dakhliga guud';

  @override
  String get platformSubscriptionRevenue => 'Dakhliga rukunka';

  @override
  String get platformSmsRevenue => 'Dakhliga SMS';

  @override
  String get platformMrrContracted => 'MRR (qandaraaska)';

  @override
  String get platformActiveSubs => 'Rukunno firfircoon';

  @override
  String get platformTrialing => 'Tijaabada';

  @override
  String get platformTrialsExpiring7d => 'Tijaabooyin dhacaya (7d)';

  @override
  String get platformFailedPayments30d => 'Lacag bixinno fashilmay (30d)';

  @override
  String get platformOtpTitle => 'Kaabayaasha OTP';

  @override
  String get platformOtpSubtitle =>
      'Xaqiijinta auth dhexe — branding badan, Hormuud, xadka codsiyada';

  @override
  String get platformOtpSentToday => 'La diray maanta';

  @override
  String get platformOtpVerifiedToday => 'La xaqiijiyay maanta';

  @override
  String get platformOtpFailedToday => 'Fashilmay maanta';

  @override
  String get platformOtpPending => 'Sugaya (firfircoon)';

  @override
  String get platformAppBranding => 'Branding app-ka';

  @override
  String get platformAppBrandingSubtitle =>
      'KULMIS ERP (kulmis-erp) — qaab-dhismeedyada otp_apps. Ku dar apps badan KULMIS PAY iyo alaabada kale.';

  @override
  String get platformRealtimeStatus => 'Xaaladda waqtiga dhabta ah';

  @override
  String get platformWebsocketHealth => 'Caafimaadka websocket';

  @override
  String get platformFailedPayments24h => 'Lacag bixinno fashilmay (24h)';

  @override
  String get platformFailedSms24h => 'SMS fashilmay (24h)';

  @override
  String get platformEventLog => 'Diiwaanka dhacdooyinka';

  @override
  String get platformSearchButton => 'Raadi';

  @override
  String get platformStoresSearchHint => 'Magaca dukaanka, milkiilaha, email…';
}
