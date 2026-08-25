import 'package:hive/hive.dart';

import '../../domain/entities/library_item.dart';
import '../../domain/entities/library_item_type.dart';

part 'library_item_model.g.dart';

@HiveType(typeId: 20)
class LibraryItemModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(3)
  int type;

  @HiveField(4)
  String sourceId;

  @HiveField(5)
  String localPath;

  @HiveField(6)
  String? imageUrl;

  @HiveField(7)
  int? durationInSeconds;

  @HiveField(8)
  int? fileSize;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime? lastPlayedAt;

  // تم تعديل الترقيم إلى 11 بعد حذف folderId
  @HiveField(11)
  String? categoryId;

  @HiveField(12)
  String? audioUrl;

  @HiveField(13)
  String? videoUrl;

  LibraryItemModel({
    required this.id,
    required this.title,
    required this.type,
    required this.sourceId,
    required this.localPath,
    this.imageUrl,
    this.durationInSeconds,
    this.fileSize,
    required this.createdAt,
    this.lastPlayedAt,
    this.categoryId,
    this.audioUrl,
    this.videoUrl,
  });

  factory LibraryItemModel.fromEntity(LibraryItem item) {
    return LibraryItemModel(
      id: item.id,
      title: item.title,
      type: item.type.index,
      sourceId: item.sourceId,
      localPath: item.localPath,
      imageUrl: item.coverUrl,
      audioUrl: item.audioUrl,
      videoUrl: item.videoUrl,
      createdAt: item.createdAt,
      categoryId: item.categoryId,
    );
  }

  LibraryItem toEntity() {
    return LibraryItem(
      id: id,
      title: title,
      type: LibraryItemType.values[type],
      sourceId: sourceId,
      localPath: localPath,
      audioUrl: audioUrl,
      videoUrl: videoUrl,
      coverUrl: imageUrl,
      createdAt: createdAt,
      categoryId: categoryId,
    );
  }

  LibraryItemModel copyWith({
    String? id,
    String? title,
    int? type,
    String? sourceId,
    String? localPath,
    String? imageUrl,
    int? durationInSeconds,
    int? fileSize,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    String? categoryId,
    String? audioUrl,
    String? videoUrl,
  }) {
    return LibraryItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      sourceId: sourceId ?? this.sourceId,
      localPath: localPath ?? this.localPath,
      imageUrl: imageUrl ?? this.imageUrl,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      categoryId: categoryId ?? this.categoryId,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}
