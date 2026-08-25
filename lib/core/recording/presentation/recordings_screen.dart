import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/audio/providers/audio_provider.dart';
import 'package:alwan_hub/core/recording/models/recording_file.dart';
import 'package:alwan_hub/core/recording/providers/recording_providers.dart';
import 'package:alwan_hub/core/recording/providers/recording_state.dart';
import 'package:alwan_hub/core/router/app_router.dart';

import 'widgets/recording_app_bar.dart';
import 'widgets/recording_empty_view.dart';
import 'widgets/recording_loading.dart';
import 'widgets/recording_search_bar.dart';
import 'widgets/recording_card.dart';
import 'widgets/recording_selection_bar.dart';

class RecordingsScreen extends ConsumerStatefulWidget {
  const RecordingsScreen({
    super.key,
    this.embedded = false,
  });

  final bool embedded;

  @override
  ConsumerState<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends ConsumerState<RecordingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(recordingNotifierProvider.notifier).loadRecordings(),
    );
  }

  Future<void> _refresh() async {
    await ref.read(recordingNotifierProvider.notifier).refresh();
  }

  Future<void> _playRecording(RecordingFile recording) async {
    await ref.read(audioPlayerProvider.notifier).play(
      AudioTrack(
        id: 'recording-${recording.id}',
        title: recording.title,
        subtitle: recording.folderName,
        url: recording.filePath,
        imageUrl: recording.imageUrl,
        sourceType: AudioSourceType.local,
        category: 'التسجيلات',
        duration: recording.duration,
      ),
    );

    if (!mounted) return;
    if (ref.read(audioPlayerProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تشغيل ملف التسجيل.')),
      );
      return;
    }
    await context.push(AppRoutes.playerPath);
  }

  Future<void> _showRecordingActions(RecordingFile recording) async {
    final action = await showModalBottomSheet<_RecordingFileAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionTile(
              sheetContext,
              Icons.share_outlined,
              'المشاركة',
              _RecordingFileAction.share,
            ),
            _actionTile(
              sheetContext,
              Icons.edit_outlined,
              'تغيير الاسم',
              _RecordingFileAction.rename,
            ),
            _actionTile(
              sheetContext,
              Icons.drive_file_move_outline,
              'نقل الملف',
              _RecordingFileAction.move,
            ),
            _actionTile(
              sheetContext,
              Icons.check_circle_outline,
              'تحديد',
              _RecordingFileAction.select,
            ),
            _actionTile(
              sheetContext,
              Icons.delete_outline,
              'حذف',
              _RecordingFileAction.delete,
              destructive: true,
            ),
          ],
        ),
      ),
    );

    if (action == null || !mounted) return;
    switch (action) {
      case _RecordingFileAction.share:
        await _shareRecording(recording);
      case _RecordingFileAction.rename:
        await _renameRecording(recording);
      case _RecordingFileAction.move:
        await _moveRecording(recording);
      case _RecordingFileAction.delete:
        await _deleteRecording(recording);
      case _RecordingFileAction.select:
        ref
            .read(recordingNotifierProvider.notifier)
            .toggleSelection(recording.id);
    }
  }

  Widget _actionTile(
    BuildContext sheetContext,
    IconData icon,
    String title,
    _RecordingFileAction action, {
    bool destructive = false,
  }) {
    final color = destructive ? Colors.red : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: () => Navigator.pop(sheetContext, action),
    );
  }

  Future<void> _shareRecording(RecordingFile recording) async {
    try {
      await ref.read(storageServiceProvider).shareRecording(recording);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذرت المشاركة: $error')),
        );
      }
    }
  }

  Future<void> _renameRecording(RecordingFile recording) async {
    final controller = TextEditingController(text: recording.title);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تغيير اسم التسجيل'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(border: OutlineInputBorder()),
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
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;

    await ref
        .read(recordingNotifierProvider.notifier)
        .renameRecording(recording.id, name);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تغيير اسم التسجيل.')),
      );
    }
  }

  Future<void> _moveRecording(RecordingFile recording) async {
    final folders = ref.read(recordingNotifierProvider).folders;
    final destination = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('نقل الملف إلى'),
        children: folders
            .map(
              (folder) => SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, folder),
                child: ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(folder),
                  trailing: folder == recording.folderName
                      ? const Icon(Icons.check)
                      : null,
                ),
              ),
            )
            .toList(),
      ),
    );
    if (destination == null || destination == recording.folderName) return;

    await ref.read(recordingNotifierProvider.notifier).moveRecording(
      id: recording.id,
      folder: destination,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم نقل التسجيل إلى $destination.')),
      );
    }
  }

  Future<void> _deleteRecording(RecordingFile recording) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف التسجيل'),
        content: Text('هل تريد حذف "${recording.title}" نهائياً؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref
        .read(recordingNotifierProvider.notifier)
        .deleteRecording(recording.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف التسجيل.')),
      );
    }
  }

  Widget _buildFolders(RecordingState state) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          ChoiceChip(
            label: const Text('الكل'),
            selected: state.selectedFolder == null,
            onSelected: (_) => ref
                .read(recordingNotifierProvider.notifier)
                .selectFolder(null),
          ),
          const SizedBox(width: 8),
          ...state.folders.map(
            (folder) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                avatar: const Icon(Icons.folder_outlined, size: 18),
                label: Text(folder),
                selected: state.selectedFolder == folder,
                onSelected: (_) => ref
                    .read(recordingNotifierProvider.notifier)
                    .selectFolder(folder),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recordingNotifierProvider);

    final content = SafeArea(
      child: Column(
        children: [
          if (widget.embedded)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: [
                  Text(
                    'تسجيلاتي',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  RecordingActionsMenu(),
                ],
              ),
            ),
          _buildFolders(state),
          const RecordingSearchBar(),
          if (state.selectionMode) const RecordingSelectionBar(),
          Expanded(
            child: Builder(
              builder: (_) {
                if (state.isLoading) {
                  return const RecordingLoading();
                }
                if (state.filteredRecordings.isEmpty) {
                  return const RecordingEmptyView();
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.filteredRecordings.length,
                    itemBuilder: (context, index) {
                      final recording = state.filteredRecordings[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: RecordingCard(
                          recording: recording,
                          selected: state.selectedIds.contains(recording.id),
                          selectionMode: state.selectionMode,
                          onTap: () {
                            if (state.selectionMode) {
                              ref
                                  .read(recordingNotifierProvider.notifier)
                                  .toggleSelection(recording.id);
                            } else {
                              _playRecording(recording);
                            }
                          },
                          onLongPress: () => ref
                              .read(recordingNotifierProvider.notifier)
                              .toggleSelection(recording.id),
                          onMore: () => _showRecordingActions(recording),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    if (widget.embedded) return content;

    return Scaffold(
      appBar: const RecordingAppBar(),
      body: content,
    );
  }
}

enum _RecordingFileAction {
  share,
  rename,
  move,
  delete,
  select,
}
