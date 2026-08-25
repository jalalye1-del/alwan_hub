import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:alwan_hub/core/localization/localized_text.dart';

import '../../domain/entities/user_folder.dart';
import '../../domain/entities/library_item.dart'; // 🟢 تم استبدال FolderItem بـ LibraryItem
import '../providers/library_provider.dart';

class FolderDetailsScreen extends ConsumerWidget {
  final UserFolder folder;

  const FolderDetailsScreen({super.key, required this.folder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // استخدام read بدلاً من watch، وجلب البيانات لمرة واحدة عبر getFolderItems
    final repository = ref.read(libraryRepositoryProvider);
    const Color primaryColor = Color(0xFFD32F2F);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF),
        elevation: 0,
        centerTitle: true,
        title: Text(
          folder.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E1E1E),
          ),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      // 🟢 تم استبدال نوع البيانات إلى LibraryItem
      body: FutureBuilder<List<LibraryItem>>(
        future: repository.getFolderItems(folder.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final folderItems = snapshot.data ?? [];

          if (folderItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 72,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'المجلد فارغ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'قم بإضافة المقاطع والأغاني إليه لتظهر هنا',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: folderItems.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item =
                  folderItems[index]; // 🟢 المتغير الآن يمثل الملف الفعلي
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.music_note_rounded,
                      color: primaryColor,
                    ),
                  ),
                  // 🟢 عرض اسم الملف الفعلي
                  title: Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // 🟢 عرض تاريخ إضافة الملف الفعلي
                  subtitle: Text(
                    'تاريخ الإضافة: ${item.createdAt.toString().substring(0, 10)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: const Icon(
                    Icons.play_circle_fill_rounded,
                    color: primaryColor,
                    size: 32,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
