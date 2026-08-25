import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:alwan_hub/core/services/link_launcher_service.dart';

class ChallengeInvitationService {
  ChallengeInvitationService({LinkLauncherService? launcher})
    : _launcher = launcher ?? LinkLauncherService();

  static const _outboxKey = 'games.challenge_notification_outbox';
  final LinkLauncherService _launcher;

  /// Stores a dashboard-ready broadcast request until a remote push endpoint
  /// is configured. This keeps the client free from privileged push keys.
  Future<void> queueGroupNotification({
    required String challengeId,
    required String challengeTitle,
    required String inviteCode,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final outbox = preferences.getStringList(_outboxKey) ?? <String>[];
    outbox.add(
      jsonEncode({
        'type': 'challenge_invitation',
        'challengeId': challengeId,
        'title': challengeTitle,
        'inviteCode': inviteCode,
        'audience': 'all_app_installations',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'status': 'queued',
      }),
    );
    await preferences.setStringList(_outboxKey, outbox);
  }

  Future<bool> sendWhatsApp(String message) {
    final uri = Uri.https('wa.me', '/', {'text': message});
    return _launcher.open(uri.toString());
  }

  Future<bool> sendSms(String message) {
    final uri = Uri(scheme: 'sms', queryParameters: {'body': message});
    return _launcher.open(uri.toString());
  }
}
