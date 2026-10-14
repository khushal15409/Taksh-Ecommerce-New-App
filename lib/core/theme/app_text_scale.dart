/// Font-size scale measured from the Home Dashboard (the visual reference).
///
/// Dashboard widgets use 10–14sp for body/metadata and 16–18sp for section
/// headings (see `product_section.dart`, `product_card.dart`,
/// `category_catalog_section.dart`, `bottom_nav_bar.dart`). New and redesigned
/// screens should pick sizes from here instead of scattering literals, so
/// every page keeps the same hierarchy.
///
/// Sizes are in logical pixels and still scale with the user's system font
/// size setting (do not wrap text in `textScaler: TextScaler.noScaling`).
class AppTextScale {
  AppTextScale._();

  /// Page / hero title in a header (e.g. "My Cart", "Order Details").
  static const double pageTitle = 20;

  /// Section heading above a block of cards ("You may also like").
  static const double sectionTitle = 16;

  /// Card title / product name inside a card.
  static const double cardTitle = 14;

  /// Primary body text and list-row labels.
  static const double body = 13;

  /// Supporting text (SKU, subtitles, helper copy).
  static const double caption = 11.5;

  /// Small labels, chips and metadata.
  static const double label = 10.5;

  /// Prices in cards and summaries.
  static const double price = 14;

  /// Emphasised totals (grand total, amount to pay).
  static const double total = 18;

  /// Text inside buttons.
  static const double button = 14;
}

/// Button / control heights used across redesigned screens.
class AppControlSize {
  AppControlSize._();

  /// Full-width primary action (Proceed to Checkout, Place Order).
  static const double primaryButton = 45;

  /// Secondary / outlined actions inside cards.
  static const double compactButton = 36;

  /// Smallest tappable pill (quantity stepper, chips).
  static const double pill = 30;
}
