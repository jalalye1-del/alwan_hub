// lib/core/recording/models/recording_file.dart

import 'dart:convert';
import 'package:hive/hive.dart';

part 'recording_file.g.dart';

/// نوع مصدر التسجيل
@HiveType(typeId: 1)
enum RecordingSourceType {
  @HiveField(0)
  liveBroadcast,

  @HiveField(1)
  fmStation,

  @HiveField(2)
  program,

  @HiveField(3)
  podcast,

  @HiveField(4)
  audiobook,
}

/// حالة التسجيل
@HiveType(typeId: 2)
enum RecordingStatus {
  @HiveField(0)
  recording,

  @HiveField(1)
  completed,

  @HiveField(2)
  cancelled,

  @HiveField(3)
  failed,
}

/// نموذج ملف التسجيل
@HiveType(typeId: 3)
class RecordingFile extends HiveObject {
  @HiveField(0)
  final String id;

  /// اسم التسجيل الذي يظهر للمستخدم
  @HiveField(1)
  final String title;

  /// اسم الملف الحقيقي
  @HiveField(2)
  final String fileName;

  /// المسار الكامل داخل الهاتف
  @HiveField(3)
  final String filePath;

  /// نوع التسجيل
  @HiveField(4)
  final RecordingSourceType sourceType;

  /// اسم التصنيف الرئيسي
  @HiveField(5)
  final String category;

  /// اسم المجلد الفرعي
  @HiveField(6)
  final String folderName;

  /// اسم المحطة
  @HiveField(7)
  final String? stationName;

  /// اسم البرنامج
  @HiveField(8)
  final String? programName;

  /// معرف المحطة
  @HiveField(9)
  final String? stationId;

  /// معرف البرنامج
  @HiveField(10)
  final String? programId;

  /// صورة الغلاف
  @HiveField(11)
  final String? imageUrl;

  /// مدة التسجيل
  @HiveField(12)
  final int durationMilliseconds;

  Duration get duration => Duration(milliseconds: durationMilliseconds);

  /// حجم الملف بالبايت
  @HiveField(13)
  final int fileSize;

  /// وقت الإنشاء
  @HiveField(14)
  final DateTime createdAt;

  /// آخر تشغيل
  @HiveField(15)
  final DateTime? lastPlayed;

  /// عدد مرات التشغيل
  @HiveField(16)
  final int playCount;

  /// مفضل
  @HiveField(17)
  final bool isFavorite;

  /// حالة التسجيل
  @HiveField(18)
  final RecordingStatus status;

  /// ملاحظات
  @HiveField(19)
  final String? notes;

  /// كلمات مفتاحية
  @HiveField(20)
  final List<String> tags;

  RecordingFile({
    required this.id,
    required this.title,
    required this.fileName,
    required this.filePath,
    required this.sourceType,
    required this.category,
    required this.folderName,
    Duration? duration,
    int? durationMilliseconds,
    required this.fileSize,
    required this.createdAt,
    required this.status,
    this.stationName,
    this.programName,
    this.stationId,
    this.programId,
    this.imageUrl,
    this.lastPlayed,
    this.playCount = 0,
    this.isFavorite = false,
    this.notes,
    this.tags = const [],
  }) : durationMilliseconds =
            durationMilliseconds ?? duration?.inMilliseconds ?? 0;

  RecordingFile copyWith({
    String? id,
    String? title,
    String? fileName,
    String? filePath,
    RecordingSourceType? sourceType,
    String? category,
    String? folderName,
    String? stationName,
    String? programName,
    String? stationId,
    String? programId,
    String? imageUrl,
    Duration? duration,
    int? fileSize,
    DateTime? createdAt,
    DateTime? lastPlayed,
    int? playCount,
    bool? isFavorite,
    RecordingStatus? status,
    String? notes,
    List<String>? tags,
  }) {
    return RecordingFile(
      id: id ?? this.id,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      sourceType: sourceType ?? this.sourceType,
      category: category ?? this.category,
      folderName: folderName ?? this.folderName,
      stationName: stationName ?? this.stationName,
      programName: programName ?? this.programName,
      stationId: stationId ?? this.stationId,
      programId: programId ?? this.programId,
      imageUrl: imageUrl ?? this.imageUrl,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      playCount: playCount ?? this.playCount,
      isFavorite: isFavorite ?? this.isFavorite,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'fileName': fileName,
      'filePath': filePath,
      'sourceType': sourceType.name,
      'category': category,
      'folderName': folderName,
      'stationName': stationName,
      'programName': programName,
      'stationId': stationId,
      'programId': programId,
      'imageUrl': imageUrl,
      'duration': duration.inMilliseconds,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
      'lastPlayed': lastPlayed?.toIso8601String(),
      'playCount': playCount,
      'isFavorite': isFavorite,
      'status': status.name,
      'notes': notes,
      'tags': tags,
    };
  }

  factory RecordingFile.fromMap(Map<String, dynamic> map) {
    return RecordingFile(
      id: map['id'],
      title: map['title'],
      fileName: map['fileName'],
      filePath: map['filePath'],
      sourceType: RecordingSourceType.values.firstWhere(
        (e) => e.name == map['sourceType'],
      ),
      category: map['category'],
      folderName: map['folderName'],
      stationName: map['stationName'],
      programName: map['programName'],
      stationId: map['stationId'],
      programId: map['programId'],
      imageUrl: map['imageUrl'],
      duration: Duration(milliseconds: map['duration']),
      fileSize: map['fileSize'],
      createdAt: DateTime.parse(map['createdAt']),
      lastPlayed: map['lastPlayed'] == null
          ? null
          : DateTime.parse(map['lastPlayed']),
      playCount: map['playCount'] ?? 0,
      isFavorite: map['isFavorite'] ?? false,
      status: RecordingStatus.values.firstWhere(
        (e) => e.name == map['status'],
      ),
      notes: map['notes'],
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory RecordingFile.fromJson(String source) {
    return RecordingFile.fromMap(jsonDecode(source));
  }

  @override
  bool operator ==(Object other) {
    return other is RecordingFile && other.id == id;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        title,
        fileName,
        filePath,
        sourceType,
        category,
        folderName,
        stationName,
        programName,
        stationId,
        programId,
        imageUrl,
        duration,
        fileSize,
        createdAt,
        lastPlayed,
        playCount,
        isFavorite,
        status,
        notes,
        ...tags,
      ]);
}
