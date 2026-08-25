import 'package:flutter/material.dart';

// 1. تعريف الكلاس هنا مباشرة لكي لا يبحث التطبيق في أي ملفات أخرى ضائعة
class BottomNavItem {
  final String id; // مسار أو معرف ثابت (Route) لتسهيل الربط مع GoRouter
  final String title;
  final IconData icon;
  final IconData? activeIcon; // خاصية اختيارية لدعم أيقونة مختلفة عند التفعيل
  final bool hasBadge; // خاصية اختيارية لدعم شارات الإشعارات (Badges)

  const BottomNavItem({
    required this.id,
    required this.title,
    required this.icon,
    this.activeIcon,
    this.hasBadge = false, // القيمة الافتراضية هي إخفاء الشارة
  });
}

// 2. القائمة المحدثة بالشكل الجديد
const List<BottomNavItem> bottomNavItems = [
  BottomNavItem(
    id: '/home',
    title: 'الرئيسية', 
    icon: Icons.home_rounded,
  ),
  BottomNavItem(
    id: '/programs',
    title: 'برامج FM', 
    icon: Icons.radio_rounded,
  ),
  BottomNavItem(
    id: '/stations',
    title: 'إذاعات FM',
    icon: Icons.cell_tower_rounded,
  ), // الأيقونة والاسم الجديد
  BottomNavItem(
    id: '/library',
    title: 'مكتبتي', 
    icon: Icons.library_books_rounded,
  ),
  BottomNavItem(
    id: '/more',
    title: 'المزيد', 
    icon: Icons.menu_rounded,
    // hasBadge: true, // يمكنك تفعيل هذه الخاصية مستقبلاً لظهور شارة على هذا العنصر
  ),
];