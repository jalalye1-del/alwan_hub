// lib/core/audio/models/audio_track.dart

import 'package:flutter/foundation.dart';

/// نوع مصدر المادة الصوتية
enum AudioSourceType {
  fm,
  audiobook,
  podcast,
  music,
  program,
  local,
}

@immutable
class AudioTrack {
  final String id;

  /// عنوان المادة
  final String title;

  /// عنوان فرعي (اسم البرنامج أو الفنان أو المؤلف)
  final String subtitle;

  /// وصف مختصر
  final String? description;

  /// رابط التشغيل
  final String url;

  /// صورة مصغرة
  final String? imageUrl;

  /// صورة الغلاف (للتوافق مع الإصدارات السابقة)
  final String? coverUrl;

  /// اسم المقدم
  final String? presenterName;

  /// صورة المقدم
  final String? presenterImage;

  /// صورة البرنامج
  final String? programImage;

  /// بث مباشر
  final bool isLiveStream;

  /// هل المصدر محطة FM
  final bool isFm;

  /// نوع المصدر
  final AudioSourceType sourceType;

  /// التصنيف
  final String category;

  /// مدة التشغيل النصية
  final String? durationText;

  /// مدة التشغيل
  final Duration? duration;

  /// التقييم
  final double rating;

  /// عدد التحميلات
  final int downloads;

  const AudioTrack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.url,
    this.description,
    this.imageUrl,
    this.coverUrl,
    this.presenterName,
    this.presenterImage,
    this.programImage,
    this.isLiveStream = false,
    this.isFm = false,
    this.sourceType = AudioSourceType.music,
    this.category = 'أخرى',
    this.durationText,
    this.duration,
    this.rating = 0.0,
    this.downloads = 0,
  });

  AudioTrack copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    String? url,
    String? imageUrl,
    String? coverUrl,
    String? presenterName,
    String? presenterImage,
    String? programImage,
    bool? isLiveStream,
    bool? isFm,
    AudioSourceType? sourceType,
    String? category,
    String? durationText,
    Duration? duration,
    double? rating,
    int? downloads,
  }) {
    return AudioTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      presenterName: presenterName ?? this.presenterName,
      presenterImage: presenterImage ?? this.presenterImage,
      programImage: programImage ?? this.programImage,
      isLiveStream: isLiveStream ?? this.isLiveStream,
      isFm: isFm ?? this.isFm,
      sourceType: sourceType ?? this.sourceType,
      category: category ?? this.category,
      durationText: durationText ?? this.durationText,
      duration: duration ?? this.duration,
      rating: rating ?? this.rating,
      downloads: downloads ?? this.downloads,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'url': url,
      'imageUrl': imageUrl,
      'coverUrl': coverUrl,
      'presenterName': presenterName,
      'presenterImage': presenterImage,
      'programImage': programImage,
      'isLiveStream': isLiveStream,
      'isFm': isFm,
      'sourceType': sourceType.name,
      'category': category,
      'durationText': durationText,
      'duration': duration?.inMilliseconds,
      'rating': rating,
      'downloads': downloads,
    };
  }

  factory AudioTrack.fromJson(Map<String, dynamic> json) {
    return AudioTrack(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      description: json['description']?.toString(),
      url: json['url']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      coverUrl: json['coverUrl']?.toString(),
      presenterName: json['presenterName']?.toString(),
      presenterImage: json['presenterImage']?.toString(),
      programImage: json['programImage']?.toString(),
      isLiveStream: json['isLiveStream'] == true,
      isFm: json['isFm'] == true,
      sourceType: AudioSourceType.values.firstWhere(
        (e) => e.name == json['sourceType'],
        orElse: () => AudioSourceType.music,
      ),
      category: json['category']?.toString() ?? 'أخرى',
      durationText: json['durationText']?.toString(),
      duration: json['duration'] != null
          ? Duration(
              milliseconds:
                  int.tryParse(json['duration'].toString()) ?? 0,
            )
          : null,
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      downloads: (json['downloads'] is int)
          ? json['downloads'] as int
          : int.tryParse(json['downloads']?.toString() ?? '0') ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioTrack &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AudioTrack(id: $id, title: $title, sourceType: $sourceType)';
  }
}