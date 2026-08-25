import 'package:alwan_hub/core/content/models/managed_content.dart';

class DailyHoroscope {
  const DailyHoroscope({
    required this.id,
    required this.name,
    required this.symbol,
    required this.dateRange,
    required this.element,
    required this.summary,
    required this.love,
    required this.work,
    required this.health,
    required this.mood,
    required this.advice,
    required this.luckyNumber,
    required this.luckyColor,
  });

  final String id;
  final String name;
  final String symbol;
  final String dateRange;
  final String element;
  final String summary;
  final String love;
  final String work;
  final String health;
  final String mood;
  final String advice;
  final int luckyNumber;
  final String luckyColor;

  factory DailyHoroscope.fromManagedContent(ManagedContent content) {
    final metadata = content.metadata;
    return DailyHoroscope(
      id: content.id,
      name: content.title,
      symbol: metadata['symbol']?.toString() ?? '',
      dateRange: metadata['dateRange']?.toString() ?? '',
      element: metadata['element']?.toString() ?? '',
      summary: content.description ?? content.subtitle ?? '',
      love: metadata['love']?.toString() ?? '',
      work: metadata['work']?.toString() ?? '',
      health: metadata['health']?.toString() ?? '',
      mood: metadata['mood']?.toString() ?? '',
      advice: metadata['advice']?.toString() ?? '',
      luckyNumber: _parseInt(metadata['luckyNumber']),
      luckyColor: metadata['luckyColor']?.toString() ?? '',
    );
  }

  static int _parseInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
