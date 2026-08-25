// lib/core/recording/presentation/widgets/recording_selection_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:alwan_hub/core/recording/providers/recording_provider.dart';

class RecordingSelectionBar extends ConsumerWidget {
  const RecordingSelectionBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. مراقبة جزء الحالة المطلوب فقط لتحسين الأداء
    final selectionState = ref.watch(
      recordingNotifierProvider.select(
        (state) => (
          selectedCount: state.selectedCount,
          hasSelection: state.hasSelection,
        ),
      ),
    );
    
    final notifier = ref.read(recordingNotifierProvider.notifier);
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.primaryContainer,
      child: SafeArea(
        bottom: false,
        // 3. استبدال Container بـ SizedBox مع Padding
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'إلغاء التحديد',
                  onPressed: notifier.clearSelection,
                  icon: const Icon(Icons.close),
                ),

                Expanded(
                  child: Text(
                    '${selectionState.selectedCount} عنصر محدد',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    // حماية إضافية من تجاوز النص للشاشات الصغيرة
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                IconButton(
                  tooltip: 'تحديد الكل',
                  onPressed: notifier.selectAll,
                  icon: const Icon(
                    Icons.select_all,
                  ),
                ),

                IconButton(
                  tooltip: 'مشاركة',
                  onPressed: selectionState.hasSelection
                      ? () async {
                          final state = ref.read(recordingNotifierProvider);
                          final selectedRecordings = state.recordings
                              .where((r) => state.selectedIds.contains(r.id))
                              .toList();
                          
                          if (selectedRecordings.isNotEmpty) {
                            await SharePlus.instance.share(
                              ShareParams(
                                text: 'مشاركة التسجيلات المحددة من تطبيق ألوان هب',
                                files: selectedRecordings
                                    .map((recording) => XFile(recording.filePath))
                                    .toList(),
                              ),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(Icons.share),
                ),

                IconButton(
                  tooltip: 'نقل',
                  onPressed: selectionState.hasSelection
                      ? () async {
                          final state = ref.read(recordingNotifierProvider);
                          final destination = await showDialog<String>(
                            context: context,
                            builder: (dialogContext) => SimpleDialog(
                              title: const Text('نقل التسجيلات المحددة'),
                              children: state.folders
                                  .map(
                                    (folder) => SimpleDialogOption(
                                      onPressed: () => Navigator.pop(
                                        dialogContext,
                                        folder,
                                      ),
                                      child: ListTile(
                                        leading: const Icon(Icons.folder_outlined),
                                        title: Text(folder),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          );

                          if (destination != null && destination.isNotEmpty) {
                            await notifier.moveSelected(destination);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('تم نقل التسجيلات إلى $destination')),
                              );
                            }
                          }
                        }
                      : null,
                  icon: const Icon(Icons.drive_file_move),
                ),

                IconButton(
                  tooltip: 'حذف',
                  onPressed: selectionState.hasSelection
                      ? () async {
                          final count = selectionState.selectedCount;
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text(
                                'حذف التسجيلات',
                              ),
                              // 2. تحسين رسالة الحذف لتكون أكثر طبيعية
                              content: Text(
                                count == 1
                                    ? 'هل تريد حذف التسجيل المحدد؟'
                                    : 'هل تريد حذف $count تسجيلات؟',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text('إلغاء'),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: const Text('حذف'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await notifier.deleteSelected();
                          }
                        }
                      : null,
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
