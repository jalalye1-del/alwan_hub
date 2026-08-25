import 'package:hive/hive.dart';

import '../../domain/entities/folder_type.dart';
import '../../domain/entities/user_folder.dart';

part 'user_folder_model.g.dart';

@HiveType(typeId: 11)
class UserFolderModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int folderType;

  @HiveField(3)
  final String? imageUrl;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime? updatedAt;

  UserFolderModel({
    required this.id,
    required this.name,
    required this.folderType,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserFolderModel.fromEntity(UserFolder folder) {
    return UserFolderModel(
      id: folder.id,
      name: folder.name,
      folderType: folder.type.index,
      imageUrl: folder.imageUrl,
      createdAt: folder.createdAt,
      updatedAt: folder.updatedAt,
    );
  }

  UserFolder toEntity() {
    return UserFolder(
      id: id,
      name: name,
      type: FolderType.values[folderType],
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  UserFolderModel copyWith({
    String? id,
    String? name,
    int? folderType,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserFolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      folderType: folderType ?? this.folderType,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
