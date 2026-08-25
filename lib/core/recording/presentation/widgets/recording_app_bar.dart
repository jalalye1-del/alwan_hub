import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/core/recording/providers/recording_providers.dart';

class RecordingAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const RecordingAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordingNotifierProvider);
    final notifier = ref.read(recordingNotifierProvider.notifier);

    if (state.selectionMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'إلغاء التحديد',
          onPressed: notifier.clearSelection,
        ),
        title: Text('${state.selectedCount} محدد'),
        actions: [
          IconButton(
            tooltip: 'تحديد الكل',
            onPressed: notifier.selectAll,
            icon: const Icon(Icons.select_all),
          ),
        ],
      );
    }

    return AppBar(
      title: const Text('التسجيلات'),
      centerTitle: true,
      actions: const [RecordingActionsMenu()],
    );
  }
}

class RecordingActionsMenu extends ConsumerWidget {
  const RecordingActionsMenu({super.key});

  Future<void> _createFolder(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إنشاء مجلد جديد'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'اسم المجلد',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              controller.text.trim(),
            ),
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (name == null || name.isEmpty || !context.mounted) return;
    final created = await ref
        .read(recordingNotifierProvider.notifier)
        .createFolder(name);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          created ? 'تم إنشاء مجلد $name.' : 'المجلد موجود مسبقاً.',
        ),
      ),
    );
  }

  Future<void> _deleteAll(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف جميع التسجيلات'),
        content: const Text(
          'سيتم حذف جميع ملفات التسجيل نهائياً، هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(recordingNotifierProvider.notifier).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف جميع التسجيلات.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasRecordings = ref.watch(
      recordingNotifierProvider.select((state) => state.recordings.isNotEmpty),
    );

    return PopupMenuButton<_RecordingMenuAction>(
      tooltip: 'إدارة التسجيلات',
      icon: const Icon(Icons.playlist_add_check_circle_outlined),
      onSelected: (action) async {
        final notifier = ref.read(recordingNotifierProvider.notifier);
        switch (action) {
          case _RecordingMenuAction.selectAll:
            notifier.selectAll();
          case _RecordingMenuAction.createFolder:
            await _createFolder(context, ref);
          case _RecordingMenuAction.deleteAll:
            await _deleteAll(context, ref);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _RecordingMenuAction.selectAll,
          enabled: hasRecordings,
          child: const ListTile(
            leading: Icon(Icons.select_all),
            title: Text('تحديد كل الملفات'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: _RecordingMenuAction.createFolder,
          child: ListTile(
            leading: Icon(Icons.create_new_folder_outlined),
            title: Text('إنشاء مجلد'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _RecordingMenuAction.deleteAll,
          enabled: hasRecordings,
          child: const ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
            title: Text('حذف الكل', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

enum _RecordingMenuAction {
  selectAll,
  createFolder,
  deleteAll,
}
