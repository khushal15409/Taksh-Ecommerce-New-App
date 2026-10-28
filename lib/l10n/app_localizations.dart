import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Taksh E-Commerce'**
  String get appTitle;

  /// No description provided for @madeInIndia.
  ///
  /// In en, this message translates to:
  /// **'Made in India'**
  String get madeInIndia;

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// No description provided for @checkingAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Checking authentication...'**
  String get checkingAuthentication;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Food delivered to your doorstep'**
  String get loginTagline;

  /// No description provided for @enterPhoneDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to receive OTP'**
  String get enterPhoneDescription;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 10-digit phone number'**
  String get enterPhoneNumberHint;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service and Privacy Policy'**
  String get termsAndPrivacy;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @enterOtpDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code sent to {phone}'**
  String enterOtpDescription(String phone);

  /// No description provided for @otpHint.
  ///
  /// In en, this message translates to:
  /// **'0000'**
  String get otpHint;

  /// No description provided for @verifyOtpButton.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtpButton;

  /// No description provided for @didNotReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? '**
  String get didNotReceiveCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @otpResentSuccess.
  ///
  /// In en, this message translates to:
  /// **'OTP resent successfully'**
  String get otpResentSuccess;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit phone number'**
  String get invalidPhone;

  /// No description provided for @otpRequired.
  ///
  /// In en, this message translates to:
  /// **'OTP is required'**
  String get otpRequired;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 4-digit OTP'**
  String get invalidOtp;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @themeChanged.
  ///
  /// In en, this message translates to:
  /// **'Theme changed to {theme}'**
  String themeChanged(String theme);

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChanged(String language);

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @myAddress.
  ///
  /// In en, this message translates to:
  /// **'My Address'**
  String get myAddress;

  /// No description provided for @coupons.
  ///
  /// In en, this message translates to:
  /// **'Coupons'**
  String get coupons;

  /// No description provided for @paymentMethodsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods - Coming Soon'**
  String get paymentMethodsComingSoon;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @joinAsDeliveryMan.
  ///
  /// In en, this message translates to:
  /// **'Join as Delivery Man'**
  String get joinAsDeliveryMan;

  /// No description provided for @openVendor.
  ///
  /// In en, this message translates to:
  /// **'Open Vendor'**
  String get openVendor;

  /// No description provided for @languageSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Language Settings - Coming Soon'**
  String get languageSettingsComingSoon;

  /// No description provided for @createApplication.
  ///
  /// In en, this message translates to:
  /// **'Create Application'**
  String get createApplication;

  /// No description provided for @createWebsite.
  ///
  /// In en, this message translates to:
  /// **'Create Website'**
  String get createWebsite;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @refundPolicy.
  ///
  /// In en, this message translates to:
  /// **'Refund Policy'**
  String get refundPolicy;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @standardDelivery.
  ///
  /// In en, this message translates to:
  /// **'Standard Delivery'**
  String get standardDelivery;

  /// No description provided for @standardDeliveryDescription.
  ///
  /// In en, this message translates to:
  /// **'Standard Delivery - Shop Your Favorites!'**
  String get standardDeliveryDescription;

  /// No description provided for @quickDelivery.
  ///
  /// In en, this message translates to:
  /// **'Quick Delivery'**
  String get quickDelivery;

  /// No description provided for @quickDeliveryDescription.
  ///
  /// In en, this message translates to:
  /// **'Quick Delivery - Express 30'**
  String get quickDeliveryDescription;

  /// No description provided for @homeService.
  ///
  /// In en, this message translates to:
  /// **'Home Service'**
  String get homeService;

  /// No description provided for @homeServiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore home services coming soon'**
  String get homeServiceDescription;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for products...'**
  String get searchHint;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @exitAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit app?'**
  String get exitAppTitle;

  /// No description provided for @exitAppContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit?'**
  String get exitAppContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @categoriesTab.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTab;

  /// No description provided for @cartTab.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTab;

  /// No description provided for @ordersTab.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clearCart;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Cart is Empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add items to get started'**
  String get cartEmptySubtitle;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'Start Shopping'**
  String get startShopping;

  /// No description provided for @sku.
  ///
  /// In en, this message translates to:
  /// **'SKU: {sku}'**
  String sku(String sku);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total: ₹{amount}'**
  String total(String amount);

  /// No description provided for @removeItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Item'**
  String get removeItemTitle;

  /// No description provided for @removeItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {product} from cart?'**
  String removeItemConfirm(String product);

  /// No description provided for @clearCartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove all items from cart?'**
  String get clearCartConfirm;

  /// No description provided for @totalItemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Items: {count}'**
  String totalItemsLabel(int count);

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @filterByStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by Status'**
  String get filterByStatus;

  /// No description provided for @allOrders.
  ///
  /// In en, this message translates to:
  /// **'All Orders'**
  String get allOrders;

  /// No description provided for @readyForDispatch.
  ///
  /// In en, this message translates to:
  /// **'Ready for Dispatch'**
  String get readyForDispatch;

  /// No description provided for @dispatched.
  ///
  /// In en, this message translates to:
  /// **'Dispatched'**
  String get dispatched;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @dateNewestFirst.
  ///
  /// In en, this message translates to:
  /// **'Date: Newest First'**
  String get dateNewestFirst;

  /// No description provided for @dateOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Date: Oldest First'**
  String get dateOldestFirst;

  /// No description provided for @amountHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Amount: High to Low'**
  String get amountHighToLow;

  /// No description provided for @amountLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Amount: Low to High'**
  String get amountLowToHigh;

  /// No description provided for @recentlyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recently Updated'**
  String get recentlyUpdated;

  /// No description provided for @leastRecentlyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Least Recently Updated'**
  String get leastRecentlyUpdated;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrdersFound;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters'**
  String get tryAdjustingFilters;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by date'**
  String get filterByDate;

  /// No description provided for @clearDateFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear date filter'**
  String get clearDateFilter;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No Orders Yet'**
  String get noOrdersYet;

  /// No description provided for @yourOrdersAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here'**
  String get yourOrdersAppearHere;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{number}'**
  String orderNumber(String number);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// No description provided for @estDelivery.
  ///
  /// In en, this message translates to:
  /// **'Est. delivery: {date}'**
  String estDelivery(String date);

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @placedOn.
  ///
  /// In en, this message translates to:
  /// **'Placed on {date}'**
  String placedOn(String date);

  /// No description provided for @deliveryType.
  ///
  /// In en, this message translates to:
  /// **'Delivery Type'**
  String get deliveryType;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// No description provided for @estimatedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Estimated Delivery'**
  String get estimatedDelivery;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Order Items ({count})'**
  String orderItems(int count);

  /// No description provided for @qtyPrice.
  ///
  /// In en, this message translates to:
  /// **'Qty: {qty} × ₹{price}'**
  String qtyPrice(int qty, String price);

  /// No description provided for @returnItem.
  ///
  /// In en, this message translates to:
  /// **'Return Item'**
  String get returnItem;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @paymentInformation.
  ///
  /// In en, this message translates to:
  /// **'Payment Information'**
  String get paymentInformation;

  /// No description provided for @paidVia.
  ///
  /// In en, this message translates to:
  /// **'Paid via {method}'**
  String paidVia(String method);

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @whatsappError.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp. Please make sure WhatsApp is installed.'**
  String get whatsappError;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated: {date}'**
  String lastUpdated(String date);

  /// No description provided for @termsIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Introduction and Acceptance'**
  String get termsIntroTitle;

  /// No description provided for @termsIntroContent.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Taksh, operated by TAKSH ALL IN ONE ECOMMERCE & LOGISTICS WITH MULTI SERVICES PRIVATE LIMITED ("Taksh", "we", "us"). These Terms & Conditions govern your use of our mobile application and related services (the "Platform"). By downloading, registering or using the Platform, you agree to these Terms. If you do not agree, please do not use the Platform.\n\nYou must be at least 18 years old and legally able to enter into a contract under the Indian Contract Act, 1872. Minors may use the Platform only under the supervision of a parent or guardian.'**
  String get termsIntroContent;

  /// No description provided for @termsAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Account Registration'**
  String get termsAccountTitle;

  /// No description provided for @termsAccountContent.
  ///
  /// In en, this message translates to:
  /// **'You sign in with your mobile number, verified by a One-Time Password (OTP). You agree to:\n\n• Provide accurate and complete information\n• Keep your device and OTP confidential and never share your OTP with anyone\n• Tell us immediately if you suspect unauthorised use\n• Accept responsibility for all activity under your account\n\nWe may suspend or close accounts that give false information or break these Terms.'**
  String get termsAccountContent;

  /// No description provided for @termsUserRespTitle.
  ///
  /// In en, this message translates to:
  /// **'3. User Responsibilities'**
  String get termsUserRespTitle;

  /// No description provided for @termsUserRespContent.
  ///
  /// In en, this message translates to:
  /// **'As a user of the Platform, you agree to:\n\n• Use it only for lawful purposes\n• Not provide false information or pretend to be someone else\n• Not misuse offers, coupons or referral benefits\n• Not post abusive, misleading or unlawful reviews or content\n• Not copy, scrape or interfere with the Platform or try to gain unauthorised access to our systems\n• Not infringe the intellectual property rights of others'**
  String get termsUserRespContent;

  /// No description provided for @termsProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Products and Pricing'**
  String get termsProductsTitle;

  /// No description provided for @termsProductsContent.
  ///
  /// In en, this message translates to:
  /// **'We try to show accurate product descriptions, images, prices and availability. However:\n\n• Images are for illustration and colour or packaging may differ slightly\n• All prices are in Indian Rupees (INR) and include applicable taxes unless stated otherwise\n• Delivery or handling charges, if any, are shown before you place the order\n• Prices, offers and availability may change without notice; the price shown when you place the order applies\n• If a product is listed at a wrong price because of a technical or typing error, we may cancel the order and refund any amount paid'**
  String get termsProductsContent;

  /// No description provided for @termsOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'5. Orders'**
  String get termsOrdersTitle;

  /// No description provided for @termsOrdersContent.
  ///
  /// In en, this message translates to:
  /// **'• Placing an order is an offer to buy. A contract is formed only when we confirm your order\n• You confirm that the details you give (including your delivery address and phone number) are correct\n• We may cancel or refuse an order if stock is unavailable, there is a pricing error, fraud is suspected or the address cannot be served. If you have already paid, we will refund you\n• Quantity limits may apply to some products'**
  String get termsOrdersContent;

  /// No description provided for @termsPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'6. Payments'**
  String get termsPaymentTitle;

  /// No description provided for @termsPaymentContent.
  ///
  /// In en, this message translates to:
  /// **'• You can pay online through our payment gateway (UPI, cards, net banking or wallets) or choose Cash on Delivery where available\n• Online payments are processed by a third-party payment gateway. We do not store your card number, CVV, UPI PIN or banking passwords\n• You confirm that you are authorised to use the payment method you choose\n• If money is debited but the order is not confirmed, the amount is normally reversed automatically within 5 to 7 working days. If it is not, please contact us with the transaction details\n• For Cash on Delivery, please keep the payment ready at delivery. We may limit or disable Cash on Delivery for accounts with repeated refused or undelivered orders'**
  String get termsPaymentContent;

  /// No description provided for @termsShippingTitle.
  ///
  /// In en, this message translates to:
  /// **'7. Delivery'**
  String get termsShippingTitle;

  /// No description provided for @termsShippingContent.
  ///
  /// In en, this message translates to:
  /// **'• Delivery options (Express 30-minute, Next-Day and Standard) depend on your location and product availability\n• Delivery times are estimates, not guarantees. Delays can happen due to weather, traffic, high demand or other events beyond our control\n• Please give a complete and correct address and keep your phone reachable. We are not responsible for failed delivery caused by wrong or incomplete details\n• Please check your items at delivery and report any problem as soon as possible\n• Risk of loss passes to you on delivery'**
  String get termsShippingContent;

  /// No description provided for @termsCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'8. Cancellations'**
  String get termsCancelTitle;

  /// No description provided for @termsCancelContent.
  ///
  /// In en, this message translates to:
  /// **'• You can cancel an order before it is dispatched, from the app or by contacting us\n• Once an order is dispatched it cannot be cancelled, but it may be returned as per our Refund & Return Policy\n• Prepaid orders cancelled before dispatch are refunded as described in our Refund & Return Policy'**
  String get termsCancelContent;

  /// No description provided for @termsReturnsTitle.
  ///
  /// In en, this message translates to:
  /// **'9. Returns and Refunds'**
  String get termsReturnsTitle;

  /// No description provided for @termsReturnsContent.
  ///
  /// In en, this message translates to:
  /// **'Returns, replacements and refunds are governed by our Refund & Return Policy, which is part of these Terms. In short:\n\n• Return requests must be raised in the app within the return window shown for the product\n• Items must be unused and in their original condition and packaging\n• Some items cannot be returned, as listed in the policy\n• Approved refunds for returned items are credited to your Taksh wallet'**
  String get termsReturnsContent;

  /// No description provided for @termsOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'10. Offers and Third-Party Sellers'**
  String get termsOffersTitle;

  /// No description provided for @termsOffersContent.
  ///
  /// In en, this message translates to:
  /// **'• Offers, discounts and coupons are subject to their own terms, validity and usage limits and may be withdrawn or changed at any time\n• Some products are sold by third-party sellers and delivered through our fulfillment centers or delivery partners. Taksh facilitates the sale and, where applicable, the seller\'s details are shown on the product page\n• The Platform may link to third-party services. We are not responsible for their content or practices'**
  String get termsOffersContent;

  /// No description provided for @termsIpTitle.
  ///
  /// In en, this message translates to:
  /// **'11. Intellectual Property'**
  String get termsIpTitle;

  /// No description provided for @termsIpContent.
  ///
  /// In en, this message translates to:
  /// **'All content on the Platform, including logos, trademarks, text, graphics, images and software, belongs to Taksh or its licensors and is protected by Indian intellectual property laws. You may not copy, modify, distribute or use it commercially without our written permission.'**
  String get termsIpContent;

  /// No description provided for @termsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'12. Privacy and Data Protection'**
  String get termsPrivacyTitle;

  /// No description provided for @termsPrivacyContent.
  ///
  /// In en, this message translates to:
  /// **'Your privacy matters to us. We collect and use your personal data as described in our Privacy Policy. By using the Platform, you consent to that collection and use.'**
  String get termsPrivacyContent;

  /// No description provided for @termsLiabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'13. Limitation of Liability'**
  String get termsLiabilityTitle;

  /// No description provided for @termsLiabilityContent.
  ///
  /// In en, this message translates to:
  /// **'To the extent permitted by law:\n\n• The Platform is provided "as is" and "as available". We do not promise that it will always be uninterrupted or error-free\n• We are not liable for indirect or consequential losses\n• Our total liability for any claim about an order is limited to the amount you paid for that order\n• Manufacturer warranties, if any, are given by the manufacturer\n\nNothing in these Terms limits your rights under the Consumer Protection Act, 2019.'**
  String get termsLiabilityContent;

  /// No description provided for @termsIndemnifyTitle.
  ///
  /// In en, this message translates to:
  /// **'14. Indemnification'**
  String get termsIndemnifyTitle;

  /// No description provided for @termsIndemnifyContent.
  ///
  /// In en, this message translates to:
  /// **'You agree to compensate and hold Taksh harmless against claims, losses and expenses that arise from your breach of these Terms or your violation of any law or the rights of others.'**
  String get termsIndemnifyContent;

  /// No description provided for @termsModTitle.
  ///
  /// In en, this message translates to:
  /// **'15. Changes to These Terms'**
  String get termsModTitle;

  /// No description provided for @termsModContent.
  ///
  /// In en, this message translates to:
  /// **'We may update these Terms from time to time. The updated Terms will be shown in the app with a new "Last Updated" date. If you continue to use the Platform after the change, you accept the updated Terms.'**
  String get termsModContent;

  /// No description provided for @termsTerminationTitle.
  ///
  /// In en, this message translates to:
  /// **'16. Suspension and Termination'**
  String get termsTerminationTitle;

  /// No description provided for @termsTerminationContent.
  ///
  /// In en, this message translates to:
  /// **'We may suspend or end your access if you break these Terms, misuse the Platform or the law requires it. You may stop using the Platform and delete your account at any time. Rights and obligations that arose before termination continue.'**
  String get termsTerminationContent;

  /// No description provided for @termsLawTitle.
  ///
  /// In en, this message translates to:
  /// **'17. Governing Law and Jurisdiction'**
  String get termsLawTitle;

  /// No description provided for @termsLawContent.
  ///
  /// In en, this message translates to:
  /// **'These Terms are governed by the laws of India. Subject to your rights as a consumer under applicable law, the courts at Bhopal, Madhya Pradesh will have jurisdiction over disputes.'**
  String get termsLawContent;

  /// No description provided for @termsGrievanceTitle.
  ///
  /// In en, this message translates to:
  /// **'18. Grievance Officer'**
  String get termsGrievanceTitle;

  /// No description provided for @termsGrievanceContent.
  ///
  /// In en, this message translates to:
  /// **'In line with the Information Technology Act, 2000 and the Consumer Protection (E-Commerce) Rules, 2020, you can send complaints to our Grievance Officer:\n\nGrievance Officer\nTAKSH ALL IN ONE ECOMMERCE & LOGISTICS WITH MULTI SERVICES PRIVATE LIMITED\nEmail: customersupport@takshallinone.in\nAddress: Bhopal, Madhya Pradesh, India\n\nWe acknowledge complaints within 48 hours and aim to resolve them within one month.'**
  String get termsGrievanceContent;

  /// No description provided for @termsContactTitle.
  ///
  /// In en, this message translates to:
  /// **'19. Contact Us'**
  String get termsContactTitle;

  /// No description provided for @termsContactContent.
  ///
  /// In en, this message translates to:
  /// **'For any question about these Terms, contact us:\n\nEmail: customersupport@takshallinone.in\nAddress: Bhopal, Madhya Pradesh, India'**
  String get termsContactContent;

  /// No description provided for @termsAck.
  ///
  /// In en, this message translates to:
  /// **'By using Taksh, you confirm that you have read and understood these Terms & Conditions.'**
  String get termsAck;

  /// No description provided for @refundCommitmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Commitment'**
  String get refundCommitmentTitle;

  /// No description provided for @refundCommitmentContent.
  ///
  /// In en, this message translates to:
  /// **'At Taksh E-Commerce we want you to be happy with every order. If something is wrong with your order, this policy explains how returns, replacements, cancellations and refunds work.'**
  String get refundCommitmentContent;

  /// No description provided for @refundReadPolicy.
  ///
  /// In en, this message translates to:
  /// **'Please read this policy carefully. It is part of our Terms & Conditions.'**
  String get refundReadPolicy;

  /// No description provided for @refundEligibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Return Eligibility'**
  String get refundEligibilityTitle;

  /// No description provided for @refundEligibilityContent.
  ///
  /// In en, this message translates to:
  /// **'You can request a return within the return window of the product, counted from the date of delivery. The window is shown on the product page and is 7 days unless stated otherwise. You can request a return if:'**
  String get refundEligibilityContent;

  /// No description provided for @refundEligibilityItem1.
  ///
  /// In en, this message translates to:
  /// **'You received a wrong, damaged or defective item, or one that is different from its description'**
  String get refundEligibilityItem1;

  /// No description provided for @refundEligibilityItem2.
  ///
  /// In en, this message translates to:
  /// **'Parts, accessories or quantity are missing from your order'**
  String get refundEligibilityItem2;

  /// No description provided for @refundEligibilityItem3.
  ///
  /// In en, this message translates to:
  /// **'There is a size, fit or colour issue (where the product allows it)'**
  String get refundEligibilityItem3;

  /// No description provided for @refundEligibilityItem4.
  ///
  /// In en, this message translates to:
  /// **'The item is unused, with original packaging, tags and labels intact'**
  String get refundEligibilityItem4;

  /// No description provided for @refundEligibilityItem5.
  ///
  /// In en, this message translates to:
  /// **'You raise the request in the app with a reason and clear photos'**
  String get refundEligibilityItem5;

  /// No description provided for @refundNonReturnableTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Non-Returnable Items'**
  String get refundNonReturnableTitle;

  /// No description provided for @refundNonReturnableContent.
  ///
  /// In en, this message translates to:
  /// **'The following items cannot be returned, unless they arrive damaged, defective or wrong:'**
  String get refundNonReturnableContent;

  /// No description provided for @refundNonReturnableItem1.
  ///
  /// In en, this message translates to:
  /// **'Perishable goods such as fresh food, fruits and vegetables'**
  String get refundNonReturnableItem1;

  /// No description provided for @refundNonReturnableItem2.
  ///
  /// In en, this message translates to:
  /// **'Opened or used personal care, hygiene and intimate items'**
  String get refundNonReturnableItem2;

  /// No description provided for @refundNonReturnableItem3.
  ///
  /// In en, this message translates to:
  /// **'Customised or personalised items'**
  String get refundNonReturnableItem3;

  /// No description provided for @refundNonReturnableItem4.
  ///
  /// In en, this message translates to:
  /// **'Digital products, gift cards and vouchers'**
  String get refundNonReturnableItem4;

  /// No description provided for @refundNonReturnableItem5.
  ///
  /// In en, this message translates to:
  /// **'Products marked "non-returnable" on the product page'**
  String get refundNonReturnableItem5;

  /// No description provided for @refundNonReturnableItem6.
  ///
  /// In en, this message translates to:
  /// **'Items damaged through misuse after delivery'**
  String get refundNonReturnableItem6;

  /// No description provided for @refundProcessTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Return Process'**
  String get refundProcessTitle;

  /// No description provided for @refundProcessContent.
  ///
  /// In en, this message translates to:
  /// **'Follow these steps to return an item:'**
  String get refundProcessContent;

  /// No description provided for @refundStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Raise a Return Request'**
  String get refundStep1Title;

  /// No description provided for @refundStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Go to "Your Orders", select the item and tap Return. Choose a reason, add up to 5 photos and submit.'**
  String get refundStep1Desc;

  /// No description provided for @refundStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Request Review'**
  String get refundStep2Title;

  /// No description provided for @refundStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Our team reviews your request, usually within 24 to 48 hours. You can see the status in the app.'**
  String get refundStep2Desc;

  /// No description provided for @refundStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Pack the Item'**
  String get refundStep3Title;

  /// No description provided for @refundStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Keep the item in its original packaging with all accessories, tags and the invoice.'**
  String get refundStep3Desc;

  /// No description provided for @refundStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Pickup and Resolution'**
  String get refundStep4Title;

  /// No description provided for @refundStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'If approved, we will arrange a pickup or tell you how to send the item back. After it is received and checked, your refund or replacement is processed.'**
  String get refundStep4Desc;

  /// No description provided for @refundTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Refund Timeline'**
  String get refundTimelineTitle;

  /// No description provided for @refundTimelineContent.
  ///
  /// In en, this message translates to:
  /// **'A typical timeline after your return request is approved (actual time may vary by location and product):'**
  String get refundTimelineContent;

  /// No description provided for @refundTimelineItem1Day.
  ///
  /// In en, this message translates to:
  /// **'Day 1-2'**
  String get refundTimelineItem1Day;

  /// No description provided for @refundTimelineItem1Desc.
  ///
  /// In en, this message translates to:
  /// **'Item picked up or received and quality check started'**
  String get refundTimelineItem1Desc;

  /// No description provided for @refundTimelineItem2Day.
  ///
  /// In en, this message translates to:
  /// **'Day 3-4'**
  String get refundTimelineItem2Day;

  /// No description provided for @refundTimelineItem2Desc.
  ///
  /// In en, this message translates to:
  /// **'Quality check completed and refund approved'**
  String get refundTimelineItem2Desc;

  /// No description provided for @refundTimelineItem3Day.
  ///
  /// In en, this message translates to:
  /// **'Day 5-7'**
  String get refundTimelineItem3Day;

  /// No description provided for @refundTimelineItem3Desc.
  ///
  /// In en, this message translates to:
  /// **'Refund credited to your Taksh wallet or replacement dispatched'**
  String get refundTimelineItem3Desc;

  /// No description provided for @refundProcessingNote.
  ///
  /// In en, this message translates to:
  /// **'These timelines are estimates. Delays can happen during sale periods and holidays or when extra verification is needed.'**
  String get refundProcessingNote;

  /// No description provided for @refundMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'5. How You Get Your Money Back'**
  String get refundMethodsTitle;

  /// No description provided for @refundMethodsContent.
  ///
  /// In en, this message translates to:
  /// **'Depending on your case, your request is settled in one of these ways:'**
  String get refundMethodsContent;

  /// No description provided for @refundMethodOriginalTitle.
  ///
  /// In en, this message translates to:
  /// **'Taksh Wallet Credit'**
  String get refundMethodOriginalTitle;

  /// No description provided for @refundMethodOriginalDesc.
  ///
  /// In en, this message translates to:
  /// **'Refunds for approved returns are credited to your Taksh wallet and can be used on future orders'**
  String get refundMethodOriginalDesc;

  /// No description provided for @refundMethodOriginalDays.
  ///
  /// In en, this message translates to:
  /// **'After check'**
  String get refundMethodOriginalDays;

  /// No description provided for @refundMethodCreditTitle.
  ///
  /// In en, this message translates to:
  /// **'Replacement'**
  String get refundMethodCreditTitle;

  /// No description provided for @refundMethodCreditDesc.
  ///
  /// In en, this message translates to:
  /// **'The same item is sent again, subject to stock availability'**
  String get refundMethodCreditDesc;

  /// No description provided for @refundMethodCreditDays.
  ///
  /// In en, this message translates to:
  /// **'Subject to stock'**
  String get refundMethodCreditDays;

  /// No description provided for @refundMethodBankTitle.
  ///
  /// In en, this message translates to:
  /// **'Original Payment Method'**
  String get refundMethodBankTitle;

  /// No description provided for @refundMethodBankDesc.
  ///
  /// In en, this message translates to:
  /// **'Prepaid orders cancelled before dispatch are refunded to the card, UPI or bank account used to pay'**
  String get refundMethodBankDesc;

  /// No description provided for @refundMethodBankDays.
  ///
  /// In en, this message translates to:
  /// **'5-7 days'**
  String get refundMethodBankDays;

  /// No description provided for @refundDamagedTitle.
  ///
  /// In en, this message translates to:
  /// **'6. Damaged or Defective Products'**
  String get refundDamagedTitle;

  /// No description provided for @refundDamagedContent.
  ///
  /// In en, this message translates to:
  /// **'If you receive a damaged or defective product:\n\n• Report it in the app as soon as possible, ideally within 48 hours of delivery and always within the return window\n• Add clear photos of the item and its packaging\n• After verification we will offer a replacement or refund\n• For perishable items, please report at the time of delivery or within 24 hours'**
  String get refundDamagedContent;

  /// No description provided for @refundWrongTitle.
  ///
  /// In en, this message translates to:
  /// **'7. Wrong Product Delivered'**
  String get refundWrongTitle;

  /// No description provided for @refundWrongContent.
  ///
  /// In en, this message translates to:
  /// **'If you receive the wrong product:\n\n• Raise a return in the app with photos\n• We will not charge you for a return that results from our error\n• We will send the correct item, subject to stock\n• If the correct item is not available, you will be refunded'**
  String get refundWrongContent;

  /// No description provided for @refundPartialTitle.
  ///
  /// In en, this message translates to:
  /// **'8. Partial Refunds'**
  String get refundPartialTitle;

  /// No description provided for @refundPartialContent.
  ///
  /// In en, this message translates to:
  /// **'In some cases only a part of the amount may be refunded:'**
  String get refundPartialContent;

  /// No description provided for @refundPartialItem1.
  ///
  /// In en, this message translates to:
  /// **'The item shows signs of use or minor damage not caused by us'**
  String get refundPartialItem1;

  /// No description provided for @refundPartialItem2.
  ///
  /// In en, this message translates to:
  /// **'Accessories, tags or original packaging are missing'**
  String get refundPartialItem2;

  /// No description provided for @refundPartialItem3.
  ///
  /// In en, this message translates to:
  /// **'Only a part of the order is affected or returned'**
  String get refundPartialItem3;

  /// No description provided for @refundPartialItem4.
  ///
  /// In en, this message translates to:
  /// **'Free or promotional items that came with the order are not returned'**
  String get refundPartialItem4;

  /// No description provided for @refundExchangeTitle.
  ///
  /// In en, this message translates to:
  /// **'9. Replacement'**
  String get refundExchangeTitle;

  /// No description provided for @refundExchangeContent.
  ///
  /// In en, this message translates to:
  /// **'When you raise a return, you can ask for a replacement instead of a refund. We send the same item again, subject to stock. If it is not available, the amount is refunded to your Taksh wallet.'**
  String get refundExchangeContent;

  /// No description provided for @refundCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'10. Cancellation Policy'**
  String get refundCancelTitle;

  /// No description provided for @refundCancelContent.
  ///
  /// In en, this message translates to:
  /// **'You can cancel an order before it is dispatched, from the app or by contacting us:\n\n• No cancellation charges before dispatch\n• Prepaid orders are refunded to the original payment method, usually within 5 to 7 working days (your bank\'s timelines may vary)\n• Cash on Delivery orders have nothing to refund\n• After dispatch an order cannot be cancelled, but you may return it as per this policy\n• If an order is refused at delivery or cannot be delivered because of a wrong address, it may be cancelled and delivery charges may be deducted from any refund'**
  String get refundCancelContent;

  /// No description provided for @refundContactTitle.
  ///
  /// In en, this message translates to:
  /// **'11. Contact for Returns'**
  String get refundContactTitle;

  /// No description provided for @refundContactContent.
  ///
  /// In en, this message translates to:
  /// **'Need help with a return or refund? Email us at customersupport@takshallinone.in with your order number and we will get back to you as soon as possible.\n\nThis policy does not affect your rights under the Consumer Protection Act, 2019.'**
  String get refundContactContent;

  /// No description provided for @refundSatisfactionTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re Here to Help'**
  String get refundSatisfactionTitle;

  /// No description provided for @refundSatisfactionContent.
  ///
  /// In en, this message translates to:
  /// **'If something is not right with your order, tell us and we will work with you to fix it.'**
  String get refundSatisfactionContent;

  /// No description provided for @privacyIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get privacyIntroTitle;

  /// No description provided for @privacyIntroContent.
  ///
  /// In en, this message translates to:
  /// **'TAKSH ALL IN ONE ECOMMERCE & LOGISTICS WITH MULTI SERVICES PRIVATE LIMITED ("Taksh", "we", "us") respects your privacy. This policy explains what personal data we collect through our mobile app, why we collect it, how we use, share and protect it, and the choices you have. It follows the Information Technology Act, 2000, the IT (Reasonable Security Practices and Procedures) Rules, 2011 and the Digital Personal Data Protection Act, 2023.'**
  String get privacyIntroContent;

  /// No description provided for @privacyAgreeContent.
  ///
  /// In en, this message translates to:
  /// **'By using our app and giving consent where we ask for it, you agree to the practices described in this policy.'**
  String get privacyAgreeContent;

  /// No description provided for @privacyCollectTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get privacyCollectTitle;

  /// No description provided for @privacyCollectContent.
  ///
  /// In en, this message translates to:
  /// **'We collect only the information we need to run the app and deliver your orders:'**
  String get privacyCollectContent;

  /// No description provided for @privacyPersonalTitle.
  ///
  /// In en, this message translates to:
  /// **'Information You Give Us'**
  String get privacyPersonalTitle;

  /// No description provided for @privacyPersonalContent.
  ///
  /// In en, this message translates to:
  /// **'• Name and mobile number (used to sign you in with an OTP)\n• Email address, if you provide it\n• Delivery addresses and pincode\n• Profile details you choose to add'**
  String get privacyPersonalContent;

  /// No description provided for @privacyUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Device and Usage Data'**
  String get privacyUsageTitle;

  /// No description provided for @privacyUsageContent.
  ///
  /// In en, this message translates to:
  /// **'• Device information (model, operating system, app version)\n• Location, only with your permission, to show what can be delivered to you\n• App activity and crash reports, to fix problems\n• A notification token, to send you order updates'**
  String get privacyUsageContent;

  /// No description provided for @privacyTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Order and Payment Data'**
  String get privacyTransactionTitle;

  /// No description provided for @privacyTransactionContent.
  ///
  /// In en, this message translates to:
  /// **'• Orders, delivery and return details\n• Payment status and transaction reference. Card, UPI and bank details are handled by our payment gateway and are not stored by us\n• Photos you upload with a return request\n• Reviews and ratings you submit'**
  String get privacyTransactionContent;

  /// No description provided for @privacyUseTitle.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Your Information'**
  String get privacyUseTitle;

  /// No description provided for @privacyUseContent.
  ///
  /// In en, this message translates to:
  /// **'We use your information to:'**
  String get privacyUseContent;

  /// No description provided for @privacyUseItem1.
  ///
  /// In en, this message translates to:
  /// **'Create your account and verify you with an OTP'**
  String get privacyUseItem1;

  /// No description provided for @privacyUseItem2.
  ///
  /// In en, this message translates to:
  /// **'Process, deliver and track your orders'**
  String get privacyUseItem2;

  /// No description provided for @privacyUseItem3.
  ///
  /// In en, this message translates to:
  /// **'Handle payments, cancellations, returns and refunds'**
  String get privacyUseItem3;

  /// No description provided for @privacyUseItem4.
  ///
  /// In en, this message translates to:
  /// **'Provide customer support and answer your queries'**
  String get privacyUseItem4;

  /// No description provided for @privacyUseItem5.
  ///
  /// In en, this message translates to:
  /// **'Send order updates and important notifications'**
  String get privacyUseItem5;

  /// No description provided for @privacyUseItem6.
  ///
  /// In en, this message translates to:
  /// **'Show products and delivery options available at your location'**
  String get privacyUseItem6;

  /// No description provided for @privacyUseItem7.
  ///
  /// In en, this message translates to:
  /// **'Send offers and promotions, only if you have agreed'**
  String get privacyUseItem7;

  /// No description provided for @privacyUseItem8.
  ///
  /// In en, this message translates to:
  /// **'Improve the app and keep it secure, and detect and prevent fraud'**
  String get privacyUseItem8;

  /// No description provided for @privacyUseItem9.
  ///
  /// In en, this message translates to:
  /// **'Comply with legal obligations'**
  String get privacyUseItem9;

  /// No description provided for @privacySharingTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Sharing of Information'**
  String get privacySharingTitle;

  /// No description provided for @privacySharingContent.
  ///
  /// In en, this message translates to:
  /// **'We do not sell your personal data. We share it only in these cases:'**
  String get privacySharingContent;

  /// No description provided for @privacyProvidersTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Providers'**
  String get privacyProvidersTitle;

  /// No description provided for @privacyProvidersContent.
  ///
  /// In en, this message translates to:
  /// **'Payment gateways, SMS and notification providers, cloud hosting and analytics providers who process data for us under confidentiality obligations.'**
  String get privacyProvidersContent;

  /// No description provided for @privacyPartnersTitle.
  ///
  /// In en, this message translates to:
  /// **'Sellers and Delivery Partners'**
  String get privacyPartnersTitle;

  /// No description provided for @privacyPartnersContent.
  ///
  /// In en, this message translates to:
  /// **'Sellers, fulfillment centers and delivery partners receive your name, address, phone number and order details only to prepare and deliver your order.'**
  String get privacyPartnersContent;

  /// No description provided for @privacyLegalTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Requirements'**
  String get privacyLegalTitle;

  /// No description provided for @privacyLegalContent.
  ///
  /// In en, this message translates to:
  /// **'When required by law, a court order or a request from a government authority, or to protect the rights and safety of our users and Taksh.'**
  String get privacyLegalContent;

  /// No description provided for @privacyTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Business Transfers'**
  String get privacyTransferTitle;

  /// No description provided for @privacyTransferContent.
  ///
  /// In en, this message translates to:
  /// **'If Taksh is merged with or acquired by another business, your data may be transferred to it, and we will tell you before it becomes subject to a different policy.'**
  String get privacyTransferContent;

  /// No description provided for @privacySecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Data Security'**
  String get privacySecurityTitle;

  /// No description provided for @privacySecurityContent.
  ///
  /// In en, this message translates to:
  /// **'We use reasonable technical and organisational safeguards to protect your data:\n\n• Encryption of data in transit\n• Access controls and authentication\n• Access limited to authorised personnel\n• Payments handled by a secure payment gateway'**
  String get privacySecurityContent;

  /// No description provided for @privacySecurityNote.
  ///
  /// In en, this message translates to:
  /// **'No method of transmission or storage is 100% secure. Please never share your OTP with anyone.'**
  String get privacySecurityNote;

  /// No description provided for @privacyRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'5. Your Rights'**
  String get privacyRightsTitle;

  /// No description provided for @privacyRightsContent.
  ///
  /// In en, this message translates to:
  /// **'Subject to applicable law, you have the right to:'**
  String get privacyRightsContent;

  /// No description provided for @privacyRightsItem1.
  ///
  /// In en, this message translates to:
  /// **'Access: ask what personal data we hold about you'**
  String get privacyRightsItem1;

  /// No description provided for @privacyRightsItem2.
  ///
  /// In en, this message translates to:
  /// **'Correction: update or correct inaccurate data'**
  String get privacyRightsItem2;

  /// No description provided for @privacyRightsItem3.
  ///
  /// In en, this message translates to:
  /// **'Erasure: delete your account and data, from the app or by emailing us'**
  String get privacyRightsItem3;

  /// No description provided for @privacyRightsItem4.
  ///
  /// In en, this message translates to:
  /// **'Withdraw consent at any time'**
  String get privacyRightsItem4;

  /// No description provided for @privacyRightsItem5.
  ///
  /// In en, this message translates to:
  /// **'Opt out of promotional messages'**
  String get privacyRightsItem5;

  /// No description provided for @privacyRightsItem6.
  ///
  /// In en, this message translates to:
  /// **'Nominate a person to exercise your rights in case of your death or incapacity'**
  String get privacyRightsItem6;

  /// No description provided for @privacyRightsItem7.
  ///
  /// In en, this message translates to:
  /// **'Raise a grievance with our Grievance Officer'**
  String get privacyRightsItem7;

  /// No description provided for @privacyCookiesTitle.
  ///
  /// In en, this message translates to:
  /// **'6. App Permissions'**
  String get privacyCookiesTitle;

  /// No description provided for @privacyCookiesContent.
  ///
  /// In en, this message translates to:
  /// **'The app may ask for these permissions:\n\n• Location: to show delivery availability near you\n• Notifications: for order updates and offers\n• Camera and photos: to add images to a return request or profile\n\nYou can change any permission in your device settings. Some features may not work without them.'**
  String get privacyCookiesContent;

  /// No description provided for @privacyLinksTitle.
  ///
  /// In en, this message translates to:
  /// **'7. Third-Party Links'**
  String get privacyLinksTitle;

  /// No description provided for @privacyLinksContent.
  ///
  /// In en, this message translates to:
  /// **'The app may link to third-party websites or services. We are not responsible for their privacy practices, so please read their policies.'**
  String get privacyLinksContent;

  /// No description provided for @privacyChildrenTitle.
  ///
  /// In en, this message translates to:
  /// **'8. Children\'s Privacy'**
  String get privacyChildrenTitle;

  /// No description provided for @privacyChildrenContent.
  ///
  /// In en, this message translates to:
  /// **'Our service is meant for people aged 18 and above. We do not knowingly collect personal data of children without a parent\'s or guardian\'s consent. If you think a child has given us data, please contact us and we will delete it.'**
  String get privacyChildrenContent;

  /// No description provided for @privacyRetentionTitle.
  ///
  /// In en, this message translates to:
  /// **'9. Data Retention'**
  String get privacyRetentionTitle;

  /// No description provided for @privacyRetentionContent.
  ///
  /// In en, this message translates to:
  /// **'We keep your data while your account is active and as long as needed to provide our services. After that we keep only what the law requires, such as invoices and transaction records, or what is needed to resolve disputes. We then delete or anonymise it.'**
  String get privacyRetentionContent;

  /// No description provided for @privacyInternationalTitle.
  ///
  /// In en, this message translates to:
  /// **'10. Data Storage and Transfers'**
  String get privacyInternationalTitle;

  /// No description provided for @privacyInternationalContent.
  ///
  /// In en, this message translates to:
  /// **'Our service providers may store or process data on servers in or outside India. Where data is processed outside India, we take steps to make sure it stays protected as required by law.'**
  String get privacyInternationalContent;

  /// No description provided for @privacyChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'11. Changes to This Policy'**
  String get privacyChangesTitle;

  /// No description provided for @privacyChangesContent.
  ///
  /// In en, this message translates to:
  /// **'We may update this policy from time to time. The new version will be shown in the app with a new "Last Updated" date.'**
  String get privacyChangesContent;

  /// No description provided for @privacyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'12. Contact and Grievance Officer'**
  String get privacyContactTitle;

  /// No description provided for @privacyContactContent.
  ///
  /// In en, this message translates to:
  /// **'For questions, requests or complaints about your data, contact our Grievance Officer:\n\nGrievance Officer\nTAKSH ALL IN ONE ECOMMERCE & LOGISTICS WITH MULTI SERVICES PRIVATE LIMITED\nEmail: customersupport@takshallinone.in\nAddress: Bhopal, Madhya Pradesh, India\n\nWe acknowledge requests within 48 hours and aim to resolve them within one month.'**
  String get privacyContactContent;

  /// No description provided for @privacyMattersTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Privacy Matters'**
  String get privacyMattersTitle;

  /// No description provided for @privacyMattersContent.
  ///
  /// In en, this message translates to:
  /// **'We handle your data responsibly and only for the purposes described here.'**
  String get privacyMattersContent;

  /// No description provided for @ourStoryContent.
  ///
  /// In en, this message translates to:
  /// **'Taksh is a shopping app operated by TAKSH ALL IN ONE ECOMMERCE & LOGISTICS WITH MULTI SERVICES PRIVATE LIMITED, built to bring everyday products to your doorstep quickly and reliably. We work with local sellers and fulfillment centers, so you can choose Express delivery in 30 minutes in select areas, Next-Day delivery or Standard delivery, and pay online or with Cash on Delivery where available.'**
  String get ourStoryContent;

  /// No description provided for @ourMissionContent.
  ///
  /// In en, this message translates to:
  /// **'To make everyday shopping simple, fast and trustworthy, with clear prices, genuine products and honest service, while supporting local businesses.'**
  String get ourMissionContent;

  /// No description provided for @ourVisionContent.
  ///
  /// In en, this message translates to:
  /// **'To be a shopping app that people across India trust for their daily needs, where they can find what they want and get it when they need it.'**
  String get ourVisionContent;

  /// No description provided for @trustTransparencyDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear prices, clear policies and honest communication at every step.'**
  String get trustTransparencyDesc;

  /// No description provided for @qualityFirstDesc.
  ///
  /// In en, this message translates to:
  /// **'We work with sellers and partners to offer genuine products in good condition.'**
  String get qualityFirstDesc;

  /// No description provided for @customerCentricityDesc.
  ///
  /// In en, this message translates to:
  /// **'Our customers are at the heart of everything we do. Your feedback shapes how we improve.'**
  String get customerCentricityDesc;

  /// No description provided for @sustainabilityDesc.
  ///
  /// In en, this message translates to:
  /// **'We work with local sellers and fulfillment centers to deliver faster and support local businesses.'**
  String get sustainabilityDesc;

  /// No description provided for @innovationDesc.
  ///
  /// In en, this message translates to:
  /// **'We keep improving our app and services to make shopping easier.'**
  String get innovationDesc;

  /// No description provided for @whatWeOfferContent.
  ///
  /// In en, this message translates to:
  /// **'• Wide Range of Products: A growing selection across many categories from trusted sellers\n\n• Flexible Delivery: Express 30-minute (select areas), Next-Day and Standard delivery\n\n• Secure Payments: Pay online through a secure payment gateway, or choose Cash on Delivery where available\n\n• Easy Returns: Raise a return in the app for eligible items within the return window\n\n• Support: Write to us anytime and we will get back to you'**
  String get whatWeOfferContent;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @addressValue.
  ///
  /// In en, this message translates to:
  /// **'Bhopal, Madhya Pradesh, India'**
  String get addressValue;

  /// No description provided for @updateProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfileTitle;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @mobileLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobileLabel;

  /// No description provided for @saveDetails.
  ///
  /// In en, this message translates to:
  /// **'Save Details'**
  String get saveDetails;

  /// No description provided for @enterValidName.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid name'**
  String get enterValidName;

  /// No description provided for @joinDeliveryManTitle.
  ///
  /// In en, this message translates to:
  /// **'Join as Delivery Man'**
  String get joinDeliveryManTitle;

  /// No description provided for @fillDetailsDelivery.
  ///
  /// In en, this message translates to:
  /// **'Fill in your details to join as a delivery partner'**
  String get fillDetailsDelivery;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @mobileRequired.
  ///
  /// In en, this message translates to:
  /// **'Mobile number is required'**
  String get mobileRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @pincodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get pincodeLabel;

  /// No description provided for @pincodeInvalidLength.
  ///
  /// In en, this message translates to:
  /// **'Pincode must be 6 digits'**
  String get pincodeInvalidLength;

  /// No description provided for @pincodeInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Pincode must contain only numbers'**
  String get pincodeInvalidFormat;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @requiredFieldsNote.
  ///
  /// In en, this message translates to:
  /// **'* Required fields'**
  String get requiredFieldsNote;

  /// No description provided for @fillDetailsRequest.
  ///
  /// In en, this message translates to:
  /// **'Fill in your details to request {type}'**
  String fillDetailsRequest(String type);

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordComplexity.
  ///
  /// In en, this message translates to:
  /// **'Password must contain uppercase, lowercase, and number'**
  String get passwordComplexity;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @nameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinLength;

  /// No description provided for @appDevelopment.
  ///
  /// In en, this message translates to:
  /// **'App Development'**
  String get appDevelopment;

  /// No description provided for @webDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Web Development'**
  String get webDevelopment;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @deliveryCharges.
  ///
  /// In en, this message translates to:
  /// **'Delivery Charges'**
  String get deliveryCharges;

  /// No description provided for @platformFee.
  ///
  /// In en, this message translates to:
  /// **'Platform Fee'**
  String get platformFee;

  /// No description provided for @takshCharge.
  ///
  /// In en, this message translates to:
  /// **'Taksh Charge'**
  String get takshCharge;

  /// No description provided for @quickDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Quick Delivery Fee'**
  String get quickDeliveryFee;

  /// No description provided for @cgst.
  ///
  /// In en, this message translates to:
  /// **'CGST'**
  String get cgst;

  /// No description provided for @sgst.
  ///
  /// In en, this message translates to:
  /// **'SGST'**
  String get sgst;

  /// No description provided for @discountLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discountLabel;

  /// No description provided for @otherCharges.
  ///
  /// In en, this message translates to:
  /// **'Other Charges'**
  String get otherCharges;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get free;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @returnOrder.
  ///
  /// In en, this message translates to:
  /// **'Return Order'**
  String get returnOrder;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help'**
  String get needHelp;

  /// No description provided for @orderIssues.
  ///
  /// In en, this message translates to:
  /// **'Do you have any issues with this order?'**
  String get orderIssues;

  /// No description provided for @chatWithUs.
  ///
  /// In en, this message translates to:
  /// **'Chat with us'**
  String get chatWithUs;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send us an email'**
  String get sendEmail;

  /// No description provided for @returnFunctionalityComing.
  ///
  /// In en, this message translates to:
  /// **'Return functionality will be available soon. You can contact support for assistance.'**
  String get returnFunctionalityComing;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get noCategoriesAvailable;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @similarProducts.
  ///
  /// In en, this message translates to:
  /// **'Similar Products'**
  String get similarProducts;

  /// No description provided for @selectVariant.
  ///
  /// In en, this message translates to:
  /// **'Select Variant'**
  String get selectVariant;

  /// No description provided for @ratings.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratings;

  /// No description provided for @failedToLoadProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to load product'**
  String get failedToLoadProduct;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @typeMinCharsToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type at least {count} characters to start searching'**
  String typeMinCharsToSearch(int count);

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @deliveryOptions.
  ///
  /// In en, this message translates to:
  /// **'Delivery Options'**
  String get deliveryOptions;

  /// No description provided for @priceDetails.
  ///
  /// In en, this message translates to:
  /// **'Price Details'**
  String get priceDetails;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @proceedToPay.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Pay'**
  String get proceedToPay;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addAddress;

  /// No description provided for @loadingOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading order details...'**
  String get loadingOrderDetails;

  /// No description provided for @addAddressToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please add a delivery address to continue'**
  String get addAddressToContinue;

  /// No description provided for @paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccess;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailed;

  /// No description provided for @orderPlacedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your order has been placed successfully!'**
  String get orderPlacedSuccessfully;

  /// No description provided for @somethingWentWrongPayment.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong with your payment'**
  String get somethingWentWrongPayment;

  /// No description provided for @viewOrder.
  ///
  /// In en, this message translates to:
  /// **'View Order'**
  String get viewOrder;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// No description provided for @selectAddress.
  ///
  /// In en, this message translates to:
  /// **'Select Address'**
  String get selectAddress;

  /// No description provided for @myAddresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get myAddresses;

  /// No description provided for @noAddressesSaved.
  ///
  /// In en, this message translates to:
  /// **'No addresses saved'**
  String get noAddressesSaved;

  /// No description provided for @addFirstAddress.
  ///
  /// In en, this message translates to:
  /// **'Add your first address to get started'**
  String get addFirstAddress;

  /// No description provided for @deleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get deleteAddress;

  /// No description provided for @deleteAddressConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this address? This action cannot be undone.'**
  String get deleteAddressConfirm;

  /// No description provided for @setDefault.
  ///
  /// In en, this message translates to:
  /// **'Set Default'**
  String get setDefault;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addNewAddress;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editAddress;

  /// No description provided for @selectLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Select Location on Map'**
  String get selectLocationOnMap;

  /// No description provided for @locationSelected.
  ///
  /// In en, this message translates to:
  /// **'Location Selected'**
  String get locationSelected;

  /// No description provided for @tapToPickLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick location on map'**
  String get tapToPickLocation;

  /// No description provided for @addressType.
  ///
  /// In en, this message translates to:
  /// **'Address Type'**
  String get addressType;

  /// No description provided for @recipientName.
  ///
  /// In en, this message translates to:
  /// **'Recipient Name'**
  String get recipientName;

  /// No description provided for @enterRecipientName.
  ///
  /// In en, this message translates to:
  /// **'Enter recipient\'s full name'**
  String get enterRecipientName;

  /// No description provided for @labelOther.
  ///
  /// In en, this message translates to:
  /// **'Label (e.g., Friend\'s House)'**
  String get labelOther;

  /// No description provided for @enterLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter a label for this address'**
  String get enterLabel;

  /// No description provided for @houseFlatNo.
  ///
  /// In en, this message translates to:
  /// **'House/Flat/Block No.'**
  String get houseFlatNo;

  /// No description provided for @enterHouseNo.
  ///
  /// In en, this message translates to:
  /// **'Enter house or flat number'**
  String get enterHouseNo;

  /// No description provided for @landmarkOptional.
  ///
  /// In en, this message translates to:
  /// **'Landmark (Optional)'**
  String get landmarkOptional;

  /// No description provided for @landmarkHint.
  ///
  /// In en, this message translates to:
  /// **'E.g., Near City Mall'**
  String get landmarkHint;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @enterCity.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get enterCity;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @enterState.
  ///
  /// In en, this message translates to:
  /// **'Enter state'**
  String get enterState;

  /// No description provided for @pincode.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get pincode;

  /// No description provided for @enterPincode.
  ///
  /// In en, this message translates to:
  /// **'Enter Pincode'**
  String get enterPincode;

  /// No description provided for @pincodeLengthError.
  ///
  /// In en, this message translates to:
  /// **'Pincode must be 6 digits'**
  String get pincodeLengthError;

  /// No description provided for @setAsDefaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Set as default address'**
  String get setAsDefaultAddress;

  /// No description provided for @setAsDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This address will be used by default for deliveries'**
  String get setAsDefaultSubtitle;

  /// No description provided for @updateAddress.
  ///
  /// In en, this message translates to:
  /// **'Update Address'**
  String get updateAddress;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get saveAddress;

  /// No description provided for @pleaseEnterRecipientName.
  ///
  /// In en, this message translates to:
  /// **'Please enter recipient name'**
  String get pleaseEnterRecipientName;

  /// No description provided for @pleaseEnterHouseNo.
  ///
  /// In en, this message translates to:
  /// **'Please enter house/flat number'**
  String get pleaseEnterHouseNo;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @pleaseSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Please select a location on the map'**
  String get pleaseSelectLocation;

  /// No description provided for @ourStory.
  ///
  /// In en, this message translates to:
  /// **'Our Story'**
  String get ourStory;

  /// No description provided for @ourMission.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get ourMission;

  /// No description provided for @ourVision.
  ///
  /// In en, this message translates to:
  /// **'Our Vision'**
  String get ourVision;

  /// No description provided for @ourCoreValues.
  ///
  /// In en, this message translates to:
  /// **'Our Core Values'**
  String get ourCoreValues;

  /// No description provided for @trustTransparency.
  ///
  /// In en, this message translates to:
  /// **'Trust & Transparency'**
  String get trustTransparency;

  /// No description provided for @qualityFirst.
  ///
  /// In en, this message translates to:
  /// **'Quality First'**
  String get qualityFirst;

  /// No description provided for @customerCentricity.
  ///
  /// In en, this message translates to:
  /// **'Customer Centricity'**
  String get customerCentricity;

  /// No description provided for @sustainability.
  ///
  /// In en, this message translates to:
  /// **'Local First'**
  String get sustainability;

  /// No description provided for @innovation.
  ///
  /// In en, this message translates to:
  /// **'Innovation'**
  String get innovation;

  /// No description provided for @whatWeOffer.
  ///
  /// In en, this message translates to:
  /// **'What We Offer'**
  String get whatWeOffer;

  /// No description provided for @ourImpact.
  ///
  /// In en, this message translates to:
  /// **'Why Shop with Taksh'**
  String get ourImpact;

  /// No description provided for @aboutHighlightLocal.
  ///
  /// In en, this message translates to:
  /// **'Local Sellers'**
  String get aboutHighlightLocal;

  /// No description provided for @aboutHighlightReturns.
  ///
  /// In en, this message translates to:
  /// **'Easy Returns'**
  String get aboutHighlightReturns;

  /// No description provided for @aboutHighlightCod.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get aboutHighlightCod;

  /// No description provided for @aboutHighlightPayments.
  ///
  /// In en, this message translates to:
  /// **'Secure Payments'**
  String get aboutHighlightPayments;

  /// No description provided for @aboutHighlightDelivery.
  ///
  /// In en, this message translates to:
  /// **'Flexible Delivery'**
  String get aboutHighlightDelivery;

  /// No description provided for @aboutHighlightExpress.
  ///
  /// In en, this message translates to:
  /// **'30-Min Express'**
  String get aboutHighlightExpress;

  /// No description provided for @happyCustomers.
  ///
  /// In en, this message translates to:
  /// **'Happy Customers'**
  String get happyCustomers;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @brands.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get brands;

  /// No description provided for @cities.
  ///
  /// In en, this message translates to:
  /// **'Cities'**
  String get cities;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @getInTouch.
  ///
  /// In en, this message translates to:
  /// **'Get in Touch'**
  String get getInTouch;

  /// No description provided for @redirectingToCart.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to cart in {seconds} seconds'**
  String redirectingToCart(String seconds);

  /// No description provided for @errorCode.
  ///
  /// In en, this message translates to:
  /// **'Error Code: {code}'**
  String errorCode(String code);

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @orderNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get orderNumberLabel;

  /// No description provided for @searchForProducts.
  ///
  /// In en, this message translates to:
  /// **'Search for products'**
  String get searchForProducts;

  /// No description provided for @searchForProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Search for products'**
  String get searchForProductsHint;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search Products'**
  String get searchProducts;

  /// No description provided for @quick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get quick;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @failedToLoadAddresses.
  ///
  /// In en, this message translates to:
  /// **'Failed to load addresses'**
  String get failedToLoadAddresses;

  /// No description provided for @couldNotDeleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the address. Please try again.'**
  String get couldNotDeleteAddress;

  /// No description provided for @couldNotUpdateAddress.
  ///
  /// In en, this message translates to:
  /// **'Could not update the address. Please try again.'**
  String get couldNotUpdateAddress;

  /// No description provided for @couldNotAddAddress.
  ///
  /// In en, this message translates to:
  /// **'Could not add the address. Please try again.'**
  String get couldNotAddAddress;

  /// No description provided for @couldNotSetDefaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Could not set the default address. Please try again.'**
  String get couldNotSetDefaultAddress;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocation;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @locationEnabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Location enabled! Showing nearby stores...'**
  String get locationEnabledMessage;

  /// No description provided for @nearbyStores.
  ///
  /// In en, this message translates to:
  /// **'Nearby Stores'**
  String get nearbyStores;

  /// No description provided for @findNearbyStores.
  ///
  /// In en, this message translates to:
  /// **'Find Nearby Stores'**
  String get findNearbyStores;

  /// No description provided for @loadingNearbyStores.
  ///
  /// In en, this message translates to:
  /// **'Loading nearby stores...'**
  String get loadingNearbyStores;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// No description provided for @autoDetectLocation.
  ///
  /// In en, this message translates to:
  /// **'Auto-detect your delivery address'**
  String get autoDetectLocation;

  /// No description provided for @yourAppContent.
  ///
  /// In en, this message translates to:
  /// **'Your App Content'**
  String get yourAppContent;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @locationServices.
  ///
  /// In en, this message translates to:
  /// **'Location Services'**
  String get locationServices;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @disableLocation.
  ///
  /// In en, this message translates to:
  /// **'Disable Location'**
  String get disableLocation;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @locationAccess.
  ///
  /// In en, this message translates to:
  /// **'Location Access'**
  String get locationAccess;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationPermissionRequired;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @permissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Permanently Denied'**
  String get permissionPermanentlyDenied;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location Services Disabled'**
  String get locationServicesDisabled;

  /// No description provided for @allowLocationAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow Location Access'**
  String get allowLocationAccess;

  /// No description provided for @permissionUIComponents.
  ///
  /// In en, this message translates to:
  /// **'Location Permission UI Components'**
  String get permissionUIComponents;

  /// No description provided for @showBottomSheet.
  ///
  /// In en, this message translates to:
  /// **'Show Bottom Sheet'**
  String get showBottomSheet;

  /// No description provided for @showRationaleDialog.
  ///
  /// In en, this message translates to:
  /// **'Show Rationale Dialog'**
  String get showRationaleDialog;

  /// No description provided for @showSettingsDialog.
  ///
  /// In en, this message translates to:
  /// **'Show Settings Dialog'**
  String get showSettingsDialog;

  /// No description provided for @requestPermissionFullFlow.
  ///
  /// In en, this message translates to:
  /// **'Request Permission (Full Flow)'**
  String get requestPermissionFullFlow;

  /// No description provided for @getCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Get Current Location'**
  String get getCurrentLocation;

  /// No description provided for @locationPermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Location permission granted'**
  String get locationPermissionGranted;

  /// No description provided for @grantLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Location Permission'**
  String get grantLocationPermission;

  /// No description provided for @dataAlreadyLoaded.
  ///
  /// In en, this message translates to:
  /// **'Data already loaded - instant display!'**
  String get dataAlreadyLoaded;

  /// No description provided for @searchSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Search saved addresses'**
  String get searchSavedAddresses;

  /// No description provided for @searchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get searchCategories;

  /// No description provided for @searchRestaurantsDishes.
  ///
  /// In en, this message translates to:
  /// **'Search for restaurants, dishes...'**
  String get searchRestaurantsDishes;

  /// No description provided for @searchAreaStreetName.
  ///
  /// In en, this message translates to:
  /// **'Search for area, street name...'**
  String get searchAreaStreetName;

  /// No description provided for @joinAsVendorTitle.
  ///
  /// In en, this message translates to:
  /// **'Join as Vendor'**
  String get joinAsVendorTitle;

  /// No description provided for @vendorFillDetails.
  ///
  /// In en, this message translates to:
  /// **'Fill in your vendor shop details. Required fields are marked with *'**
  String get vendorFillDetails;

  /// No description provided for @vendorShopDetails.
  ///
  /// In en, this message translates to:
  /// **'Shop Details'**
  String get vendorShopDetails;

  /// No description provided for @vendorShopDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your shop information'**
  String get vendorShopDetailsSubtitle;

  /// No description provided for @vendorOwnerDetails.
  ///
  /// In en, this message translates to:
  /// **'Owner Details'**
  String get vendorOwnerDetails;

  /// No description provided for @vendorOwnerDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter owner information'**
  String get vendorOwnerDetailsSubtitle;

  /// No description provided for @vendorDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get vendorDocuments;

  /// No description provided for @vendorDocumentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload required documents for verification'**
  String get vendorDocumentsSubtitle;

  /// No description provided for @vendorShopName.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get vendorShopName;

  /// No description provided for @vendorShopNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter shop name'**
  String get vendorShopNameHint;

  /// No description provided for @vendorShopAddress.
  ///
  /// In en, this message translates to:
  /// **'Shop Address'**
  String get vendorShopAddress;

  /// No description provided for @vendorShopAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter complete shop address'**
  String get vendorShopAddressHint;

  /// No description provided for @vendorShopPincode.
  ///
  /// In en, this message translates to:
  /// **'Shop Pincode'**
  String get vendorShopPincode;

  /// No description provided for @vendorShopPincodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit pincode'**
  String get vendorShopPincodeHint;

  /// No description provided for @vendorShopLocation.
  ///
  /// In en, this message translates to:
  /// **'Shop Location *'**
  String get vendorShopLocation;

  /// No description provided for @vendorShopImages.
  ///
  /// In en, this message translates to:
  /// **'Shop Images *'**
  String get vendorShopImages;

  /// No description provided for @vendorShopImagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload up to 5 shop images'**
  String get vendorShopImagesSubtitle;

  /// No description provided for @vendorOwnerName.
  ///
  /// In en, this message translates to:
  /// **'Owner Name'**
  String get vendorOwnerName;

  /// No description provided for @vendorOwnerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter owner full name'**
  String get vendorOwnerNameHint;

  /// No description provided for @vendorOwnerAddress.
  ///
  /// In en, this message translates to:
  /// **'Owner Address'**
  String get vendorOwnerAddress;

  /// No description provided for @vendorOwnerAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter complete owner address'**
  String get vendorOwnerAddressHint;

  /// No description provided for @vendorOwnerPincode.
  ///
  /// In en, this message translates to:
  /// **'Owner Pincode'**
  String get vendorOwnerPincode;

  /// No description provided for @vendorOwnerPincodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit pincode'**
  String get vendorOwnerPincodeHint;

  /// No description provided for @vendorOwnerLocation.
  ///
  /// In en, this message translates to:
  /// **'Owner Location *'**
  String get vendorOwnerLocation;

  /// No description provided for @vendorMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get vendorMobileNumber;

  /// No description provided for @vendorMobileNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 10-digit mobile number'**
  String get vendorMobileNumberHint;

  /// No description provided for @vendorEmailId.
  ///
  /// In en, this message translates to:
  /// **'Email ID'**
  String get vendorEmailId;

  /// No description provided for @vendorEmailIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get vendorEmailIdHint;

  /// No description provided for @vendorOwnerImages.
  ///
  /// In en, this message translates to:
  /// **'Owner Images *'**
  String get vendorOwnerImages;

  /// No description provided for @vendorOwnerImagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload up to 2 owner images'**
  String get vendorOwnerImagesSubtitle;

  /// No description provided for @vendorPickLocation.
  ///
  /// In en, this message translates to:
  /// **'Pick Location from Map'**
  String get vendorPickLocation;

  /// No description provided for @vendorAadharCard.
  ///
  /// In en, this message translates to:
  /// **'Aadhar Card'**
  String get vendorAadharCard;

  /// No description provided for @vendorPanCard.
  ///
  /// In en, this message translates to:
  /// **'PAN Card'**
  String get vendorPanCard;

  /// No description provided for @vendorBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank Account'**
  String get vendorBankAccount;

  /// No description provided for @vendorGstNumber.
  ///
  /// In en, this message translates to:
  /// **'GST Number'**
  String get vendorGstNumber;

  /// No description provided for @vendorNonGstCertificate.
  ///
  /// In en, this message translates to:
  /// **'Non GST Certificate'**
  String get vendorNonGstCertificate;

  /// No description provided for @vendorNonGstCertificateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Non GST certificate'**
  String get vendorNonGstCertificateSubtitle;

  /// No description provided for @vendorMsmeCertificate.
  ///
  /// In en, this message translates to:
  /// **'MSME Certificate'**
  String get vendorMsmeCertificate;

  /// No description provided for @vendorMsmeCertificateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload MSME certificate (if applicable)'**
  String get vendorMsmeCertificateSubtitle;

  /// No description provided for @vendorFssaiCertificate.
  ///
  /// In en, this message translates to:
  /// **'FSSAI Certificate *'**
  String get vendorFssaiCertificate;

  /// No description provided for @vendorFssaiCertificateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload FSSAI license for food businesses'**
  String get vendorFssaiCertificateSubtitle;

  /// No description provided for @vendorShopAgreement.
  ///
  /// In en, this message translates to:
  /// **'Shop Agreement'**
  String get vendorShopAgreement;

  /// No description provided for @vendorShopAgreementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload shop agreement (optional)'**
  String get vendorShopAgreementSubtitle;

  /// No description provided for @vendorSubmitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get vendorSubmitApplication;

  /// No description provided for @vendorAadharDetails.
  ///
  /// In en, this message translates to:
  /// **'Aadhar Details'**
  String get vendorAadharDetails;

  /// No description provided for @vendorAadharNumber.
  ///
  /// In en, this message translates to:
  /// **'Aadhar Number *'**
  String get vendorAadharNumber;

  /// No description provided for @vendorAadharNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 12-digit Aadhar number'**
  String get vendorAadharNumberHint;

  /// No description provided for @vendorAadharDocument.
  ///
  /// In en, this message translates to:
  /// **'Aadhar Number Document *'**
  String get vendorAadharDocument;

  /// No description provided for @vendorPanDetails.
  ///
  /// In en, this message translates to:
  /// **'PAN Details'**
  String get vendorPanDetails;

  /// No description provided for @vendorPanCardNumber.
  ///
  /// In en, this message translates to:
  /// **'PAN Card Number *'**
  String get vendorPanCardNumber;

  /// No description provided for @vendorPanCardNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter PAN card number (e.g., ABCDE1234F)'**
  String get vendorPanCardNumberHint;

  /// No description provided for @vendorPanDocument.
  ///
  /// In en, this message translates to:
  /// **'PAN Card Number Document *'**
  String get vendorPanDocument;

  /// No description provided for @vendorBankDetails.
  ///
  /// In en, this message translates to:
  /// **'Bank Details'**
  String get vendorBankDetails;

  /// No description provided for @vendorAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number *'**
  String get vendorAccountNumber;

  /// No description provided for @vendorAccountNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter bank account number'**
  String get vendorAccountNumberHint;

  /// No description provided for @vendorIfscCode.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code *'**
  String get vendorIfscCode;

  /// No description provided for @vendorIfscCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter IFSC code'**
  String get vendorIfscCodeHint;

  /// No description provided for @vendorAccountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name *'**
  String get vendorAccountHolderName;

  /// No description provided for @vendorAccountHolderNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter account holder name'**
  String get vendorAccountHolderNameHint;

  /// No description provided for @vendorBankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name *'**
  String get vendorBankName;

  /// No description provided for @vendorBankNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter bank name (optional)'**
  String get vendorBankNameHint;

  /// No description provided for @vendorBranchName.
  ///
  /// In en, this message translates to:
  /// **'Branch Name'**
  String get vendorBranchName;

  /// No description provided for @vendorBranchNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter branch name (optional)'**
  String get vendorBranchNameHint;

  /// No description provided for @vendorUploadBankProof.
  ///
  /// In en, this message translates to:
  /// **'Upload Bank Proof'**
  String get vendorUploadBankProof;

  /// No description provided for @vendorUploadBankProofSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload either Bank Passbook or Cancelled Cheque'**
  String get vendorUploadBankProofSubtitle;

  /// No description provided for @vendorBankDocument.
  ///
  /// In en, this message translates to:
  /// **'Bank Document *'**
  String get vendorBankDocument;

  /// No description provided for @vendorGstDetails.
  ///
  /// In en, this message translates to:
  /// **'GST Details'**
  String get vendorGstDetails;

  /// No description provided for @vendorGstNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'GST Number *'**
  String get vendorGstNumberLabel;

  /// No description provided for @vendorGstNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 15-digit GST number'**
  String get vendorGstNumberHint;

  /// No description provided for @vendorGstDocument.
  ///
  /// In en, this message translates to:
  /// **'GST Number Document *'**
  String get vendorGstDocument;

  /// No description provided for @vendorSaveAndVerify.
  ///
  /// In en, this message translates to:
  /// **'Save & Verify'**
  String get vendorSaveAndVerify;

  /// No description provided for @vendorUploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload Document'**
  String get vendorUploadDocument;

  /// No description provided for @vendorUploadDocumentHint.
  ///
  /// In en, this message translates to:
  /// **'PDF, JPG, PNG (Max 5MB)'**
  String get vendorUploadDocumentHint;

  /// No description provided for @vendorAddImage.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get vendorAddImage;

  /// No description provided for @vendorJoinSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vendor application submitted successfully!'**
  String get vendorJoinSuccess;

  /// No description provided for @vendorShopNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Shop name is required'**
  String get vendorShopNameRequired;

  /// No description provided for @vendorShopLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Shop location is required'**
  String get vendorShopLocationRequired;

  /// No description provided for @vendorShopImagesRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one shop image is required'**
  String get vendorShopImagesRequired;

  /// No description provided for @vendorOwnerLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Owner location is required'**
  String get vendorOwnerLocationRequired;

  /// No description provided for @vendorOwnerImagesRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one owner image is required'**
  String get vendorOwnerImagesRequired;

  /// No description provided for @vendorOwnerImageRequired.
  ///
  /// In en, this message translates to:
  /// **'Owner image is required'**
  String get vendorOwnerImageRequired;

  /// No description provided for @vendorVendorDetails.
  ///
  /// In en, this message translates to:
  /// **'Vendor Details'**
  String get vendorVendorDetails;

  /// No description provided for @vendorVendorDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your vendor registration details'**
  String get vendorVendorDetailsSubtitle;

  /// No description provided for @vendorVendorName.
  ///
  /// In en, this message translates to:
  /// **'Vendor Name'**
  String get vendorVendorName;

  /// No description provided for @vendorVendorNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter vendor/store name'**
  String get vendorVendorNameHint;

  /// No description provided for @vendorVendorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Vendor name is required'**
  String get vendorVendorNameRequired;

  /// No description provided for @vendorAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get vendorAddress;

  /// No description provided for @vendorAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter vendor address'**
  String get vendorAddressHint;

  /// No description provided for @vendorAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get vendorAddressRequired;

  /// No description provided for @vendorPincode.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get vendorPincode;

  /// No description provided for @vendorPincodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter pincode'**
  String get vendorPincodeHint;

  /// No description provided for @vendorPincodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Pincode is required'**
  String get vendorPincodeRequired;

  /// No description provided for @vendorStateId.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get vendorStateId;

  /// No description provided for @vendorStateIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter state ID'**
  String get vendorStateIdHint;

  /// No description provided for @vendorStateIdRequired.
  ///
  /// In en, this message translates to:
  /// **'State is required'**
  String get vendorStateIdRequired;

  /// No description provided for @vendorCityId.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get vendorCityId;

  /// No description provided for @vendorCityIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter city ID'**
  String get vendorCityIdHint;

  /// No description provided for @vendorCityIdRequired.
  ///
  /// In en, this message translates to:
  /// **'City is required'**
  String get vendorCityIdRequired;

  /// No description provided for @vendorOwnerImage.
  ///
  /// In en, this message translates to:
  /// **'Owner Image *'**
  String get vendorOwnerImage;

  /// No description provided for @vendorOwnerImageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload owner photo'**
  String get vendorOwnerImageSubtitle;

  /// No description provided for @vendorShopAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Shop address is required'**
  String get vendorShopAddressRequired;

  /// No description provided for @vendorShopPincodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Shop pincode is required'**
  String get vendorShopPincodeRequired;

  /// No description provided for @vendorOwnerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Owner name is required'**
  String get vendorOwnerNameRequired;

  /// No description provided for @vendorOwnerAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Owner address is required'**
  String get vendorOwnerAddressRequired;

  /// No description provided for @vendorOwnerPincodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Owner pincode is required'**
  String get vendorOwnerPincodeRequired;

  /// No description provided for @vendorMobileNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Mobile number is required'**
  String get vendorMobileNumberRequired;

  /// No description provided for @vendorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get vendorEmailRequired;

  /// No description provided for @vendorAadhaarNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar number is required'**
  String get vendorAadhaarNumberRequired;

  /// No description provided for @vendorAadhaarFileRequired.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar document is required'**
  String get vendorAadhaarFileRequired;

  /// No description provided for @vendorPanFileRequired.
  ///
  /// In en, this message translates to:
  /// **'PAN document is required'**
  String get vendorPanFileRequired;

  /// No description provided for @vendorBankFileRequired.
  ///
  /// In en, this message translates to:
  /// **'Bank document is required'**
  String get vendorBankFileRequired;

  /// No description provided for @vendorGstFileRequired.
  ///
  /// In en, this message translates to:
  /// **'GST document is required'**
  String get vendorGstFileRequired;

  /// No description provided for @vendorGstOrNonGstRequired.
  ///
  /// In en, this message translates to:
  /// **'Upload either GST document or Non-GST certificate'**
  String get vendorGstOrNonGstRequired;

  /// No description provided for @vendorFssaiFileRequired.
  ///
  /// In en, this message translates to:
  /// **'FSSAI certificate is required'**
  String get vendorFssaiFileRequired;

  /// No description provided for @chooseHowToReachUs.
  ///
  /// In en, this message translates to:
  /// **'Choose how you\'d like to reach us'**
  String get chooseHowToReachUs;

  /// No description provided for @requestCallback.
  ///
  /// In en, this message translates to:
  /// **'Request Callback'**
  String get requestCallback;

  /// No description provided for @requestCallbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Get a call from our support team'**
  String get requestCallbackDescription;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @emailSupportDescription.
  ///
  /// In en, this message translates to:
  /// **'Send us an email at customersupport@takshallinone.in'**
  String get emailSupportDescription;

  /// No description provided for @emailAppError.
  ///
  /// In en, this message translates to:
  /// **'Could not open email app. Please email us at customersupport@takshallinone.in'**
  String get emailAppError;

  /// No description provided for @myWishlist.
  ///
  /// In en, this message translates to:
  /// **'My Wishlist'**
  String get myWishlist;

  /// No description provided for @addedToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Added to wishlist'**
  String get addedToWishlist;

  /// No description provided for @removedFromWishlist.
  ///
  /// In en, this message translates to:
  /// **'Removed from wishlist'**
  String get removedFromWishlist;

  /// No description provided for @wishlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get wishlistEmpty;

  /// No description provided for @wishlistEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse products and add your favorites here'**
  String get wishlistEmptySubtitle;

  /// No description provided for @removeFromWishlistConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove from wishlist?'**
  String get removeFromWishlistConfirm;

  /// No description provided for @failedToLoadWishlist.
  ///
  /// In en, this message translates to:
  /// **'Failed to load wishlist'**
  String get failedToLoadWishlist;

  /// No description provided for @couldNotAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Could not add item to cart. Please try again.'**
  String get couldNotAddToCart;

  /// No description provided for @couldNotLoadProduct.
  ///
  /// In en, this message translates to:
  /// **'Could not load product details. Please try again.'**
  String get couldNotLoadProduct;

  /// No description provided for @noVariantsAvailable.
  ///
  /// In en, this message translates to:
  /// **'This product is currently unavailable.'**
  String get noVariantsAvailable;

  /// No description provided for @cartUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get cartUnexpectedError;

  /// No description provided for @checkDeliveryAvailability.
  ///
  /// In en, this message translates to:
  /// **'Check Delivery Availability'**
  String get checkDeliveryAvailability;

  /// No description provided for @invalidPincode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-digit pincode'**
  String get invalidPincode;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @fulfilledBy.
  ///
  /// In en, this message translates to:
  /// **'Fulfilled by {shopName}'**
  String fulfilledBy(String shopName);

  /// No description provided for @couldNotCheckDelivery.
  ///
  /// In en, this message translates to:
  /// **'Could not check delivery availability. Please try again.'**
  String get couldNotCheckDelivery;

  /// No description provided for @homeServices.
  ///
  /// In en, this message translates to:
  /// **'Home Services'**
  String get homeServices;

  /// No description provided for @homeServicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book professional services at your doorstep'**
  String get homeServicesSubtitle;

  /// No description provided for @couldNotLoadServices.
  ///
  /// In en, this message translates to:
  /// **'Could not load services'**
  String get couldNotLoadServices;

  /// No description provided for @courierBooking.
  ///
  /// In en, this message translates to:
  /// **'Courier Booking'**
  String get courierBooking;

  /// No description provided for @customerAndPickupDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer & Pickup Details'**
  String get customerAndPickupDetails;

  /// No description provided for @electrician.
  ///
  /// In en, this message translates to:
  /// **'Electrician'**
  String get electrician;

  /// No description provided for @plumber.
  ///
  /// In en, this message translates to:
  /// **'Plumber'**
  String get plumber;

  /// No description provided for @salonParlor.
  ///
  /// In en, this message translates to:
  /// **'Salon / Parlor'**
  String get salonParlor;

  /// No description provided for @pickupDetails.
  ///
  /// In en, this message translates to:
  /// **'Pickup Details'**
  String get pickupDetails;

  /// No description provided for @pickupAddress.
  ///
  /// In en, this message translates to:
  /// **'Pickup Address'**
  String get pickupAddress;

  /// No description provided for @enterPickupAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter full pickup address'**
  String get enterPickupAddress;

  /// No description provided for @pickupPincode.
  ///
  /// In en, this message translates to:
  /// **'Pickup Pincode'**
  String get pickupPincode;

  /// No description provided for @deliveryDetails.
  ///
  /// In en, this message translates to:
  /// **'Delivery Details'**
  String get deliveryDetails;

  /// No description provided for @enterDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter full delivery address'**
  String get enterDeliveryAddress;

  /// No description provided for @deliveryPincode.
  ///
  /// In en, this message translates to:
  /// **'Delivery Pincode'**
  String get deliveryPincode;

  /// No description provided for @parcelDetails.
  ///
  /// In en, this message translates to:
  /// **'Parcel Details'**
  String get parcelDetails;

  /// No description provided for @packagingDetails.
  ///
  /// In en, this message translates to:
  /// **'Packaging Details'**
  String get packagingDetails;

  /// No description provided for @enterProductDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter product name and details'**
  String get enterProductDetails;

  /// No description provided for @enterPackagingDetails.
  ///
  /// In en, this message translates to:
  /// **'Envelope, box, etc.'**
  String get enterPackagingDetails;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @dimensionUnit.
  ///
  /// In en, this message translates to:
  /// **'Dimension Unit'**
  String get dimensionUnit;

  /// No description provided for @additionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional Info'**
  String get additionalInfo;

  /// No description provided for @customerNotes.
  ///
  /// In en, this message translates to:
  /// **'Customer Notes (optional)'**
  String get customerNotes;

  /// No description provided for @addProductImage.
  ///
  /// In en, this message translates to:
  /// **'Add Product Image (optional)'**
  String get addProductImage;

  /// No description provided for @checkPrice.
  ///
  /// In en, this message translates to:
  /// **'Check Price'**
  String get checkPrice;

  /// No description provided for @bookService.
  ///
  /// In en, this message translates to:
  /// **'Book Service'**
  String get bookService;

  /// No description provided for @priceCheckComplete.
  ///
  /// In en, this message translates to:
  /// **'Price Check Complete'**
  String get priceCheckComplete;

  /// No description provided for @bookingSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Booking Submitted'**
  String get bookingSubmitted;

  /// No description provided for @tokenAmount.
  ///
  /// In en, this message translates to:
  /// **'Token Amount'**
  String get tokenAmount;

  /// No description provided for @serviceHistory.
  ///
  /// In en, this message translates to:
  /// **'Service History'**
  String get serviceHistory;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noPreviousOrders.
  ///
  /// In en, this message translates to:
  /// **'No previous orders'**
  String get noPreviousOrders;

  /// No description provided for @serviceHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your service booking history will appear here'**
  String get serviceHistoryEmpty;

  /// No description provided for @couldNotLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load history'**
  String get couldNotLoadHistory;

  /// No description provided for @inquiryId.
  ///
  /// In en, this message translates to:
  /// **'Inquiry ID'**
  String get inquiryId;

  /// No description provided for @yourAddress.
  ///
  /// In en, this message translates to:
  /// **'Your Address'**
  String get yourAddress;

  /// No description provided for @fullAddress.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get fullAddress;

  /// No description provided for @enterCompleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your complete address'**
  String get enterCompleteAddress;

  /// No description provided for @serviceDescription.
  ///
  /// In en, this message translates to:
  /// **'Service Description'**
  String get serviceDescription;

  /// No description provided for @describeServiceNeeded.
  ///
  /// In en, this message translates to:
  /// **'Describe the service you need'**
  String get describeServiceNeeded;

  /// No description provided for @sixDigitPincode.
  ///
  /// In en, this message translates to:
  /// **'6-digit pincode'**
  String get sixDigitPincode;

  /// No description provided for @enterValidPincode.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 6-digit pincode'**
  String get enterValidPincode;

  /// No description provided for @guestWallTitle.
  ///
  /// In en, this message translates to:
  /// **'Login to view {contentLabel}'**
  String guestWallTitle(String contentLabel);

  /// No description provided for @guestWallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access {contentLabel} and enjoy a personalised shopping experience with order tracking, saved addresses, and more.'**
  String guestWallSubtitle(String contentLabel);

  /// No description provided for @guestWallLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Login to Continue'**
  String get guestWallLoginButton;

  /// No description provided for @guestWallContinueBrowsing.
  ///
  /// In en, this message translates to:
  /// **'Continue browsing as guest'**
  String get guestWallContinueBrowsing;

  /// No description provided for @loginCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get loginCancelButton;

  /// No description provided for @orderReview.
  ///
  /// In en, this message translates to:
  /// **'Review Order'**
  String get orderReview;

  /// No description provided for @reviewYourOrder.
  ///
  /// In en, this message translates to:
  /// **'Review your order before confirming'**
  String get reviewYourOrder;

  /// No description provided for @reviewOrderDescription.
  ///
  /// In en, this message translates to:
  /// **'Please verify the details below and tap \"Confirm Order\" to place your order.'**
  String get reviewOrderDescription;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrder;

  /// No description provided for @confirmingOrder.
  ///
  /// In en, this message translates to:
  /// **'Placing your order...'**
  String get confirmingOrder;

  /// No description provided for @deliveryTo.
  ///
  /// In en, this message translates to:
  /// **'Delivering to'**
  String get deliveryTo;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @orderSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummaryTitle;

  /// No description provided for @itemTotal.
  ///
  /// In en, this message translates to:
  /// **'Item Total'**
  String get itemTotal;

  /// No description provided for @platformFees.
  ///
  /// In en, this message translates to:
  /// **'Platform Fees'**
  String get platformFees;

  /// No description provided for @otherChargesLabel.
  ///
  /// In en, this message translates to:
  /// **'Other Charges'**
  String get otherChargesLabel;

  /// No description provided for @orderPlacedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get orderPlacedTitle;

  /// No description provided for @orderPlacedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your order has been placed successfully. Pay on delivery.'**
  String get orderPlacedSubtitle;

  /// No description provided for @orderPlacedOnlineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your order has been placed successfully. Redirecting to payment...'**
  String get orderPlacedOnlineSubtitle;

  /// No description provided for @thankYouForOrder.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your order!'**
  String get thankYouForOrder;

  /// No description provided for @viewMyOrders.
  ///
  /// In en, this message translates to:
  /// **'View My Orders'**
  String get viewMyOrders;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'Read less'**
  String get readLess;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Shop everything you need'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Discover thousands of products from local stores, delivered straight to your door.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Fast & reliable delivery'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Track your orders in real-time and get them delivered in minutes, not days.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Safe & secure payments'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Pay with confidence using trusted payment methods, every single time.'**
  String get onboardingSubtitle3;

  /// No description provided for @exitAppSavedNote.
  ///
  /// In en, this message translates to:
  /// **'Your shopping cart and progress will be saved.'**
  String get exitAppSavedNote;

  /// No description provided for @cartEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Looks like you haven\'t added anything yet.\nStart exploring our wide range of products.'**
  String get cartEmptyDescription;

  /// No description provided for @splashPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing the best shopping experience for you'**
  String get splashPreparing;

  /// No description provided for @trustFastDelivery.
  ///
  /// In en, this message translates to:
  /// **'Fast Delivery'**
  String get trustFastDelivery;

  /// No description provided for @trustSecureShopping.
  ///
  /// In en, this message translates to:
  /// **'Secure Shopping'**
  String get trustSecureShopping;

  /// No description provided for @trustQualityProducts.
  ///
  /// In en, this message translates to:
  /// **'Quality Products'**
  String get trustQualityProducts;

  /// No description provided for @trustByIndia.
  ///
  /// In en, this message translates to:
  /// **'Trusted by India'**
  String get trustByIndia;

  /// No description provided for @trustWideSelection.
  ///
  /// In en, this message translates to:
  /// **'Wide Selection'**
  String get trustWideSelection;

  /// No description provided for @trustBestPrices.
  ///
  /// In en, this message translates to:
  /// **'Best Prices'**
  String get trustBestPrices;

  /// No description provided for @trustSecurePayment.
  ///
  /// In en, this message translates to:
  /// **'Secure Payment'**
  String get trustSecurePayment;

  /// No description provided for @quickNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No Quick delivery categories are available for this address yet.'**
  String get quickNoCategories;

  /// No description provided for @quickLocationNeededTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a delivery address'**
  String get quickLocationNeededTitle;

  /// No description provided for @quickLocationNeededBody.
  ///
  /// In en, this message translates to:
  /// **'Quick delivery needs a delivery address with a map location. Choose or add one to see what is available near you.'**
  String get quickLocationNeededBody;

  /// No description provided for @quickNotServiceableTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick delivery isn\'t available here'**
  String get quickNotServiceableTitle;

  /// No description provided for @quickNotServiceableDefault.
  ///
  /// In en, this message translates to:
  /// **'Quick delivery is not available at this address right now. You can change the address or use Standard delivery.'**
  String get quickNotServiceableDefault;

  /// No description provided for @changeAddress.
  ///
  /// In en, this message translates to:
  /// **'Change address'**
  String get changeAddress;

  /// No description provided for @quickCheckoutUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Quick delivery can\'t be confirmed for this address right now. Please change the address or choose Standard delivery.'**
  String get quickCheckoutUnavailable;

  /// No description provided for @quickDeliveryNearbyStore.
  ///
  /// In en, this message translates to:
  /// **'Quick delivery from a nearby store'**
  String get quickDeliveryNearbyStore;

  /// No description provided for @loginRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get loginRequiredTitle;

  /// No description provided for @loginToAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Please login to add items to your cart.'**
  String get loginToAddToCart;
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
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );

  /// No description provided for @quickAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get quickAvailabilityTitle;

  /// No description provided for @quickAvailabilityChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking availability at your address…'**
  String get quickAvailabilityChecking;

  /// No description provided for @quickAvailabilityAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available for Quick delivery at your address'**
  String get quickAvailabilityAvailable;

  /// No description provided for @quickAvailabilityNotInArea.
  ///
  /// In en, this message translates to:
  /// **'This product is not available in your area right now.'**
  String get quickAvailabilityNotInArea;

  /// No description provided for @quickAvailabilityOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'This product is out of stock right now.'**
  String get quickAvailabilityOutOfStock;

  /// No description provided for @quickAvailabilityLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Select an address with a map location to check availability.'**
  String get quickAvailabilityLocationRequired;

  /// No description provided for @quickAvailabilityUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This product is not available for Quick delivery right now.'**
  String get quickAvailabilityUnavailable;

  /// No description provided for @quickAvailabilityFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not check availability. Please try again.'**
  String get quickAvailabilityFailed;

  /// No description provided for @quickBadgeNotInArea.
  ///
  /// In en, this message translates to:
  /// **'Not in your area'**
  String get quickBadgeNotInArea;

  /// No description provided for @quickCatalogueFallbackNotice.
  ///
  /// In en, this message translates to:
  /// **'Quick delivery is not available at this address. You can still browse these products.'**
  String get quickCatalogueFallbackNotice;

  /// No description provided for @multiOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Your items are split into {count} orders'**
  String multiOrderTitle(int count);

  /// No description provided for @multiOrderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Each shop prepares and delivers its own order.'**
  String get multiOrderSubtitle;

  /// No description provided for @checkoutSplitNotice.
  ///
  /// In en, this message translates to:
  /// **'Your items are from {count} shops, so {count} separate orders will be placed.'**
  String checkoutSplitNotice(int count);

  /// No description provided for @orderOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Order {index} of {total}'**
  String orderOfTotal(int index, int total);

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications to get order updates, payment confirmations and offers from Taksh. You can turn them on in your device settings.'**
  String get notificationPermissionMessage;
}
