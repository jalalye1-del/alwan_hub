import 'folder_type.dart';

class UserFolder {
  final String id;
  final String name;
  final FolderType type; // 🟢 تم استبدال section بـ type
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserFolder({
    required this.id,
    required this.name,
    required this.type,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  UserFolder copyWith({
    String? name,
    FolderType? type,
    String? imageUrl,
    DateTime? updatedAt,
  }) {
    return UserFolder(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
