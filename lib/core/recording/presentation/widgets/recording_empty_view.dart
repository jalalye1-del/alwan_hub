// lib/core/recording/presentation/widgets/recording_empty_view.dart

import 'package:flutter/material.dart';

class RecordingEmptyView extends StatelessWidget {
  const RecordingEmptyView({
    super.key,
    this.title = 'لا توجد تسجيلات',
    this.message =
        'لم يتم العثور على أي تسجيلات حتى الآن.\nابدأ بتسجيل البث أو برامجك المفضلة لتظهر هنا.',
    this.buttonText,
    this.onPressed,
    this.icon = Icons.library_music_outlined,
  });

  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: .08), //[cite: 8]
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 58,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 28),

            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),

            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 30),

              FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.fiber_manual_record),
                label: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}