enum ManagedMediaType { image, audio, video, liveStream, file, externalLink }

class ManagedMedia {
  const ManagedMedia({
    required this.id,
    required this.type,
    required this.url,
    this.title,
    this.thumbnailUrl,
    this.mimeType,
    this.sortOrder = 0,
    this.isActive = true,
    this.metadata = const {},
  });

  final String id;
  final ManagedMediaType type;
  final String url;
  final String? title;
  final String? thumbnailUrl;
  final String? mimeType;
  final int sortOrder;
  final bool isActive;
  final Map<String, dynamic> metadata;

  factory ManagedMedia.fromJson(Map<String, dynamic> json) {
    return ManagedMedia(
      id: json['id'] as String? ?? '',
      type: ManagedMediaType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => ManagedMediaType.file,
      ),
      url: json['url'] as String? ?? '',
      title: json['title'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      mimeType: json['mimeType'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'url': url,
    'title': title,
    'thumbnailUrl': thumbnailUrl,
    'mimeType': mimeType,
    'sortOrder': sortOrder,
    'isActive': isActive,
    'metadata': metadata,
  };
}
