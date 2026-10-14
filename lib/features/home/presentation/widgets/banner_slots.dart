import 'package:taksh_e_commerce/features/home/data/models/banner_model.dart';

/// Where a banner is rendered on a home tab (standard / quick / service).
///
/// Mapped from the admin panel's banner `position`:
/// `home_top` / `dashboard` → [top], `home_middle` → [middle],
/// `home_bottom` → [bottom]. Unknown values fall back to [top] so a banner is
/// never lost.
enum BannerSlot { top, middle, bottom }

BannerSlot bannerSlotFor(String position) {
  switch (position) {
    case 'home_middle':
      return BannerSlot.middle;
    case 'home_bottom':
      return BannerSlot.bottom;
    default:
      return BannerSlot.top;
  }
}

/// Splits [banners] by slot, keeping the API order (admin `sort_order`) inside
/// each slot.
Map<BannerSlot, List<BannerModel>> groupBannersBySlot(
  Iterable<BannerModel> banners,
) {
  final grouped = {for (final slot in BannerSlot.values) slot: <BannerModel>[]};
  for (final banner in banners) {
    grouped[bannerSlotFor(banner.position)]!.add(banner);
  }
  return grouped;
}
