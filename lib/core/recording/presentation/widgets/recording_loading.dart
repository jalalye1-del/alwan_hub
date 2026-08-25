import 'package:flutter/material.dart';

class RecordingLoading extends StatelessWidget {
  const RecordingLoading({
    super.key,
    this.itemCount = 6,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, _) =>
          const SizedBox(height: 14),
      itemBuilder: (_, _) {
        return const _LoadingCard();
      },
    );
  }
}

class _LoadingCard extends StatefulWidget {
  const _LoadingCard();

  @override
  State<_LoadingCard> createState() =>
      _LoadingCardState();
}

class _LoadingCardState
    extends State<_LoadingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context)
        .colorScheme
        .surfaceContainerHighest;

    return FadeTransition(
      opacity: Tween<double>(
        begin: .35,
        end: .9,
      ).animate(_controller),
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius:
              BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius:
                    BorderRadius.circular(18),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    height: 12,
                    width: 170,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    height: 10,
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}