// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Taksh E-Commerce';

  @override
  String get madeInIndia => 'Made in India';

  @override
  String get initializing => 'Initializing...';

  @override
  String get checkingAuthentication => 'Checking authentication...';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get login => 'Login';

  @override
  String get loginTagline => 'Food delivered to your doorstep';

  @override
  String get enterPhoneDescription => 'Enter your phone number to receive OTP';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterPhoneNumberHint => 'Enter 10-digit phone number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get termsAndPrivacy =>
      'By continuing, you agree to our Terms of Service and Privacy Policy';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String enterOtpDescription(String phone) {
    return 'Enter the 4-digit code sent to $phone';
  }

  @override
  String get otpHint => '0000';

  @override
  String get verifyOtpButton => 'Verify OTP';

  @override
  String get didNotReceiveCode => 'Didn\'t receive the code? ';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get otpResentSuccess => 'OTP resent successfully';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get invalidPhone => 'Enter a valid 10-digit phone number';

  @override
  String get otpRequired => 'OTP is required';

  @override
  String get invalidOtp => 'Enter a valid 4-digit OTP';

  @override
  String get profile => 'Profile';

  @override
  String get appearance => 'Appearance';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String themeChanged(String theme) {
    return 'Theme changed to $theme';
  }

  @override
  String get preferences => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';

  @override
  String languageChanged(String language) {
    return 'Language changed to $language';
  }

  @override
  String get general => 'General';

  @override
  String get myAddress => 'My Address';

  @override
  String get coupons => 'Coupons';

  @override
  String get paymentMethodsComingSoon => 'Payment Methods - Coming Soon';

  @override
  String get earnings => 'Earnings';

  @override
  String get joinAsDeliveryMan => 'Join as Delivery Man';

  @override
  String get openVendor => 'Open Vendor';

  @override
  String get languageSettingsComingSoon => 'Language Settings - Coming Soon';

  @override
  String get createApplication => 'Create Application';

  @override
  String get createWebsite => 'Create Website';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get liveChat => 'Live Chat';

  @override
  String get aboutUs => 'About Us';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get refundPolicy => 'Refund Policy';

  @override
  String get support => 'Support';

  @override
  String get remove => 'Remove';

  @override
  String get clear => 'Clear';

  @override
  String get logout => 'Logout';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get standardDelivery => 'Standard Delivery';

  @override
  String get standardDeliveryDescription =>
      'Standard Delivery - Shop Your Favorites!';

  @override
  String get quickDelivery => 'Quick Delivery';

  @override
  String get quickDeliveryDescription => 'Quick Delivery - Express 30';

  @override
  String get homeService => 'Home Service';

  @override
  String get homeServiceDescription => 'Explore home services coming soon';

  @override
  String get searchHint => 'Search for products...';

  @override
  String get somethingWentWrong => 'Oops! Something went wrong';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get exitAppTitle => 'Exit App?';

  @override
  String get exitAppContent => 'Are you sure you want to exit?';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get homeTab => 'Home';

  @override
  String get categoriesTab => 'Categories';

  @override
  String get cartTab => 'Cart';

  @override
  String get ordersTab => 'Orders';

  @override
  String get profileTab => 'Profile';

  @override
  String get cart => 'Cart';

  @override
  String get clearCart => 'Clear Cart';

  @override
  String get cartEmptyTitle => 'Your Cart is Empty';

  @override
  String get cartEmptySubtitle => 'Add items to get started';

  @override
  String get startShopping => 'Start Shopping';

  @override
  String sku(String sku) {
    return 'SKU: $sku';
  }

  @override
  String total(String amount) {
    return 'Total: ₹$amount';
  }

  @override
  String get removeItemTitle => 'Remove Item';

  @override
  String removeItemConfirm(String product) {
    return 'Remove $product from cart?';
  }

  @override
  String get clearCartConfirm => 'Remove all items from cart?';

  @override
  String totalItemsLabel(int count) {
    return 'Total Items: $count';
  }

  @override
  String get proceedToCheckout => 'Proceed to Checkout';

  @override
  String get myOrders => 'My Orders';

  @override
  String get filterByStatus => 'Filter by Status';

  @override
  String get allOrders => 'All Orders';

  @override
  String get readyForDispatch => 'Ready for Dispatch';

  @override
  String get dispatched => 'Dispatched';

  @override
  String get delivered => 'Delivered';

  @override
  String get dateNewestFirst => 'Date: Newest First';

  @override
  String get dateOldestFirst => 'Date: Oldest First';

  @override
  String get amountHighToLow => 'Amount: High to Low';

  @override
  String get amountLowToHigh => 'Amount: Low to High';

  @override
  String get recentlyUpdated => 'Recently Updated';

  @override
  String get leastRecentlyUpdated => 'Least Recently Updated';

  @override
  String get noOrdersFound => 'No orders found';

  @override
  String get tryAdjustingFilters => 'Try adjusting your filters';

  @override
  String get filterByDate => 'Filter by date';

  @override
  String get clearDateFilter => 'Clear date filter';

  @override
  String get noOrdersYet => 'No Orders Yet';

  @override
  String get yourOrdersAppearHere => 'Your orders will appear here';

  @override
  String orderNumber(String number) {
    return 'Order #$number';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String estDelivery(String date) {
    return 'Est. delivery: $date';
  }

  @override
  String get orderDetails => 'Order Details';

  @override
  String placedOn(String date) {
    return 'Placed on $date';
  }

  @override
  String get deliveryType => 'Delivery Type';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get paymentStatus => 'Payment Status';

  @override
  String get estimatedDelivery => 'Estimated Delivery';

  @override
  String get invoice => 'Invoice';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String orderItems(int count) {
    return 'Order Items ($count)';
  }

  @override
  String qtyPrice(int qty, String price) {
    return 'Qty: $qty × ₹$price';
  }

  @override
  String get returnItem => 'Return Item';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get paymentInformation => 'Payment Information';

  @override
  String paidVia(String method) {
    return 'Paid via $method';
  }

  @override
  String get orders => 'Orders';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get reviews => 'Reviews';

  @override
  String get whatsappError =>
      'Could not open WhatsApp. Please make sure WhatsApp is installed.';

  @override
  String lastUpdated(String date) {
    return 'Last Updated: $date';
  }

  @override
  String get termsIntroTitle =>
      '1. Introduction and Acceptance';

  @override
  String get termsIntroContent =>
      'Welcome to Taksh, operated by TAKSH ALL IN ONE ECOMMERCE & LOGISTICS WITH MULTI SERVICES PRIVATE LIMITED ("Taksh", "we", "us"). These Terms & Conditions govern your use of our mobile application and related services (the "Platform"). By downloading, registering or using the Platform, you agree to these Terms. If you do not agree, please do not use the Platform.\n\nYou must be at least 18 years old and legally able to enter into a contract under the Indian Contract Act, 1872. Minors may use the Platform only under the supervision of a parent or guardian.';

  @override
  String get termsAccountTitle =>
      '2. Account Registration';

  @override
  String get termsAccountContent =>
      'You sign in with your mobile number, verified by a One-Time Password (OTP). You agree to:\n\n• Provide accurate and complete information\n• Keep your device and OTP confidential and never share your OTP with anyone\n• Tell us immediately if you suspect unauthorised use\n• Accept responsibility for all activity under your account\n\nWe may suspend or close accounts that give false information or break these Terms.';

  @override
  String get termsUserRespTitle =>
      '3. User Responsibilities';

  @override
  String get termsUserRespContent =>
      'As a user of the Platform, you agree to:\n\n• Use it only for lawful purposes\n• Not provide false information or pretend to be someone else\n• Not misuse offers, coupons or referral benefits\n• Not post abusive, misleading or unlawful reviews or content\n• Not copy, scrape or interfere with the Platform or try to gain unauthorised access to our systems\n• Not infringe the intellectual property rights of others';

  @override
  String get termsProductsTitle =>
      '4. Products and Pricing';

  @override
  String get termsProductsContent =>
      'We try to show accurate product descriptions, images, prices and availability. However:\n\n• Images are for illustration and colour or packaging may differ slightly\n• All prices are in Indian Rupees (INR) and include applicable taxes unless stated otherwise\n• Delivery or handling charges, if any, are shown before you place the order\n• Prices, offers and availability may change without notice; the price shown when you place the order applies\n• If a product is listed at a wrong price because of a technical or typing error, we may cancel the order and refund any amount paid';

  @override
  String get termsOrdersTitle =>
      '5. Orders';

  @override
  String get termsOrdersContent =>
      '• Placing an order is an offer to buy. A contract is formed only when we confirm your order\n• You confirm that the details you give (including your delivery address and phone number) are correct\n• We may cancel or refuse an order if stock is unavailable, there is a pricing error, fraud is suspected or the address cannot be served. If you have already paid, we will refund you\n• Quantity limits may apply to some products';

  @override
  String get termsPaymentTitle =>
      '6. Payments';

  @override
  String get termsPaymentContent =>
      '• You can pay online through our payment gateway (UPI, cards, net banking or wallets) or choose Cash on Delivery where available\n• Online payments are processed by a third-party payment gateway. We do not store your card number, CVV, UPI PIN or banking passwords\n• You confirm that you are authorised to use the payment method you choose\n• If money is debited but the order is not confirmed, the amount is normally reversed automatically within 5 to 7 working days. If it is not, please contact us with the transaction details\n• For Cash on Delivery, please keep the payment ready at delivery. We may limit or disable Cash on Delivery for accounts with repeated refused or undelivered orders';

  @override
  String get termsShippingTitle =>
      '7. Delivery';

  @override
  String get termsShippingContent =>
      '• Delivery options (Express 30-minute, Next-Day and Standard) depend on your location and product availability\n• Delivery times are estimates, not guarantees. Delays can happen due to weather, traffic, high demand or other events beyond our control\n• Please give a complete and correct address and keep your phone reachable. We are not responsible for failed delivery caused by wrong or incomplete details\n• Please check your items at delivery and report any problem as soon as possible\n• Risk of loss passes to you on delivery';

  @override
  String get termsCancelTitle =>
      '8. Cancellations';

  @override
  String get termsCancelContent =>
      '• You can cancel an order before it is dispatched, from the app or by contacting us\n• Once an order is dispatched it cannot be cancelled, but it may be returned as per our Refund & Return Policy\n• Prepaid orders cancelled before dispatch are refunded as described in our Refund & Return Policy';

  @override
  String get termsReturnsTitle =>
      '9. Returns and Refunds';

  @override
  String get termsReturnsContent =>
      'Returns, replacements and refunds are governed by our Refund & Return Policy, which is part of these Terms. In short:\n\n• Return requests must be raised in the app within the return window shown for the product\n• Items must be unused and in their original condition and packaging\n• Some items cannot be returned, as listed in the policy\n• Approved refunds for returned items are credited to your Taksh wallet';

  @override
  String get termsOffersTitle =>
      '10. Offers and Third-Party Sellers';

  @override
  String get termsOffersContent =>
      '• Offers, discounts and coupons are subject to their own terms, validity and usage limits and may be withdrawn or changed at any time\n• Some products are sold by third-party sellers and delivered through our fulfillment centers or delivery partners. Taksh facilitates the sale and, where applicable, the seller\'s details are shown on the product page\n• The Platform may link to third-party services. We are not responsible for their content or practices';

  @override
  String get termsIpTitle =>
      '11. Intellectual Property';

  @override
  String get termsIpContent =>
      'All content on the Platform, including logos, trademarks, text, graphics, images and software, belongs to Taksh or its licensors and is protected by Indian intellectual property laws. You may not copy, modify, distribute or use it commercially without our written permission.';

  @override
  String get termsPrivacyTitle =>
      '12. Privacy and Data Protection';

  @override
  String get termsPrivacyContent =>
      'Your privacy matters to us. We collect and use your personal data as described in our Privacy Policy. By using the Platform, you consent to that collection and use.';

  @override
  String get termsLiabilityTitle =>
      '13. Limitation of Liability';

  @override
  String get termsLiabilityContent =>
      'To the extent permitted by law:\n\n• The Platform is provided "as is" and "as available". We do not promise that it will always be uninterrupted or error-free\n• We are not liable for indirect or consequential losses\n• Our total liability for any claim about an order is limited to the amount you paid for that order\n• Manufacturer warranties, if any, are given by the manufacturer\n\nNothing in these Terms limits your rights under the Consumer Protection Act, 2019.';

  @override
  String get termsIndemnifyTitle =>
      '14. Indemnification';

  @override
  String get termsIndemnifyContent =>
      'You agree to compensate and hold Taksh harmless against claims, losses and expenses that arise from your breach of these Terms or your violation of any law or the rights of others.';

  @override
  String get termsModTitle =>
      '15. Changes to These Terms';

  @override
  String get termsModContent =>
      'We may update these Terms from time to time. The updated Terms will be shown in the app with a new "Last Updated" date. If you continue to use the Platform after the change, you accept the updated Terms.';

  @override
  String get termsTerminationTitle =>
      '16. Suspension and Termination';

  @override
  String get termsTerminationContent =>
      'We may suspend or end your access if you break these Terms, misuse the Platform or the law requires it. You may stop using the Platform and delete your account at any time. Rights and obligations that arose before termination continue.';

  @override
  String get termsLawTitle =>
      '17. Governing Law and Jurisdiction';

  @override
  String get termsLawContent =>
      'These Terms are governed by the laws of India. Subject to your rights as a consumer under applicable law, the courts at Bhopal, Madhya Pradesh will have jurisdiction over disputes.';

  @override
  String get termsGrievanceTitle =>
      '18. Grievance Officer';

  @override
  String get termsGrievanceContent =>
      'In line with the Information Technology Act, 2000 and the Consumer Protection (E-Commerce) Rules, 2020, you can send complaints to our Grievance Officer:\n\nGrievance Officer\nTAKSH ALL IN ONE ECOMMERCE & LOGISTICS WITH MULTI SERVICES PRIVATE LIMITED\nEmail: customersupport@takshallinone.in\nAddress: Bhopal, Madhya Pradesh, India\n\nWe acknowledge complaints within 48 hours and aim to resolve them within one month.';

  @override
  String get termsContactTitle =>
      '19. Contact Us';

  @override
  String get termsContactContent =>
      'For any question about these Terms, contact us:\n\nEmail: customersupport@takshallinone.in\nAddress: Bhopal, Madhya Pradesh, India';

  @override
  String get termsAck =>
      'By using Taksh, you confirm that you have read and understood these Terms & Conditions.';

  @override
  String get refundCommitmentTitle =>
      'Our Commitment';

  @override
  String get refundCommitmentContent =>
      'At Taksh E-Commerce we want you to be happy with every order. If something is wrong with your order, this policy explains how returns, replacements, cancellations and refunds work.';

  @override
  String get refundReadPolicy =>
      'Please read this policy carefully. It is part of our Terms & Conditions.';

  @override
  String get refundEligibilityTitle =>
      '1. Return Eligibility';

  @override
  String get refundEligibilityContent =>
      'You can request a return within the return window of the product, counted from the date of delivery. The window is shown on the product page and is 7 days unless stated otherwise. You can request a return if:';

  @override
  String get refundEligibilityItem1 =>
      'You received a wrong, damaged or defective item, or one that is different from its description';

  @override
  String get refundEligibilityItem2 =>
      'Parts, accessories or quantity are missing from your order';

  @override
  String get refundEligibilityItem3 =>
      'There is a size, fit or colour issue (where the product allows it)';

  @override
  String get refundEligibilityItem4 =>
      'The item is unused, with original packaging, tags and labels intact';

  @override
  String get refundEligibilityItem5 =>
      'You raise the request in the app with a reason and clear photos';

  @override
  String get refundNonReturnableTitle =>
      '2. Non-Returnable Items';

  @override
  String get refundNonReturnableContent =>
      'The following items cannot be returned, unless they arrive damaged, defective or wrong:';

  @override
  String get refundNonReturnableItem1 =>
      'Perishable goods such as fresh food, fruits and vegetables';

  @override
  String get refundNonReturnableItem2 =>
      'Opened or used personal care, hygiene and intimate items';

  @override
  String get refundNonReturnableItem3 =>
      'Customised or personalised items';

  @override
  String get refundNonReturnableItem4 =>
      'Digital products, gift cards and vouchers';

  @override
  String get refundNonReturnableItem5 =>
      'Products marked "non-returnable" on the product page';

  @override
  String get refundNonReturnableItem6 =>
      'Items damaged through misuse after delivery';

  @override
  String get refundProcessTitle =>
      '3. Return Process';

  @override
  String get refundProcessContent =>
      'Follow these steps to return an item:';

  @override
  String get refundStep1Title =>
      'Raise a Return Request';

  @override
  String get refundStep1Desc =>
      'Go to "Your Orders", select the item and tap Return. Choose a reason, add up to 5 photos and submit.';

  @override
  String get refundStep2Title =>
      'Request Review';

  @override
  String get refundStep2Desc =>
      'Our team reviews your request, usually within 24 to 48 hours. You can see the status in the app.';

  @override
  String get refundStep3Title =>
      'Pack the Item';

  @override
  String get refundStep3Desc =>
      'Keep the item in its original packaging with all accessories, tags and the invoice.';

  @override
  String get refundStep4Title =>
      'Pickup and Resolution';

  @override
  String get refundStep4Desc =>
      'If approved, we will arrange a pickup or tell you how to send the item back. After it is received and checked, your refund or replacement is processed.';

  @override
  String get refundTimelineTitle =>
      '4. Refund Timeline';

  @override
  String get refundTimelineContent =>
      'A typical timeline after your return request is approved (actual time may vary by location and product):';

  @override
  String get refundTimelineItem1Day =>
      'Day 1-2';

  @override
  String get refundTimelineItem1Desc =>
      'Item picked up or received and quality check started';

  @override
  String get refundTimelineItem2Day =>
      'Day 3-4';

  @override
  String get refundTimelineItem2Desc =>
      'Quality check completed and refund approved';

  @override
  String get refundTimelineItem3Day =>
      'Day 5-7';

  @override
  String get refundTimelineItem3Desc =>
      'Refund credited to your Taksh wallet or replacement dispatched';

  @override
  String get refundProcessingNote =>
      'These timelines are estimates. Delays can happen during sale periods and holidays or when extra verification is needed.';

  @override
  String get refundMethodsTitle =>
      '5. How You Get Your Money Back';

  @override
  String get refundMethodsContent =>
      'Depending on your case, your request is settled in one of these ways:';

  @override
  String get refundMethodOriginalTitle =>
      'Taksh Wallet Credit';

  @override
  String get refundMethodOriginalDesc =>
      'Refunds for approved returns are credited to your Taksh wallet and can be used on future orders';

  @override
  String get refundMethodOriginalDays =>
      'After check';

  @override
  String get refundMethodCreditTitle =>
      'Replacement';

  @override
  String get refundMethodCreditDesc =>
      'The same item is sent again, subject to stock availability';

  @override
  String get refundMethodCreditDays =>
      'Subject to stock';

  @override
  String get refundMethodBankTitle =>
      'Original Payment Method';

  @override
  String get refundMethodBankDesc =>
      'Prepaid orders cancelled before dispatch are refunded to the card, UPI or bank account used to pay';

  @override
  String get refundMethodBankDays =>
      '5-7 days';

  @override
  String get refundDamagedTitle =>
      '6. Damaged or Defective Products';

  @override
  String get refundDamagedContent =>
      'If you receive a damaged or defective product:\n\n• Report it in the app as soon as possible, ideally within 48 hours of delivery and always within the return window\n• Add clear photos of the item and its packaging\n• After verification we will offer a replacement or refund\n• For perishable items, please report at the time of delivery or within 24 hours';

  @override
  String get refundWrongTitle =>
      '7. Wrong Product Delivered';

  @override
  String get refundWrongContent =>
      'If you receive the wrong product:\n\n• Raise a return in the app with photos\n• We will not charge you for a return that results from our error\n• We will send the correct item, subject to stock\n• If the correct item is not available, you will be refunded';

  @override
  String get refundPartialTitle =>
      '8. Partial Refunds';

  @override
  String get refundPartialContent =>
      'In some cases only a part of the amount may be refunded:';

  @override
  String get refundPartialItem1 =>
      'The item shows signs of use or minor damage not caused by us';

  @override
  String get refundPartialItem2 =>
      'Accessories, tags or original packaging are missing';

  @override
  String get refundPartialItem3 =>
      'Only a part of the order is affected or returned';

  @override
  String get refundPartialItem4 =>
      'Free or promotional items that came with the order are not returned';

  @override
  String get refundExchangeTitle =>
      '9. Replacement';

  @override
  String get refundExchangeContent =>
      'When you raise a return, you can ask for a replacement instead of a refund. We send the same item again, subject to stock. If it is not available, the amount is refunded to your Taksh wallet.';

  @override
  String get refundCancelTitle =>
      '10. Cancellation Policy';

  @override
  String get refundCancelContent =>
      'You can cancel an order before it is dispatched, from the app or by contacting us:\n\n• No cancellation charges before dispatch\n• Prepaid orders are refunded to the original payment method, usually within 5 to 7 working days (your bank\'s timelines may vary)\n• Cash on Delivery orders have nothing to refund\n• After dispatch an order cannot be cancelled, but you may return it as per this policy\n• If an order is refused at delivery or cannot be delivered because of a wrong address, it may be cancelled and delivery charges may be deducted from any refund';

  @override
  String get refundContactTitle =>
      '11. Contact for Returns';

  @override
  String get refundContactContent =>
      'Need help with a return or refund? Email us at customersupport@takshallinone.in with your order number and we will get back to you as soon as possible.\n\nThis policy does not affect your rights under the Consumer Protection Act, 2019.';

  @override
  String get refundSatisfactionTitle =>
      'We\'re Here to Help';

  @override
  String get refundSatisfactionContent =>
      'If something is not right with your order, tell us and we will work with you to fix it.';

  @override
  String get privacyIntroTitle =>
      'Introduction';

  @override
  String get privacyIntroContent =>
      'TAKSH ALL IN ONE ECOMMERCE & LOGISTICS WITH MULTI SERVICES PRIVATE LIMITED ("Taksh", "we", "us") respects your privacy. This policy explains what personal data we collect through our mobile app, why we collect it, how we use, share and protect it, and the choices you have. It follows the Information Technology Act, 2000, the IT (Reasonable Security Practices and Procedures) Rules, 2011 and the Digital Personal Data Protection Act, 2023.';

  @override
  String get privacyAgreeContent =>
      'By using our app and giving consent where we ask for it, you agree to the practices described in this policy.';

  @override
  String get privacyCollectTitle =>
      '1. Information We Collect';

  @override
  String get privacyCollectContent =>
      'We collect only the information we need to run the app and deliver your orders:';

  @override
  String get privacyPersonalTitle =>
      'Information You Give Us';

  @override
  String get privacyPersonalContent =>
      '• Name and mobile number (used to sign you in with an OTP)\n• Email address, if you provide it\n• Delivery addresses and pincode\n• Profile details you choose to add';

  @override
  String get privacyUsageTitle =>
      'Device and Usage Data';

  @override
  String get privacyUsageContent =>
      '• Device information (model, operating system, app version)\n• Location, only with your permission, to show what can be delivered to you\n• App activity and crash reports, to fix problems\n• A notification token, to send you order updates';

  @override
  String get privacyTransactionTitle =>
      'Order and Payment Data';

  @override
  String get privacyTransactionContent =>
      '• Orders, delivery and return details\n• Payment status and transaction reference. Card, UPI and bank details are handled by our payment gateway and are not stored by us\n• Photos you upload with a return request\n• Reviews and ratings you submit';

  @override
  String get privacyUseTitle =>
      '2. How We Use Your Information';

  @override
  String get privacyUseContent =>
      'We use your information to:';

  @override
  String get privacyUseItem1 =>
      'Create your account and verify you with an OTP';

  @override
  String get privacyUseItem2 =>
      'Process, deliver and track your orders';

  @override
  String get privacyUseItem3 =>
      'Handle payments, cancellations, returns and refunds';

  @override
  String get privacyUseItem4 =>
      'Provide customer support and answer your queries';

  @override
  String get privacyUseItem5 =>
      'Send order updates and important notifications';

  @override
  String get privacyUseItem6 =>
      'Show products and delivery options available at your location';

  @override
  String get privacyUseItem7 =>
      'Send offers and promotions, only if you have agreed';

  @override
  String get privacyUseItem8 =>
      'Improve the app and keep it secure, and detect and prevent fraud';

  @override
  String get privacyUseItem9 =>
      'Comply with legal obligations';

  @override
  String get privacySharingTitle =>
      '3. Sharing of Information';

  @override
  String get privacySharingContent =>
      'We do not sell your personal data. We share it only in these cases:';

  @override
  String get privacyProvidersTitle =>
      'Service Providers';

  @override
  String get privacyProvidersContent =>
      'Payment gateways, SMS and notification providers, cloud hosting and analytics providers who process data for us under confidentiality obligations.';

  @override
  String get privacyPartnersTitle =>
      'Sellers and Delivery Partners';

  @override
  String get privacyPartnersContent =>
      'Sellers, fulfillment centers and delivery partners receive your name, address, phone number and order details only to prepare and deliver your order.';

  @override
  String get privacyLegalTitle =>
      'Legal Requirements';

  @override
  String get privacyLegalContent =>
      'When required by law, a court order or a request from a government authority, or to protect the rights and safety of our users and Taksh.';

  @override
  String get privacyTransferTitle =>
      'Business Transfers';

  @override
  String get privacyTransferContent =>
      'If Taksh is merged with or acquired by another business, your data may be transferred to it, and we will tell you before it becomes subject to a different policy.';

  @override
  String get privacySecurityTitle =>
      '4. Data Security';

  @override
  String get privacySecurityContent =>
      'We use reasonable technical and organisational safeguards to protect your data:\n\n• Encryption of data in transit\n• Access controls and authentication\n• Access limited to authorised personnel\n• Payments handled by a secure payment gateway';

  @override
  String get privacySecurityNote =>
      'No method of transmission or storage is 100% secure. Please never share your OTP with anyone.';

  @override
  String get privacyRightsTitle =>
      '5. Your Rights';

  @override
  String get privacyRightsContent =>
      'Subject to applicable law, you have the right to:';

  @override
  String get privacyRightsItem1 =>
      'Access: ask what personal data we hold about you';

  @override
  String get privacyRightsItem2 =>
      'Correction: update or correct inaccurate data';

  @override
  String get privacyRightsItem3 =>
      'Erasure: delete your account and data, from the app or by emailing us';

  @override
  String get privacyRightsItem4 =>
      'Withdraw consent at any time';

  @override
  String get privacyRightsItem5 =>
      'Opt out of promotional messages';

  @override
  String get privacyRightsItem6 =>
      'Nominate a person to exercise your rights in case of your death or incapacity';

  @override
  String get privacyRightsItem7 =>
      'Raise a grievance with our Grievance Officer';

  @override
  String get privacyCookiesTitle =>
      '6. App Permissions';

  @override
  String get privacyCookiesContent =>
      'The app may ask for these permissions:\n\n• Location: to show delivery availability near you\n• Notifications: for order updates and offers\n• Camera and photos: to add images to a return request or profile\n\nYou can change any permission in your device settings. Some features may not work without them.';

  @override
  String get privacyLinksTitle =>
      '7. Third-Party Links';

  @override
  String get privacyLinksContent =>
      'The app may link to third-party websites or services. We are not responsible for their privacy practices, so please read their policies.';

  @override
  String get privacyChildrenTitle =>
      '8. Children\'s Privacy';

  @override
  String get privacyChildrenContent =>
      'Our service is meant for people aged 18 and above. We do not knowingly collect personal data of children without a parent\'s or guardian\'s consent. If you think a child has given us data, please contact us and we will delete it.';

  @override
  String get privacyRetentionTitle =>
      '9. Data Retention';

  @override
  String get privacyRetentionContent =>
      'We keep your data while your account is active and as long as needed to provide our services. After that we keep only what the law requires, such as invoices and transaction records, or what is needed to resolve disputes. We then delete or anonymise it.';

  @override
  String get privacyInternationalTitle =>
      '10. Data Storage and Transfers';

  @override
  String get privacyInternationalContent =>
      'Our service providers may store or process data on servers in or outside India. Where data is processed outside India, we take steps to make sure it stays protected as required by law.';

  @override
  String get privacyChangesTitle =>
      '11. Changes to This Policy';

  @override
  String get privacyChangesContent =>
      'We may update this policy from time to time. The new version will be shown in the app with a new "Last Updated" date.';

  @override
  String get privacyContactTitle =>
      '12. Contact and Grievance Officer';

  @override
  String get privacyContactContent =>
      'For questions, requests or complaints about your data, contact our Grievance Officer:\n\nGrievance Officer\nTAKSH ALL IN ONE ECOMMERCE & LOGISTICS WITH MULTI SERVICES PRIVATE LIMITED\nEmail: customersupport@takshallinone.in\nAddress: Bhopal, Madhya Pradesh, India\n\nWe acknowledge requests within 48 hours and aim to resolve them within one month.';

  @override
  String get privacyMattersTitle =>
      'Your Privacy Matters';

  @override
  String get privacyMattersContent =>
      'We handle your data responsibly and only for the purposes described here.';

  @override
  String get ourStoryContent =>
      'Taksh is a shopping app operated by TAKSH ALL IN ONE ECOMMERCE & LOGISTICS WITH MULTI SERVICES PRIVATE LIMITED, built to bring everyday products to your doorstep quickly and reliably. We work with local sellers and fulfillment centers, so you can choose Express delivery in 30 minutes in select areas, Next-Day delivery or Standard delivery, and pay online or with Cash on Delivery where available.';

  @override
  String get ourMissionContent =>
      'To make everyday shopping simple, fast and trustworthy, with clear prices, genuine products and honest service, while supporting local businesses.';

  @override
  String get ourVisionContent =>
      'To be a shopping app that people across India trust for their daily needs, where they can find what they want and get it when they need it.';

  @override
  String get trustTransparencyDesc =>
      'Clear prices, clear policies and honest communication at every step.';

  @override
  String get qualityFirstDesc =>
      'We work with sellers and partners to offer genuine products in good condition.';

  @override
  String get customerCentricityDesc =>
      'Our customers are at the heart of everything we do. Your feedback shapes how we improve.';

  @override
  String get sustainabilityDesc =>
      'We work with local sellers and fulfillment centers to deliver faster and support local businesses.';

  @override
  String get innovationDesc =>
      'We keep improving our app and services to make shopping easier.';

  @override
  String get whatWeOfferContent =>
      '• Wide Range of Products: A growing selection across many categories from trusted sellers\n\n• Flexible Delivery: Express 30-minute (select areas), Next-Day and Standard delivery\n\n• Secure Payments: Pay online through a secure payment gateway, or choose Cash on Delivery where available\n\n• Easy Returns: Raise a return in the app for eligible items within the return window\n\n• Support: Write to us anytime and we will get back to you';

  @override
  String get emailLabel => 'Email';

  @override
  String get addressLabel => 'Address';

  @override
  String get addressValue => 'Bhopal, Madhya Pradesh, India';

  @override
  String get updateProfileTitle => 'Update Profile';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get mobileLabel => 'Mobile';

  @override
  String get saveDetails => 'Save Details';

  @override
  String get enterValidName => 'Please enter valid name';

  @override
  String get joinDeliveryManTitle => 'Join as Delivery Man';

  @override
  String get fillDetailsDelivery =>
      'Fill in your details to join as a delivery partner';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get mobileRequired => 'Mobile number is required';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get pincodeLabel => 'Pincode';

  @override
  String get pincodeInvalidLength => 'Pincode must be 6 digits';

  @override
  String get pincodeInvalidFormat => 'Pincode must contain only numbers';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get submitRequest => 'Submit Request';

  @override
  String get requiredFieldsNote => '* Required fields';

  @override
  String fillDetailsRequest(String type) {
    return 'Fill in your details to request $type';
  }

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get passwordComplexity =>
      'Password must contain uppercase, lowercase, and number';

  @override
  String get confirmPasswordRequired => 'Confirm password is required';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String get appDevelopment => 'App Development';

  @override
  String get webDevelopment => 'Web Development';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get deliveryCharges => 'Delivery Charges';

  @override
  String get platformFee => 'Platform Fee';

  @override
  String get takshCharge => 'Taksh Charge';

  @override
  String get quickDeliveryFee => 'Quick Delivery Fee';

  @override
  String get cgst => 'CGST';

  @override
  String get sgst => 'SGST';

  @override
  String get discountLabel => 'Discount';

  @override
  String get otherCharges => 'Other Charges';

  @override
  String get free => 'FREE';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get returnOrder => 'Return Order';

  @override
  String get needHelp => 'Need Help';

  @override
  String get orderIssues => 'Do you have any issues with this order?';

  @override
  String get chatWithUs => 'Chat with us';

  @override
  String get sendEmail => 'Send us an email';

  @override
  String get returnFunctionalityComing =>
      'Return functionality will be available soon. You can contact support for assistance.';

  @override
  String get noCategoriesAvailable => 'No categories available';

  @override
  String get description => 'Description';

  @override
  String get similarProducts => 'Similar Products';

  @override
  String get selectVariant => 'Select Variant';

  @override
  String get ratings => 'Ratings';

  @override
  String get failedToLoadProduct => 'Failed to load product';

  @override
  String get retry => 'Retry';

  @override
  String get searching => 'Searching...';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String typeMinCharsToSearch(int count) {
    return 'Type at least $count characters to start searching';
  }

  @override
  String get inStock => 'In stock';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get checkout => 'Checkout';

  @override
  String get deliveryOptions => 'Delivery Options';

  @override
  String get priceDetails => 'Price Details';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get proceedToPay => 'Proceed to Pay';

  @override
  String get addAddress => 'Add Address';

  @override
  String get loadingOrderDetails => 'Loading order details...';

  @override
  String get addAddressToContinue =>
      'Please add a delivery address to continue';

  @override
  String get paymentSuccess => 'Payment Successful';

  @override
  String get paymentFailed => 'Payment Failed';

  @override
  String get orderPlacedSuccessfully =>
      'Your order has been placed successfully!';

  @override
  String get somethingWentWrongPayment =>
      'Something went wrong with your payment';

  @override
  String get viewOrder => 'View Order';

  @override
  String get continueShopping => 'Continue Shopping';

  @override
  String get selectAddress => 'Select Address';

  @override
  String get myAddresses => 'My Addresses';

  @override
  String get noAddressesSaved => 'No addresses saved';

  @override
  String get addFirstAddress => 'Add your first address to get started';

  @override
  String get deleteAddress => 'Delete Address';

  @override
  String get deleteAddressConfirm =>
      'Are you sure you want to delete this address? This action cannot be undone.';

  @override
  String get setDefault => 'Set Default';

  @override
  String get addNewAddress => 'Add New Address';

  @override
  String get editAddress => 'Edit Address';

  @override
  String get selectLocationOnMap => 'Select Location on Map';

  @override
  String get locationSelected => 'Location Selected';

  @override
  String get tapToPickLocation => 'Tap to pick location on map';

  @override
  String get addressType => 'Address Type';

  @override
  String get recipientName => 'Recipient Name';

  @override
  String get enterRecipientName => 'Enter recipient\'s full name';

  @override
  String get labelOther => 'Label (e.g., Friend\'s House)';

  @override
  String get enterLabel => 'Enter a label for this address';

  @override
  String get houseFlatNo => 'House/Flat/Block No.';

  @override
  String get enterHouseNo => 'Enter house or flat number';

  @override
  String get landmarkOptional => 'Landmark (Optional)';

  @override
  String get landmarkHint => 'E.g., Near City Mall';

  @override
  String get city => 'City';

  @override
  String get enterCity => 'Enter city';

  @override
  String get state => 'State';

  @override
  String get enterState => 'Enter state';

  @override
  String get pincode => 'Pincode';

  @override
  String get enterPincode => 'Enter Pincode';

  @override
  String get pincodeLengthError => 'Pincode must be 6 digits';

  @override
  String get setAsDefaultAddress => 'Set as default address';

  @override
  String get setAsDefaultSubtitle =>
      'This address will be used by default for deliveries';

  @override
  String get updateAddress => 'Update Address';

  @override
  String get saveAddress => 'Save Address';

  @override
  String get pleaseEnterRecipientName => 'Please enter recipient name';

  @override
  String get pleaseEnterHouseNo => 'Please enter house/flat number';

  @override
  String get required => 'Required';

  @override
  String get pleaseSelectLocation => 'Please select a location on the map';

  @override
  String get ourStory => 'Our Story';

  @override
  String get ourMission => 'Our Mission';

  @override
  String get ourVision => 'Our Vision';

  @override
  String get ourCoreValues => 'Our Core Values';

  @override
  String get trustTransparency => 'Trust & Transparency';

  @override
  String get qualityFirst => 'Quality First';

  @override
  String get customerCentricity => 'Customer Centricity';

  @override
  String get sustainability =>
      'Local First';

  @override
  String get innovation => 'Innovation';

  @override
  String get whatWeOffer => 'What We Offer';

  @override
  String get ourImpact =>
      'Why Shop with Taksh';

  @override
  String get aboutHighlightLocal =>
      'Local Sellers';

  @override
  String get aboutHighlightReturns =>
      'Easy Returns';

  @override
  String get aboutHighlightCod =>
      'Cash on Delivery';

  @override
  String get aboutHighlightPayments =>
      'Secure Payments';

  @override
  String get aboutHighlightDelivery =>
      'Flexible Delivery';

  @override
  String get aboutHighlightExpress =>
      '30-Min Express';

  @override
  String get happyCustomers => 'Happy Customers';

  @override
  String get products => 'Products';

  @override
  String get brands => 'Brands';

  @override
  String get cities => 'Cities';

  @override
  String get rating => 'Rating';

  @override
  String get getInTouch => 'Get in Touch';

  @override
  String redirectingToCart(String seconds) {
    return 'Redirecting to cart in $seconds seconds';
  }

  @override
  String errorCode(String code) {
    return 'Error Code: $code';
  }

  @override
  String get backToHome => 'Back to Home';

  @override
  String get orderNumberLabel => 'Order Number';

  @override
  String get searchForProducts => 'Search for products';

  @override
  String get searchForProductsHint => 'Search for products';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Search';

  @override
  String get productDetails => 'Product Details';

  @override
  String get searchProducts => 'Search Products';

  @override
  String get quick => 'Quick';

  @override
  String get services => 'Services';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get standard => 'Standard';

  @override
  String get failedToLoadAddresses => 'Failed to load addresses';

  @override
  String get couldNotDeleteAddress =>
      'Could not delete the address. Please try again.';

  @override
  String get couldNotUpdateAddress =>
      'Could not update the address. Please try again.';

  @override
  String get couldNotAddAddress =>
      'Could not add the address. Please try again.';

  @override
  String get couldNotSetDefaultAddress =>
      'Could not set the default address. Please try again.';

  @override
  String get delete => 'Delete';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String get enable => 'Enable';

  @override
  String get enableLocation => 'Enable Location';

  @override
  String get home => 'Home';

  @override
  String get locationEnabledMessage =>
      'Location enabled! Showing nearby stores...';

  @override
  String get nearbyStores => 'Nearby Stores';

  @override
  String get findNearbyStores => 'Find Nearby Stores';

  @override
  String get loadingNearbyStores => 'Loading nearby stores...';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get useCurrentLocation => 'Use Current Location';

  @override
  String get autoDetectLocation => 'Auto-detect your delivery address';

  @override
  String get yourAppContent => 'Your App Content';

  @override
  String get settings => 'Settings';

  @override
  String get locationServices => 'Location Services';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get disableLocation => 'Disable Location';

  @override
  String get ok => 'OK';

  @override
  String get locationAccess => 'Location Access';

  @override
  String get notNow => 'Not Now';

  @override
  String get allow => 'Allow';

  @override
  String get locationPermissionRequired => 'Location Permission Required';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get permissionPermanentlyDenied => 'Permission Permanently Denied';

  @override
  String get appSettings => 'App Settings';

  @override
  String get locationServicesDisabled => 'Location Services Disabled';

  @override
  String get allowLocationAccess => 'Allow Location Access';

  @override
  String get permissionUIComponents => 'Location Permission UI Components';

  @override
  String get showBottomSheet => 'Show Bottom Sheet';

  @override
  String get showRationaleDialog => 'Show Rationale Dialog';

  @override
  String get showSettingsDialog => 'Show Settings Dialog';

  @override
  String get requestPermissionFullFlow => 'Request Permission (Full Flow)';

  @override
  String get getCurrentLocation => 'Get Current Location';

  @override
  String get locationPermissionGranted => 'Location permission granted';

  @override
  String get grantLocationPermission => 'Grant Location Permission';

  @override
  String get dataAlreadyLoaded => 'Data already loaded - instant display!';

  @override
  String get searchSavedAddresses => 'Search saved addresses';

  @override
  String get searchCategories => 'Search categories...';

  @override
  String get searchRestaurantsDishes => 'Search for restaurants, dishes...';

  @override
  String get searchAreaStreetName => 'Search for area, street name...';

  @override
  String get joinAsVendorTitle => 'Join as Vendor';

  @override
  String get vendorFillDetails =>
      'Fill in your vendor shop details. Required fields are marked with *';

  @override
  String get vendorShopDetails => 'Shop Details';

  @override
  String get vendorShopDetailsSubtitle => 'Enter your shop information';

  @override
  String get vendorOwnerDetails => 'Owner Details';

  @override
  String get vendorOwnerDetailsSubtitle => 'Enter owner information';

  @override
  String get vendorDocuments => 'Documents';

  @override
  String get vendorDocumentsSubtitle =>
      'Upload required documents for verification';

  @override
  String get vendorShopName => 'Shop Name';

  @override
  String get vendorShopNameHint => 'Enter shop name';

  @override
  String get vendorShopAddress => 'Shop Address';

  @override
  String get vendorShopAddressHint => 'Enter complete shop address';

  @override
  String get vendorShopPincode => 'Shop Pincode';

  @override
  String get vendorShopPincodeHint => 'Enter 6-digit pincode';

  @override
  String get vendorShopLocation => 'Shop Location *';

  @override
  String get vendorShopImages => 'Shop Images *';

  @override
  String get vendorShopImagesSubtitle => 'Upload up to 5 shop images';

  @override
  String get vendorOwnerName => 'Owner Name';

  @override
  String get vendorOwnerNameHint => 'Enter owner full name';

  @override
  String get vendorOwnerAddress => 'Owner Address';

  @override
  String get vendorOwnerAddressHint => 'Enter complete owner address';

  @override
  String get vendorOwnerPincode => 'Owner Pincode';

  @override
  String get vendorOwnerPincodeHint => 'Enter 6-digit pincode';

  @override
  String get vendorOwnerLocation => 'Owner Location *';

  @override
  String get vendorMobileNumber => 'Mobile Number';

  @override
  String get vendorMobileNumberHint => 'Enter 10-digit mobile number';

  @override
  String get vendorEmailId => 'Email ID';

  @override
  String get vendorEmailIdHint => 'Enter email address';

  @override
  String get vendorOwnerImages => 'Owner Images *';

  @override
  String get vendorOwnerImagesSubtitle => 'Upload up to 2 owner images';

  @override
  String get vendorPickLocation => 'Pick Location from Map';

  @override
  String get vendorAadharCard => 'Aadhar Card';

  @override
  String get vendorPanCard => 'PAN Card';

  @override
  String get vendorBankAccount => 'Bank Account';

  @override
  String get vendorGstNumber => 'GST Number';

  @override
  String get vendorNonGstCertificate => 'Non GST Certificate';

  @override
  String get vendorNonGstCertificateSubtitle => 'Upload Non GST certificate';

  @override
  String get vendorMsmeCertificate => 'MSME Certificate';

  @override
  String get vendorMsmeCertificateSubtitle =>
      'Upload MSME certificate (if applicable)';

  @override
  String get vendorFssaiCertificate => 'FSSAI Certificate *';

  @override
  String get vendorFssaiCertificateSubtitle =>
      'Upload FSSAI license for food businesses';

  @override
  String get vendorShopAgreement => 'Shop Agreement';

  @override
  String get vendorShopAgreementSubtitle => 'Upload shop agreement (optional)';

  @override
  String get vendorSubmitApplication => 'Submit Application';

  @override
  String get vendorAadharDetails => 'Aadhar Details';

  @override
  String get vendorAadharNumber => 'Aadhar Number *';

  @override
  String get vendorAadharNumberHint => 'Enter 12-digit Aadhar number';

  @override
  String get vendorAadharDocument => 'Aadhar Number Document *';

  @override
  String get vendorPanDetails => 'PAN Details';

  @override
  String get vendorPanCardNumber => 'PAN Card Number *';

  @override
  String get vendorPanCardNumberHint =>
      'Enter PAN card number (e.g., ABCDE1234F)';

  @override
  String get vendorPanDocument => 'PAN Card Number Document *';

  @override
  String get vendorBankDetails => 'Bank Details';

  @override
  String get vendorAccountNumber => 'Account Number *';

  @override
  String get vendorAccountNumberHint => 'Enter bank account number';

  @override
  String get vendorIfscCode => 'IFSC Code *';

  @override
  String get vendorIfscCodeHint => 'Enter IFSC code';

  @override
  String get vendorAccountHolderName => 'Account Holder Name *';

  @override
  String get vendorAccountHolderNameHint => 'Enter account holder name';

  @override
  String get vendorBankName => 'Bank Name *';

  @override
  String get vendorBankNameHint => 'Enter bank name (optional)';

  @override
  String get vendorBranchName => 'Branch Name';

  @override
  String get vendorBranchNameHint => 'Enter branch name (optional)';

  @override
  String get vendorUploadBankProof => 'Upload Bank Proof';

  @override
  String get vendorUploadBankProofSubtitle =>
      'Upload either Bank Passbook or Cancelled Cheque';

  @override
  String get vendorBankDocument => 'Bank Document *';

  @override
  String get vendorGstDetails => 'GST Details';

  @override
  String get vendorGstNumberLabel => 'GST Number *';

  @override
  String get vendorGstNumberHint => 'Enter 15-digit GST number';

  @override
  String get vendorGstDocument => 'GST Number Document *';

  @override
  String get vendorSaveAndVerify => 'Save & Verify';

  @override
  String get vendorUploadDocument => 'Upload Document';

  @override
  String get vendorUploadDocumentHint => 'PDF, JPG, PNG (Max 5MB)';

  @override
  String get vendorAddImage => 'Add';

  @override
  String get vendorJoinSuccess => 'Vendor application submitted successfully!';

  @override
  String get vendorShopNameRequired => 'Shop name is required';

  @override
  String get vendorShopLocationRequired => 'Shop location is required';

  @override
  String get vendorShopImagesRequired => 'At least one shop image is required';

  @override
  String get vendorOwnerLocationRequired => 'Owner location is required';

  @override
  String get vendorOwnerImagesRequired =>
      'At least one owner image is required';

  @override
  String get vendorOwnerImageRequired => 'Owner image is required';

  @override
  String get vendorVendorDetails => 'Vendor Details';

  @override
  String get vendorVendorDetailsSubtitle =>
      'Enter your vendor registration details';

  @override
  String get vendorVendorName => 'Vendor Name';

  @override
  String get vendorVendorNameHint => 'Enter vendor/store name';

  @override
  String get vendorVendorNameRequired => 'Vendor name is required';

  @override
  String get vendorAddress => 'Address';

  @override
  String get vendorAddressHint => 'Enter vendor address';

  @override
  String get vendorAddressRequired => 'Address is required';

  @override
  String get vendorPincode => 'Pincode';

  @override
  String get vendorPincodeHint => 'Enter pincode';

  @override
  String get vendorPincodeRequired => 'Pincode is required';

  @override
  String get vendorStateId => 'State';

  @override
  String get vendorStateIdHint => 'Enter state ID';

  @override
  String get vendorStateIdRequired => 'State is required';

  @override
  String get vendorCityId => 'City';

  @override
  String get vendorCityIdHint => 'Enter city ID';

  @override
  String get vendorCityIdRequired => 'City is required';

  @override
  String get vendorOwnerImage => 'Owner Image *';

  @override
  String get vendorOwnerImageSubtitle => 'Upload owner photo';

  @override
  String get vendorShopAddressRequired => 'Shop address is required';

  @override
  String get vendorShopPincodeRequired => 'Shop pincode is required';

  @override
  String get vendorOwnerNameRequired => 'Owner name is required';

  @override
  String get vendorOwnerAddressRequired => 'Owner address is required';

  @override
  String get vendorOwnerPincodeRequired => 'Owner pincode is required';

  @override
  String get vendorMobileNumberRequired => 'Mobile number is required';

  @override
  String get vendorEmailRequired => 'Email is required';

  @override
  String get vendorAadhaarNumberRequired => 'Aadhaar number is required';

  @override
  String get vendorAadhaarFileRequired => 'Aadhaar document is required';

  @override
  String get vendorPanFileRequired => 'PAN document is required';

  @override
  String get vendorBankFileRequired => 'Bank document is required';

  @override
  String get vendorGstFileRequired => 'GST document is required';

  @override
  String get vendorGstOrNonGstRequired =>
      'Upload either GST document or Non-GST certificate';

  @override
  String get vendorFssaiFileRequired => 'FSSAI certificate is required';

  @override
  String get chooseHowToReachUs => 'Choose how you\'d like to reach us';

  @override
  String get requestCallback => 'Request Callback';

  @override
  String get requestCallbackDescription => 'Get a call from our support team';

  @override
  String get emailSupport => 'Email Support';

  @override
  String get emailSupportDescription =>
      'Send us an email at customersupport@takshallinone.in';

  @override
  String get emailAppError =>
      'Could not open email app. Please email us at customersupport@takshallinone.in';

  @override
  String get myWishlist => 'My Wishlist';

  @override
  String get addedToWishlist => 'Added to wishlist';

  @override
  String get removedFromWishlist => 'Removed from wishlist';

  @override
  String get wishlistEmpty => 'Your wishlist is empty';

  @override
  String get wishlistEmptySubtitle =>
      'Browse products and add your favorites here';

  @override
  String get removeFromWishlistConfirm => 'Remove from wishlist?';

  @override
  String get failedToLoadWishlist => 'Failed to load wishlist';

  @override
  String get couldNotAddToCart =>
      'Could not add item to cart. Please try again.';

  @override
  String get couldNotLoadProduct =>
      'Could not load product details. Please try again.';

  @override
  String get noVariantsAvailable => 'This product is currently unavailable.';

  @override
  String get cartUnexpectedError => 'Something went wrong. Please try again.';

  @override
  String get checkDeliveryAvailability => 'Check Delivery Availability';

  @override
  String get invalidPincode => 'Please enter a valid 6-digit pincode';

  @override
  String get check => 'Check';

  @override
  String fulfilledBy(String shopName) {
    return 'Fulfilled by $shopName';
  }

  @override
  String get couldNotCheckDelivery =>
      'Could not check delivery availability. Please try again.';

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
  String get customerAndPickupDetails => 'Customer & Pickup Details';

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
  String get packagingDetails => 'Packaging Details';

  @override
  String get enterProductDetails => 'Enter product name and details';

  @override
  String get enterPackagingDetails => 'Envelope, box, etc.';

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
    return 'Login to view $contentLabel';
  }

  @override
  String guestWallSubtitle(String contentLabel) {
    return 'Sign in to access $contentLabel and enjoy a personalised shopping experience with order tracking, saved addresses, and more.';
  }

  @override
  String get guestWallLoginButton => 'Login to Continue';

  @override
  String get guestWallContinueBrowsing => 'Continue browsing as guest';

  @override
  String get loginCancelButton => 'Cancel';

  @override
  String get orderReview => 'Review Order';

  @override
  String get reviewYourOrder => 'Review your order before confirming';

  @override
  String get reviewOrderDescription =>
      'Please verify the details below and tap \"Confirm Order\" to place your order.';

  @override
  String get confirmOrder => 'Confirm Order';

  @override
  String get confirmingOrder => 'Placing your order...';

  @override
  String get deliveryTo => 'Delivering to';

  @override
  String get payment => 'Payment';

  @override
  String get orderSummaryTitle => 'Order Summary';

  @override
  String get itemTotal => 'Item Total';

  @override
  String get platformFees => 'Platform Fees';

  @override
  String get otherChargesLabel => 'Other Charges';

  @override
  String get orderPlacedTitle => 'Order Placed';

  @override
  String get orderPlacedSubtitle =>
      'Your order has been placed successfully. Pay on delivery.';

  @override
  String get orderPlacedOnlineSubtitle =>
      'Your order has been placed successfully. Redirecting to payment...';

  @override
  String get thankYouForOrder => 'Thank you for your order!';

  @override
  String get viewMyOrders => 'View My Orders';

  @override
  String get back => 'Back';

  @override
  String get readMore => 'Read more';

  @override
  String get readLess => 'Read less';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get onboardingTitle1 => 'Shop everything you need';

  @override
  String get onboardingSubtitle1 =>
      'Discover thousands of products from local stores, delivered straight to your door.';

  @override
  String get onboardingTitle2 => 'Fast & reliable delivery';

  @override
  String get onboardingSubtitle2 =>
      'Track your orders in real-time and get them delivered in minutes, not days.';

  @override
  String get onboardingTitle3 => 'Safe & secure payments';

  @override
  String get onboardingSubtitle3 =>
      'Pay with confidence using trusted payment methods, every single time.';

  @override
  String get exitAppSavedNote => 'Your shopping cart and progress will be saved.';

  @override
  String get cartEmptyDescription => 'Looks like you haven\'t added anything yet.\nStart exploring our wide range of products.';

  @override
  String get splashPreparing => 'Preparing the best shopping experience for you';

  @override
  String get trustFastDelivery => 'Fast Delivery';

  @override
  String get trustSecureShopping => 'Secure Shopping';

  @override
  String get trustQualityProducts => 'Quality Products';

  @override
  String get trustByIndia => 'Trusted by India';

  @override
  String get trustWideSelection => 'Wide Selection';

  @override
  String get trustBestPrices => 'Best Prices';

  @override
  String get trustSecurePayment => 'Secure Payment';

  @override
  String get quickNoCategories => 'No Quick delivery categories are available for this address yet.';

  @override
  String get quickLocationNeededTitle => 'Select a delivery address';

  @override
  String get quickLocationNeededBody => 'Quick delivery needs a delivery address with a map location. Choose or add one to see what is available near you.';

  @override
  String get quickNotServiceableTitle => 'Quick delivery isn\'t available here';

  @override
  String get quickNotServiceableDefault => 'Quick delivery is not available at this address right now. You can change the address or use Standard delivery.';

  @override
  String get changeAddress => 'Change address';

  @override
  String get quickCheckoutUnavailable => 'Quick delivery can\'t be confirmed for this address right now. Please change the address or choose Standard delivery.';

  @override
  String get quickDeliveryNearbyStore => 'Quick delivery from a nearby store';

  @override
  String get loginRequiredTitle => 'Login required';

  @override
  String get loginToAddToCart => 'Please login to add items to your cart.';

  @override
  String get quickAvailabilityTitle => 'Availability';

  @override
  String get quickAvailabilityChecking => 'Checking availability at your address…';

  @override
  String get quickAvailabilityAvailable => 'Available for Quick delivery at your address';

  @override
  String get quickAvailabilityNotInArea => 'This product is not available in your area right now.';

  @override
  String get quickAvailabilityOutOfStock => 'This product is out of stock right now.';

  @override
  String get quickAvailabilityLocationRequired => 'Select an address with a map location to check availability.';

  @override
  String get quickAvailabilityUnavailable => 'This product is not available for Quick delivery right now.';

  @override
  String get quickAvailabilityFailed => 'We could not check availability. Please try again.';

  @override
  String get quickBadgeNotInArea => 'Not in your area';

  @override
  String get quickCatalogueFallbackNotice => 'Quick delivery is not available at this address. You can still browse these products.';

  @override
  String multiOrderTitle(int count) {
    return 'Your items are split into $count orders';
  }

  @override
  String get multiOrderSubtitle => 'Each shop prepares and delivers its own order.';

  @override
  String checkoutSplitNotice(int count) {
    return 'Your items are from $count shops, so $count separate orders will be placed.';
  }

  @override
  String orderOfTotal(int index, int total) {
    return 'Order $index of $total';
  }

  @override
  String get notificationPermissionTitle => 'Turn on notifications';

  @override
  String get notificationPermissionMessage => 'Allow notifications to get order updates, payment confirmations and offers from Taksh. You can turn them on in your device settings.';
}
