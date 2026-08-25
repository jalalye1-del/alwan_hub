import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/core/audio/audio_controller.dart';
import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/widgets/adaptive_content_image.dart';
import 'package:alwan_hub/features/programs/domain/entities/fm_program.dart';
import 'package:alwan_hub/features/programs/presentation/providers/fm_program_provider.dart';

const _programsFont = 'MohammadBoldArt';
const _programsInk = Color(0xFF171561);
const _programsPurple = Color(0xFF4B35E8);

class FmProgramsScreen extends ConsumerStatefulWidget {
  const FmProgramsScreen({super.key});

  @override
  ConsumerState<FmProgramsScreen> createState() => _FmProgramsScreenState();
}

class _FmProgramsScreenState extends ConsumerState<FmProgramsScreen> {
  static const _days = [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  int _selectedDayIndex = 0;
  final Set<String> _favorites = {};
  final Set<String> _reminders = {};

  Future<void> _playProgram(FmProgram program) async {
    if (program.streamUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رابط البث غير متوفر حالياً.')),
      );
      return;
    }
    await ref
        .read(audioControllerProvider)
        .play(
          AudioTrack(
            id: 'fm-program-${program.id}',
            title: program.title,
            subtitle: 'ألوان FM 88.7 • ${program.presenterName}',
            url: program.streamUrl,
            imageUrl: program.imageUrl,
            presenterName: program.presenterName,
            isLiveStream: true,
            isFm: true,
            sourceType: AudioSourceType.fm,
            category: 'برامج FM',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final programs = ref.watch(fmProgramsProvider);
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: _programsFont),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8FF),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 36),
            child: ResponsiveContent(
              maxWidth: 1180,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SizedBox(
                    height: context.responsive.value(compact: 56, medium: 36),
                  ),
                  const _PageTitle(),
                  SizedBox(
                    height: context.responsive.value(compact: 22, medium: 22),
                  ),
                  const _ProgramsHero(),
                  SizedBox(
                    height: context.responsive.value(compact: 8, medium: 12),
                  ),
                  _DaysSelector(
                    days: _days,
                    selectedIndex: _selectedDayIndex,
                    onSelected: (index) =>
                        setState(() => _selectedDayIndex = index),
                  ),
                  const SizedBox(height: 20),
                  programs.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: _programsPurple),
                    ),
                    error: (_, _) => const _ProgramsError(),
                    data: (items) {
                      final visible = items
                          .where((program) => program.airsOn(_selectedDayIndex))
                          .toList(growable: false);
                      return _ScheduleList(
                        programs: visible,
                        favorites: _favorites,
                        reminders: _reminders,
                        onListen: _playProgram,
                        onFavorite: (program) => setState(() {
                          _favorites.contains(program.id)
                              ? _favorites.remove(program.id)
                              : _favorites.add(program.id);
                        }),
                        onReminder: (program) => setState(() {
                          _reminders.contains(program.id)
                              ? _reminders.remove(program.id)
                              : _reminders.add(program.id);
                        }),
                      );
                    },
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

class _PageTitle extends StatelessWidget {
  const _PageTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.responsive.pagePadding,
      child: Text(
        'برامج إذاعة ألوان FM',
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: _programsFont,
          color: _programsInk,
          fontSize: context.responsive.value(compact: 16, medium: 27),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProgramsHero extends StatelessWidget {
  const _ProgramsHero();

  @override
  Widget build(BuildContext context) {
    final compact = context.responsive.isCompact;
    return Padding(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 14)
          : context.responsive.pagePadding,
      child: Container(
        height: context.responsive.value(compact: 160, medium: 240),
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24131B6A),
              blurRadius: 17,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const AdaptiveContentImage(
          source: 'assets/images/fm/programs_hero_v2.png',
          fit: BoxFit.cover,
          semanticLabel: 'صورة برامج إذاعة ألوان FM',
        ),
      ),
    );
  }
}

class _DaysSelector extends StatelessWidget {
  const _DaysSelector({
    required this.days,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> days;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final compact = context.responsive.isCompact;
    final compactItemWidth = ((MediaQuery.sizeOf(context).width - 32) / 4)
        .clamp(72.0, 96.0);
    return SizedBox(
      height: context.responsive.value(compact: 66, medium: 90),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 4)
            : context.responsive.pagePadding,
        itemCount: days.length,
        separatorBuilder: (_, _) => SizedBox(width: compact ? 8 : 10),
        itemBuilder: (context, index) {
          final selected = selectedIndex == index;
          return InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(compact ? 16 : 18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: compact ? compactItemWidth : 108,
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [Color(0xFF5947F3), Color(0xFF3020D1)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      )
                    : null,
                color: selected ? null : Colors.white,
                borderRadius: BorderRadius.circular(compact ? 16 : 18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF3030A1,
                    ).withValues(alpha: selected ? .22 : .08),
                    blurRadius: selected ? 14 : 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        days[index],
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF242470),
                          fontWeight: FontWeight.w900,
                          fontSize: compact ? 13 : 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 4 : 6),
                  Icon(
                    selected
                        ? Icons.calendar_month_rounded
                        : Icons.wb_sunny_outlined,
                    color: selected ? Colors.white : const Color(0xFFFF9D00),
                    size: compact ? 19 : 21,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScheduleHeader extends StatelessWidget {
  const _ScheduleHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.responsive.value(compact: 58, medium: 68),
      child: const _ScheduleColumns(
        live: _HeaderLabel(icon: Icons.sensors_rounded, label: 'مواعيد البث'),
        details: _HeaderLabel(
          icon: Icons.article_outlined,
          label: 'بيانات البرنامج',
        ),
        image: _HeaderLabel(
          icon: Icons.forum_rounded,
          label: 'حوارات البرنامج',
        ),
        replay: _HeaderLabel(
          icon: Icons.replay_rounded,
          label: 'مواعيد الإعادة',
        ),
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final compact = context.responsive.isCompact;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFF3828CE), size: compact ? 15 : 21),
        SizedBox(width: compact ? 3 : 7),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF15156A),
              fontSize: compact ? 9.5 : 15,
              height: 1.25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScheduleList extends StatelessWidget {
  const _ScheduleList({
    required this.programs,
    required this.favorites,
    required this.reminders,
    required this.onListen,
    required this.onFavorite,
    required this.onReminder,
  });

  final List<FmProgram> programs;
  final Set<String> favorites;
  final Set<String> reminders;
  final ValueChanged<FmProgram> onListen;
  final ValueChanged<FmProgram> onFavorite;
  final ValueChanged<FmProgram> onReminder;

  @override
  Widget build(BuildContext context) {
    final compact = context.responsive.isCompact;
    return Padding(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 6)
          : context.responsive.pagePadding,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(compact ? 24 : 28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x141B2255),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
          border: Border.all(color: const Color(0xFFE6E8F4)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                const _ScheduleHeader(),
                const Divider(height: 1, color: Color(0xFFE7E9F4)),
                if (programs.isEmpty) const _EmptyDaySchedule(),
                for (var index = 0; index < programs.length; index++) ...[
                  _ProgramRow(
                    program: programs[index],
                    favorite: favorites.contains(programs[index].id),
                    reminder: reminders.contains(programs[index].id),
                    onListen: () => onListen(programs[index]),
                    onFavorite: () => onFavorite(programs[index]),
                    onReminder: () => onReminder(programs[index]),
                  ),
                  if (index != programs.length - 1)
                    const Divider(
                      height: 1,
                      indent: 22,
                      endIndent: 22,
                      color: Color(0xFFE9EBF5),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProgramRow extends StatelessWidget {
  const _ProgramRow({
    required this.program,
    required this.favorite,
    required this.reminder,
    required this.onListen,
    required this.onFavorite,
    required this.onReminder,
  });

  final FmProgram program;
  final bool favorite;
  final bool reminder;
  final VoidCallback onListen;
  final VoidCallback onFavorite;
  final VoidCallback onReminder;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: program.isLive
          ? program.accentColor.withValues(alpha: .025)
          : Colors.transparent,
      child: SizedBox(
        height: context.responsive.value(compact: 130, medium: 184),
        child: _ScheduleColumns(
          live: _TimeColumn(
            key: ValueKey('fm-broadcast-${program.id}'),
            time: program.liveTime,
            slots: program.broadcastSlots,
            accentColor: program.accentColor,
            isLive: program.isLive,
            onTap: onListen,
          ),
          details: _ProgramDetails(program: program),
          image: _ProgramImage(
            program: program,
            favorite: favorite,
            reminder: reminder,
            onFavorite: onFavorite,
            onReminder: onReminder,
          ),
          replay: _ReplayColumn(
            times: program.replayTimes,
            slots: program.replaySlots,
            accentColor: program.accentColor,
          ),
        ),
      ),
    );
  }
}

class _ScheduleColumns extends StatelessWidget {
  const _ScheduleColumns({
    required this.live,
    required this.details,
    required this.image,
    required this.replay,
  });

  final Widget live;
  final Widget details;
  final Widget image;
  final Widget replay;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = context.responsive.isCompact;
        final edge = compact ? 0.0 : constraints.maxWidth * .05;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: edge),
          child: Row(
            children: [
              Expanded(
                flex: 18,
                child: _ColumnCell(showDivider: true, child: live),
              ),
              Expanded(
                flex: 31,
                child: _ColumnCell(showDivider: true, child: details),
              ),
              Expanded(
                flex: 31,
                child: _ColumnCell(showDivider: true, child: image),
              ),
              Expanded(flex: 18, child: _ColumnCell(child: replay)),
            ],
          ),
        );
      },
    );
  }
}

class _ColumnCell extends StatelessWidget {
  const _ColumnCell({required this.child, this.showDivider = false});

  final Widget child;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: showDivider
          ? const BorderDirectional(end: BorderSide(color: Color(0xFFE8EAF3)))
          : null,
    ),
    child: child,
  );
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    super.key,
    required this.time,
    required this.slots,
    required this.accentColor,
    required this.isLive,
    required this.onTap,
  });

  final String time;
  final List<FmScheduleSlot> slots;
  final Color accentColor;
  final bool isLive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = context.responsive.isCompact;
    final effectiveSlots = slots.isEmpty
        ? [FmScheduleSlot(dayLabel: '', time: time)]
        : slots;
    return Semantics(
      button: true,
      label: isLive ? 'استمع للبث المباشر الآن' : 'استمع إلى بث البرنامج',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(top: compact ? 4 : 0),
          child: Column(
            mainAxisAlignment: compact
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Container(
                width: compact ? 26 : 34,
                height: compact ? 26 : 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sensors_rounded,
                  color: accentColor,
                  size: compact ? 15 : 20,
                ),
              ),
              SizedBox(height: compact ? 4 : 11),
              for (final slot in effectiveSlots.take(3))
                _ScheduleSlotLabel(
                  key: ValueKey('fm-broadcast-slot-${slot.dayLabel}'),
                  slot: slot,
                  compact: compact,
                  accentColor: accentColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgramDetails extends StatelessWidget {
  const _ProgramDetails({required this.program});

  final FmProgram program;

  @override
  Widget build(BuildContext context) {
    final compact = context.responsive.isCompact;
    final veryCompact = MediaQuery.sizeOf(context).width < 340;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: veryCompact ? 4 : (compact ? 8 : 18),
        vertical: compact ? 7 : 12,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BroadcastStatusBadge(
            key: ValueKey('fm-broadcast-status-${program.id}'),
            isLive: program.isLive,
            compact: compact,
          ),
          SizedBox(height: compact ? 3 : 6),
          Text(
            program.title,
            maxLines: compact ? 1 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF171561),
              fontSize: veryCompact ? 11.5 : (compact ? 13 : 21),
              height: veryCompact ? 1.15 : null,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: compact ? 4 : 7),
          Text(
            program.description,
            maxLines: compact ? 3 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF5F6279),
              fontSize: veryCompact ? 7.5 : (compact ? 8 : 12),
              height: compact ? 1.35 : 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: compact ? 7 : 12),
          Row(
            children: [
              Icon(
                Icons.person_rounded,
                color: program.accentColor,
                size: compact ? 13 : 18,
              ),
              SizedBox(width: compact ? 3 : 6),
              Expanded(
                child: Text(
                  program.presenterName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: program.accentColor,
                    fontSize: compact ? 8.5 : 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BroadcastStatusBadge extends StatelessWidget {
  const _BroadcastStatusBadge({
    super.key,
    required this.isLive,
    required this.compact,
  });

  final bool isLive;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = isLive ? const Color(0xFFE74654) : const Color(0xFF5947D9);
    final label = isLive ? 'مباشر' : 'مسجل';
    return Semantics(
      label: 'حالة البرنامج: $label',
      child: Container(
        height: compact ? 17 : 25,
        padding: EdgeInsets.symmetric(horizontal: compact ? 5 : 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: .22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLive ? Icons.sensors_rounded : Icons.mic_rounded,
              color: color,
              size: compact ? 10 : 14,
            ),
            SizedBox(width: compact ? 2 : 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: compact ? 7.5 : 11,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramImage extends StatelessWidget {
  const _ProgramImage({
    required this.program,
    required this.favorite,
    required this.reminder,
    required this.onFavorite,
    required this.onReminder,
  });

  final FmProgram program;
  final bool favorite;
  final bool reminder;
  final VoidCallback onFavorite;
  final VoidCallback onReminder;

  @override
  Widget build(BuildContext context) {
    final compact = context.responsive.isCompact;
    final veryCompact = MediaQuery.sizeOf(context).width < 340;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: veryCompact ? 5 : (compact ? 14 : 18),
        vertical: compact ? 12 : 18,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(compact ? 8 : 18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                program.accentColor.withValues(alpha: .28),
                BlendMode.color,
              ),
              child: AdaptiveContentImage(
                source: program.imageUrl,
                fit: BoxFit.cover,
                semanticLabel: program.conversationTitle.isEmpty
                    ? program.title
                    : program.conversationTitle,
              ),
            ),
            Positioned(
              top: 4,
              left: 4,
              child: _ImageAction(
                tooltip: favorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                icon: favorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: const Color(0xFFFF315A),
                onTap: onFavorite,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: _ImageAction(
                tooltip: reminder ? 'إلغاء التذكير' : 'تفعيل التذكير',
                icon: reminder
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_rounded,
                color: reminder ? program.accentColor : Colors.white,
                onTap: onReminder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplayColumn extends StatelessWidget {
  const _ReplayColumn({
    required this.times,
    required this.slots,
    required this.accentColor,
  });

  final List<String> times;
  final List<FmScheduleSlot> slots;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final compact = context.responsive.isCompact;
    final effectiveSlots = slots.isEmpty
        ? times
              .map((time) => FmScheduleSlot(dayLabel: '', time: time))
              .toList(growable: false)
        : slots;
    return Padding(
      padding: EdgeInsets.only(top: compact ? 4 : 0),
      child: Column(
        mainAxisAlignment: compact
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          Container(
            width: compact ? 24 : 32,
            height: compact ? 24 : 32,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.replay_rounded,
              color: accentColor,
              size: compact ? 15 : 19,
            ),
          ),
          SizedBox(height: compact ? 4 : 10),
          for (final slot in effectiveSlots.take(2))
            _ScheduleSlotLabel(
              key: ValueKey('fm-replay-slot-${slot.dayLabel}'),
              slot: slot,
              compact: compact,
              accentColor: accentColor,
            ),
        ],
      ),
    );
  }
}

class _ScheduleSlotLabel extends StatelessWidget {
  const _ScheduleSlotLabel({
    super.key,
    required this.slot,
    required this.compact,
    required this.accentColor,
  });

  final FmScheduleSlot slot;
  final bool compact;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final dayHeight = compact ? 9.0 : 14.0;
    final timeHeight = compact ? 12.0 : 20.0;
    return SizedBox(
      height: compact ? 24 : 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (slot.dayLabel.trim().isNotEmpty)
            SizedBox(
              height: dayHeight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  slot.dayLabel,
                  maxLines: 1,
                  style: TextStyle(
                    color: _programsInk,
                    fontSize: compact ? 7.5 : 11,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          SizedBox(height: compact ? 1 : 2),
          SizedBox(
            height: timeHeight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                slot.time,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: accentColor,
                  fontSize: compact ? 9 : 15,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageAction extends StatelessWidget {
  const _ImageAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 14,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color == Colors.white
                ? const Color(0x662C1AB8)
                : Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 12),
        ),
      ),
    );
  }
}

class _EmptyDaySchedule extends StatelessWidget {
  const _EmptyDaySchedule();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 150,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded, color: _programsPurple, size: 34),
            SizedBox(height: 8),
            Text(
              'لا توجد برامج مجدولة في هذا اليوم',
              style: TextStyle(
                color: _programsInk,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramsError extends StatelessWidget {
  const _ProgramsError();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.responsive.pagePadding,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E6F3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: _programsPurple),
            SizedBox(width: 9),
            Text(
              'تعذر تحميل جدول البرامج من لوحة التحكم',
              style: TextStyle(
                color: _programsInk,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
