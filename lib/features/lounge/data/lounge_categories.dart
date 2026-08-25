import 'package:flutter/material.dart';

import '../domain/models/category_config.dart';

class LoungeCategoriesData {
  static const List<CategoryConfig> loungeCategories = [
    // 1. الأغاني اليمنية
    CategoryConfig(
      id: 'yemeni-songs',
      title: 'الأغاني اليمنية',
      gridTitle: 'الفنانين اليمنيين',
      bannerTitle: 'روائع الطرب الأصيل',
      bannerSubtitle: 'جلسات صنعانية وحضرمية\nمتجددة باستمرار',
      bannerImage:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/Sanaa.jpg/800px-Sanaa.jpg',
      primaryColor: Color(0xFFD32F2F),
      items: [],
    ),
    
    // 2. الأغاني العربية
    CategoryConfig(
      id: 'arabic-songs',
      title: 'الأغاني العربية',
      gridTitle: 'الفنانين العرب',
      bannerTitle: 'سحر الموسيقى العربية',
      bannerSubtitle: 'أجمل الأصوات والطرب العربي',
      bannerImage:
          'https://images.pexels.com/photos/1763075/pexels-photo-1763075.jpeg?auto=compress&cs=tinysrgb&w=800',
      primaryColor: Color(0xFF1976D2),
      items: [],
    ),

    // 3. الشيلات والقصائد الشعرية
    CategoryConfig(
      id: 'poetry-and-sheelat',
      title: 'الشيلات والقصائد الشعرية',
      gridTitle: 'التصنيفات',
      bannerTitle: 'أعذب الكلمات والقصائد',
      bannerSubtitle: 'شيلات وقصائد مختارة',
      bannerImage:
          'https://images.pexels.com/photos/226589/pexels-photo-226589.jpeg?auto=compress&cs=tinysrgb&w=800',
      primaryColor: Color(0xFFE64A19),
      items: [],
    ),

    // 4. الأناشيد الدينية
    CategoryConfig(
      id: 'religious-nasheed',
      title: 'الأناشيد الدينية',
      gridTitle: 'المنشدين',
      bannerTitle: 'روحانيات وأناشيد',
      bannerSubtitle: 'أناشيد إسلامية تلامس القلوب',
      bannerImage:
          'https://images.pexels.com/photos/1590154/pexels-photo-1590154.jpeg?auto=compress&cs=tinysrgb&w=800',
      primaryColor: Color(0xFF388E3C),
      items: [],
    ),

    // 5. القرآن الكريم
    CategoryConfig(
      id: 'holy-quran',
      title: 'القرآن الكريم',
      gridTitle: 'القراء',
      bannerTitle: 'تلاوات خاشعة',
      bannerSubtitle: 'القرآن الكريم بأعذب الأصوات',
      bannerImage:
          'https://images.pexels.com/photos/8164380/pexels-photo-8164380.jpeg?auto=compress&cs=tinysrgb&w=800',
      primaryColor: Color(0xFF00796B),
      items: [],
    ),

    // 6. الموسيقى
    CategoryConfig(
      id: 'music',
      title: 'الموسيقى',
      gridTitle: 'التصنيفات الموسيقية',
      bannerTitle: 'عالم الألحان',
      bannerSubtitle: 'مقطوعات موسيقية متنوعة',
      bannerImage:
          'https://images.pexels.com/photos/164745/pexels-photo-164745.jpeg?auto=compress&cs=tinysrgb&w=800',
      primaryColor: Color(0xFF8E24AA),
      items: [],
    ),

    // 7. مسلسلات إذاعية
    CategoryConfig(
      id: 'documentary-programs',
      title: 'مسلسلات إذاعية',
      gridTitle: 'قائمة المسلسلات',
      bannerTitle: 'حكايات تُروى بالصوت',
      bannerSubtitle: 'مسلسلات إذاعية ممتعة',
      bannerImage:
          'https://images.pexels.com/photos/164829/pexels-photo-164829.jpeg?auto=compress&cs=tinysrgb&w=800',
      primaryColor: Color(0xFF455A64),
      items: [],
    ),

    // 8. البرامج الثقافية
    CategoryConfig(
      id: 'cultural-programs',
      title: 'البرامج الثقافية',
      gridTitle: 'قائمة البرامج',
      bannerTitle: 'زاد المعرفة',
      bannerSubtitle: 'برامج ثقافية وأدبية',
      bannerImage:
          'https://images.pexels.com/photos/159711/books-bookstore-book-reading-159711.jpeg?auto=compress&cs=tinysrgb&w=800',
      primaryColor: Color(0xFF795548),
      items: [],
    ),

    // 9. البرامج الفنية
    CategoryConfig(
      id: 'art-programs',
      title: 'البرامج الفنية',
      gridTitle: 'قائمة البرامج',
      bannerTitle: 'عالم الفن',
      bannerSubtitle: 'لقاءات وحوارات فنية',
      bannerImage:
          'https://images.pexels.com/photos/164936/pexels-photo-164936.jpeg?auto=compress&cs=tinysrgb&w=800',
      primaryColor: Color(0xFFC2185B),
      items: [],
    ),

    // 10. البرامج الطبية
    CategoryConfig(
      id: 'medical-programs',
      title: 'البرامج الطبية',
      gridTitle: 'قائمة البرامج',
      bannerTitle: 'صحتك تهمنا',
      bannerSubtitle: 'نصائح واستشارات طبية',
      bannerImage:
          'https://images.pexels.com/photos/40568/medical-appointment-doctor-healthcare-40568.jpeg?auto=compress&cs=tinysrgb&w=800',
      primaryColor: Color(0xFF0288D1),
      items: [],
    ),

    // 11. البرامج الاجتماعية
    CategoryConfig(
      id: 'social-programs',
      title: 'البرامج الاجتماعية',
      gridTitle: 'قائمة البرامج',
      bannerTitle: 'المجتمع والناس',
      bannerSubtitle: 'قضايا وحوارات اجتماعية',
      bannerImage:
          'https://images.pexels.com/photos/3184180/pexels-photo-3184180.jpeg?auto=compress&cs=tinysrgb&w=800',
      primaryColor: Color(0xFFF57C00),
      items: [],
    ),

    // 12. البرامج الدينية
    CategoryConfig(
      id: 'religious-programs',
      title: 'البرامج الدينية',
      gridTitle: 'قائمة البرامج',
      bannerTitle: 'نور على نور',
      bannerSubtitle: 'برامج ومواعظ دينية',
      bannerImage:
          'https://images.pexels.com/photos/2233391/pexels-photo-2233391.jpeg?auto=compress&cs=tinysrgb&w=800',
      primaryColor: Color(0xFF00897B),
      items: [],
    ),
  ];
}
