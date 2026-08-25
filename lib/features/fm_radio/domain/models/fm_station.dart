// lib/features/fm_radio/domain/models/fm_station.dart

import 'package:flutter/foundation.dart';
import 'package:alwan_hub/core/audio/models/audio_track.dart';

@immutable
class FmStation {
  // Identity
  final String id;
  final String name;

  // Images
  final String logo;
  final String coverImage;

  // Stream
  final String url;
  final String frequency;
  final bool isLive;
  final String currentProgram;

  // Location
  final String country;
  final String city;
  final String language;

  // Classification
  final String category;
  final String type;

  // Statistics
  final int listeners;
  final double rating;
  final int foundedYear;

  // Contact
  final String? website;
  final String? websiteName;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? email;
  final String? studioPhone;
  final String? studioWhatsapp;

  // Description
  final String description;

  // State
  final bool isFavorite;
  final bool isVerified;

  const FmStation({
    required this.id,
    required this.name,
    this.logo = '',
    this.coverImage = '',
    required this.url,
    this.frequency = '',
    this.isLive = false,
    this.currentProgram = '',
    this.country = '',
    this.city = '',
    this.language = '',
    this.category = '',
    this.type = '',
    this.listeners = 0,
    this.rating = 0.0,
    this.foundedYear = 0,
    this.website,
    this.websiteName,
    this.facebookUrl,
    this.instagramUrl,
    this.email,
    this.studioPhone,
    this.studioWhatsapp,
    this.description = '',
    this.isFavorite = false,
    this.isVerified = false,
  });

  // 🟢 التحسين السادس: Getter لعرض صورة الغلاف أو الشعار تلقائياً
  String get displayImage =>
      coverImage.isNotEmpty ? coverImage : logo;

  // 🟢 التحسين السابع: Getter لتنسيق التردد وضمان عدم تكرار كلمة FM
  String get displayFrequency =>
      frequency.contains('FM') ? frequency : '$frequency FM';

  FmStation copyWith({
    String? id,
    String? name,
    String? logo,
    String? coverImage,
    String? url,
    String? frequency,
    bool? isLive,
    String? currentProgram,
    String? country,
    String? city,
    String? language,
    String? category,
    String? type,
    int? listeners,
    double? rating,
    int? foundedYear,
    String? website,
    String? websiteName,
    String? facebookUrl,
    String? instagramUrl,
    String? email,
    String? studioPhone,
    String? studioWhatsapp,
    String? description,
    bool? isFavorite,
    bool? isVerified,
  }) {
    return FmStation(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      coverImage: coverImage ?? this.coverImage,
      url: url ?? this.url,
      frequency: frequency ?? this.frequency,
      isLive: isLive ?? this.isLive,
      currentProgram: currentProgram ?? this.currentProgram,
      country: country ?? this.country,
      city: city ?? this.city,
      language: language ?? this.language,
      category: category ?? this.category,
      type: type ?? this.type,
      listeners: listeners ?? this.listeners,
      rating: rating ?? this.rating,
      foundedYear: foundedYear ?? this.foundedYear,
      website: website ?? this.website,
      websiteName: websiteName ?? this.websiteName,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      email: email ?? this.email,
      studioPhone: studioPhone ?? this.studioPhone,
      studioWhatsapp: studioWhatsapp ?? this.studioWhatsapp,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  factory FmStation.fromJson(Map<String, dynamic> json) {
    return FmStation(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logo: json['logo']?.toString() ?? json['imageUrl']?.toString() ?? '',
      coverImage: json['coverImage']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? '',
      // 🟢 التحسين الثاني: دعم القيم المتعددة للبوليان (true, 1, 'true')
      isLive: json['isLive'] == true || json['isLive'] == 1 || json['isLive'] == 'true',
      currentProgram: json['currentProgram']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      // 🟢 التحسين الرابع: دعم قراءة المبتدئين والأرقام والنصوص للـ listeners
      listeners: (json['listeners'] as num?)?.toInt() ??
          int.tryParse(json['listeners']?.toString() ?? '') ??
          0,
      // 🟢 التحسين الثالث: دعم قراءة الأرقام والنصوص للـ rating
      rating: (json['rating'] as num?)?.toDouble() ??
          double.tryParse(json['rating']?.toString() ?? '') ??
          0.0,
      foundedYear: (json['foundedYear'] as num?)?.toInt() ??
          int.tryParse(json['foundedYear']?.toString() ?? '') ??
          0,
      website: json['website']?.toString(),
      websiteName: json['websiteName']?.toString(),
      facebookUrl: json['facebookUrl']?.toString(),
      instagramUrl: json['instagramUrl']?.toString(),
      email: json['email']?.toString(),
      studioPhone: json['studioPhone']?.toString(),
      studioWhatsapp: json['studioWhatsapp']?.toString(),
      description: json['description']?.toString() ?? '',
      isFavorite: json['isFavorite'] == true || json['isFavorite'] == 1 || json['isFavorite'] == 'true',
      isVerified: json['isVerified'] == true || json['isVerified'] == 1 || json['isVerified'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'coverImage': coverImage,
      'url': url,
      'frequency': frequency,
      'isLive': isLive,
      'currentProgram': currentProgram,
      'country': country,
      'city': city,
      'language': language,
      'category': category,
      'type': type,
      'listeners': listeners,
      'rating': rating,
      'foundedYear': foundedYear,
      'website': website,
      'websiteName': websiteName,
      'facebookUrl': facebookUrl,
      'instagramUrl': instagramUrl,
      'email': email,
      'studioPhone': studioPhone,
      'studioWhatsapp': studioWhatsapp,
      'description': description,
      'isFavorite': isFavorite,
      'isVerified': isVerified,
    };
  }

  AudioTrack toAudioTrack() {
    return AudioTrack(
      id: id,
      title: name,
      subtitle: currentProgram.isNotEmpty
          ? currentProgram
          : '$displayFrequency • $country',
      url: url,
      // 🟢 التحسين الخامس: ضمان وجود صورة للمشغل حتى لو كان الشعار فارغاً
      imageUrl: displayImage,
      coverUrl: displayImage,
      presenterName: currentProgram.isNotEmpty ? currentProgram : null,
      isLiveStream: true,
      isFm: true,
      sourceType: AudioSourceType.fm,
      category: 'إذاعات FM',
      rating: rating,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is FmStation &&
      other.id == id &&
      other.name == name &&
      other.logo == logo &&
      other.coverImage == coverImage &&
      other.url == url &&
      other.frequency == frequency &&
      other.isLive == isLive &&
      other.currentProgram == currentProgram &&
      other.country == country &&
      other.city == city &&
      other.language == language &&
      other.category == category &&
      other.type == type &&
      other.listeners == listeners &&
      other.rating == rating &&
      other.foundedYear == foundedYear &&
      other.website == website &&
      other.websiteName == websiteName &&
      other.facebookUrl == facebookUrl &&
      other.instagramUrl == instagramUrl &&
      other.email == email &&
      other.studioPhone == studioPhone &&
      other.studioWhatsapp == studioWhatsapp &&
      other.description == description &&
      other.isFavorite == isFavorite &&
      other.isVerified == isVerified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      logo.hashCode ^
      coverImage.hashCode ^
      url.hashCode ^
      frequency.hashCode ^
      isLive.hashCode ^
      currentProgram.hashCode ^
      country.hashCode ^
      city.hashCode ^
      language.hashCode ^
      category.hashCode ^
      type.hashCode ^
      listeners.hashCode ^
      rating.hashCode ^
      foundedYear.hashCode ^
      website.hashCode ^
      websiteName.hashCode ^
      facebookUrl.hashCode ^
      instagramUrl.hashCode ^
      email.hashCode ^
      studioPhone.hashCode ^
      studioWhatsapp.hashCode ^
      description.hashCode ^
      isFavorite.hashCode ^
      isVerified.hashCode;
  }
}