// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';

import 'core/audio/audio_handler.dart';
import 'core/audio/audio_manager.dart';
import 'core/storage/hive_service.dart';
import 'core/theme/theme_mode_controller.dart';
import 'core/recording/services/recording_platform_registration.dart';
import 'core/localization/app_locale_controller.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة محرك قاعدة البيانات Hive أولاً
  await HiveService.init();
  await AppThemeModeController.instance.initialize();
  await AppLocaleController.instance.initialize();

  registerDefaultRecordingPlatform();

  // 2. تهيئة خدمة الصوت الأساسية للتحكم بالبث والمشغل.
  // عند تعذر الخدمة الخلفية يبقى المشغل المحلي متاحاً بدلاً من ترك
  // AudioManager دون معالج وظهور LateInitializationError لاحقاً.
  late AlwanAudioHandler audioHandler;
  try {
    audioHandler = await AudioService.init(
      builder: () => AlwanAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'fm.alwan.alwan_hub.audio',
        androidNotificationChannelName: 'Alwan Hub Audio',
        androidNotificationOngoing: true,
      ),
    );

  } catch (e, s) {
    debugPrint('تعذر تهيئة خدمة الصوت الخلفية، سيتم استخدام المشغل المحلي: $e');
    debugPrintStack(stackTrace: s);

    FlutterError.reportError(
      FlutterErrorDetails(
        exception: e,
        stack: s,
        library: 'main.dart',
        context: ErrorDescription('AudioService Initialization Failed'),
      ),
    );

    audioHandler = AlwanAudioHandler();
  }

  AudioManager.instance.setAudioHandler(audioHandler);

  runApp(ProviderScope(child: const AlwanHubApp()));
}
