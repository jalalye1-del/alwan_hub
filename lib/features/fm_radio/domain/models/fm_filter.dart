enum FmFilter {
  all,
  yemeni,
  arabic,
  world,
  religious,
}

extension FmFilterExtension on FmFilter {
  String get title {
    switch (this) {
      case FmFilter.all:
        return 'الكل';

      case FmFilter.yemeni:
        return '🇾🇪 يمنية';

      case FmFilter.arabic:
        return '🌍 عربية';

      case FmFilter.world:
        return '🌐 عالمية';

      case FmFilter.religious:
        return '🕌 دينية';
    }
  }
}