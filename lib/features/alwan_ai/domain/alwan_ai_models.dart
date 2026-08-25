import 'package:flutter/foundation.dart';

enum AlwanAiMode { chat, search, image, music }

enum AlwanAiMessageRole { user, assistant }

@immutable
class AlwanAiMessage {
  const AlwanAiMessage({
    required this.id,
    required this.role,
    required this.text,
    this.imageUrl,
    this.audioUrl,
    this.mediaTitle,
  });

  final String id;
  final AlwanAiMessageRole role;
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  final String? mediaTitle;
}

@immutable
class AlwanAiGatewayResponse {
  const AlwanAiGatewayResponse({
    required this.text,
    this.imageUrl,
    this.audioUrl,
    this.title,
  });

  final String text;
  final String? imageUrl;
  final String? audioUrl;
  final String? title;
}
