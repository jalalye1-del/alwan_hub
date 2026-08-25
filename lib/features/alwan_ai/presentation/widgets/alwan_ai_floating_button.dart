import 'package:flutter/material.dart';

/// زر عائم لا يدخل في حساب ارتفاع أو ترتيب محتوى الواجهة الرئيسية.
class AlwanAiFloatingButton extends StatelessWidget {
  const AlwanAiFloatingButton({super.key, required this.onTap, this.size = 66});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'فتح مساعد ألوان AI',
      button: true,
      child: Tooltip(
        message: 'ألوان AI',
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            key: const ValueKey('home-alwan-ai-floating-button'),
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Ink(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF7A25DC),
                    Color(0xFF2754E6),
                    Color(0xFF06A9C7),
                  ],
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x556C27D9),
                    blurRadius: 22,
                    offset: Offset(0, 9),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 31,
                    ),
                  ),
                  PositionedDirectional(
                    start: 1,
                    bottom: 1,
                    child: Container(
                      width: size * .34,
                      height: size * .34,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mic_rounded,
                        size: size * .2,
                        color: const Color(0xFF6429D5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
