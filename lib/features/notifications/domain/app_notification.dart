import 'package:flutter/material.dart';

class AppNotificationItem {
  const AppNotificationItem({
    required this.id,
    required this.emoji,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    required this.category,
    this.isUnread = true,
  });

  final String id;
  final String emoji;
  final Color color;
  final String title;
  final String body;
  final String time;
  final String category;
  final bool isUnread;

  AppNotificationItem copyWith({bool? isUnread}) {
    return AppNotificationItem(
      id: id,
      emoji: emoji,
      color: color,
      title: title,
      body: body,
      time: time,
      category: category,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}

abstract final class NotificationCatalog {
  static const filters = <String>[
    'الكل',
    'غير مقروء',
    'البرامج 📻',
    'المسابقات 🏆',
    'الأخبار 📰',
    'الكتب الصوتية 📚',
    'البث المباشر 📡',
    'الذكاء الاصطناعي 🤖',
  ];

  static const items = <AppNotificationItem>[
    AppNotificationItem(
      id: '1',
      emoji: '🎧',
      color: Color(0xFFFF8A65),
      title: 'تمت إضافة حلقة جديدة إلى برنامجك المفضل',
      body: 'حلقة «الصباح مع ألوان» متوفرة الآن',
      time: 'الآن',
      category: 'البرامج',
    ),
    AppNotificationItem(
      id: '2',
      emoji: '📡',
      color: Color(0xFFFF5252),
      title: 'بدأ الآن البث المباشر لبرنامج الصباح',
      body: 'لا تفوّت حلقة اليوم مع فريق ألوان',
      time: 'منذ 5 دقائق',
      category: 'البث المباشر',
    ),
    AppNotificationItem(
      id: '3',
      emoji: '✔️',
      color: Color(0xFF42A5F5),
      title: 'تم قبول تصويتك في استفتاء أفضل برنامج',
      body: 'شكراً لمشاركتك في التصويت',
      time: 'منذ 15 دقيقة',
      category: 'المسابقات',
    ),
    AppNotificationItem(
      id: '4',
      emoji: '⭐',
      color: Color(0xFFFFC107),
      title: 'أضاف فريق ألوان محتوى جديداً',
      body: 'اكتشف الآن المقاطع والحلقات الجديدة',
      time: 'منذ ساعة',
      category: 'الكل',
      isUnread: false,
    ),
    AppNotificationItem(
      id: '5',
      emoji: '📚',
      color: Color(0xFF7E57C2),
      title: 'تمت إضافة كتاب صوتي جديد',
      body: 'استمع الآن إلى كتاب «العادات الذرية»',
      time: 'منذ ساعتين',
      category: 'الكتب الصوتية',
    ),
    AppNotificationItem(
      id: '6',
      emoji: '📰',
      color: Color(0xFFEF5350),
      title: 'عاجل: أخبار جديدة تهمك',
      body: 'اقرأ أحدث المستجدات في قسم الأخبار',
      time: 'منذ 3 ساعات',
      category: 'الأخبار',
      isUnread: false,
    ),
  ];
}
