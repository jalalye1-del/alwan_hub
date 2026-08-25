import 'home_feature_link.dart';

abstract interface class HomeFeatureLinkRepository {
  Stream<List<HomeFeatureLink>> watchLinks();
}
