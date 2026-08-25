import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:alwan_hub/features/alwan_ai/data/alwan_ai_gateway.dart';

void main() {
  test(
    'uses the secure chat gateway contract and parses voice output',
    () async {
      late Map<String, dynamic> requestBody;
      final client = MockClient((request) async {
        expect(request.url.path, '/v1/assistant/chat');
        requestBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'text': 'مرحبًا بك',
            'audioUrl': 'https://example.com/reply.mp3',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final gateway = HttpAlwanAiGateway(
        baseUrl: 'https://ai.example.com/',
        client: client,
      );

      final response = await gateway.chat(
        message: 'ابحث لي عن خبر',
        voiceReply: true,
      );

      expect(requestBody['model'], 'chat-latest');
      expect(requestBody['voiceModel'], 'gpt-realtime-2.1');
      expect(requestBody['voiceReply'], isTrue);
      expect(response.text, 'مرحبًا بك');
      expect(response.audioUrl, 'https://example.com/reply.mp3');
    },
  );

  test('parses base64 image output returned by the gateway', () async {
    final gateway = HttpAlwanAiGateway(
      baseUrl: 'https://ai.example.com',
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'imageBase64': 'aW1hZ2U=', 'mimeType': 'image/png'}),
          200,
        ),
      ),
    );

    final response = await gateway.generateImage('سماء ملونة');

    expect(response.imageUrl, 'data:image/png;base64,aW1hZ2U=');
  });
}
