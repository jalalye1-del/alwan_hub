class LoungeCatalogGroup {
  const LoungeCatalogGroup({required this.id, required this.title});

  final String id;
  final String title;

  factory LoungeCatalogGroup.fromJson(Map<String, dynamic> json) {
    return LoungeCatalogGroup(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'title': title};
}

class LoungeCatalogItem {
  const LoungeCatalogItem({
    required this.id,
    required this.name,
    required this.roleLabel,
    required this.imageUrl,
    required this.accentColorValue,
    this.groupId,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String roleLabel;
  final String imageUrl;
  final int accentColorValue;
  final String? groupId;
  final int sortOrder;
  final bool isActive;

  String get displayTitle => roleLabel.isEmpty ? name : '$roleLabel $name';

  factory LoungeCatalogItem.fromJson(Map<String, dynamic> json) {
    return LoungeCatalogItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      roleLabel: json['roleLabel'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      accentColorValue: json['accentColorValue'] as int? ?? 0xFF5B4CF0,
      groupId: json['groupId'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'roleLabel': roleLabel,
    'imageUrl': imageUrl,
    'accentColorValue': accentColorValue,
    'groupId': groupId,
    'sortOrder': sortOrder,
    'isActive': isActive,
  };
}

class LoungeCategoryCatalog {
  const LoungeCategoryCatalog({
    required this.categoryId,
    required this.sectionTitle,
    required this.trackItemLabel,
    required this.items,
    this.groups = const [],
  });

  final String categoryId;
  final String sectionTitle;
  final String trackItemLabel;
  final List<LoungeCatalogGroup> groups;
  final List<LoungeCatalogItem> items;

  bool get hasGroups => groups.isNotEmpty;

  factory LoungeCategoryCatalog.fromJson(Map<String, dynamic> json) {
    return LoungeCategoryCatalog(
      categoryId: json['categoryId'] as String? ?? '',
      sectionTitle: json['sectionTitle'] as String? ?? '',
      trackItemLabel: json['trackItemLabel'] as String? ?? 'أغنية',
      groups: (json['groups'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(LoungeCatalogGroup.fromJson)
          .toList(),
      items: (json['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(LoungeCatalogItem.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'sectionTitle': sectionTitle,
    'trackItemLabel': trackItemLabel,
    'groups': groups.map((group) => group.toJson()).toList(),
    'items': items.map((item) => item.toJson()).toList(),
  };
}
