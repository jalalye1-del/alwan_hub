// lib/core/recording/services/recording_platform.dart

import 'dart:async';

import 'recording_factory.dart';
import 'recording_types.dart';

// =========================================================================
// عقد منصة التسجيل (Recording Platform Contract)
// =========================================================================

/// واجهة أساسية تحدد عقد منصة التسجيل (Recording Platform Contract).
/// 
/// [تلميح للتوسع المستقبلي]:
/// إذا احتاج المشروع لاحقًا إلى دعم الإيقاف المؤقت (Pause) والاستئناف (Resume)، 
/// يمكن توسيع هذه الواجهة بإضافة دوال مثل `pauseRecording()` و `resumeRecording()` 
/// دون كسر البنية المعمارية الحالية.
abstract interface class RecordingPlatform {
  /// حالة التسجيل الحالية. تُرجع [true] إذا كان هناك تسجيل نشط قيد التقدم.
  bool get isRecording;

  /// المدة الزمنية المستغرقة حتى اللحظة في التسجيل النشط.
  Duration get currentDuration;

  /// إجمالي حجم البيانات التي تم تسجيلها حتى اللحظة بالبايت (Bytes).
  int get recordedBytes;

  /// مجرى (Stream) يبث تحديثات التقدم بشكل دوري (مثل المدة الزمنية وحجم البيانات المستهلكة).
  Stream<RecordingProgress> get progressStream;

  /// يبدأ عملية تسجيل المادة الصوتية من الرابط المحدد.
  /// 
  /// - **حالة النجاح:** يُمثل [RecordingResult] نجاح تهيئة وبدء التسجيل وتكوين الملف المبدئي.
  /// - **حالة الفشل:** يُمثل [RecordingResult] سبب الإخفاق (مثل عدم وجود اتصال بالشبكة، الرابط غير صالح، أو رفض صلاحيات النظام).
  Future<RecordingResult<RecordingOutput>> startRecording({
    required String streamUrl,
    required String title,
    required String filePath,
  });

  /// يوقف عملية التسجيل الحالية ويقوم بحفظ الملف النهائي في المسار المحدد.
  /// 
  /// - **حالة النجاح:** يُمثل [RecordingResult] اكتمال عملية التسجيل بنجاح، ويُرجع كائن [RecordingOutput] يحتوي على التفاصيل والمسار النهائي.
  /// - **حالة الفشل:** يُمثل [RecordingResult] حدوث خطأ منع حفظ الملف بنجاح (مثل امتلاء مساحة التخزين أو تلف تدفق البيانات).
  Future<RecordingResult<RecordingOutput>> stopRecording();

  /// يلغي عملية التسجيل الحالية فوراً، ويتخلص من أي ملفات مؤقتة تم إنشاؤها دون حفظها.
  Future<void> cancelRecording();

  /// يُحرر الموارد والذاكرة المستخدمة بواسطة منصة التسجيل. يجب استدعاؤه عند تدمير الكائن (Dispose) أو انتهاء الحاجة للخدمة.
  Future<void> dispose();
}

RecordingPlatform buildRecordingPlatform() {
  return createRecordingPlatform();
}
