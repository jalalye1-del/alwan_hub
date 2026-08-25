import 'package:hive/hive.dart';

part 'folder_item_model.g.dart';

@HiveType(typeId: 21)
class FolderItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String folderId;

  @HiveField(2)
  final String itemId;

  @HiveField(3)
  final DateTime addedAt;

  FolderItemModel({
    required this.id,
    required this.folderId,
    required this.itemId,
    required this.addedAt,
  });

  FolderItemModel copyWith({
    String? id,
    String? folderId,
    String? itemId,
    DateTime? addedAt,
  }) {
    return FolderItemModel(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      itemId: itemId ?? this.itemId,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
