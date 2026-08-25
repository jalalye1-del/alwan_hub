import 'package:flutter/material.dart' hide Text;
import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import 'package:alwan_hub/features/library/domain/entities/folder_type.dart';
import 'package:alwan_hub/features/library/domain/entities/library_category.dart';
import 'package:alwan_hub/features/library/domain/entities/library_item.dart';
import 'package:alwan_hub/features/library/domain/entities/library_item_type.dart';
import 'package:alwan_hub/features/library/domain/entities/user_folder.dart';
import 'package:alwan_hub/features/library/domain/repositories/library_repository.dart';
import 'package:alwan_hub/features/lounge/domain/models/audio_item.dart';

LibraryItem createLibraryItem(AudioItem track, String categoryId) {
  return LibraryItem(
    id: const Uuid().v4(),
    title: track.title,
    type: switch (categoryId) {
      'audio_books' => LibraryItemType.audiobook,
      'podcasts' => LibraryItemType.podcast,
      _ => LibraryItemType.music,
    },
    sourceId: track.id,
    localPath: track.audioUrl,
    createdAt: DateTime.now(),
    categoryId: categoryId,
  );
}

Future<void> shareAudioTrack(AudioItem track) async {
  await SharePlus.instance.share(
    ShareParams(
      text:
          'استمع إلى "${track.title}" بصوت ${track.artist} على تطبيق ألوان. ${track.audioUrl}',
    ),
  );
}

Future<void> showAddToLibraryBottomSheet(
  BuildContext context,
  AudioItem track,
  LibraryRepository repository,
  List<LibraryCategory> categories,
  String defaultCategoryId,
  Color primaryColor,
) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 24)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Text(
              'إضافة أغنية "${track.title}"',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            _MenuTile(
              icon: Icons.share_rounded,
              title: 'المشاركة',
              color: primaryColor,
              onTap: () async {
                Navigator.pop(sheetContext);
                await shareAudioTrack(track);
              },
            ),
            _MenuTile(
              icon: Icons.library_music_rounded,
              title: 'مكتبتي',
              subtitle: 'عرض جميع التصنيفات',
              color: primaryColor,
              showArrow: true,
              onTap: () {
                Navigator.pop(sheetContext);
                showLibraryCategoriesDialog(
                  context,
                  repository,
                  track,
                  categories,
                  primaryColor,
                  sourceCategoryId: defaultCategoryId,
                );
              },
            ),
            _MenuTile(
              icon: Icons.folder_copy_rounded,
              title: 'مجلداتي',
              subtitle: 'عرض المجلدات التي أنشأتها',
              color: primaryColor,
              showArrow: true,
              onTap: () {
                Navigator.pop(sheetContext);
                showSelectFolderDialog(
                  context,
                  repository,
                  track,
                  defaultCategoryId,
                  primaryColor,
                );
              },
            ),
            _MenuTile(
              icon: Icons.create_new_folder_rounded,
              title: 'إنشاء مجلد',
              subtitle: 'إنشاء مجلد وحفظ الملف بداخله',
              color: primaryColor,
              onTap: () {
                Navigator.pop(sheetContext);
                showCreateFolderDialog(
                  context,
                  repository,
                  track,
                  defaultCategoryId,
                  primaryColor,
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showLibraryCategoriesDialog(
  BuildContext context,
  LibraryRepository repository,
  AudioItem track,
  List<LibraryCategory> categories,
  Color primaryColor, {
  String? sourceCategoryId,
}) async {
  final availableCategories =
      categories.where((category) => category.acceptsItems).toList()
        ..sort((first, second) => first.order.compareTo(second.order));

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (dialogContext) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(dialogContext).height * .72,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر تصنيفًا من مكتبتي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              if (availableCategories.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('لا توجد تصنيفات متاحة حاليًا.'),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: availableCategories.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final category = availableCategories[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: primaryColor.withValues(alpha: .1),
                          child: Icon(
                            Icons.library_music_rounded,
                            color: primaryColor,
                          ),
                        ),
                        title: Text(category.name),
                        trailing: const Icon(Icons.chevron_left_rounded),
                        onTap: () async {
                          await repository.saveItem(
                            createLibraryItem(
                              track,
                              sourceCategoryId ?? category.id,
                            ),
                          );
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          if (!context.mounted) return;
                          _showSavedMessage(
                            context,
                            'تم حفظ "${track.title}" في "${category.name}"',
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showSelectFolderDialog(
  BuildContext context,
  LibraryRepository repository,
  AudioItem track,
  String categoryId,
  Color primaryColor,
) async {
  final allFolders = await repository.getFolders();
  final folders = allFolders
      .where((folder) => folder.type == FolderType.user)
      .toList();
  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (dialogContext) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(dialogContext).height * .72,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'مجلداتي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              if (folders.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_off_outlined,
                        size: 46,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 10),
                      const Text('لم تنشئ أي مجلد بعد.'),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: folders.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final folder = folders[index];
                      return ListTile(
                        leading: Icon(
                          Icons.folder_rounded,
                          color: primaryColor,
                          size: 34,
                        ),
                        title: Text(folder.name),
                        trailing: const Icon(Icons.chevron_left_rounded),
                        onTap: () => _saveToFolder(
                          context: context,
                          dialogContext: dialogContext,
                          repository: repository,
                          track: track,
                          categoryId: categoryId,
                          folder: folder,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showCreateFolderDialog(
  BuildContext context,
  LibraryRepository repository,
  AudioItem track,
  String categoryId,
  Color primaryColor,
) async {
  final folderController = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Text(
        'إنشاء مجلد جديد',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: TextField(
        controller: folderController,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'اسم المجلد',
          hintText: 'اكتب اسم المجلد هنا',
          prefixIcon: Icon(Icons.create_new_folder_rounded),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: const Size(0, 48),
          ),
          onPressed: () async {
            final folderName = folderController.text.trim();
            if (folderName.isEmpty) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('اكتب اسم المجلد أولًا.')),
              );
              return;
            }

            final folder = await repository.createFolder(
              name: folderName,
              type: FolderType.user,
            );
            final item = createLibraryItem(track, categoryId);
            await repository.saveItem(item);
            await repository.addItemToFolder(
              folderId: folder.id,
              itemId: item.id,
            );

            if (!dialogContext.mounted) return;
            Navigator.pop(dialogContext);
            if (!context.mounted) return;
            _showSavedMessage(
              context,
              'تم إنشاء "$folderName" وحفظ "${track.title}" بداخله',
            );
          },
          child: const Text('حفظ المجلد والملف بداخله'),
        ),
      ],
    ),
  );

  folderController.dispose();
}

Future<void> _saveToFolder({
  required BuildContext context,
  required BuildContext dialogContext,
  required LibraryRepository repository,
  required AudioItem track,
  required String categoryId,
  required UserFolder folder,
}) async {
  final item = createLibraryItem(track, categoryId);
  await repository.saveItem(item);
  await repository.addItemToFolder(folderId: folder.id, itemId: item.id);

  if (!dialogContext.mounted) return;
  Navigator.pop(dialogContext);
  if (!context.mounted) return;
  _showSavedMessage(context, 'تم حفظ "${track.title}" في "${folder.name}"');
}

void _showSavedMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.green.shade700),
  );
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.showArrow = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: .1),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: showArrow ? const Icon(Icons.chevron_left_rounded) : null,
      onTap: onTap,
    );
  }
}
