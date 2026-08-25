// lib/core/recording/presentation/widgets/recording_search_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/core/recording/providers/recording_provider.dart';
import 'package:alwan_hub/core/recording/providers/recording_notifier.dart';
class RecordingSearchBar extends ConsumerStatefulWidget {
  const RecordingSearchBar({super.key});

  @override
  ConsumerState<RecordingSearchBar> createState() => _RecordingSearchBarState();
}

class _RecordingSearchBarState extends ConsumerState<RecordingSearchBar> {
  final TextEditingController _controller = TextEditingController();
  ProviderSubscription? _searchSubscription;

  @override
  void initState() {
    super.initState();
    
    // 🟢 تسجيل المستمع مرة واحدة فقط خارج دورة البناء (Build)
    _searchSubscription = ref.listenManual(
      recordingNotifierProvider.select((state) => state.searchQuery),
      (previous, next) {
        if (next.isEmpty && _controller.text.isNotEmpty) {
          _controller.clear();
        }
      },
    );
  }

  @override
  void dispose() {
    // 🟢 إغلاق المستمع يدوياً لتنظيف الذاكرة
    _searchSubscription?.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = ref.read(recordingNotifierProvider.notifier);

    // مراقبة نص البحث فقط لتحديث حالة أيقونة الحذف (X)
    final searchQuery = ref.watch(
      recordingNotifierProvider.select((state) => state.searchQuery),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _controller,
        onChanged: notifier.search,
        decoration: InputDecoration(
          hintText: 'ابحث عن تسجيل...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    notifier.clearSearch();
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}