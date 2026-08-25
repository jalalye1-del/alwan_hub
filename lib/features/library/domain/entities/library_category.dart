class LibraryCategory {
  final String id;
  final String name;

  final String? parentId;

  final int order;

  final String icon;

  final bool isSystem;

  final bool allowsChildren;

  final bool acceptsItems;

  const LibraryCategory({
    required this.id,
    required this.name,
    this.parentId,
    required this.order,
    required this.icon,
    this.isSystem = true,
    this.allowsChildren = false,
    this.acceptsItems = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'order': order,
      'icon': icon,
      'isSystem': isSystem ? 1 : 0,
      'allowsChildren': allowsChildren ? 1 : 0,
      'acceptsItems': acceptsItems ? 1 : 0,
    };
  }

  factory LibraryCategory.fromMap(Map<String, dynamic> map) {
    return LibraryCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      parentId: map['parentId'] as String?,
      order: map['order'] as int,
      icon: map['icon'] as String,
      isSystem: (map['isSystem'] == 1 || map['isSystem'] == true),
      allowsChildren:
          (map['allowsChildren'] == 1 || map['allowsChildren'] == true),
      acceptsItems: (map['acceptsItems'] == 1 || map['acceptsItems'] == true),
    );
  }
}
