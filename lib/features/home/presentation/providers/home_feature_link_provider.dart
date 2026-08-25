import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/features/home/data/local_home_feature_link_repository.dart';
import 'package:alwan_hub/features/home/domain/home_feature_link.dart';
import 'package:alwan_hub/features/home/domain/home_feature_link_repository.dart';

/// Override with DashboardHomeFeatureLinkRepository when the managed-content
/// API is configured at application bootstrap.
final homeFeatureLinkRepositoryProvider = Provider<HomeFeatureLinkRepository>((
  ref,
) {
  return const LocalHomeFeatureLinkRepository();
});

final homeFeatureLinksProvider = StreamProvider<List<HomeFeatureLink>>((ref) {
  return ref.watch(homeFeatureLinkRepositoryProvider).watchLinks();
});
