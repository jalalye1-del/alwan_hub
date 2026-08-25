import 'package:hive/hive.dart';
import '../../domain/entities/library_category.dart';

// هذا السطر ضروري جداً لتوليد ملف الـ Adapter
part 'library_category_model.g.dart';

@HiveType(typeId: 23) // تم استخدام typeId 23 كما حددناه في HiveService
class LibraryCategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? parentId;

  @HiveField(3)
  final int order;

  @HiveField(4)
  final String icon;

  @HiveField(5)
  final bool isSystem;

  @HiveField(6)
  final bool acceptsItems;

  @HiveField(7)
  final bool allowsChildren;

  LibraryCategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    required this.order,
    required this.icon,
    this.isSystem = true,
    this.acceptsItems = true,
    this.allowsChildren = false,
  });

  factory LibraryCategoryModel.fromEntity(LibraryCategory entity) {
    return LibraryCategoryModel(
      id: entity.id,
      name: entity.name,
      parentId: entity.parentId,
      order: entity.order,
      icon: entity.icon,
      isSystem: entity.isSystem,
      acceptsItems: entity.acceptsItems,
      allowsChildren: entity.allowsChildren,
    );
  }

  LibraryCategory toEntity() {
    return LibraryCategory(
      id: id,
      name: name,
      parentId: parentId,
      order: order,
      icon: icon,
      isSystem: isSystem,
      acceptsItems: acceptsItems,
      allowsChildren: allowsChildren,
    );
  }

  LibraryCategoryModel copyWith({
    String? id,
    String? name,
    String? parentId,
    int? order,
    String? icon,
    bool? isSystem,
    bool? acceptsItems,
    bool? allowsChildren,
  }) {
    return LibraryCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      order: order ?? this.order,
      icon: icon ?? this.icon,
      isSystem: isSystem ?? this.isSystem,
      acceptsItems: acceptsItems ?? this.acceptsItems,
      allowsChildren: allowsChildren ?? this.allowsChildren,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'order': order,
      'icon': icon,
      'isSystem': isSystem,
      'acceptsItems': acceptsItems,
      'allowsChildren': allowsChildren,
    };
  }

  factory LibraryCategoryModel.fromMap(Map<String, dynamic> map) {
    return LibraryCategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      parentId: map['parentId'] as String?,
      order: map['order'] as int,
      icon: map['icon'] as String,
      isSystem: map['isSystem'] ?? true,
      acceptsItems: map['acceptsItems'] ?? true,
      allowsChildren: map['allowsChildren'] ?? false,
    );
  }
}
