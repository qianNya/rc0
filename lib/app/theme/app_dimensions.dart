abstract final class AppDimensions {
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;

  static const double pagePadding = 20;
  static const double bottomNavBrandIconSize = 20;
  static const double bottomNavBrandIconPadding = 8;
  static const double shellBarHeight =
      bottomNavBrandIconSize + bottomNavBrandIconPadding + spacingXs;
  static const double bottomNavHeight = shellBarHeight;
  static const double primaryButtonHeight = 48;

  static const double glassBlurSigma = 24;
  static const double glassNavBlurSigma = 16;
  static const double floatingBarRadius = 28;
  static const double floatingBarMarginHorizontal = 16;
  static const double floatingBarMarginBottom = 16;
  static const double topNavFloatingMarginTop = 8;
  static const double topNavFloatingMarginBottom = 12;
  static const double topNavFloatingRadius = 28;
  static const double bottomNavFloatingRadius = 32;
  static const double tabFloatingRadius = 32;
  static const double tabFloatingHeight = 56;
  static const double bottomNavFloatingHeight = 56;
  static const double bottomNavLiquidActiveOrbSize = 36;
  static const double bottomNavSecondaryTabSize = bottomNavFloatingHeight;
  static const double bottomNavSecondaryTabGap = spacingSm;
  static const double bottomNavIndicatorInsetH = 6;
  static const double bottomNavIndicatorInsetV = 6;
  /// Icon-only bottom-nav tab slot width.
  static const double bottomNavTabSlotWidth = 56;
  /// Horizontal padding inside the floating bottom-nav pill.
  static const double bottomNavBarInsetH = 6;
  /// Horizontal padding for labeled bottom-nav tabs (icon + caption).
  static const double bottomNavLabeledTabPaddingH = 14;
  /// Max width for centered floating bottom nav on tablet / wide phones.
  static const double floatingBottomNavMaxWidth = 420;
  static const double floatingBottomNavEditorMaxWidth = 560;

  static double bottomNavBarWidth(List<double> tabWidths) {
    if (tabWidths.isEmpty) return 0;
    final tabsWidth = tabWidths.fold<double>(0, (sum, width) => sum + width);
    return bottomNavBarInsetH * 2 + tabsWidth;
  }
  static const double floatingBottomClearance = 72;
  static const double feedTabBarHeight = 40;
  static const double titleBarHeight = 40;
  static const double macTitleBarLeadingInset = 72;
}
