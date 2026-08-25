import 'package:flutter/material.dart';

import 'package:alwan_hub/core/content/models/managed_content.dart';
import 'package:alwan_hub/core/content/models/managed_media.dart';

class FmScheduleSlot {
  const FmScheduleSlot({required this.dayLabel, required this.time});

  final String dayLabel;
  final String time;

  factory FmScheduleSlot.fromMap(Map<dynamic, dynamic> map) {
    return FmScheduleSlot(
      dayLabel: (map['dayLabel'] ?? map['day'] ?? '').toString(),
      time: (map['time'] ?? '').toString(),
    );
  }

  Map<String, String> toMap() => {'dayLabel': dayLabel, 'time': time};
}

/// Dashboard-owned FM program and its weekly broadcast schedule.
class FmProgram {
  const FmProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.presenterName,
    required this.liveTime,
    required this.replayTimes,
    required this.imageUrl,
    required this.streamUrl,
    required this.accentColor,
    required this.broadcastDays,
    this.liveEndTime = '',
    this.broadcastSlots = const [],
    this.replaySlots = const [],
    this.conversationTitle = '',
    this.isLive = false,
    this.isPublished = true,
    this.sortOrder = 0,
  });

  final String id;
  final String title;
  final String description;
  final String presenterName;
  final String liveTime;
  final String liveEndTime;
  final List<String> replayTimes;
  final String imageUrl;
  final String streamUrl;
  final Color accentColor;
  final List<FmScheduleSlot> broadcastSlots;
  final List<FmScheduleSlot> replaySlots;

  /// Indexes follow the screen order: Saturday = 0 ... Friday = 6.
  final Set<int> broadcastDays;
  final String conversationTitle;
  final bool isLive;
  final bool isPublished;
  final int sortOrder;

  bool airsOn(int dayIndex) => broadcastDays.contains(dayIndex);

  String get broadcastTimeLabel {
    if (liveEndTime.trim().isEmpty) return liveTime;
    return '$liveTime - $liveEndTime';
  }

  factory FmProgram.fromDashboardMap(Map<String, dynamic> map) {
    return FmProgram(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      presenterName:
          map['presenterName']?.toString() ??
          map['presenter']?.toString() ??
          '',
      liveTime: map['liveTime']?.toString() ?? '',
      liveEndTime: map['liveEndTime']?.toString() ?? '',
      replayTimes: _stringList(
        map['replayTimes'] ?? [map['replayStart'], map['replayEnd']],
      ),
      imageUrl: map['imageUrl']?.toString() ?? '',
      streamUrl: map['streamUrl']?.toString() ?? '',
      accentColor: _parseColor(map['accentColor']),
      broadcastDays: _dayIndexes(map['broadcastDays']),
      broadcastSlots: _scheduleSlots(map['broadcastSlots']),
      replaySlots: _scheduleSlots(map['replaySlots']),
      conversationTitle: map['conversationTitle']?.toString() ?? '',
      isLive: _parseLiveStatus(map),
      isPublished: map['isPublished'] != false,
      sortOrder: int.tryParse(map['sortOrder']?.toString() ?? '') ?? 0,
    );
  }

  /// Maps the app-wide managed-content schema used by a remote dashboard.
  factory FmProgram.fromManagedContent(ManagedContent content) {
    final image = content.mediaOfType(ManagedMediaType.image);
    final liveStream = content.mediaOfType(ManagedMediaType.liveStream);
    return FmProgram.fromDashboardMap({
      'id': content.id,
      'title': content.title,
      'description': content.description,
      'presenterName': content.subtitle,
      'imageUrl': image?.url,
      'streamUrl': liveStream?.url,
      'isPublished': content.isPublished,
      'sortOrder': content.sortOrder,
      ...content.metadata,
    });
  }

  Map<String, dynamic> toDashboardMap() => {
    'id': id,
    'title': title,
    'description': description,
    'presenterName': presenterName,
    'liveTime': liveTime,
    'liveEndTime': liveEndTime,
    'replayTimes': replayTimes,
    'imageUrl': imageUrl,
    'streamUrl': streamUrl,
    'accentColor': accentColor.toARGB32(),
    'broadcastDays': broadcastDays.toList()..sort(),
    'broadcastSlots': broadcastSlots.map((slot) => slot.toMap()).toList(),
    'replaySlots': replaySlots.map((slot) => slot.toMap()).toList(),
    'conversationTitle': conversationTitle,
    'broadcastType': isLive ? 'live' : 'recorded',
    'isLive': isLive,
    'isPublished': isPublished,
    'sortOrder': sortOrder,
  };

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .where((item) => item != null && item.toString().trim().isNotEmpty)
        .map((item) => item.toString())
        .toList(growable: false);
  }

  static Set<int> _dayIndexes(dynamic value) {
    if (value is! List) {
      return Set.unmodifiable(List.generate(7, (index) => index));
    }
    final indexes = value
        .map((item) => int.tryParse(item.toString()))
        .whereType<int>()
        .where((index) => index >= 0 && index <= 6)
        .toSet();
    return indexes.isEmpty
        ? Set.unmodifiable(List.generate(7, (index) => index))
        : Set.unmodifiable(indexes);
  }

  static List<FmScheduleSlot> _scheduleSlots(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(FmScheduleSlot.fromMap)
        .where((slot) => slot.time.trim().isNotEmpty)
        .toList(growable: false);
  }

  static bool _parseLiveStatus(Map<String, dynamic> map) {
    final source = (map['broadcastType'] ?? map['broadcastMode'])
        ?.toString()
        .trim()
        .toLowerCase();
    if (source != null && source.isNotEmpty) {
      if (const {'live', 'direct', 'مباشر'}.contains(source)) return true;
      if (const {'recorded', 'record', 'مسجل'}.contains(source)) return false;
    }
    return map['isLive'] == true;
  }

  static Color _parseColor(dynamic value) {
    if (value is int) return Color(value);
    final source = value?.toString().trim() ?? '';
    if (source.isEmpty) return const Color(0xFF4A35E8);
    final normalized = source
        .replaceFirst('#', '')
        .replaceFirst('0x', '')
        .replaceFirst('0X', '');
    final parsed =
        int.tryParse(normalized, radix: 16) ??
        int.tryParse(source) ??
        0xFF4A35E8;
    return Color(normalized.length <= 6 ? 0xFF000000 | parsed : parsed);
  }
}
