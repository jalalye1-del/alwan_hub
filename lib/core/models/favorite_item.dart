// lib/core/models/favorite_item.dart

enum FavoriteType {
  yemeniSongs,
  arabicSongs,
  islamicNasheed,
  poemsAndZamil,
  quran,
  programs,
  audioBooks,
  podcasts,
  other
}

class FavoriteItem {
  final String id;
  final String title;
  final String? subtitle; // اسم الفنان، القارئ، أو المؤلف
  final String imageUrl;
  final String audioUrl;
  final FavoriteType type; // القسم الرئيسي (مثلاً: برامج)
  final String? subCategory; // القسم الفرعي (مثلاً: برامج ثقافية)
  final DateTime addedAt;

  FavoriteItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    required this.audioUrl,
    required this.type,
    this.subCategory,
    required this.addedAt,
  });

  // 1. دالة تحويل البيانات إلى JSON (لإرسالها للوحة التحكم أو حفظها محلياً)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'type': type.name, // حفظ نوع القسم كنص
      'subCategory': subCategory,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  // 2. دالة استقبال البيانات من JSON (القادمة من لوحة التحكم أو التخزين المحلي)
  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['imageUrl'] as String,
      audioUrl: json['audioUrl'] as String,
      type: FavoriteType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FavoriteType.other,
      ),
      subCategory: json['subCategory'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  // 3. دالة النسخ (لتحديث حالة العنصر بسهولة عبر Riverpod)
  FavoriteItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? audioUrl,
    FavoriteType? type,
    String? subCategory,
    DateTime? addedAt,
  }) {
    return FavoriteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      type: type ?? this.type,
      subCategory: subCategory ?? this.subCategory,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}