// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'तक्ष ई-कॉमर्स';

  @override
  String get madeInIndia => 'भारत में निर्मित';

  @override
  String get initializing => 'आरंभ हो रहा है...';

  @override
  String get checkingAuthentication => 'प्रमाणीकरण की जाँच हो रही है...';

  @override
  String get loadingData => 'डेटा लोड हो रहा है...';

  @override
  String get login => 'लॉगिन';

  @override
  String get loginTagline => 'भोजन आपके दरवाजे तक पहुँचाया गया';

  @override
  String get enterPhoneDescription =>
      'ओटीपी प्राप्त करने के लिए अपना फोन नंबर दर्ज करें';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get enterPhoneNumberHint => '10 अंकों का फोन नंबर दर्ज करें';

  @override
  String get sendOtp => 'ओटीपी भेजें';

  @override
  String get termsAndPrivacy =>
      'जारी रखकर, आप हमारी सेवा की शर्तों और गोपनीयता नीति से सहमत होते हैं';

  @override
  String get verifyOtp => 'ओटीपी सत्यापित करें';

  @override
  String enterOtpDescription(String phone) {
    return '$phone पर भेजा गया 4-अंकीय कोड दर्ज करें';
  }

  @override
  String get otpHint => '0000';

  @override
  String get verifyOtpButton => 'ओटीपी सत्यापित करें';

  @override
  String get didNotReceiveCode => 'कोड प्राप्त नहीं हुआ? ';

  @override
  String resendIn(int seconds) {
    return '${seconds}s में पुनः भेजें';
  }

  @override
  String get resendOtp => 'ओटीपी पुनः भेजें';

  @override
  String get otpResentSuccess => 'ओटीपी सफलतापूर्वक पुनः भेजा गया';

  @override
  String get loginSuccess => 'लॉगिन सफल रहा';

  @override
  String get phoneRequired => 'फ़ोन नंबर आवश्यक है';

  @override
  String get invalidPhone => 'एक मान्य 10-अंकीय फ़ोन नंबर दर्ज करें';

  @override
  String get otpRequired => 'ओटीपी आवश्यक है';

  @override
  String get invalidOtp => 'एक मान्य 4-अंकीय ओटीपी दर्ज करें';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get appearance => 'दिखावट';

  @override
  String get light => 'हल्का';

  @override
  String get dark => 'डार्क';

  @override
  String get system => 'सिस्टम';

  @override
  String themeChanged(String theme) {
    return 'थीम बदलकर $theme कर दी गई';
  }

  @override
  String get preferences => 'वरीयताएँ';

  @override
  String get language => 'भाषा';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get hindi => 'हिंदी';

  @override
  String languageChanged(String language) {
    return 'भाषा बदलकर $language कर दी गई';
  }

  @override
  String get general => 'सामान्य';

  @override
  String get myAddress => 'मेरा पता';

  @override
  String get coupons => 'कूपन';

  @override
  String get paymentMethodsComingSoon => 'भुगतान के तरीके - जल्द ही आ रहे हैं';

  @override
  String get earnings => 'कमाई';

  @override
  String get joinAsDeliveryMan => 'डिलीवरी मैन के रूप में शामिल हों';

  @override
  String get openVendor => 'वेंडर खोलें';

  @override
  String get languageSettingsComingSoon => 'भाषा सेटिंग्स - जल्द ही आ रही हैं';

  @override
  String get createApplication => 'एप्लिकेशन बनाएं';

  @override
  String get createWebsite => 'वेबसाइट बनाएं';

  @override
  String get helpAndSupport => 'सहायता और समर्थन';

  @override
  String get liveChat => 'लाइव चैट';

  @override
  String get aboutUs => 'हमारे बारे में';

  @override
  String get termsAndConditions => 'नियम और शर्तें';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get refundPolicy => 'धनवापसी नीति';

  @override
  String get support => 'सहायता';

  @override
  String get remove => 'हटाएं';

  @override
  String get clear => 'साफ़ करें';

  @override
  String get logout => 'लॉगआउट';

  @override
  String version(String version) {
    return 'संस्करण $version';
  }

  @override
  String get standardDelivery => 'स्टैंडर्ड डिलीवरी';

  @override
  String get standardDeliveryDescription =>
      'स्टैंडर्ड डिलीवरी - अपने पसंदीदा सामान की खरीदारी करें!';

  @override
  String get quickDelivery => 'क्विक डिलीवरी';

  @override
  String get quickDeliveryDescription => 'क्विक डिलीवरी - एक्सप्रेस 30';

  @override
  String get homeService => 'होम सर्विस';

  @override
  String get homeServiceDescription => 'होम सर्विसेज जल्द ही आ रही हैं';

  @override
  String get searchHint => 'उत्पादों की खोज करें...';

  @override
  String get somethingWentWrong => 'ओह! कुछ गलत हो गया';

  @override
  String get tryAgain => 'फिर से प्रयास करें';

  @override
  String get exitAppTitle => 'ऐप से बाहर निकलें?';

  @override
  String get exitAppContent => 'क्या आप वाकई बाहर निकलना चाहते हैं?';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get exit => 'बाहर निकलें';

  @override
  String get homeTab => 'होम';

  @override
  String get categoriesTab => 'श्रेणियाँ';

  @override
  String get cartTab => 'कार्ट';

  @override
  String get ordersTab => 'ऑर्डर';

  @override
  String get profileTab => 'प्रोफ़ाइल';

  @override
  String get cart => 'कार्ट';

  @override
  String get clearCart => 'कार्ट खाली करें';

  @override
  String get cartEmptyTitle => 'आपकी कार्ट खाली है';

  @override
  String get cartEmptySubtitle => 'शुरू करने के लिए आइटम जोड़ें';

  @override
  String get startShopping => 'खरीदारी शुरू करें';

  @override
  String sku(String sku) {
    return 'SKU: $sku';
  }

  @override
  String total(String amount) {
    return 'कुल: ₹$amount';
  }

  @override
  String get removeItemTitle => 'आइटम हटाएं';

  @override
  String removeItemConfirm(String product) {
    return 'कार्ट से $product हटाएं?';
  }

  @override
  String get clearCartConfirm => 'कार्ट से सभी आइटम हटाएं?';

  @override
  String totalItemsLabel(int count) {
    return 'कुल आइटम: $count';
  }

  @override
  String get proceedToCheckout => 'चेकआउट के लिए आगे बढ़ें';

  @override
  String get myOrders => 'मेरे ऑर्डर';

  @override
  String get filterByStatus => 'स्थिति के अनुसार फ़िल्टर करें';

  @override
  String get allOrders => 'सभी ऑर्डर';

  @override
  String get readyForDispatch => 'शिपमेंट के लिए तैयार';

  @override
  String get dispatched => 'भेज दिया गया';

  @override
  String get delivered => 'पहुँचा दिया गया';

  @override
  String get dateNewestFirst => 'दिनांक: नवीनतम पहले';

  @override
  String get dateOldestFirst => 'दिनांक: सबसे पुराना पहले';

  @override
  String get amountHighToLow => 'राशि: उच्च से निम्न';

  @override
  String get amountLowToHigh => 'राशि: निम्न से उच्च';

  @override
  String get recentlyUpdated => 'हाल ही में अपडेट किया गया';

  @override
  String get leastRecentlyUpdated => 'सबसे कम हाल ही में अपडेट किया गया';

  @override
  String get noOrdersFound => 'कोई ऑर्डर नहीं मिला';

  @override
  String get tryAdjustingFilters =>
      'अपने फ़िल्टर को समायोजित करने का प्रयास करें';

  @override
  String get filterByDate => 'तारीख़ से फ़िल्टर करें';

  @override
  String get clearDateFilter => 'तारीख़ फ़िल्टर हटाएँ';

  @override
  String get noOrdersYet => 'अभी तक कोई ऑर्डर नहीं';

  @override
  String get yourOrdersAppearHere => 'आपके ऑर्डर यहाँ दिखाई देंगे';

  @override
  String orderNumber(String number) {
    return 'ऑर्डर # $number';
  }

  @override
  String get today => 'आज';

  @override
  String get yesterday => 'कल';

  @override
  String daysAgo(int days) {
    return '$days दिन पहले';
  }

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम',
      one: '1 आइटम',
    );
    return '$_temp0';
  }

  @override
  String estDelivery(String date) {
    return 'अनुमानित डिलीवरी: $date';
  }

  @override
  String get orderDetails => 'ऑर्डर विवरण';

  @override
  String placedOn(String date) {
    return '$date को दिया गया';
  }

  @override
  String get deliveryType => 'डिलीवरी का प्रकार';

  @override
  String get paymentMethod => 'भुगतान का तरीका';

  @override
  String get paymentStatus => 'भुगतान की स्थिति';

  @override
  String get estimatedDelivery => 'अनुमानित डिलीवरी';

  @override
  String get invoice => 'इनवॉइस';

  @override
  String get cancelOrder => 'ऑर्डर रद्द करें';

  @override
  String orderItems(int count) {
    return 'ऑर्डर आइटम ($count)';
  }

  @override
  String qtyPrice(int qty, String price) {
    return 'मात्रा: $qty × ₹$price';
  }

  @override
  String get returnItem => 'आइटम वापस करें';

  @override
  String get deliveryAddress => 'डिलीवरी का पता';

  @override
  String get paymentInformation => 'भुगतान की जानकारी';

  @override
  String paidVia(String method) {
    return '$method के माध्यम से भुगतान किया गया';
  }

  @override
  String get orders => 'ऑर्डर';

  @override
  String get wishlist => 'विशलिस्ट';

  @override
  String get reviews => 'समीक्षाएं';

  @override
  String get whatsappError =>
      'WhatsApp नहीं खुल सका। कृपया सुनिश्चित करें कि WhatsApp इंस्टॉल है।';

  @override
  String lastUpdated(String date) {
    return 'अंतिम अपडेट: $date';
  }

  @override
  String get termsIntroTitle =>
      '1. परिचय और स्वीकृति';

  @override
  String get termsIntroContent =>
      'TAKSH ALL IN ONE ECOMMERCE & LOGISTICS WITH MULTI SERVICES PRIVATE LIMITED ("Taksh", "हम") द्वारा संचालित Taksh में आपका स्वागत है। ये नियम और शर्तें हमारे मोबाइल एप्लिकेशन और संबंधित सेवाओं ("प्लेटफ़ॉर्म") के उपयोग को नियंत्रित करती हैं। प्लेटफ़ॉर्म को डाउनलोड करने, रजिस्टर करने या उपयोग करने पर आप इन शर्तों से सहमत होते हैं। यदि आप सहमत नहीं हैं, तो कृपया प्लेटफ़ॉर्म का उपयोग न करें।\n\nआपकी आयु कम से कम 18 वर्ष होनी चाहिए और आप भारतीय अनुबंध अधिनियम, 1872 के तहत अनुबंध करने में सक्षम होने चाहिए। नाबालिग केवल माता-पिता या अभिभावक की निगरानी में प्लेटफ़ॉर्म का उपयोग कर सकते हैं।';

  @override
  String get termsAccountTitle =>
      '2. अकाउंट रजिस्ट्रेशन';

  @override
  String get termsAccountContent =>
      'आप अपने मोबाइल नंबर से साइन इन करते हैं, जिसे वन-टाइम पासवर्ड (OTP) से सत्यापित किया जाता है। आप सहमत हैं कि आप:\n\n• सही और पूरी जानकारी देंगे\n• अपने डिवाइस और OTP को गोपनीय रखेंगे और OTP किसी के साथ साझा नहीं करेंगे\n• अनधिकृत उपयोग का संदेह होने पर हमें तुरंत बताएंगे\n• अपने अकाउंट की सभी गतिविधियों की ज़िम्मेदारी लेंगे\n\nहम गलत जानकारी देने वाले या इन शर्तों का उल्लंघन करने वाले अकाउंट को निलंबित या बंद कर सकते हैं।';

  @override
  String get termsUserRespTitle =>
      '3. उपयोगकर्ता की ज़िम्मेदारियाँ';

  @override
  String get termsUserRespContent =>
      'प्लेटफ़ॉर्म के उपयोगकर्ता के रूप में आप सहमत हैं कि आप:\n\n• इसका उपयोग केवल कानूनी उद्देश्यों के लिए करेंगे\n• गलत जानकारी नहीं देंगे और किसी और का रूप नहीं धरेंगे\n• ऑफ़र, कूपन या रेफ़रल लाभों का दुरुपयोग नहीं करेंगे\n• अपमानजनक, भ्रामक या गैरकानूनी रिव्यू या सामग्री पोस्ट नहीं करेंगे\n• प्लेटफ़ॉर्म की नकल, स्क्रैपिंग या उसमें बाधा नहीं डालेंगे और हमारे सिस्टम तक अनधिकृत पहुँच का प्रयास नहीं करेंगे\n• दूसरों के बौद्धिक संपदा अधिकारों का उल्लंघन नहीं करेंगे';

  @override
  String get termsProductsTitle =>
      '4. उत्पाद और कीमतें';

  @override
  String get termsProductsContent =>
      'हम उत्पाद का विवरण, तस्वीरें, कीमतें और उपलब्धता सही दिखाने का प्रयास करते हैं। फिर भी:\n\n• तस्वीरें केवल उदाहरण के लिए हैं; रंग या पैकेजिंग थोड़ी अलग हो सकती है\n• सभी कीमतें भारतीय रुपये (INR) में हैं और जब तक अन्यथा न लिखा हो, लागू करों सहित हैं\n• डिलीवरी या हैंडलिंग शुल्क, यदि कोई हो, ऑर्डर देने से पहले दिखाया जाता है\n• कीमतें, ऑफ़र और उपलब्धता बिना सूचना के बदल सकती हैं; ऑर्डर देते समय दिखाई गई कीमत लागू होगी\n• यदि किसी तकनीकी या टाइपिंग त्रुटि से उत्पाद की कीमत गलत दिखे, तो हम ऑर्डर रद्द कर सकते हैं और चुकाई गई राशि लौटा देंगे';

  @override
  String get termsOrdersTitle =>
      '5. ऑर्डर';

  @override
  String get termsOrdersContent =>
      '• ऑर्डर देना खरीदने का प्रस्ताव है। अनुबंध तभी बनता है जब हम आपका ऑर्डर कन्फ़र्म करते हैं\n• आप पुष्टि करते हैं कि आपकी दी हुई जानकारी (डिलीवरी पता और फ़ोन नंबर सहित) सही है\n• स्टॉक न होने, कीमत की गलती, धोखाधड़ी के संदेह या पता सेवा क्षेत्र से बाहर होने पर हम ऑर्डर रद्द या अस्वीकार कर सकते हैं। यदि आपने भुगतान कर दिया है, तो राशि लौटाई जाएगी\n• कुछ उत्पादों पर मात्रा की सीमा लागू हो सकती है';

  @override
  String get termsPaymentTitle =>
      '6. भुगतान';

  @override
  String get termsPaymentContent =>
      '• आप हमारे पेमेंट गेटवे से ऑनलाइन (UPI, कार्ड, नेट बैंकिंग या वॉलेट) भुगतान कर सकते हैं, या जहाँ उपलब्ध हो वहाँ कैश ऑन डिलीवरी चुन सकते हैं\n• ऑनलाइन भुगतान तृतीय-पक्ष पेमेंट गेटवे द्वारा प्रोसेस होते हैं। हम आपका कार्ड नंबर, CVV, UPI PIN या बैंकिंग पासवर्ड स्टोर नहीं करते\n• आप पुष्टि करते हैं कि आप चुने गए भुगतान माध्यम का उपयोग करने के लिए अधिकृत हैं\n• यदि पैसा कट गया लेकिन ऑर्डर कन्फ़र्म नहीं हुआ, तो राशि सामान्यतः 5 से 7 कार्य दिवसों में अपने-आप वापस आ जाती है। न आने पर कृपया लेन-देन विवरण के साथ हमसे संपर्क करें\n• कैश ऑन डिलीवरी के लिए कृपया डिलीवरी पर भुगतान तैयार रखें। बार-बार ऑर्डर अस्वीकार करने या न लेने वाले अकाउंट पर हम कैश ऑन डिलीवरी सीमित या बंद कर सकते हैं';

  @override
  String get termsShippingTitle =>
      '7. डिलीवरी';

  @override
  String get termsShippingContent =>
      '• डिलीवरी विकल्प (एक्सप्रेस 30-मिनट, नेक्स्ट-डे और स्टैंडर्ड) आपके स्थान और उत्पाद की उपलब्धता पर निर्भर हैं\n• डिलीवरी का समय अनुमानित है, गारंटी नहीं। मौसम, ट्रैफ़िक, अधिक माँग या हमारे नियंत्रण से बाहर कारणों से देरी हो सकती है\n• कृपया पूरा और सही पता दें और अपना फ़ोन उपलब्ध रखें। गलत या अधूरी जानकारी से डिलीवरी विफल होने पर हम ज़िम्मेदार नहीं हैं\n• कृपया डिलीवरी पर अपना सामान जाँचें और कोई समस्या हो तो जल्द से जल्द बताएं\n• डिलीवरी के बाद नुकसान का जोखिम आपका होगा';

  @override
  String get termsCancelTitle =>
      '8. रद्द करना';

  @override
  String get termsCancelContent =>
      '• आप ऑर्डर डिस्पैच होने से पहले ऐप से या हमसे संपर्क करके उसे रद्द कर सकते हैं\n• डिस्पैच होने के बाद ऑर्डर रद्द नहीं हो सकता, लेकिन हमारी रिफंड और रिटर्न पॉलिसी के अनुसार वापस किया जा सकता है\n• डिस्पैच से पहले रद्द किए गए प्रीपेड ऑर्डर का रिफंड हमारी रिफंड और रिटर्न पॉलिसी के अनुसार किया जाता है';

  @override
  String get termsReturnsTitle =>
      '9. रिटर्न और रिफंड';

  @override
  String get termsReturnsContent =>
      'रिटर्न, रिप्लेसमेंट और रिफंड हमारी रिफंड और रिटर्न पॉलिसी से नियंत्रित होते हैं, जो इन शर्तों का हिस्सा है। संक्षेप में:\n\n• रिटर्न अनुरोध उत्पाद के लिए बताई गई रिटर्न अवधि के भीतर ऐप में करना होगा\n• सामान अनयूज़्ड और मूल स्थिति व पैकेजिंग में होना चाहिए\n• कुछ वस्तुएँ वापस नहीं हो सकतीं, जैसा पॉलिसी में बताया गया है\n• वापस किए गए सामान का स्वीकृत रिफंड आपके Taksh वॉलेट में जमा किया जाता है';

  @override
  String get termsOffersTitle =>
      '10. ऑफ़र और तृतीय-पक्ष विक्रेता';

  @override
  String get termsOffersContent =>
      '• ऑफ़र, छूट और कूपन की अपनी शर्तें, वैधता और उपयोग सीमा होती हैं और उन्हें कभी भी बदला या हटाया जा सकता है\n• कुछ उत्पाद तृतीय-पक्ष विक्रेताओं द्वारा बेचे जाते हैं और हमारे फ़ुलफ़िलमेंट सेंटर या डिलीवरी पार्टनर के ज़रिए पहुँचाए जाते हैं। Taksh बिक्री की सुविधा देता है और जहाँ लागू हो, विक्रेता का विवरण उत्पाद पेज पर दिखाया जाता है\n• प्लेटफ़ॉर्म में तृतीय-पक्ष सेवाओं के लिंक हो सकते हैं। उनकी सामग्री या तरीकों के लिए हम ज़िम्मेदार नहीं हैं';

  @override
  String get termsIpTitle =>
      '11. बौद्धिक संपदा';

  @override
  String get termsIpContent =>
      'प्लेटफ़ॉर्म की सभी सामग्री, जिसमें लोगो, ट्रेडमार्क, टेक्स्ट, ग्राफ़िक्स, तस्वीरें और सॉफ़्टवेयर शामिल हैं, Taksh या उसके लाइसेंसदाताओं की है और भारतीय बौद्धिक संपदा कानूनों से सुरक्षित है। हमारी लिखित अनुमति के बिना आप इसकी नकल, बदलाव, वितरण या व्यावसायिक उपयोग नहीं कर सकते।';

  @override
  String get termsPrivacyTitle =>
      '12. गोपनीयता और डेटा सुरक्षा';

  @override
  String get termsPrivacyContent =>
      'आपकी गोपनीयता हमारे लिए महत्वपूर्ण है। हम आपका व्यक्तिगत डेटा हमारी प्राइवेसी पॉलिसी के अनुसार एकत्र और उपयोग करते हैं। प्लेटफ़ॉर्म का उपयोग करके आप इसके लिए सहमति देते हैं।';

  @override
  String get termsLiabilityTitle =>
      '13. दायित्व की सीमा';

  @override
  String get termsLiabilityContent =>
      'कानून द्वारा अनुमत सीमा तक:\n\n• प्लेटफ़ॉर्म "जैसा है" और "जैसा उपलब्ध है" के आधार पर दिया जाता है। हम वादा नहीं करते कि यह हमेशा निर्बाध या त्रुटिरहित रहेगा\n• हम अप्रत्यक्ष या परिणामी नुकसान के लिए उत्तरदायी नहीं हैं\n• किसी ऑर्डर से जुड़े दावे पर हमारा कुल दायित्व उस ऑर्डर के लिए आपके द्वारा चुकाई गई राशि तक सीमित है\n• निर्माता की वारंटी, यदि कोई हो, निर्माता द्वारा दी जाती है\n\nइन शर्तों में कुछ भी उपभोक्ता संरक्षण अधिनियम, 2019 के तहत आपके अधिकारों को सीमित नहीं करता।';

  @override
  String get termsIndemnifyTitle =>
      '14. क्षतिपूर्ति';

  @override
  String get termsIndemnifyContent =>
      'आप सहमत हैं कि इन शर्तों के उल्लंघन, किसी कानून के उल्लंघन या दूसरों के अधिकारों के हनन से उत्पन्न दावों, नुकसान और खर्चों से आप Taksh को सुरक्षित रखेंगे।';

  @override
  String get termsModTitle =>
      '15. शर्तों में बदलाव';

  @override
  String get termsModContent =>
      'हम समय-समय पर इन शर्तों को अपडेट कर सकते हैं। अपडेट की गई शर्तें नई "अंतिम अपडेट" तारीख के साथ ऐप में दिखाई जाएंगी। बदलाव के बाद प्लेटफ़ॉर्म का उपयोग जारी रखने पर आप अपडेट की गई शर्तें स्वीकार करते हैं।';

  @override
  String get termsTerminationTitle =>
      '16. निलंबन और समाप्ति';

  @override
  String get termsTerminationContent =>
      'यदि आप इन शर्तों का उल्लंघन करते हैं, प्लेटफ़ॉर्म का दुरुपयोग करते हैं या कानून इसकी माँग करता है, तो हम आपकी पहुँच निलंबित या समाप्त कर सकते हैं। आप कभी भी प्लेटफ़ॉर्म का उपयोग बंद कर सकते हैं और अपना अकाउंट हटा सकते हैं। समाप्ति से पहले उत्पन्न अधिकार और दायित्व जारी रहते हैं।';

  @override
  String get termsLawTitle =>
      '17. लागू कानून और क्षेत्राधिकार';

  @override
  String get termsLawContent =>
      'ये शर्तें भारत के कानूनों द्वारा नियंत्रित हैं। लागू कानून के तहत उपभोक्ता के रूप में आपके अधिकारों के अधीन, विवादों पर भोपाल, मध्य प्रदेश की अदालतों का क्षेत्राधिकार होगा।';

  @override
  String get termsGrievanceTitle =>
      '18. शिकायत अधिकारी';

  @override
  String get termsGrievanceContent =>
      'सूचना प्रौद्योगिकी अधिनियम, 2000 और उपभोक्ता संरक्षण (ई-कॉमर्स) नियम, 2020 के अनुसार, आप अपनी शिकायतें हमारे शिकायत अधिकारी को भेज सकते हैं:\n\nशिकायत अधिकारी\nTAKSH ALL IN ONE ECOMMERCE & LOGISTICS WITH MULTI SERVICES PRIVATE LIMITED\nईमेल: customersupport@takshallinone.in\nपता: भोपाल, मध्य प्रदेश, भारत\n\nहम शिकायत की प्राप्ति 48 घंटे में स्वीकार करते हैं और उसे एक महीने के भीतर सुलझाने का प्रयास करते हैं।';

  @override
  String get termsContactTitle =>
      '19. संपर्क करें';

  @override
  String get termsContactContent =>
      'इन शर्तों के बारे में किसी भी प्रश्न के लिए हमसे संपर्क करें:\n\nईमेल: customersupport@takshallinone.in\nपता: भोपाल, मध्य प्रदेश, भारत';

  @override
  String get termsAck =>
      'Taksh का उपयोग करके आप पुष्टि करते हैं कि आपने इन नियम और शर्तों को पढ़ और समझ लिया है।';

  @override
  String get refundCommitmentTitle =>
      'हमारी प्रतिबद्धता';

  @override
  String get refundCommitmentContent =>
      'Taksh E-Commerce में हम चाहते हैं कि आप हर ऑर्डर से खुश रहें। यदि आपके ऑर्डर में कोई समस्या है, तो यह पॉलिसी बताती है कि रिटर्न, रिप्लेसमेंट, कैंसलेशन और रिफंड कैसे काम करते हैं।';

  @override
  String get refundReadPolicy =>
      'कृपया इस पॉलिसी को ध्यान से पढ़ें। यह हमारी नियम और शर्तों का हिस्सा है।';

  @override
  String get refundEligibilityTitle =>
      '1. रिटर्न की पात्रता';

  @override
  String get refundEligibilityContent =>
      'आप डिलीवरी की तारीख से उत्पाद की रिटर्न अवधि के भीतर रिटर्न का अनुरोध कर सकते हैं। यह अवधि उत्पाद पेज पर दिखाई जाती है और जब तक अन्यथा न लिखा हो, 7 दिन है। आप रिटर्न का अनुरोध कर सकते हैं यदि:';

  @override
  String get refundEligibilityItem1 =>
      'आपको गलत, क्षतिग्रस्त या दोषपूर्ण सामान मिला, या विवरण से अलग सामान मिला';

  @override
  String get refundEligibilityItem2 =>
      'आपके ऑर्डर में पार्ट्स, एक्सेसरीज़ या मात्रा कम है';

  @override
  String get refundEligibilityItem3 =>
      'साइज़, फ़िट या रंग की समस्या है (जहाँ उत्पाद इसकी अनुमति देता है)';

  @override
  String get refundEligibilityItem4 =>
      'सामान अनयूज़्ड है और मूल पैकेजिंग, टैग और लेबल सुरक्षित हैं';

  @override
  String get refundEligibilityItem5 =>
      'आप ऐप में कारण और साफ़ तस्वीरों के साथ अनुरोध करते हैं';

  @override
  String get refundNonReturnableTitle =>
      '2. वापस न होने वाली वस्तुएँ';

  @override
  String get refundNonReturnableContent =>
      'ये वस्तुएँ वापस नहीं की जा सकतीं, जब तक वे क्षतिग्रस्त, दोषपूर्ण या गलत न आई हों:';

  @override
  String get refundNonReturnableItem1 =>
      'जल्दी खराब होने वाला सामान, जैसे ताज़ा खाना, फल और सब्ज़ियाँ';

  @override
  String get refundNonReturnableItem2 =>
      'खोले या इस्तेमाल किए गए पर्सनल केयर, हाइजीन और इंटिमेट आइटम';

  @override
  String get refundNonReturnableItem3 =>
      'कस्टमाइज़्ड या पर्सनलाइज़्ड आइटम';

  @override
  String get refundNonReturnableItem4 =>
      'डिजिटल उत्पाद, गिफ़्ट कार्ड और वाउचर';

  @override
  String get refundNonReturnableItem5 =>
      'उत्पाद पेज पर "वापसी योग्य नहीं" लिखे उत्पाद';

  @override
  String get refundNonReturnableItem6 =>
      'डिलीवरी के बाद दुरुपयोग से क्षतिग्रस्त वस्तुएँ';

  @override
  String get refundProcessTitle =>
      '3. रिटर्न प्रक्रिया';

  @override
  String get refundProcessContent =>
      'सामान वापस करने के लिए ये चरण अपनाएं:';

  @override
  String get refundStep1Title =>
      'रिटर्न अनुरोध करें';

  @override
  String get refundStep1Desc =>
      '"आपके ऑर्डर" में जाएं, सामान चुनें और Return दबाएं। कारण चुनें, 5 तक फ़ोटो जोड़ें और सबमिट करें।';

  @override
  String get refundStep2Title =>
      'अनुरोध की समीक्षा';

  @override
  String get refundStep2Desc =>
      'हमारी टीम आमतौर पर 24 से 48 घंटे में आपके अनुरोध की समीक्षा करती है। स्थिति आप ऐप में देख सकते हैं।';

  @override
  String get refundStep3Title =>
      'सामान पैक करें';

  @override
  String get refundStep3Desc =>
      'सामान को मूल पैकेजिंग में सभी एक्सेसरीज़, टैग और इनवॉइस के साथ रखें।';

  @override
  String get refundStep4Title =>
      'पिकअप और समाधान';

  @override
  String get refundStep4Desc =>
      'स्वीकृत होने पर हम पिकअप की व्यवस्था करेंगे या बताएंगे कि सामान कैसे भेजें। सामान मिलने और जाँच के बाद आपका रिफंड या रिप्लेसमेंट प्रोसेस किया जाता है।';

  @override
  String get refundTimelineTitle =>
      '4. रिफंड की समय-सीमा';

  @override
  String get refundTimelineContent =>
      'आपका रिटर्न अनुरोध स्वीकृत होने के बाद सामान्य समय-सीमा (वास्तविक समय स्थान और उत्पाद के अनुसार बदल सकता है):';

  @override
  String get refundTimelineItem1Day =>
      'दिन 1-2';

  @override
  String get refundTimelineItem1Desc =>
      'सामान पिकअप या प्राप्त हुआ और क्वालिटी जाँच शुरू';

  @override
  String get refundTimelineItem2Day =>
      'दिन 3-4';

  @override
  String get refundTimelineItem2Desc =>
      'क्वालिटी जाँच पूरी और रिफंड स्वीकृत';

  @override
  String get refundTimelineItem3Day =>
      'दिन 5-7';

  @override
  String get refundTimelineItem3Desc =>
      'रिफंड आपके Taksh वॉलेट में जमा या रिप्लेसमेंट रवाना';

  @override
  String get refundProcessingNote =>
      'ये समय-सीमाएँ अनुमानित हैं। सेल, छुट्टियों के दौरान या अतिरिक्त सत्यापन की ज़रूरत होने पर देरी हो सकती है।';

  @override
  String get refundMethodsTitle =>
      '5. आपको पैसे कैसे वापस मिलते हैं';

  @override
  String get refundMethodsContent =>
      'आपके मामले के अनुसार, आपका अनुरोध इनमें से किसी एक तरीके से निपटाया जाता है:';

  @override
  String get refundMethodOriginalTitle =>
      'Taksh वॉलेट क्रेडिट';

  @override
  String get refundMethodOriginalDesc =>
      'स्वीकृत रिटर्न का रिफंड आपके Taksh वॉलेट में जमा होता है और अगले ऑर्डर में उपयोग किया जा सकता है';

  @override
  String get refundMethodOriginalDays =>
      'जाँच के बाद';

  @override
  String get refundMethodCreditTitle =>
      'रिप्लेसमेंट';

  @override
  String get refundMethodCreditDesc =>
      'वही सामान दोबारा भेजा जाता है, स्टॉक की उपलब्धता के अनुसार';

  @override
  String get refundMethodCreditDays =>
      'स्टॉक अनुसार';

  @override
  String get refundMethodBankTitle =>
      'मूल भुगतान माध्यम';

  @override
  String get refundMethodBankDesc =>
      'डिस्पैच से पहले रद्द किए गए प्रीपेड ऑर्डर का रिफंड उसी कार्ड, UPI या बैंक खाते में होता है जिससे भुगतान किया था';

  @override
  String get refundMethodBankDays =>
      '5-7 दिन';

  @override
  String get refundDamagedTitle =>
      '6. क्षतिग्रस्त या दोषपूर्ण उत्पाद';

  @override
  String get refundDamagedContent =>
      'यदि आपको क्षतिग्रस्त या दोषपूर्ण उत्पाद मिले:\n\n• ऐप में जल्द से जल्द बताएं, बेहतर होगा डिलीवरी के 48 घंटे के भीतर और हमेशा रिटर्न अवधि के भीतर\n• सामान और उसकी पैकेजिंग की साफ़ तस्वीरें जोड़ें\n• सत्यापन के बाद हम रिप्लेसमेंट या रिफंड देंगे\n• जल्दी खराब होने वाले सामान के लिए डिलीवरी के समय या 24 घंटे के भीतर बताएं';

  @override
  String get refundWrongTitle =>
      '7. गलत उत्पाद की डिलीवरी';

  @override
  String get refundWrongContent =>
      'यदि आपको गलत उत्पाद मिले:\n\n• ऐप में तस्वीरों के साथ रिटर्न करें\n• हमारी गलती से हुए रिटर्न का कोई शुल्क आपसे नहीं लिया जाएगा\n• हम सही सामान भेजेंगे, स्टॉक के अनुसार\n• सही सामान उपलब्ध न होने पर आपको रिफंड मिलेगा';

  @override
  String get refundPartialTitle =>
      '8. आंशिक रिफंड';

  @override
  String get refundPartialContent =>
      'कुछ मामलों में राशि का केवल एक हिस्सा लौटाया जा सकता है:';

  @override
  String get refundPartialItem1 =>
      'सामान पर इस्तेमाल के निशान या हमारी वजह से न हुआ मामूली नुकसान है';

  @override
  String get refundPartialItem2 =>
      'एक्सेसरीज़, टैग या मूल पैकेजिंग गायब है';

  @override
  String get refundPartialItem3 =>
      'ऑर्डर का केवल एक हिस्सा प्रभावित या वापस किया गया है';

  @override
  String get refundPartialItem4 =>
      'ऑर्डर के साथ आए मुफ़्त या प्रमोशनल आइटम वापस नहीं किए गए';

  @override
  String get refundExchangeTitle =>
      '9. रिप्लेसमेंट';

  @override
  String get refundExchangeContent =>
      'रिटर्न करते समय आप रिफंड की जगह रिप्लेसमेंट माँग सकते हैं। हम वही सामान दोबारा भेजते हैं, स्टॉक के अनुसार। उपलब्ध न होने पर राशि आपके Taksh वॉलेट में लौटा दी जाती है।';

  @override
  String get refundCancelTitle =>
      '10. कैंसलेशन पॉलिसी';

  @override
  String get refundCancelContent =>
      'आप ऑर्डर डिस्पैच होने से पहले ऐप से या हमसे संपर्क करके उसे रद्द कर सकते हैं:\n\n• डिस्पैच से पहले रद्द करने पर कोई शुल्क नहीं\n• प्रीपेड ऑर्डर का रिफंड मूल भुगतान माध्यम में आमतौर पर 5 से 7 कार्य दिवसों में होता है (आपके बैंक का समय अलग हो सकता है)\n• कैश ऑन डिलीवरी ऑर्डर में लौटाने के लिए कोई राशि नहीं होती\n• डिस्पैच के बाद ऑर्डर रद्द नहीं हो सकता, लेकिन आप इस पॉलिसी के अनुसार उसे वापस कर सकते हैं\n• यदि डिलीवरी पर ऑर्डर लेने से मना किया जाए या गलत पते के कारण डिलीवरी न हो सके, तो ऑर्डर रद्द हो सकता है और रिफंड से डिलीवरी शुल्क काटा जा सकता है';

  @override
  String get refundContactTitle =>
      '11. रिटर्न के लिए संपर्क';

  @override
  String get refundContactContent =>
      'रिटर्न या रिफंड में मदद चाहिए? अपने ऑर्डर नंबर के साथ हमें customersupport@takshallinone.in पर ईमेल करें, हम जल्द से जल्द जवाब देंगे।\n\nयह पॉलिसी उपभोक्ता संरक्षण अधिनियम, 2019 के तहत आपके अधिकारों को प्रभावित नहीं करती।';

  @override
  String get refundSatisfactionTitle =>
      'हम मदद के लिए हैं';

  @override
  String get refundSatisfactionContent =>
      'यदि आपके ऑर्डर में कुछ ठीक नहीं है, तो हमें बताएं और हम उसे सुलझाने में आपके साथ काम करेंगे।';

  @override
  String get privacyIntroTitle =>
      'परिचय';

  @override
  String get privacyIntroContent =>
      'TAKSH ALL IN ONE ECOMMERCE & LOGISTICS WITH MULTI SERVICES PRIVATE LIMITED ("Taksh", "हम") आपकी गोपनीयता का सम्मान करता है। यह पॉलिसी बताती है कि हम अपने मोबाइल ऐप के ज़रिए कौन सा व्यक्तिगत डेटा एकत्र करते हैं, क्यों करते हैं, उसका उपयोग, साझाकरण और सुरक्षा कैसे करते हैं, और आपके पास क्या विकल्प हैं। यह सूचना प्रौद्योगिकी अधिनियम, 2000, IT (उचित सुरक्षा प्रथाएँ और प्रक्रियाएँ) नियम, 2011 और डिजिटल व्यक्तिगत डेटा संरक्षण अधिनियम, 2023 के अनुसार है।';

  @override
  String get privacyAgreeContent =>
      'हमारे ऐप का उपयोग करके और जहाँ हम माँगें वहाँ सहमति देकर, आप इस पॉलिसी में बताई गई प्रथाओं से सहमत होते हैं।';

  @override
  String get privacyCollectTitle =>
      '1. हम कौन सी जानकारी एकत्र करते हैं';

  @override
  String get privacyCollectContent =>
      'हम केवल वही जानकारी एकत्र करते हैं जो ऐप चलाने और आपके ऑर्डर पहुँचाने के लिए ज़रूरी है:';

  @override
  String get privacyPersonalTitle =>
      'जो जानकारी आप देते हैं';

  @override
  String get privacyPersonalContent =>
      '• नाम और मोबाइल नंबर (OTP से साइन इन के लिए)\n• ईमेल पता, यदि आप दें\n• डिलीवरी पते और पिनकोड\n• प्रोफ़ाइल की जो जानकारी आप जोड़ना चाहें';

  @override
  String get privacyUsageTitle =>
      'डिवाइस और उपयोग डेटा';

  @override
  String get privacyUsageContent =>
      '• डिवाइस की जानकारी (मॉडल, ऑपरेटिंग सिस्टम, ऐप वर्ज़न)\n• लोकेशन, केवल आपकी अनुमति से, ताकि दिखाया जा सके कि आपके यहाँ क्या डिलीवर हो सकता है\n• समस्याएँ ठीक करने के लिए ऐप गतिविधि और क्रैश रिपोर्ट\n• ऑर्डर अपडेट भेजने के लिए नोटिफ़िकेशन टोकन';

  @override
  String get privacyTransactionTitle =>
      'ऑर्डर और भुगतान डेटा';

  @override
  String get privacyTransactionContent =>
      '• ऑर्डर, डिलीवरी और रिटर्न का विवरण\n• भुगतान की स्थिति और ट्रांज़ैक्शन रेफ़रेंस। कार्ड, UPI और बैंक विवरण हमारे पेमेंट गेटवे द्वारा संभाले जाते हैं और हम उन्हें स्टोर नहीं करते\n• रिटर्न अनुरोध के साथ आपकी अपलोड की गई फ़ोटो\n• आपके द्वारा दिए गए रिव्यू और रेटिंग';

  @override
  String get privacyUseTitle =>
      '2. हम आपकी जानकारी का उपयोग कैसे करते हैं';

  @override
  String get privacyUseContent =>
      'हम आपकी जानकारी का उपयोग इनके लिए करते हैं:';

  @override
  String get privacyUseItem1 =>
      'आपका अकाउंट बनाना और OTP से सत्यापित करना';

  @override
  String get privacyUseItem2 =>
      'आपके ऑर्डर प्रोसेस, डिलीवर और ट्रैक करना';

  @override
  String get privacyUseItem3 =>
      'भुगतान, कैंसलेशन, रिटर्न और रिफंड संभालना';

  @override
  String get privacyUseItem4 =>
      'ग्राहक सहायता देना और आपके प्रश्नों का उत्तर देना';

  @override
  String get privacyUseItem5 =>
      'ऑर्डर अपडेट और ज़रूरी सूचनाएँ भेजना';

  @override
  String get privacyUseItem6 =>
      'आपके स्थान पर उपलब्ध उत्पाद और डिलीवरी विकल्प दिखाना';

  @override
  String get privacyUseItem7 =>
      'ऑफ़र और प्रमोशन भेजना, केवल आपकी सहमति होने पर';

  @override
  String get privacyUseItem8 =>
      'ऐप को बेहतर और सुरक्षित रखना तथा धोखाधड़ी पहचानना व रोकना';

  @override
  String get privacyUseItem9 =>
      'कानूनी दायित्वों का पालन करना';

  @override
  String get privacySharingTitle =>
      '3. जानकारी साझा करना';

  @override
  String get privacySharingContent =>
      'हम आपका व्यक्तिगत डेटा बेचते नहीं हैं। हम इसे केवल इन मामलों में साझा करते हैं:';

  @override
  String get privacyProvidersTitle =>
      'सेवा प्रदाता';

  @override
  String get privacyProvidersContent =>
      'पेमेंट गेटवे, SMS और नोटिफ़िकेशन प्रदाता, क्लाउड होस्टिंग और एनालिटिक्स प्रदाता, जो गोपनीयता दायित्वों के तहत हमारी ओर से डेटा प्रोसेस करते हैं।';

  @override
  String get privacyPartnersTitle =>
      'विक्रेता और डिलीवरी पार्टनर';

  @override
  String get privacyPartnersContent =>
      'विक्रेता, फ़ुलफ़िलमेंट सेंटर और डिलीवरी पार्टनर आपका नाम, पता, फ़ोन नंबर और ऑर्डर विवरण केवल आपका ऑर्डर तैयार करने और पहुँचाने के लिए प्राप्त करते हैं।';

  @override
  String get privacyLegalTitle =>
      'कानूनी आवश्यकताएँ';

  @override
  String get privacyLegalContent =>
      'जब कानून, अदालती आदेश या सरकारी प्राधिकरण का अनुरोध इसकी माँग करे, या हमारे उपयोगकर्ताओं और Taksh के अधिकारों और सुरक्षा की रक्षा के लिए।';

  @override
  String get privacyTransferTitle =>
      'व्यवसाय हस्तांतरण';

  @override
  String get privacyTransferContent =>
      'यदि Taksh का किसी अन्य व्यवसाय में विलय हो या उसका अधिग्रहण हो, तो आपका डेटा उसे हस्तांतरित हो सकता है, और किसी अलग पॉलिसी के अधीन होने से पहले हम आपको बताएंगे।';

  @override
  String get privacySecurityTitle =>
      '4. डेटा सुरक्षा';

  @override
  String get privacySecurityContent =>
      'हम आपके डेटा की सुरक्षा के लिए उचित तकनीकी और संगठनात्मक उपाय अपनाते हैं:\n\n• ट्रांज़िट में डेटा का एन्क्रिप्शन\n• एक्सेस कंट्रोल और ऑथेंटिकेशन\n• पहुँच केवल अधिकृत कर्मियों तक सीमित\n• भुगतान सुरक्षित पेमेंट गेटवे द्वारा संभाले जाते हैं';

  @override
  String get privacySecurityNote =>
      'कोई भी ट्रांसमिशन या स्टोरेज तरीका 100% सुरक्षित नहीं है। कृपया अपना OTP कभी किसी के साथ साझा न करें।';

  @override
  String get privacyRightsTitle =>
      '5. आपके अधिकार';

  @override
  String get privacyRightsContent =>
      'लागू कानून के अधीन, आपके पास ये अधिकार हैं:';

  @override
  String get privacyRightsItem1 =>
      'एक्सेस: जानना कि हमारे पास आपका कौन सा व्यक्तिगत डेटा है';

  @override
  String get privacyRightsItem2 =>
      'सुधार: गलत डेटा को अपडेट या ठीक करना';

  @override
  String get privacyRightsItem3 =>
      'विलोपन: ऐप से या हमें ईमेल करके अपना अकाउंट और डेटा हटवाना';

  @override
  String get privacyRightsItem4 =>
      'किसी भी समय सहमति वापस लेना';

  @override
  String get privacyRightsItem5 =>
      'प्रमोशनल संदेशों से बाहर होना';

  @override
  String get privacyRightsItem6 =>
      'अपनी मृत्यु या अक्षमता की स्थिति में अपने अधिकारों के उपयोग के लिए किसी व्यक्ति को नामित करना';

  @override
  String get privacyRightsItem7 =>
      'हमारे शिकायत अधिकारी के पास शिकायत दर्ज करना';

  @override
  String get privacyCookiesTitle =>
      '6. ऐप अनुमतियाँ';

  @override
  String get privacyCookiesContent =>
      'ऐप ये अनुमतियाँ माँग सकता है:\n\n• लोकेशन: आपके पास डिलीवरी की उपलब्धता दिखाने के लिए\n• नोटिफ़िकेशन: ऑर्डर अपडेट और ऑफ़र के लिए\n• कैमरा और फ़ोटो: रिटर्न अनुरोध या प्रोफ़ाइल में तस्वीर जोड़ने के लिए\n\nआप डिवाइस सेटिंग्स में कोई भी अनुमति बदल सकते हैं। इनके बिना कुछ सुविधाएँ काम नहीं कर सकतीं।';

  @override
  String get privacyLinksTitle =>
      '7. तृतीय-पक्ष लिंक';

  @override
  String get privacyLinksContent =>
      'ऐप में तृतीय-पक्ष वेबसाइट या सेवाओं के लिंक हो सकते हैं। उनकी गोपनीयता प्रथाओं के लिए हम ज़िम्मेदार नहीं हैं, इसलिए कृपया उनकी पॉलिसी पढ़ें।';

  @override
  String get privacyChildrenTitle =>
      '8. बच्चों की गोपनीयता';

  @override
  String get privacyChildrenContent =>
      'हमारी सेवा 18 वर्ष और उससे अधिक आयु के लोगों के लिए है। हम माता-पिता या अभिभावक की सहमति के बिना जानबूझकर बच्चों का व्यक्तिगत डेटा एकत्र नहीं करते। यदि आपको लगता है कि किसी बच्चे ने हमें डेटा दिया है, तो कृपया हमसे संपर्क करें, हम उसे हटा देंगे।';

  @override
  String get privacyRetentionTitle =>
      '9. डेटा प्रतिधारण';

  @override
  String get privacyRetentionContent =>
      'हम आपका डेटा तब तक रखते हैं जब तक आपका अकाउंट सक्रिय है और हमारी सेवाएँ देने के लिए ज़रूरी है। उसके बाद हम केवल वही रखते हैं जो कानून के अनुसार आवश्यक है, जैसे इनवॉइस और लेन-देन रिकॉर्ड, या विवाद सुलझाने के लिए ज़रूरी है। फिर उसे हटा या अनाम कर दिया जाता है।';

  @override
  String get privacyInternationalTitle =>
      '10. डेटा स्टोरेज और हस्तांतरण';

  @override
  String get privacyInternationalContent =>
      'हमारे सेवा प्रदाता डेटा को भारत के भीतर या बाहर के सर्वरों पर स्टोर या प्रोसेस कर सकते हैं। जहाँ डेटा भारत के बाहर प्रोसेस होता है, हम कानून के अनुसार उसकी सुरक्षा सुनिश्चित करने के कदम उठाते हैं।';

  @override
  String get privacyChangesTitle =>
      '11. इस पॉलिसी में बदलाव';

  @override
  String get privacyChangesContent =>
      'हम समय-समय पर इस पॉलिसी को अपडेट कर सकते हैं। नया संस्करण नई "अंतिम अपडेट" तारीख के साथ ऐप में दिखाया जाएगा।';

  @override
  String get privacyContactTitle =>
      '12. संपर्क और शिकायत अधिकारी';

  @override
  String get privacyContactContent =>
      'अपने डेटा से जुड़े प्रश्नों, अनुरोधों या शिकायतों के लिए हमारे शिकायत अधिकारी से संपर्क करें:\n\nशिकायत अधिकारी\nTAKSH ALL IN ONE ECOMMERCE & LOGISTICS WITH MULTI SERVICES PRIVATE LIMITED\nईमेल: customersupport@takshallinone.in\nपता: भोपाल, मध्य प्रदेश, भारत\n\nहम अनुरोध की प्राप्ति 48 घंटे में स्वीकार करते हैं और उसे एक महीने के भीतर सुलझाने का प्रयास करते हैं।';

  @override
  String get privacyMattersTitle =>
      'आपकी गोपनीयता महत्वपूर्ण है';

  @override
  String get privacyMattersContent =>
      'हम आपके डेटा को ज़िम्मेदारी से और केवल यहाँ बताए गए उद्देश्यों के लिए संभालते हैं।';

  @override
  String get ourStoryContent =>
      'Taksh, TAKSH ALL IN ONE ECOMMERCE & LOGISTICS WITH MULTI SERVICES PRIVATE LIMITED द्वारा संचालित, एक शॉपिंग ऐप है, जो रोज़मर्रा का सामान आपके दरवाज़े तक तेज़ी और भरोसे से पहुँचाने के लिए बना है। हम स्थानीय विक्रेताओं और फ़ुलफ़िलमेंट सेंटर के साथ काम करते हैं, ताकि आप चुनिंदा क्षेत्रों में 30 मिनट की एक्सप्रेस डिलीवरी, नेक्स्ट-डे डिलीवरी या स्टैंडर्ड डिलीवरी चुन सकें, और ऑनलाइन या जहाँ उपलब्ध हो कैश ऑन डिलीवरी से भुगतान कर सकें।';

  @override
  String get ourMissionContent =>
      'रोज़ की खरीदारी को आसान, तेज़ और भरोसेमंद बनाना, साफ़ कीमतों, असली उत्पादों और ईमानदार सेवा के साथ, और स्थानीय व्यवसायों का समर्थन करते हुए।';

  @override
  String get ourVisionContent =>
      'एक ऐसा शॉपिंग ऐप बनना जिस पर पूरे भारत के लोग अपनी रोज़मर्रा की ज़रूरतों के लिए भरोसा करें, जहाँ वे जो चाहें पा सकें और जब चाहें पा सकें।';

  @override
  String get trustTransparencyDesc =>
      'हर कदम पर साफ़ कीमतें, साफ़ नीतियाँ और ईमानदार संवाद।';

  @override
  String get qualityFirstDesc =>
      'हम विक्रेताओं और पार्टनर के साथ मिलकर असली और अच्छी स्थिति वाले उत्पाद देने का प्रयास करते हैं।';

  @override
  String get customerCentricityDesc =>
      'हमारे ग्राहक हमारे हर काम के केंद्र में हैं। आपकी प्रतिक्रिया से हम बेहतर बनते हैं।';

  @override
  String get sustainabilityDesc =>
      'हम स्थानीय विक्रेताओं और फ़ुलफ़िलमेंट सेंटर के साथ काम करते हैं ताकि तेज़ डिलीवरी हो और स्थानीय व्यवसायों को सहारा मिले।';

  @override
  String get innovationDesc =>
      'खरीदारी को आसान बनाने के लिए हम अपने ऐप और सेवाओं को लगातार बेहतर करते रहते हैं।';

  @override
  String get whatWeOfferContent =>
      '• उत्पादों की विस्तृत श्रृंखला: भरोसेमंद विक्रेताओं से कई श्रेणियों में बढ़ता चयन\n\n• लचीली डिलीवरी: एक्सप्रेस 30-मिनट (चुनिंदा क्षेत्र), नेक्स्ट-डे और स्टैंडर्ड डिलीवरी\n\n• सुरक्षित भुगतान: सुरक्षित पेमेंट गेटवे से ऑनलाइन भुगतान करें, या जहाँ उपलब्ध हो कैश ऑन डिलीवरी चुनें\n\n• आसान रिटर्न: रिटर्न अवधि के भीतर पात्र वस्तुओं के लिए ऐप में रिटर्न करें\n\n• सहायता: हमें कभी भी लिखें, हम आपको जवाब देंगे';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get addressLabel => 'पता';

  @override
  String get addressValue => 'भोपाल, मध्य प्रदेश, भारत';

  @override
  String get updateProfileTitle => 'प्रोफ़ाइल अपडेट करें';

  @override
  String get firstName => 'पहला नाम';

  @override
  String get lastName => 'अंतिम नाम';

  @override
  String get mobileLabel => 'मोबाइल';

  @override
  String get saveDetails => 'विवरण सहेजें';

  @override
  String get enterValidName => 'कृपया मान्य नाम दर्ज करें';

  @override
  String get joinDeliveryManTitle => 'डिलीवरी मैन के रूप में शामिल हों';

  @override
  String get fillDetailsDelivery =>
      'डिलीवरी पार्टनर के रूप में शामिल होने के लिए अपना विवरण भरें';

  @override
  String get nameLabel => 'नाम';

  @override
  String get nameRequired => 'नाम आवश्यक है';

  @override
  String get mobileRequired => 'मोबाइल नंबर आवश्यक है';

  @override
  String get emailRequired => 'ईमेल आवश्यक है';

  @override
  String get pincodeLabel => 'पिन कोड';

  @override
  String get pincodeInvalidLength => 'पिन कोड 6 अंकों का होना चाहिए';

  @override
  String get pincodeInvalidFormat => 'पिन कोड में केवल नंबर होने चाहिए';

  @override
  String get descriptionLabel => 'विवरण';

  @override
  String get descriptionRequired => 'विवरण आवश्यक है';

  @override
  String get submitRequest => 'अनुरोध जमा करें';

  @override
  String get requiredFieldsNote => '* आवश्यक क्षेत्र';

  @override
  String fillDetailsRequest(String type) {
    return '$type का अनुरोध करने के लिए अपना विवरण भरें';
  }

  @override
  String get invalidEmail => 'एक मान्य ईमेल पता दर्ज करें';

  @override
  String get passwordRequired => 'पसवर्ड आवश्यक है';

  @override
  String get passwordMinLength => 'पासवर्ड कम से कम 8 वर्णों का होना चाहिए';

  @override
  String get passwordComplexity =>
      'पासवर्ड में अपरकेस, लोअरकेस और नंबर होना चाहिए';

  @override
  String get confirmPasswordRequired => 'पुष्टि पासवर्ड आवश्यक है';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get nameMinLength => 'नाम कम से कम 2 वर्णों का होना चाहिए';

  @override
  String get appDevelopment => 'ऐप डेवलपमेंट';

  @override
  String get webDevelopment => 'वेब डेवलपमेंट';

  @override
  String get orderSummary => 'ऑर्डर सारांश';

  @override
  String get subtotal => 'उप-योग';

  @override
  String get deliveryCharges => 'डिलीवरी शुल्क';

  @override
  String get platformFee => 'प्लेटफ़ॉर्म शुल्क';

  @override
  String get takshCharge => 'तक्ष शुल्क';

  @override
  String get quickDeliveryFee => 'क्विक डिलीवरी शुल्क';

  @override
  String get cgst => 'सीजीएसटी';

  @override
  String get sgst => 'एसजीएसटी';

  @override
  String get discountLabel => 'छूट';

  @override
  String get otherCharges => 'अन्य शुल्क';

  @override
  String get free => 'मुफ़्त';

  @override
  String get totalAmount => 'कुल राशि';

  @override
  String get returnOrder => 'ऑर्डर वापस करें';

  @override
  String get needHelp => 'सहायता की आवश्यकता है';

  @override
  String get orderIssues => 'क्या आपको इस ऑर्डर में कोई समस्या है?';

  @override
  String get chatWithUs => 'हमसे चैट करें';

  @override
  String get sendEmail => 'हमें ईमेल भेजें';

  @override
  String get returnFunctionalityComing =>
      'वापसी की सुविधा जल्द ही उपलब्ध होगी। आप सहायता के लिए समर्थन से संपर्क कर सकते हैं।';

  @override
  String get noCategoriesAvailable => 'कोई श्रेणी उपलब्ध नहीं है';

  @override
  String get description => 'विवरण';

  @override
  String get similarProducts => 'समान उत्पाद';

  @override
  String get selectVariant => 'वेरिएंट चुनें';

  @override
  String get ratings => 'रेटिंग';

  @override
  String get failedToLoadProduct => 'उत्पाद लोड करने में विफल';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get searching => 'खोज रहा है...';

  @override
  String get recentSearches => 'हाल की खोजें';

  @override
  String typeMinCharsToSearch(int count) {
    return 'खोज शुरू करने के लिए कम से कम $count अक्षर टाइप करें';
  }

  @override
  String get inStock => 'स्टॉक में है';

  @override
  String get outOfStock => 'स्टॉक में नहीं है';

  @override
  String get checkout => 'चेकआउट';

  @override
  String get deliveryOptions => 'डिलीवरी विकल्प';

  @override
  String get priceDetails => 'मूल्य विवरण';

  @override
  String get placeOrder => 'ऑर्डर दें';

  @override
  String get proceedToPay => 'भुगतान के लिए आगे बढ़ें';

  @override
  String get addAddress => 'पता जोड़ें';

  @override
  String get loadingOrderDetails => 'ऑर्डर विवरण लोड हो रहा है...';

  @override
  String get addAddressToContinue =>
      'जारी रखने के लिए कृपया एक डिलीवरी पता जोड़ें';

  @override
  String get paymentSuccess => 'भुगतान सफल';

  @override
  String get paymentFailed => 'भुगतान विफल';

  @override
  String get orderPlacedSuccessfully => 'आपका ऑर्डर सफलतापूर्वक दिया गया!';

  @override
  String get somethingWentWrongPayment => 'आपके भुगतान में कुछ गलत हो गया';

  @override
  String get viewOrder => 'ऑर्डर देखें';

  @override
  String get continueShopping => 'खरीदारी जारी रखें';

  @override
  String get selectAddress => 'पता चुनें';

  @override
  String get myAddresses => 'मेरे पते';

  @override
  String get noAddressesSaved => 'कोई पता सहेजा नहीं गया';

  @override
  String get addFirstAddress => 'शुरू करने के लिए अपना पहला पता जोड़ें';

  @override
  String get deleteAddress => 'पता हटाएं';

  @override
  String get deleteAddressConfirm =>
      'क्या आप वाकई इस पते को हटाना चाहते हैं? यह कार्रवाई पूर्ववत नहीं की जा सकती।';

  @override
  String get setDefault => 'डिफ़ॉल्ट सेट करें';

  @override
  String get addNewAddress => 'नया पता जोड़ें';

  @override
  String get editAddress => 'पता संपादित करें';

  @override
  String get selectLocationOnMap => 'मानचित्र पर स्थान चुनें';

  @override
  String get locationSelected => 'स्थान चुना गया';

  @override
  String get tapToPickLocation => 'मानचित्र पर स्थान चुनने के लिए टैप करें';

  @override
  String get addressType => 'पता प्रकार';

  @override
  String get recipientName => 'प्राप्तकर्ता का नाम';

  @override
  String get enterRecipientName => 'प्राप्तकर्ता का पूरा नाम दर्ज करें';

  @override
  String get labelOther => 'लेबल (जैसे, मित्र का घर)';

  @override
  String get enterLabel => 'इस पते के लिए एक लेबल दर्ज करें';

  @override
  String get houseFlatNo => 'घर/फ्लैट/ब्लॉक नंबर';

  @override
  String get enterHouseNo => 'घर या फ्लैट नंबर दर्ज करें';

  @override
  String get landmarkOptional => 'लैंडमार्क (वैकल्पिक)';

  @override
  String get landmarkHint => 'उदाहरण: सिटी मॉल के पास';

  @override
  String get city => 'शहर';

  @override
  String get enterCity => 'शहर दर्ज करें';

  @override
  String get state => 'राज्य';

  @override
  String get enterState => 'राज्य दर्ज करें';

  @override
  String get pincode => 'पिनकोड';

  @override
  String get enterPincode => 'पिनकोड दर्ज करें';

  @override
  String get pincodeLengthError => 'पिनकोड 6 अंकों का होना चाहिए';

  @override
  String get setAsDefaultAddress => 'डिफ़ॉल्ट पते के रूप में सेट करें';

  @override
  String get setAsDefaultSubtitle =>
      'इस पते का उपयोग डिलीवरी के लिए डिफ़ॉल्ट रूप से किया जाएगा';

  @override
  String get updateAddress => 'पता अपडेट करें';

  @override
  String get saveAddress => 'पता सहेजें';

  @override
  String get pleaseEnterRecipientName => 'कृपया प्राप्तकर्ता का नाम दर्ज करें';

  @override
  String get pleaseEnterHouseNo => 'कृपया घर/फ्लैट नंबर दर्ज करें';

  @override
  String get required => 'आवश्यक';

  @override
  String get pleaseSelectLocation => 'कृपया मानचित्र पर एक स्थान चुनें';

  @override
  String get ourStory => 'हमारी कहानी';

  @override
  String get ourMission => 'हमारा मिशन';

  @override
  String get ourVision => 'हमारा विजन';

  @override
  String get ourCoreValues => 'हमारे मुख्य मूल्य';

  @override
  String get trustTransparency => 'विश्वास और पारदर्शिता';

  @override
  String get qualityFirst => 'गुणवत्ता पहले';

  @override
  String get customerCentricity => 'ग्राहक केंद्रितता';

  @override
  String get sustainability =>
      'स्थानीय पहले';

  @override
  String get innovation => 'नवाचार';

  @override
  String get whatWeOffer => 'हम क्या प्रदान करते हैं';

  @override
  String get ourImpact =>
      'Taksh से खरीदारी क्यों करें';

  @override
  String get aboutHighlightLocal =>
      'स्थानीय विक्रेता';

  @override
  String get aboutHighlightReturns =>
      'आसान रिटर्न';

  @override
  String get aboutHighlightCod =>
      'कैश ऑन डिलीवरी';

  @override
  String get aboutHighlightPayments =>
      'सुरक्षित भुगतान';

  @override
  String get aboutHighlightDelivery =>
      'लचीली डिलीवरी';

  @override
  String get aboutHighlightExpress =>
      '30-मिनट एक्सप्रेस';

  @override
  String get happyCustomers => 'खुश ग्राहक';

  @override
  String get products => 'उत्पाद';

  @override
  String get brands => 'ब्रांड';

  @override
  String get cities => 'शहर';

  @override
  String get rating => 'रेटिंग';

  @override
  String get getInTouch => 'संपर्क करें';

  @override
  String redirectingToCart(String seconds) {
    return '$seconds सेकंड में कार्ट पर रीडायरेक्ट किया जा रहा है';
  }

  @override
  String errorCode(String code) {
    return 'त्रुटि कोड: $code';
  }

  @override
  String get backToHome => 'मुखपृष्ठ पर वापस जाएं';

  @override
  String get orderNumberLabel => 'ऑर्डर संख्या';

  @override
  String get searchForProducts => 'उत्पादों की खोज करें';

  @override
  String get searchForProductsHint => 'उत्पादों की खोज करें';

  @override
  String get noResultsFound => 'कोई परिणाम नहीं मिला';

  @override
  String get noProductsFound => 'कोई उत्पाद नहीं मिला';

  @override
  String get edit => 'संपादित करें';

  @override
  String get search => 'खोजें';

  @override
  String get productDetails => 'उत्पाद विवरण';

  @override
  String get searchProducts => 'उत्पाद खोजें';

  @override
  String get quick => 'त्वरित';

  @override
  String get services => 'सेवाएं';

  @override
  String get helpSupport => 'सहायता और समर्थन';

  @override
  String get standard => 'मानक';

  @override
  String get failedToLoadAddresses => 'पते लोड करने में विफल';

  @override
  String get couldNotDeleteAddress =>
      'पता हटाया नहीं जा सका। कृपया पुनः प्रयास करें।';

  @override
  String get couldNotUpdateAddress =>
      'पता अपडेट नहीं किया जा सका। कृपया पुनः प्रयास करें।';

  @override
  String get couldNotAddAddress =>
      'पता जोड़ा नहीं जा सका। कृपया पुनः प्रयास करें।';

  @override
  String get couldNotSetDefaultAddress =>
      'डिफ़ॉल्ट पता सेट नहीं किया जा सका। कृपया पुनः प्रयास करें।';

  @override
  String get delete => 'हटाएं';

  @override
  String get maybeLater => 'शायद बाद में';

  @override
  String get enable => 'सक्षम करें';

  @override
  String get enableLocation => 'स्थान सक्षम करें';

  @override
  String get home => 'होम';

  @override
  String get locationEnabledMessage =>
      'स्थान सक्षम! आस-पास की दुकानें दिखाई जा रही हैं...';

  @override
  String get nearbyStores => 'नज़दीकी दुकानें';

  @override
  String get findNearbyStores => 'नज़दीकी दुकानें खोजें';

  @override
  String get loadingNearbyStores => 'नज़दीकी दुकानें लोड हो रही हैं...';

  @override
  String get skipForNow => 'अभी के लिए छोड़ें';

  @override
  String get useCurrentLocation => 'वर्तमान स्थान का उपयोग करें';

  @override
  String get autoDetectLocation => 'अपना डिलीवरी पता ऑटो-डिटेक्ट करें';

  @override
  String get yourAppContent => 'आपकी ऐप सामग्री';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get locationServices => 'स्थान सेवाएं';

  @override
  String get currentLocation => 'वर्तमान स्थान';

  @override
  String get disableLocation => 'स्थान अक्षम करें';

  @override
  String get ok => 'ठीक है';

  @override
  String get locationAccess => 'स्थान पहुंच';

  @override
  String get notNow => 'अभी नहीं';

  @override
  String get allow => 'अनुमति दें';

  @override
  String get locationPermissionRequired => 'स्थान अनुमति आवश्यक';

  @override
  String get openSettings => 'सेटिंग्स खोलें';

  @override
  String get permissionPermanentlyDenied =>
      'अनुमति स्थायी रूप से अस्वीकार कर दी गई';

  @override
  String get appSettings => 'ऐप सेटिंग्स';

  @override
  String get locationServicesDisabled => 'स्थान सेवाएं अक्षम हैं';

  @override
  String get allowLocationAccess => 'स्थान पहुंच की अनुमति दें';

  @override
  String get permissionUIComponents => 'स्थान अनुमति यूआई घटक';

  @override
  String get showBottomSheet => 'बॉटम शीट दिखाएं';

  @override
  String get showRationaleDialog => 'तर्क संवाद दिखाएं';

  @override
  String get showSettingsDialog => 'सेटिंग्स संवाद दिखाएं';

  @override
  String get requestPermissionFullFlow =>
      'अनुमति का अनुरोध करें (पूर्ण प्रवाह)';

  @override
  String get getCurrentLocation => 'वर्तमान स्थान प्राप्त करें';

  @override
  String get locationPermissionGranted => 'स्थान अनुमति प्रदान की गई';

  @override
  String get grantLocationPermission => 'स्थान अनुमति प्रदान करें';

  @override
  String get dataAlreadyLoaded =>
      'डेटा पहले ही लोड हो चुका है - तुरंत प्रदर्शन!';

  @override
  String get searchSavedAddresses => 'सहेजे गए पते खोजें';

  @override
  String get searchCategories => 'श्रेणियां खोजें...';

  @override
  String get searchRestaurantsDishes => 'रेस्तरां, व्यंजन खोजें...';

  @override
  String get searchAreaStreetName => 'क्षेत्र, सड़क का नाम खोजें...';

  @override
  String get joinAsVendorTitle => 'विक्रेता के रूप में जुड़ें';

  @override
  String get vendorFillDetails =>
      'अपने विक्रेता दुकान का विवरण भरें। आवश्यक फ़ील्ड * से चिह्नित हैं';

  @override
  String get vendorShopDetails => 'दुकान विवरण';

  @override
  String get vendorShopDetailsSubtitle => 'अपनी दुकान की जानकारी दर्ज करें';

  @override
  String get vendorOwnerDetails => 'मालिक विवरण';

  @override
  String get vendorOwnerDetailsSubtitle => 'मालिक की जानकारी दर्ज करें';

  @override
  String get vendorDocuments => 'दस्तावेज़';

  @override
  String get vendorDocumentsSubtitle =>
      'सत्यापन के लिए आवश्यक दस्तावेज़ अपलोड करें';

  @override
  String get vendorShopName => 'दुकान का नाम';

  @override
  String get vendorShopNameHint => 'दुकान का नाम दर्ज करें';

  @override
  String get vendorShopAddress => 'दुकान का पता';

  @override
  String get vendorShopAddressHint => 'पूरा दुकान पता दर्ज करें';

  @override
  String get vendorShopPincode => 'दुकान पिनकोड';

  @override
  String get vendorShopPincodeHint => '6 अंकों का पिनकोड दर्ज करें';

  @override
  String get vendorShopLocation => 'दुकान स्थान *';

  @override
  String get vendorShopImages => 'दुकान की तस्वीरें *';

  @override
  String get vendorShopImagesSubtitle => '5 तक दुकान की तस्वीरें अपलोड करें';

  @override
  String get vendorOwnerName => 'मालिक का नाम';

  @override
  String get vendorOwnerNameHint => 'मालिक का पूरा नाम दर्ज करें';

  @override
  String get vendorOwnerAddress => 'मालिक का पता';

  @override
  String get vendorOwnerAddressHint => 'पूरा मालिक पता दर्ज करें';

  @override
  String get vendorOwnerPincode => 'मालिक पिनकोड';

  @override
  String get vendorOwnerPincodeHint => '6 अंकों का पिनकोड दर्ज करें';

  @override
  String get vendorOwnerLocation => 'मालिक स्थान *';

  @override
  String get vendorMobileNumber => 'मोबाइल नंबर';

  @override
  String get vendorMobileNumberHint => '10 अंकों का मोबाइल नंबर दर्ज करें';

  @override
  String get vendorEmailId => 'ईमेल आईडी';

  @override
  String get vendorEmailIdHint => 'ईमेल पता दर्ज करें';

  @override
  String get vendorOwnerImages => 'मालिक की तस्वीरें *';

  @override
  String get vendorOwnerImagesSubtitle => '2 तक मालिक की तस्वीरें अपलोड करें';

  @override
  String get vendorPickLocation => 'मानचित्र से स्थान चुनें';

  @override
  String get vendorAadharCard => 'आधार कार्ड';

  @override
  String get vendorPanCard => 'पैन कार्ड';

  @override
  String get vendorBankAccount => 'बैंक खाता';

  @override
  String get vendorGstNumber => 'जीएसटी नंबर';

  @override
  String get vendorNonGstCertificate => 'गैर जीएसटी प्रमाण पत्र';

  @override
  String get vendorNonGstCertificateSubtitle =>
      'गैर जीएसटी प्रमाण पत्र अपलोड करें';

  @override
  String get vendorMsmeCertificate => 'एमएसएमई प्रमाण पत्र';

  @override
  String get vendorMsmeCertificateSubtitle =>
      'एमएसएमई प्रमाण पत्र अपलोड करें (यदि लागू हो)';

  @override
  String get vendorFssaiCertificate => 'एफएसएसएआई प्रमाण पत्र *';

  @override
  String get vendorFssaiCertificateSubtitle =>
      'खाद्य व्यवसायों के लिए एफएसएसएआई लाइसेंस अपलोड करें';

  @override
  String get vendorShopAgreement => 'दुकान समझौता';

  @override
  String get vendorShopAgreementSubtitle =>
      'दुकान समझौता अपलोड करें (वैकल्पिक)';

  @override
  String get vendorSubmitApplication => 'आवेदन जमा करें';

  @override
  String get vendorAadharDetails => 'आधार विवरण';

  @override
  String get vendorAadharNumber => 'आधार नंबर *';

  @override
  String get vendorAadharNumberHint => '12 अंकों का आधार नंबर दर्ज करें';

  @override
  String get vendorAadharDocument => 'आधार नंबर दस्तावेज़ *';

  @override
  String get vendorPanDetails => 'पैन विवरण';

  @override
  String get vendorPanCardNumber => 'पैन कार्ड नंबर *';

  @override
  String get vendorPanCardNumberHint =>
      'पैन कार्ड नंबर दर्ज करें (जैसे, ABCDE1234F)';

  @override
  String get vendorPanDocument => 'पैन कार्ड नंबर दस्तावेज़ *';

  @override
  String get vendorBankDetails => 'बैंक विवरण';

  @override
  String get vendorAccountNumber => 'खाता नंबर *';

  @override
  String get vendorAccountNumberHint => 'बैंक खाता नंबर दर्ज करें';

  @override
  String get vendorIfscCode => 'आईएफएससी कोड *';

  @override
  String get vendorIfscCodeHint => 'आईएफएससी कोड दर्ज करें';

  @override
  String get vendorAccountHolderName => 'खाताधारक का नाम *';

  @override
  String get vendorAccountHolderNameHint => 'खाताधारक का नाम दर्ज करें';

  @override
  String get vendorBankName => 'बैंक का नाम *';

  @override
  String get vendorBankNameHint => 'बैंक का नाम दर्ज करें (वैकल्पिक)';

  @override
  String get vendorBranchName => 'शाखा का नाम';

  @override
  String get vendorBranchNameHint => 'शाखा का नाम दर्ज करें (वैकल्पिक)';

  @override
  String get vendorUploadBankProof => 'बैंक प्रमाण अपलोड करें';

  @override
  String get vendorUploadBankProofSubtitle =>
      'बैंक पासबुक या रद्द चेक अपलोड करें';

  @override
  String get vendorBankDocument => 'बैंक दस्तावेज़ *';

  @override
  String get vendorGstDetails => 'जीएसटी विवरण';

  @override
  String get vendorGstNumberLabel => 'जीएसटी नंबर *';

  @override
  String get vendorGstNumberHint => '15 अंकों का जीएसटी नंबर दर्ज करें';

  @override
  String get vendorGstDocument => 'जीएसटी नंबर दस्तावेज़ *';

  @override
  String get vendorSaveAndVerify => 'सहेजें और सत्यापित करें';

  @override
  String get vendorUploadDocument => 'दस्तावेज़ अपलोड करें';

  @override
  String get vendorUploadDocumentHint =>
      'पीडीएफ, जेपीजी, पीएनजी (अधिकतम 5एमबी)';

  @override
  String get vendorAddImage => 'जोड़ें';

  @override
  String get vendorJoinSuccess => 'विक्रेता आवेदन सफलतापूर्वक जमा किया गया!';

  @override
  String get vendorShopNameRequired => 'दुकान का नाम आवश्यक है';

  @override
  String get vendorShopLocationRequired => 'दुकान का स्थान आवश्यक है';

  @override
  String get vendorShopImagesRequired =>
      'कम से कम एक दुकान की तस्वीर आवश्यक है';

  @override
  String get vendorOwnerLocationRequired => 'मालिक का स्थान आवश्यक है';

  @override
  String get vendorOwnerImagesRequired =>
      'कम से कम एक मालिक की तस्वीर आवश्यक है';

  @override
  String get vendorOwnerImageRequired => 'मालिक की तस्वीर आवश्यक है';

  @override
  String get vendorVendorDetails => 'विक्रेता विवरण';

  @override
  String get vendorVendorDetailsSubtitle =>
      'अपना विक्रेता पंजीकरण विवरण दर्ज करें';

  @override
  String get vendorVendorName => 'विक्रेता का नाम';

  @override
  String get vendorVendorNameHint => 'विक्रेता/स्टोर का नाम दर्ज करें';

  @override
  String get vendorVendorNameRequired => 'विक्रेता का नाम आवश्यक है';

  @override
  String get vendorAddress => 'पता';

  @override
  String get vendorAddressHint => 'विक्रेता का पता दर्ज करें';

  @override
  String get vendorAddressRequired => 'पता आवश्यक है';

  @override
  String get vendorPincode => 'पिनकोड';

  @override
  String get vendorPincodeHint => 'पिनकोड दर्ज करें';

  @override
  String get vendorPincodeRequired => 'पिनकोड आवश्यक है';

  @override
  String get vendorStateId => 'राज्य';

  @override
  String get vendorStateIdHint => 'राज्य आईडी दर्ज करें';

  @override
  String get vendorStateIdRequired => 'राज्य आवश्यक है';

  @override
  String get vendorCityId => 'शहर';

  @override
  String get vendorCityIdHint => 'शहर आईडी दर्ज करें';

  @override
  String get vendorCityIdRequired => 'शहर आवश्यक है';

  @override
  String get vendorOwnerImage => 'मालिक की तस्वीर *';

  @override
  String get vendorOwnerImageSubtitle => 'मालिक की फोटो अपलोड करें';

  @override
  String get vendorShopAddressRequired => 'दुकान का पता आवश्यक है';

  @override
  String get vendorShopPincodeRequired => 'दुकान का पिनकोड आवश्यक है';

  @override
  String get vendorOwnerNameRequired => 'मालिक का नाम आवश्यक है';

  @override
  String get vendorOwnerAddressRequired => 'मालिक का पता आवश्यक है';

  @override
  String get vendorOwnerPincodeRequired => 'मालिक का पिनकोड आवश्यक है';

  @override
  String get vendorMobileNumberRequired => 'मोबाइल नंबर आवश्यक है';

  @override
  String get vendorEmailRequired => 'ईमेल आवश्यक है';

  @override
  String get vendorAadhaarNumberRequired => 'आधार नंबर आवश्यक है';

  @override
  String get vendorAadhaarFileRequired => 'आधार दस्तावेज़ आवश्यक है';

  @override
  String get vendorPanFileRequired => 'पैन दस्तावेज़ आवश्यक है';

  @override
  String get vendorBankFileRequired => 'बैंक दस्तावेज़ आवश्यक है';

  @override
  String get vendorGstFileRequired => 'जीएसटी दस्तावेज़ आवश्यक है';

  @override
  String get vendorGstOrNonGstRequired =>
      'जीएसटी दस्तावेज़ या नॉन-जीएसटी प्रमाणपत्र अपलोड करें';

  @override
  String get vendorFssaiFileRequired => 'FSSAI प्रमाणपत्र आवश्यक है';

  @override
  String get chooseHowToReachUs => 'हमसे कैसे संपर्क करना चाहेंगे चुनें';

  @override
  String get requestCallback => 'कॉलबैक अनुरोध';

  @override
  String get requestCallbackDescription =>
      'हमारी सहायता टीम से कॉल प्राप्त करें';

  @override
  String get emailSupport => 'ईमेल सहायता';

  @override
  String get emailSupportDescription =>
      'customersupport@takshallinone.in पर हमें ईमेल भेजें';

  @override
  String get emailAppError =>
      'ईमेल ऐप खोलने में असमर्थ। कृपया customersupport@takshallinone.in पर ईमेल करें';

  @override
  String get myWishlist => 'मेरी विशलिस्ट';

  @override
  String get addedToWishlist => 'विशलिस्ट में जोड़ा गया';

  @override
  String get removedFromWishlist => 'विशलिस्ट से हटाया गया';

  @override
  String get wishlistEmpty => 'आपकी विशलिस्ट खाली है';

  @override
  String get wishlistEmptySubtitle =>
      'उत्पादों को ब्राउज़ करें और अपने पसंदीदा यहां जोड़ें';

  @override
  String get removeFromWishlistConfirm => 'विशलिस्ट से हटाएं?';

  @override
  String get failedToLoadWishlist => 'विशलिस्ट लोड करने में विफल';

  @override
  String get couldNotAddToCart =>
      'कार्ट में आइटम जोड़ने में असमर्थ। कृपया पुनः प्रयास करें।';

  @override
  String get couldNotLoadProduct =>
      'उत्पाद विवरण लोड करने में असमर्थ। कृपया पुनः प्रयास करें।';

  @override
  String get noVariantsAvailable => 'यह उत्पाद वर्तमान में उपलब्ध नहीं है।';

  @override
  String get cartUnexpectedError => 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।';

  @override
  String get checkDeliveryAvailability => 'डिलीवरी उपलब्धता जांचें';

  @override
  String get invalidPincode => 'कृपया एक मान्य 6-अंकीय पिनकोड दर्ज करें';

  @override
  String get check => 'जांचें';

  @override
  String fulfilledBy(String shopName) {
    return '$shopName द्वारा पूर्ण';
  }

  @override
  String get couldNotCheckDelivery =>
      'डिलीवरी उपलब्धता जांचने में असमर्थ। कृपया पुनः प्रयास करें।';

  @override
  String get homeServices => 'Home Services';

  @override
  String get homeServicesSubtitle =>
      'Book professional services at your doorstep';

  @override
  String get couldNotLoadServices => 'Could not load services';

  @override
  String get courierBooking => 'Courier Booking';

  @override
  String get customerAndPickupDetails => 'ग्राहक और पिकअप विवरण';

  @override
  String get electrician => 'Electrician';

  @override
  String get plumber => 'Plumber';

  @override
  String get salonParlor => 'Salon / Parlor';

  @override
  String get pickupDetails => 'Pickup Details';

  @override
  String get pickupAddress => 'Pickup Address';

  @override
  String get enterPickupAddress => 'Enter full pickup address';

  @override
  String get pickupPincode => 'Pickup Pincode';

  @override
  String get deliveryDetails => 'Delivery Details';

  @override
  String get enterDeliveryAddress => 'Enter full delivery address';

  @override
  String get deliveryPincode => 'Delivery Pincode';

  @override
  String get parcelDetails => 'Parcel Details';

  @override
  String get packagingDetails => 'पैकेजिंग विवरण';

  @override
  String get enterProductDetails => 'उत्पाद का नाम और विवरण दर्ज करें';

  @override
  String get enterPackagingDetails => 'लिफाफा, बॉक्स आदि दर्ज करें';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get dimensionUnit => 'Dimension Unit';

  @override
  String get additionalInfo => 'Additional Info';

  @override
  String get customerNotes => 'Customer Notes (optional)';

  @override
  String get addProductImage => 'Add Product Image (optional)';

  @override
  String get checkPrice => 'Check Price';

  @override
  String get bookService => 'Book Service';

  @override
  String get priceCheckComplete => 'Price Check Complete';

  @override
  String get bookingSubmitted => 'Booking Submitted';

  @override
  String get tokenAmount => 'Token Amount';

  @override
  String get serviceHistory => 'Service History';

  @override
  String get history => 'History';

  @override
  String get noPreviousOrders => 'No previous orders';

  @override
  String get serviceHistoryEmpty =>
      'Your service booking history will appear here';

  @override
  String get couldNotLoadHistory => 'Could not load history';

  @override
  String get inquiryId => 'Inquiry ID';

  @override
  String get yourAddress => 'Your Address';

  @override
  String get fullAddress => 'Full Address';

  @override
  String get enterCompleteAddress => 'Enter your complete address';

  @override
  String get serviceDescription => 'Service Description';

  @override
  String get describeServiceNeeded => 'Describe the service you need';

  @override
  String get sixDigitPincode => '6-digit pincode';

  @override
  String get enterValidPincode => 'Enter a valid 6-digit pincode';

  @override
  String guestWallTitle(String contentLabel) {
    return '$contentLabel देखने के लिए लॉगिन करें';
  }

  @override
  String guestWallSubtitle(String contentLabel) {
    return '$contentLabel एक्सेस करने के लिए साइन इन करें और ऑर्डर ट्रैकिंग, सेव किए गए पतों और बहुत कुछ के साथ व्यक्तिगत खरीदारी अनुभव का आनंद लें।';
  }

  @override
  String get guestWallLoginButton => 'लॉगिन करें';

  @override
  String get guestWallContinueBrowsing => 'गेस्ट के रूप में ब्राउज़ करें';

  @override
  String get loginCancelButton => 'रद्द करें';

  @override
  String get orderReview => 'ऑर्डर की समीक्षा करें';

  @override
  String get reviewYourOrder =>
      'पुष्टि करने से पहले अपने ऑर्डर की समीक्षा करें';

  @override
  String get reviewOrderDescription =>
      'कृपया नीचे दिए गए विवरणों को सत्यापित करें और अपना ऑर्डर देने के लिए \"ऑर्डर की पुष्टि करें\" पर टैप करें।';

  @override
  String get confirmOrder => 'ऑर्डर की पुष्टि करें';

  @override
  String get confirmingOrder => 'आपका ऑर्डर दिया जा रहा है...';

  @override
  String get deliveryTo => 'डिलीवरी पता';

  @override
  String get payment => 'भुगतान';

  @override
  String get orderSummaryTitle => 'ऑर्डर सारांश';

  @override
  String get itemTotal => 'आइटम कुल';

  @override
  String get platformFees => 'प्लेटफ़ॉर्म शुल्क';

  @override
  String get otherChargesLabel => 'अन्य शुल्क';

  @override
  String get orderPlacedTitle => 'ऑर्डर दिया गया';

  @override
  String get orderPlacedSubtitle =>
      'आपका ऑर्डर सफलतापूर्वक दिया गया है। डिलीवरी पर भुगतान करें।';

  @override
  String get orderPlacedOnlineSubtitle =>
      'आपका ऑर्डर सफलतापूर्वक दिया गया है। भुगतान पर पुनः निर्देशित किया जा रहा है...';

  @override
  String get thankYouForOrder => 'आपके ऑर्डर के लिए धन्यवाद!';

  @override
  String get viewMyOrders => 'मेरे ऑर्डर देखें';

  @override
  String get back => 'वापस';

  @override
  String get readMore => 'और पढ़ें';

  @override
  String get readLess => 'कम पढ़ें';

  @override
  String get skip => 'छोड़ें';

  @override
  String get next => 'आगे';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get onboardingTitle1 => 'जो चाहिए वो सब खरीदें';

  @override
  String get onboardingSubtitle1 =>
      'स्थानीय स्टोर्स से हज़ारों उत्पाद खोजें, सीधे आपके दरवाज़े तक।';

  @override
  String get onboardingTitle2 => 'तेज़ और भरोसेमंद डिलीवरी';

  @override
  String get onboardingSubtitle2 =>
      'अपने ऑर्डर को रियल-टाइम में ट्रैक करें और मिनटों में डिलीवरी पाएं।';

  @override
  String get onboardingTitle3 => 'सुरक्षित भुगतान';

  @override
  String get onboardingSubtitle3 =>
      'भरोसेमंद भुगतान विधियों के साथ निश्चिंत होकर भुगतान करें।';

  @override
  String get exitAppSavedNote => 'आपकी शॉपिंग कार्ट और प्रगति सहेज ली जाएगी।';

  @override
  String get cartEmptyDescription => 'लगता है आपने अभी तक कुछ नहीं जोड़ा है।\nहमारे उत्पादों की विस्तृत श्रृंखला देखना शुरू करें।';

  @override
  String get splashPreparing => 'आपके लिए सबसे अच्छा शॉपिंग अनुभव तैयार हो रहा है';

  @override
  String get trustFastDelivery => 'तेज़ डिलीवरी';

  @override
  String get trustSecureShopping => 'सुरक्षित शॉपिंग';

  @override
  String get trustQualityProducts => 'गुणवत्तापूर्ण उत्पाद';

  @override
  String get trustByIndia => 'भारत का भरोसा';

  @override
  String get trustWideSelection => 'विस्तृत चयन';

  @override
  String get trustBestPrices => 'सर्वोत्तम कीमतें';

  @override
  String get trustSecurePayment => 'सुरक्षित भुगतान';

  @override
  String get quickNoCategories => 'इस पते के लिए अभी कोई क्विक डिलीवरी श्रेणी उपलब्ध नहीं है।';

  @override
  String get quickLocationNeededTitle => 'डिलीवरी पता चुनें';

  @override
  String get quickLocationNeededBody => 'क्विक डिलीवरी के लिए मैप लोकेशन वाला डिलीवरी पता चाहिए। अपने पास उपलब्ध चीज़ें देखने के लिए पता चुनें या जोड़ें।';

  @override
  String get quickNotServiceableTitle => 'क्विक डिलीवरी यहाँ उपलब्ध नहीं है';

  @override
  String get quickNotServiceableDefault => 'इस पते पर अभी क्विक डिलीवरी उपलब्ध नहीं है। आप पता बदल सकते हैं या स्टैंडर्ड डिलीवरी चुन सकते हैं।';

  @override
  String get changeAddress => 'पता बदलें';

  @override
  String get quickCheckoutUnavailable => 'इस पते के लिए अभी क्विक डिलीवरी की पुष्टि नहीं हो सकी। कृपया पता बदलें या स्टैंडर्ड डिलीवरी चुनें।';

  @override
  String get quickDeliveryNearbyStore => 'पास के स्टोर से क्विक डिलीवरी';

  @override
  String get loginRequiredTitle => 'लॉगिन ज़रूरी है';

  @override
  String get loginToAddToCart => 'कार्ट में आइटम जोड़ने के लिए कृपया लॉगिन करें।';

  @override
  String get quickAvailabilityTitle => 'उपलब्धता';

  @override
  String get quickAvailabilityChecking => 'आपके पते पर उपलब्धता जाँची जा रही है…';

  @override
  String get quickAvailabilityAvailable => 'आपके पते पर क्विक डिलीवरी के लिए उपलब्ध';

  @override
  String get quickAvailabilityNotInArea => 'यह उत्पाद आपके क्षेत्र में अभी उपलब्ध नहीं है।';

  @override
  String get quickAvailabilityOutOfStock => 'यह उत्पाद अभी स्टॉक में नहीं है।';

  @override
  String get quickAvailabilityLocationRequired => 'उपलब्धता जाँचने के लिए मानचित्र स्थान वाला पता चुनें।';

  @override
  String get quickAvailabilityUnavailable => 'यह उत्पाद अभी क्विक डिलीवरी के लिए उपलब्ध नहीं है।';

  @override
  String get quickAvailabilityFailed => 'हम उपलब्धता नहीं जाँच सके। कृपया फिर से प्रयास करें।';

  @override
  String get quickBadgeNotInArea => 'आपके क्षेत्र में नहीं';

  @override
  String get quickCatalogueFallbackNotice => 'इस पते पर क्विक डिलीवरी उपलब्ध नहीं है। आप ये उत्पाद देख सकते हैं।';

  @override
  String multiOrderTitle(int count) {
    return 'आपके आइटम $count ऑर्डर में बँटे हैं';
  }

  @override
  String get multiOrderSubtitle => 'हर दुकान अपना ऑर्डर खुद तैयार करके पहुँचाती है।';

  @override
  String checkoutSplitNotice(int count) {
    return 'आपके आइटम $count दुकानों के हैं, इसलिए $count अलग-अलग ऑर्डर दिए जाएँगे।';
  }

  @override
  String orderOfTotal(int index, int total) {
    return 'ऑर्डर $index / $total';
  }

  @override
  String get notificationPermissionTitle => 'नोटिफ़िकेशन चालू करें';

  @override
  String get notificationPermissionMessage => 'Taksh से ऑर्डर अपडेट, पेमेंट कन्फर्मेशन और ऑफ़र पाने के लिए नोटिफ़िकेशन की अनुमति दें। आप इन्हें अपने डिवाइस की सेटिंग्स में चालू कर सकते हैं।';
}
