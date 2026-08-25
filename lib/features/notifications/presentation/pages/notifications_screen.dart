import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/profile/presentation/widgets/profile_ad_banner.dart';
import 'package:alwan_hub/features/notifications/domain/app_notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<AppNotificationItem> _notifications;
  String _filter = 'الكل';
  bool _notificationsEnabled = true;
  bool _muteMode = false;
  TimeOfDay _quietStart = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    _notifications = List.of(NotificationCatalog.items);
  }

  List<AppNotificationItem> get _visibleNotifications {
    if (_filter == 'الكل') return _notifications;
    if (_filter == 'غير مقروء') {
      return _notifications.where((item) => item.isUnread).toList();
    }
    final category = switch (_filter) {
      'البرامج 📻' => 'البرامج',
      'المسابقات 🏆' => 'المسابقات',
      'الأخبار 📰' => 'الأخبار',
      'الكتب الصوتية 📚' => 'الكتب الصوتية',
      'البث المباشر 📡' => 'البث المباشر',
      'الذكاء الاصطناعي 🤖' => 'الذكاء الاصطناعي',
      _ => _filter,
    };
    return _notifications.where((item) => item.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleNotifications;
    final unreadCount = _notifications.where((item) => item.isUnread).length;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Column(
        children: [
          AlwanPageHeader(
            title: 'الإشعارات',
            subtitle: 'كل ما يهمك في منصة ألوان',
            trailing: IconButton.filledTonal(
              tooltip: context.translateInterface('تحديد الكل كمقروء'),
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all_rounded),
            ),
          ),
          Expanded(
            child: ResponsiveContent(
              maxWidth: 920,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _NotificationSettingsCard(
                      notificationsEnabled: _notificationsEnabled,
                      muteMode: _muteMode,
                      quietPeriod:
                          'من ${_formatTime(_quietStart)} إلى ${_formatTime(_quietEnd)}',
                      onNotificationsChanged: (value) => setState(() {
                        _notificationsEnabled = value;
                        if (!value) _muteMode = false;
                      }),
                      onMuteChanged: _notificationsEnabled
                          ? (value) => setState(() => _muteMode = value)
                          : null,
                      onQuietPeriodTap: _pickQuietPeriod,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  const SliverToBoxAdapter(child: _NotificationAdBanner()),
                  const SliverToBoxAdapter(child: SizedBox(height: 22)),
                  SliverToBoxAdapter(
                    child: _NotificationsSectionHeader(
                      unreadCount: unreadCount,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: NotificationCatalog.filters.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final filter = NotificationCatalog.filters[index];
                          return FilterChip(
                            selected: _filter == filter,
                            label: Text(filter),
                            avatar: filter == 'غير مقروء'
                                ? Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : null,
                            onSelected: (_) => setState(() => _filter = filter),
                          );
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  if (visible.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyNotifications(),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index.isOdd) return const SizedBox(height: 10);
                        final item = visible[index ~/ 2];
                        return _NotificationCard(
                          item: item,
                          onTap: () => _markRead(item.id),
                        );
                      }, childCount: visible.length * 2 - 1),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _markRead(String id) {
    setState(() {
      _notifications = _notifications
          .map((item) => item.id == id ? item.copyWith(isUnread: false) : item)
          .toList();
    });
  }

  void _markAllRead() {
    setState(() {
      _notifications = _notifications
          .map((item) => item.copyWith(isUnread: false))
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديد جميع الإشعارات كمقروءة')),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'صباحًا' : 'مساءً';
    return '$hour:$minute $period';
  }

  Future<void> _pickQuietPeriod() async {
    final start = await showTimePicker(
      context: context,
      initialTime: _quietStart,
      helpText: 'بداية فترة الهدوء',
      cancelText: 'إلغاء',
      confirmText: 'التالي',
    );
    if (start == null || !mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: _quietEnd,
      helpText: 'نهاية فترة الهدوء',
      cancelText: 'إلغاء',
      confirmText: 'حفظ',
    );
    if (end == null || !mounted) return;

    setState(() {
      _quietStart = start;
      _quietEnd = end;
    });
  }
}

class _NotificationSettingsCard extends StatelessWidget {
  const _NotificationSettingsCard({
    required this.notificationsEnabled,
    required this.muteMode,
    required this.quietPeriod,
    required this.onNotificationsChanged,
    required this.onMuteChanged,
    required this.onQuietPeriodTap,
  });

  final bool notificationsEnabled;
  final bool muteMode;
  final String quietPeriod;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool>? onMuteChanged;
  final VoidCallback onQuietPeriodTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF2E3289), Color(0xFF9820B5)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A238C).withValues(alpha: .24),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings_rounded, color: Color(0xFF9DE5F4)),
                SizedBox(width: 9),
                Text(
                  'إعدادات الإشعارات والتذكير',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const _SettingsDivider(),
            _NotificationSwitchRow(
              title: 'إشعارات التطبيق وبث المسابقات',
              subtitle: 'مفعّل للحصول على تنبيه البث المباشر فورًا',
              value: notificationsEnabled,
              onChanged: onNotificationsChanged,
            ),
            const _SettingsDivider(),
            _NotificationSwitchRow(
              title: 'وضع كتم وإيقاف الإزعاج المؤقت',
              subtitle: 'تعطيل مؤقت للتنبيهات الصوتية المزعجة',
              value: muteMode,
              onChanged: onMuteChanged,
            ),
            const _SettingsDivider(),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onQuietPeriodTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'الفترة الزمنية للهدوء',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          quietPeriod,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                        color: Colors.white,
                      ),
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

class _NotificationSwitchRow extends StatelessWidget {
  const _NotificationSwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onChanged == null ? .52 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF322A83),
              activeTrackColor: Colors.white,
              inactiveThumbColor: Colors.white70,
              inactiveTrackColor: Colors.white24,
              trackOutlineColor: WidgetStatePropertyAll(Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(color: Colors.white.withValues(alpha: .20), height: 14);
  }
}

class _NotificationAdBanner extends StatelessWidget {
  const _NotificationAdBanner();

  @override
  Widget build(BuildContext context) {
    return const ProfileAdBanner(
      imageAsset: 'assets/images/banners/banner1.jpg',
      headline: 'مساحتك الإعلانية تصل إلى جمهور ألوان',
    );
  }
}

class _NotificationsSectionHeader extends StatelessWidget {
  const _NotificationsSectionHeader({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'آخر الإشعارات',
            style: TextStyle(
              color: Color(0xFF202B65),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF7E57C2).withValues(alpha: .10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            unreadCount == 0 ? 'تمت القراءة' : '$unreadCount غير مقروءة',
            style: const TextStyle(
              color: Color(0xFF6A1B9A),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final AppNotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 94),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.isUnread
                  ? const Color(0xFF65218C)
                  : AppColors.divider,
              width: item.isUnread ? 1.8 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D101828),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: .14),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(item.emoji, style: const TextStyle(fontSize: 23)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF242D72),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: item.isUnread
                            ? const Color(0xFF9C27B0)
                            : const Color(0xFFD4DFEB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.time,
                      style: const TextStyle(
                        color: Color(0xFF93A1B3),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 54,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            'لا توجد إشعارات حالياً لهذه الفئة',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
