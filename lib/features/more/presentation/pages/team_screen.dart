import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/more/presentation/widgets/more_typography.dart';
import 'package:alwan_hub/features/notifications/presentation/pages/notifications_screen.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  static const _members = <_TeamMember>[
    _TeamMember(
      name: 'محمد الثقاف',
      role: 'منتج محتوى',
      icon: Icons.video_camera_front_rounded,
      color: Color(0xFF2695DE),
    ),
    _TeamMember(
      name: 'سارة البوشي',
      role: 'مذيعة',
      icon: Icons.mic_rounded,
      color: Color(0xFF6F3CC3),
    ),
    _TeamMember(
      name: 'أحمد الحميد',
      role: 'مقدم برامج',
      icon: Icons.record_voice_over_rounded,
      color: Color(0xFFE92669),
    ),
    _TeamMember(
      name: 'ريم الحميري',
      role: 'إعداد برامج',
      icon: Icons.edit_note_rounded,
      color: Color(0xFF2999E0),
    ),
    _TeamMember(
      name: 'خالد الشهري',
      role: 'مهندس صوت',
      icon: Icons.graphic_eq_rounded,
      color: Color(0xFF0AA19D),
    ),
    _TeamMember(
      name: 'نورة اليماني',
      role: 'مدققة أخبار',
      icon: Icons.fact_check_rounded,
      color: Color(0xFFFF6429),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MoreTypography(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FD),
        body: Column(
          children: [
            AlwanPageHeader(
              title: 'فريق ألوان',
              subtitle: 'تعرف على أعضاء فريق ألوان الإبداعي',
              onNotificationTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 30),
                child: ResponsiveContent(
                  maxWidth: 900,
                  child: Column(
                    children: [
                      const _TeamIntro(),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 650 ? 3 : 3;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _members.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 9,
                                  mainAxisSpacing: 11,
                                  childAspectRatio: constraints.maxWidth >= 650
                                      ? .96
                                      : .69,
                                ),
                            itemBuilder: (context, index) =>
                                _TeamMemberCard(member: _members[index]),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      const _JoinTeamNote(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamMember {
  const _TeamMember({
    required this.name,
    required this.role,
    required this.icon,
    required this.color,
  });

  final String name;
  final String role;
  final IconData icon;
  final Color color;
}

class _TeamIntro extends StatelessWidget {
  const _TeamIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFFF0EBFB), Color(0xFFEAF5FF)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDAD9ED)),
      ),
      child: const Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF343A8D), Color(0xFF9E25AE)],
              ),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.groups_rounded, color: Colors.white),
            ),
          ),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'صنّاع صوت ألوان',
                  style: TextStyle(
                    color: Color(0xFF2A3070),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'إعلاميون ومبدعون وتقنيون يعملون بروح فريق واحد',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  const _TeamMemberCard({required this.member});

  final _TeamMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9DFE8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12131D33),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    member.color.withValues(alpha: .24),
                    member.color.withValues(alpha: .07),
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .90),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Icon(member.icon, color: member.color, size: 31),
                  ),
                  Positioned(
                    bottom: 7,
                    left: 7,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: member.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 7),
            child: Column(
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF292E66),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: member.color,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    member.role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinTeamNote extends StatelessWidget {
  const _JoinTeamNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.auto_awesome_rounded, color: Color(0xFF8A32A6), size: 17),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            'نصنع المحتوى بحب، ونكبر مع ثقة جمهور ألوان',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
        ),
      ],
    );
  }
}
