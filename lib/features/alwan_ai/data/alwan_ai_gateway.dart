import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../domain/alwan_ai_models.dart';

/// عنوان البوابة الخلفية الآمنة. لا توضع مفاتيح OpenAI أو Gemini داخل التطبيق.
const alwanAiBaseUrl = String.fromEnvironment('ALWAN_AI_BASE_URL');

abstract interface class AlwanAiGateway {
  bool get isConfigured;

  Future<AlwanAiGatewayResponse> chat({
    required String message,
    required bool voiceReply,
  });

  Future<AlwanAiGatewayResponse> generateImage(String prompt);

  Future<AlwanAiGatewayResponse> generateMusic({
    required String prompt,
    required bool fullSong,
  });
}

class HttpAlwanAiGateway implements AlwanAiGateway {
  HttpAlwanAiGateway({required String baseUrl, http.Client? client})
    : _baseUrl = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl,
      _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  @override
  bool get isConfigured => _baseUrl.isNotEmpty;

  @override
  Future<AlwanAiGatewayResponse> chat({
    required String message,
    required bool voiceReply,
  }) {
    return _post(
      '/v1/assistant/chat',
      body: {
        'message': message,
        'voiceReply': voiceReply,
        'model': 'chat-latest',
        'voiceModel': 'gpt-realtime-2.1',
        'language': 'ar',
      },
    );
  }

  @override
  Future<AlwanAiGatewayResponse> generateImage(String prompt) {
    return _post(
      '/v1/assistant/images',
      body: {
        'prompt': prompt,
        'model': 'gemini-3.1-flash-image',
        'aspectRatio': '1:1',
        'imageSize': '1K',
      },
    );
  }

  @override
  Future<AlwanAiGatewayResponse> generateMusic({
    required String prompt,
    required bool fullSong,
  }) {
    return _post(
      '/v1/assistant/music',
      body: {
        'prompt': prompt,
        'model': fullSong ? 'lyria-3-pro-preview' : 'lyria-3-clip-preview',
        'fullSong': fullSong,
      },
    );
  }

  Future<AlwanAiGatewayResponse> _post(
    String path, {
    required Map<String, Object?> body,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 90));

      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AlwanAiGatewayException(
          _stringValue(decoded, const ['message', 'error']) ??
              'تعذر إكمال الطلب (${response.statusCode}).',
        );
      }

      final imageUrl = _mediaUrl(
        decoded,
        urlKeys: const ['imageUrl', 'image_url', 'url'],
        base64Keys: const ['imageBase64', 'image_base64'],
        defaultMime: 'image/png',
      );
      final audioUrl = _mediaUrl(
        decoded,
        urlKeys: const ['audioUrl', 'audio_url'],
        base64Keys: const ['audioBase64', 'audio_base64'],
        defaultMime: 'audio/mpeg',
      );

      return AlwanAiGatewayResponse(
        text:
            _stringValue(decoded, const ['text', 'answer', 'message']) ??
            (imageUrl != null
                ? 'تم إنشاء الصورة بنجاح.'
                : audioUrl != null
                ? 'تم إنشاء المقطع الصوتي بنجاح.'
                : 'تم تنفيذ الطلب.'),
        imageUrl: imageUrl,
        audioUrl: audioUrl,
        title: _stringValue(decoded, const ['title', 'name']),
      );
    } on AlwanAiGatewayException {
      rethrow;
    } on FormatException {
      throw const AlwanAiGatewayException('استجابة بوابة ألوان AI غير صالحة.');
    } catch (_) {
      throw const AlwanAiGatewayException(
        'تعذر الاتصال بخدمة ألوان AI. تحقق من الإنترنت وإعداد الخادم.',
      );
    }
  }

  String? _mediaUrl(
    Map<String, dynamic> json, {
    required List<String> urlKeys,
    required List<String> base64Keys,
    required String defaultMime,
  }) {
    final direct = _stringValue(json, urlKeys);
    if (direct != null && direct.isNotEmpty) return direct;

    final encoded = _stringValue(json, base64Keys);
    if (encoded == null || encoded.isEmpty) return null;
    final mime = _stringValue(json, const ['mimeType', 'mime_type']);
    return 'data:${mime ?? defaultMime};base64,$encoded';
  }

  String? _stringValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is Map<String, dynamic>) {
        final nested = _stringValue(value, const ['message', 'text']);
        if (nested != null) return nested;
      }
    }

    final data = json['data'];
    if (data is Map<String, dynamic>) return _stringValue(data, keys);
    final output = json['output'];
    if (output is Map<String, dynamic>) return _stringValue(output, keys);
    return null;
  }
}

class UnconfiguredAlwanAiGateway implements AlwanAiGateway {
  const UnconfiguredAlwanAiGateway();

  @override
  bool get isConfigured => false;

  Never _notConfigured() => throw const AlwanAiGatewayException(
    'الأوامر المحلية جاهزة. يلزم ضبط ALWAN_AI_BASE_URL لتفعيل خدمات ChatGPT وGemini السحابية.',
  );

  @override
  Future<AlwanAiGatewayResponse> chat({
    required String message,
    required bool voiceReply,
  }) async => _notConfigured();

  @override
  Future<AlwanAiGatewayResponse> generateImage(String prompt) async =>
      _notConfigured();

  @override
  Future<AlwanAiGatewayResponse> generateMusic({
    required String prompt,
    required bool fullSong,
  }) async => _notConfigured();
}

class AlwanAiGatewayException implements Exception {
  const AlwanAiGatewayException(this.message);

  final String message;

  @override
  String toString() => message;
}

final alwanAiGatewayProvider = Provider<AlwanAiGateway>((ref) {
  if (alwanAiBaseUrl.trim().isEmpty) {
    return const UnconfiguredAlwanAiGateway();
  }
  return HttpAlwanAiGateway(baseUrl: alwanAiBaseUrl.trim());
});
