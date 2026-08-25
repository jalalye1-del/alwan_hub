import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/profile/data/profile_repository.dart';
import 'package:alwan_hub/features/profile/presentation/widgets/profile_typography.dart';
import 'package:alwan_hub/features/profile/presentation/widgets/profile_ad_banner.dart';

class StreamQualityScreen extends StatefulWidget {
  const StreamQualityScreen({super.key, this.initialQuality});

  final String? initialQuality;

  @override
  State<StreamQualityScreen> createState() => _StreamQualityScreenState();
}

class _StreamQualityScreenState extends State<StreamQualityScreen> {
  static const _options = <_StreamQualityOption>[
    _StreamQualityOption(
      value: 'عالية',
      title: 'جودة فائقة',
      bitrate: 256,
      description: 'أفضل نقاء للصوت',
      networkLabel: 'Wi-Fi / 5G',
      activeBars: 4,
    ),
    _StreamQualityOption(
      value: 'متوسطة',
      title: 'جودة متوازنة',
      bitrate: 128,
      description: 'مثالية للاستخدام اليومي',
      networkLabel: 'شبكة 4G',
      activeBars: 3,
    ),
    _StreamQualityOption(
      value: 'منخفضة',
      title: 'جودة اقتصادية',
      bitrate: 96,
      description: 'استهلاك أقل للبيانات',
      networkLabel: 'شبكة ضعيفة',
      activeBars: 2,
    ),
  ];

  final _repository = ProfileRepository();
  late String _selectedQuality;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedQuality = widget.initialQuality ?? 'عالية';
    _loadSavedQuality();
  }

  Future<void> _loadSavedQuality() async {
    if (widget.initialQuality != null) {
      setState(() => _loading = false);
      return;
    }
    final quality = await _repository.loadStreamQuality();
    if (!mounted) return;
    setState(() {
      _selectedQuality = quality;
      _loading = false;
    });
  }

  _StreamQualityOption get _selectedOption => _options.firstWhere(
    (option) => option.value == _selectedQuality,
    orElse: () => _options.first,
  );

  @override
  Widget build(BuildContext context) {
    return ProfileTypography(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FD),
        body: Column(
          children: [
            const AlwanPageHeader(
              title: 'جودة البث',
              subtitle: 'اختر التجربة الأنسب لشبكتك',
              trailing: SizedBox(width: 48),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ResponsiveContent(
                        maxWidth: 760,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            const _StreamQualityAdBanner(),
                            Padding(
                              padding: context.responsive.pagePadding,
                              child: Column(
                                children: [
                                  const SizedBox(height: 24),
                                  const _QualityIntro(),
                                  const SizedBox(height: 18),
                                  _QualityOptions(
                                    options: _options,
                                    selectedQuality: _selectedQuality,
                                    onSelected: (value) => setState(
                                      () => _selectedQuality = value,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  _SelectedQualitySummary(
                                    option: _selectedOption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            if (!_loading)
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 728),
                  child: _ConfirmButton(
                    saving: _saving,
                    option: _selectedOption,
                    onPressed: _saveSelection,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSelection() async {
    setState(() => _saving = true);
    await _repository.saveStreamQuality(_selectedQuality);
    if (!mounted) return;
    setState(() => _saving = false);

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(_selectedQuality);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم اعتماد ${_selectedOption.title} بسرعة ${_selectedOption.bitrate} kbps',
        ),
      ),
    );
  }
}

class _StreamQualityOption {
  const _StreamQualityOption({
    required this.value,
    required this.title,
    required this.bitrate,
    required this.description,
    required this.networkLabel,
    required this.activeBars,
  });

  final String value;
  final String title;
  final int bitrate;
  final String description;
  final String networkLabel;
  final int activeBars;
}

class _StreamQualityAdBanner extends StatelessWidget {
  const _StreamQualityAdBanner();

  @override
  Widget build(BuildContext context) {
    return const ProfileAdBanner(
      imageAsset: 'assets/images/banners/banner2.jpg',
      headline: 'مساحة إعلانية لشركاء منصة ألوان',
    );
  }
}

class _QualityIntro extends StatelessWidget {
  const _QualityIntro();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.graphic_eq_rounded, color: Color(0xFF6C35A5), size: 30),
        SizedBox(height: 5),
        Text(
          'اختر جودة البث المناسبة لك',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF222B65),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 3),
        Text(
          'كلما زادت قوة الشبكة حصلت على صوت أكثر نقاءً',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

class _QualityOptions extends StatelessWidget {
  const _QualityOptions({
    required this.options,
    required this.selectedQuality,
    required this.onSelected,
  });

  final List<_StreamQualityOption> options;
  final String selectedQuality;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 350;
        if (isNarrow) {
          return Column(
            children: [
              for (var index = 0; index < options.length; index++) ...[
                _QualityCard(
                  option: options[index],
                  selected: selectedQuality == options[index].value,
                  horizontal: true,
                  onTap: () => onSelected(options[index].value),
                ),
                if (index != options.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < options.length; index++) ...[
              Expanded(
                child: _QualityCard(
                  option: options[index],
                  selected: selectedQuality == options[index].value,
                  onTap: () => onSelected(options[index].value),
                ),
              ),
              if (index != options.length - 1) const SizedBox(width: 8),
            ],
          ],
        );
      },
    );
  }
}

class _QualityCard extends StatelessWidget {
  const _QualityCard({
    required this.option,
    required this.selected,
    required this.onTap,
    this.horizontal = false,
  });

  final _StreamQualityOption option;
  final bool selected;
  final VoidCallback onTap;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? const Color(0xFF7A2EA2)
        : const Color(0xFFDCE1EB);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          constraints: BoxConstraints(minHeight: horizontal ? 106 : 205),
          padding: EdgeInsets.symmetric(
            horizontal: horizontal ? 16 : 8,
            vertical: horizontal ? 12 : 14,
          ),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF9F4FF) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: selected ? 2.2 : 1),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? const Color(0xFF5F2B91).withValues(alpha: .18)
                    : const Color(0xFF172B4D).withValues(alpha: .05),
                blurRadius: selected ? 16 : 9,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: horizontal
              ? Row(
                  children: [
                    _NetworkBars(
                      activeBars: option.activeBars,
                      selected: selected,
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _QualityDetails(option: option)),
                    _SelectionMark(selected: selected),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: _SelectionMark(selected: selected),
                    ),
                    _NetworkBars(
                      activeBars: option.activeBars,
                      selected: selected,
                    ),
                    const SizedBox(height: 11),
                    _QualityDetails(option: option, centered: true),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF7133A5) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFF7133A5) : const Color(0xFFCBD3E0),
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
          : null,
    );
  }
}

class _QualityDetails extends StatelessWidget {
  const _QualityDetails({required this.option, this.centered = false});

  final _StreamQualityOption option;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${option.bitrate} kbps',
              style: const TextStyle(
                color: Color(0xFF252D72),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          option.title,
          maxLines: 1,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF342A68),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          option.networkLabel,
          maxLines: 1,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _NetworkBars extends StatelessWidget {
  const _NetworkBars({required this.activeBars, required this.selected});

  final int activeBars;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    const heights = [12.0, 20.0, 28.0, 36.0];
    return Semantics(
      label: 'قوة تغطية الشبكة $activeBars من 4',
      child: SizedBox(
        width: 58,
        height: 40,
        child: Row(
          textDirection: TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < heights.length; index++)
              Container(
                width: 8,
                height: heights[index],
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  gradient: index < activeBars
                      ? const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xFF2F3990), Color(0xFFAD23B2)],
                        )
                      : null,
                  color: index < activeBars ? null : const Color(0xFFDDE3EE),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selected && index < activeBars
                      ? const [
                          BoxShadow(color: Color(0x337A2EA2), blurRadius: 5),
                        ]
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectedQualitySummary extends StatelessWidget {
  const _SelectedQualitySummary({required this.option});

  final _StreamQualityOption option;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Container(
        key: ValueKey(option.value),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF5FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC9DCF8)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFDFEAFE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.headphones_rounded,
                color: Color(0xFF3154A0),
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.description,
                    style: const TextStyle(
                      color: Color(0xFF283B78),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'سيتم تشغيل البث بسرعة ${option.bitrate} kbps',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.saving,
    required this.option,
    required this.onPressed,
  });

  final bool saving;
  final _StreamQualityOption option;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF31368B), Color(0xFF9B20B2)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3D5E238C),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: saving ? null : onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.headphones_rounded),
          label: Text(
            saving ? 'جارٍ الحفظ...' : 'تأكيد ${option.title} والرجوع',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
