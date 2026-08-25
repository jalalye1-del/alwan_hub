// تأكد من استيراد الـ Enums الصحيحة إذا لزم الأمر
import 'library_item_type.dart';

class LibraryItem {
  final String id;
  final String title;
  final LibraryItemType type;
  final String? folderId;
  final String? categoryId;
  final String sourceId;
  final String localPath;
  final String? audioUrl;
  final String? videoUrl;
  final String? coverUrl;
  final DateTime createdAt;

  const LibraryItem({
    required this.id,
    required this.title,
    required this.type,
    this.folderId,
    this.categoryId,
    required this.sourceId,
    required this.localPath,
    this.audioUrl,
    this.videoUrl,
    this.coverUrl,
    required this.createdAt,
  });

  LibraryItem copyWith({
    String? id,
    String? title,
    LibraryItemType? type,
    String? folderId,
    String? categoryId,
    String? sourceId,
    String? localPath,
    String? audioUrl,
    String? videoUrl,
    String? coverUrl,
    DateTime? createdAt,
  }) {
    return LibraryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      folderId: folderId ?? this.folderId,
      categoryId: categoryId ?? this.categoryId,
      sourceId: sourceId ?? this.sourceId,
      localPath: localPath ?? this.localPath,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'folderId': folderId,
      'categoryId': categoryId,
      'sourceId': sourceId,
      'localPath': localPath,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'coverUrl': coverUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory LibraryItem.fromMap(Map<String, dynamic> map) {
    return LibraryItem(
      id: map['id'] as String,
      title: map['title'] as String,
      type: LibraryItemType.values.firstWhere((e) => e.name == map['type']),
      folderId: map['folderId'] as String?,
      categoryId: map['categoryId'] as String?,
      sourceId: map['sourceId'] as String,
      localPath: map['localPath'] as String,
      audioUrl: map['audioUrl'] as String?,
      videoUrl: map['videoUrl'] as String?,
      coverUrl: map['coverUrl'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
