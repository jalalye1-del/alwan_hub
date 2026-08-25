import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/features/interaction/data/live_program_interaction_service.dart';

/// يمكن استبداله في bootstrap بخدمة مرتبطة فعليًا بلوحة التحكم أو WebSocket.
final liveProgramInteractionServiceProvider =
    Provider<LiveProgramInteractionService>((ref) {
      return LiveProgramInteractionService.instance;
    });
