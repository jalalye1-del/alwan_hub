import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'bottom_nav_data.dart';

// يُفترض استدعاء ملف الألوان المركزي الخاص بك هنا
// import 'app_colors.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    final responsive = context.responsive;
    final barHeight = responsive.value(compact: 72, medium: 76, expanded: 80);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.zero,
      // الارتفاع الكلي الذي يعطي فخامة أكبر للمربع الزجاجي
      height: barHeight + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        // --- التدرج اللوني المعتمد على AppColors بدلاً من القيم الثابتة ---
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            AppColors.navGradientStart, // بديل Color(0xFF5414C4)
            AppColors.navGradientMiddle, // بديل Color(0xFF3B24D0)
            AppColors.navGradientEnd, // بديل Color(0xFF1B40EB)
          ],
        ),
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: AppColors.navGradientEnd.withValues(alpha: .25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Row(
            children: List.generate(bottomNavItems.length, (index) {
              final item = bottomNavItems[index];
              final selected = currentIndex == index;

              return Expanded(
                // إضافة Semantics لمساعدة قارئات الشاشة في التعرف على العنصر وحالته
                child: Semantics(
                  label: item.title,
                  selected: selected,
                  button: true,
                  // إضافة Tooltip كخيار إضافي لتحسين إمكانية الوصول وتجربة المستخدم
                  child: Tooltip(
                    message: item.title,
                    child: InkWell(
                      onTap: () => onTap(index),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 6,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          // إطار الزجاج
                          border: selected
                              ? Border.all(
                                  color: AppColors.glassColor.withValues(
                                    alpha: 0.35,
                                  ),
                                  width: 1.2,
                                )
                              : Border.all(
                                  color: Colors.transparent,
                                  width: 1.2,
                                ),
                          // التدرج الزجاجي (Glassmorphism)
                          gradient: selected
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.glassColor.withValues(
                                      alpha: 0.28,
                                    ),
                                    AppColors.glassColor.withValues(
                                      alpha: 0.05,
                                    ),
                                  ],
                                )
                              : null,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.icon,
                                color: AppColors.navIconColor,
                                size: responsive.value(
                                  compact: selected ? 26 : 22,
                                  medium: selected ? 28 : 24,
                                  expanded: selected ? 30 : 26,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.title,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: 'MohammadBoldArt',
                                  fontSize: responsive.value(
                                    compact: 12,
                                    medium: 13,
                                    expanded: 14,
                                  ),
                                  height: 1.05,
                                  color: AppColors.navTextColor.withValues(
                                    alpha: selected ? 1 : .70,
                                  ),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// توضيح لكلاس AppColors المقترح لتغطية الألوان التي تمت إزالتها:
// ---------------------------------------------------------
class AppColors {
  // ألوان تدرج شريط التنقل
  static const Color navGradientStart = Color(0xFF5414C4);
  static const Color navGradientMiddle = Color(0xFF3B24D0);
  static const Color navGradientEnd = Color(0xFF1B40EB);

  // ألوان الواجهة الزجاجية والنصوص (كانت تعتمد على Colors.white سابقاً)
  static const Color glassColor = Colors.white;
  static const Color navIconColor = Colors.white;
  static const Color navTextColor = Colors.white;
}
