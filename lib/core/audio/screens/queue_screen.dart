// lib/core/audio/screens/queue_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/core/audio/providers/audio_provider.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioPlayerProvider);
    final notifier = ref.read(audioPlayerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text(
          'قائمة التشغيل',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: state.queue.isEmpty
          ? const Center(
              child: Text(
                'قائمة التشغيل فارغة حالياً',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          // 🟢 استخدام onReorderItem المتوافقة مع الإصدارات الحديثة
          : ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.queue.length,
              onReorderItem: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                // notifier.reorderQueue(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final track = state.queue[index];
                final selected = index == state.currentIndex;

                final image = track.presenterImage ?? track.programImage ?? track.imageUrl;

                return Container(
                  key: ValueKey('${track.id}_$index'),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFEEF2FF) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? const Color(0xFF2A1AD8).withValues(alpha: 0.3) : Colors.transparent,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    selected: selected,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 52,
                        height: 52,
                        child: image != null && image.isNotEmpty
                            ? (image.startsWith('http')
                                // 🟢 استبدال الشرطات السفلية بأسماء واضحة لتجنب تحذيرات الـ Linter
                                ? Image.network(
                                    image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Image.asset(
                                      'assets/images/program.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.asset(
                                    image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Image.asset(
                                      'assets/images/program.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ))
                            : Image.asset(
                                'assets/images/program.jpg',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    title: Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                        fontSize: 14,
                        color: selected ? const Color(0xFF2A1AD8) : const Color(0xFF1F2142),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        track.presenterName ?? track.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.equalizer, color: Color(0xFF2A1AD8)),
                          ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
                          onPressed: () {
                            // notifier.removeTrackFromQueue(index);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      notifier.skipToQueueItem(index);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
    );
  }
}