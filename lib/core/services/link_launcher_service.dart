import 'package:flutter/foundation.dart'; // تمت الإضافة لاستخدام debugPrint
import 'package:url_launcher/url_launcher.dart';

class LinkLauncherService {
  
  /// الدالة الرئيسية لفتح الروابط مع توفير خيار تحديد وضع الفتح (LaunchMode)
  Future<bool> open(
    String url, {
    // تعيين الفتح الخارجي كوضع افتراضي كما كان في الكود الأصلي
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    try {
      final uri = Uri.parse(url); //

      if (!await canLaunchUrl(uri)) { //
        return false; //[cite: 13]
      }

      await launchUrl(uri, mode: mode); //[cite: 13]

      return true; //[cite: 13]
    } catch (e) {
      // التقاط أي استثناءات (مثل فشل Uri.parse في تحليل نص غير صالح)
      debugPrint('Exception in LinkLauncherService: $e');
      return false;
    }
  }

  // =================================================================
  // دوال مساعدة (Helper Methods) لتوسيع قدرات الخدمة مستقبلاً
  // =================================================================

  /// فتح متصفح داخل التطبيق (In-App Browser)
  Future<bool> openInApp(String url) async {
    return open(url, mode: LaunchMode.inAppWebView);
  }

  /// فتح تطبيق البريد الإلكتروني الافتراضي
  Future<bool> openEmail(String email, {String? subject}) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: subject != null ? 'subject=${Uri.encodeComponent(subject)}' : null,
    );
    return open(emailUri.toString());
  }

  /// فتح تطبيق الاتصال الهاتفي 
  Future<bool> openPhone(String phoneNumber) async {
    return open('tel:$phoneNumber');
  }
}