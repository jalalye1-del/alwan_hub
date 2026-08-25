import 'managed_media.dart';

class ManagedContent {
  const ManagedContent({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.description,
    this.media = const [],
    this.sortOrder = 0,
    this.isPublished = true,
    this.publishedAt,
    this.updatedAt,
    this.metadata = const {},
  });

  final String id;
  final String type;
  final String title;
  final String? subtitle;
  final String? description;
  final List<ManagedMedia> media;
  final int sortOrder;
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> metadata;

  ManagedMedia? mediaOfType(ManagedMediaType type) {
    for (final item in media) {
      if (item.type == type && item.isActive && item.url.trim().isNotEmpty) {
        return item;
      }
    }
    return null;
  }

  factory ManagedContent.fromJson(Map<String, dynamic> json) {
    final rawMedia = json['media'] as List? ?? const [];
    return ManagedContent(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'content',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      media: rawMedia
          .whereType<Map>()
          .map((item) => ManagedMedia.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      sortOrder: json['sortOrder'] as int? ?? 0,
      isPublished: json['isPublished'] as bool? ?? true,
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'subtitle': subtitle,
    'description': description,
    'media': media.map((item) => item.toJson()).toList(),
    'sortOrder': sortOrder,
    'isPublished': isPublished,
    'publishedAt': publishedAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'metadata': metadata,
  };
}
